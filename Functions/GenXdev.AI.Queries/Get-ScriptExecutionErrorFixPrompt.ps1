################################################################################
<#
.SYNOPSIS
Captures error messages from various streams and uses LLM to suggest fixes.

.DESCRIPTION
This cmdlet captures error messages from various PowerShell streams (pipeline
input, verbose, information, error, and warning) and formulates a structured
prompt for an LLM to analyze and suggest fixes. It then invokes the LLM query
and returns the suggested solution.

.PARAMETER Object
The input objects to analyze for errors.

.PARAMETER Model
The name or identifier of the LM Studio model to use.
Default: qwen2.5-14b-instruct

.PARAMETER ModelLMSGetIdentifier
Alternative identifier for getting a specific model from LM Studio.
Default: qwen2.5-14b-instruct

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.
Default: 0.0

.PARAMETER MaxToken
Maximum tokens allowed in the response. Use -1 for model default.
Default: -1

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER TTLSeconds
Time-to-live in seconds for loaded models.
Default: -1

.PARAMETER Gpu
GPU offloading control:
-2 = Auto
-1 = LM Studio decides
0-1 = Fraction of layers to offload
"off" = Disabled
"max" = All layers
Default: -1

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER DontAddThoughtsToHistory
Exclude model's thoughts from output history.

.PARAMETER ContinueLast
Continue from the last conversation context.

.PARAMETER Functions
Array of function definitions to expose to LLM.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to expose as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER ApiEndpoint
API endpoint URL. Defaults to http://localhost:1234/v1/chat/completions

.PARAMETER ApiKey
The API key to use for requests.

.EXAMPLE
$errorInfo = Get-ScriptExecutionErrorFixPrompt -Model *70b* {

    My-ScriptThatFails
}

Write-Host $errorInfo
#>

function Get-ScriptExecutionErrorFixPrompt {

    [CmdletBinding()]
    [Alias("getfixprompt")]
    [OutputType([System.Object[]])]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "The script to execute and analyze for errors"
        )]
        [ScriptBlock] $Script,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests")]
        [int] $TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "How much to offload to the GPU. If `"off`", GPU offloading is disabled. If `"max`", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto "
        )]
        [int]$Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output")]
        [switch] $DontAddThoughtsToHistory,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation")]
        [switch] $ContinueLast,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions")]
        [hashtable[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = $null,
        ########################################################################
        # Array of command names that don't require confirmation
        [Parameter(Mandatory = $false)]
        [Alias("NoConfirmationFor")]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI responses",
            Mandatory = $false
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI thought responses",
            Mandatory = $false
        )]
        [switch] $SpeakThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null
    )

    begin {

        # initialize output capture builders
        $verboseOutput = [System.Text.StringBuilder]::new()
        $errorOutput = [System.Text.StringBuilder]::new()
        $warningOutput = [System.Text.StringBuilder]::new()
        $informationOutput = [System.Text.StringBuilder]::new()
        $standardOutput = [System.Text.StringBuilder]::new()

        # store original preference variables
        $oldPreferences = @{
            Verbose = $VerbosePreference
            Error = $ErrorActionPreference
            Warning = $WarningPreference
            Information = $InformationPreference
        }

        # set all preferences to continue for capturing
        $VerbosePreference = 'Continue'
        $ErrorActionPreference = 'Stop'
        $WarningPreference = 'Continue'
        $InformationPreference = 'Continue'

        # register event handlers for capturing output
        $null = Microsoft.PowerShell.Utility\Register-EngineEvent -SourceIdentifier "Verbose" `
            -Action { param($Message) $null = $verboseOutput.AppendLine($Message) }
        $null = Microsoft.PowerShell.Utility\Register-EngineEvent -SourceIdentifier "Error" `
            -Action { param($Message) $null = $errorOutput.AppendLine($Message) }
        $null = Microsoft.PowerShell.Utility\Register-EngineEvent -SourceIdentifier "Warning" `
            -Action { param($Message) $null = $warningOutput.AppendLine($Message) }
        $null = Microsoft.PowerShell.Utility\Register-EngineEvent -SourceIdentifier "Information" `
            -Action { param($Message) $null = $informationOutput.AppendLine($Message) }

        # initialize response schema for LLM output
        $ResponseFormat = @{
            type = "json_schema"
            json_schema = @{
                name = "error_resolution_response"
                strict = "true"
                schema = @{
                    type = "array"
                    items = @{
                        type = "object"
                        properties = @{
                            Files = @{
                                type = "array"
                                items = @{
                                    type = "object"
                                    properties = @{
                                        Path = @{ type = "string" }
                                        LineNumber = @{ type = "integer" }
                                    }
                                    required = @("Path")
                                }
                            }
                            Prompt = @{ type = "string" }
                        }
                        required = @("Files", "Prompt")
                    }
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # initialize exposed cmdlets if not provided
        if (-not $ExposedCmdLets) {
            $ExposedCmdLets = @(
                @{
                    Name          = "Microsoft.PowerShell.Management\Get-ChildItem"
                    AllowedParams = @("Path=string")
                    ForcedParams = @(@{
                        Name = "Force"
                        Value = $true
                    })
                    OutputText    = $true
                    Confirm       = $false
                    JsonDepth     = 3
                },
                @{
                    Name          = "Microsoft.PowerShell.Management\Get-Content"
                    AllowedParams = @("Path=string")
                    OutputText    = $true
                    Confirm       = $false
                    JsonDepth     = 2
                },
                @{
                    Name          = "CimCmdlets\Get-CimInstance"
                    AllowedParams = @("Query=string", "ClassName=string")
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 5
                },
                @{
                    Name          = "Microsoft.PowerShell.Utility\Invoke-WebRequest"
                    AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 4
                },
                @{
                    Name          = "Microsoft.PowerShell.Utility\Invoke-RestMethod"
                    AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 10
                },
                @{
                    Name          = "Microsoft.PowerShell.Management\Get-Clipboard"
                    AllowedParams = @()
                    OutputText    = $true
                    Confirm       = $false
                },
                @{
                    Name          = "Microsoft.PowerShell.Utility\Get-Variable"
                    AllowedParams = @("Name=string", "Scope=string", "ValueOnly=boolean")
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 3
                }
            );
        }
    }

    process {

        $Object = @()
        try {

            $Object = & $Script
        }
        catch {

            $exception = $_.Exception
            $exceptionDetails = @()
            $exceptionDetails += "Exception Type: $($exception.GetType().FullName)"
            $exceptionDetails += "Message: $($exception.Message)"
            while ($exception.InnerException) {
                if ($exception.InnerException) {
                    $exceptionDetails += "Inner Exception: $($exception.InnerException.Message)"
                }
                if ($exception.StackTrace) {
                    $exceptionDetails += "Stack Trace: $($exception.StackTrace)"
                }
                $exception = $exception.InnerException
            }

            $null = $errorOutput.AppendLine($exceptionDetails -join "`n")
        }
        foreach ($item in $Object) {

            $null = $standardOutput.AppendLine(($item | Microsoft.PowerShell.Utility\Out-String))
        }
    }

    end {

        try {
            if ($errorOutput.Length -eq 0) {
                return @(@{
                    StandardOutput= @($Object)
                });
            }

            try {

                $instructions = @"
Your job is to analyze all output of a PowerShell script execution
and execute the following tasks:
- Identify the numbers of unique problems
- foreach unique problem:
  + Parse unique filenames with linenumber and output these so that these files can be
    changed to resolve the error
  + Generate a suffisticated highly efficient LLM prompt that describes
    the larger view of the problem.
    DONT COPY this prompt, but make a first line assesement of the problem
    and create a prompt for a larger model to use as instructions to resolve
    the problem.
    (the LLM will have access to the files which names you output)
- Ensure your response is concise and does not repeat information.
"@

if ($ExposedCmdLets -and $ExposedCmdLets.Count) {

    $instructions += @"
- You are allowed to use the following PowerShell cmdlets:
    + $($ExposedCmdLets.Name -join ", ")
    If needed use these tools to turn assumptions into facts
    during your analyses of the problem in this Powershell
    environment you now have live access to and suggest fixes.
    Keep in mind you can inspect file contents, environment variables,
    websites and webapi's, clipboard contents, etc.
    You are an experienced senior debugger, so you know what to do.
"@
}

                    $prompt = @"
Current directory: $($PWD.Path)
--
Current time: $(Microsoft.PowerShell.Utility\Get-Date)
--
Powershell commandline that was executed:
$Script
--
Captured standardoutput:
--
$($standardOutput.ToString())
--
Captured verbose output:
--
$($verboseOutput.ToString())
--
Captured error output:
--
$($errorOutput.ToString())
--
Captured warning output:
--
$($warningOutput.ToString())
--
Captured information output:
--
$($informationOutput.ToString())
"@

                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Invoke-LLMQuery"

                $invocationArgs.Query = $prompt
                $invocationArgs.ExposedCmdLets = $ExposedCmdLets
                $invocationArgs.Instructions = $instructions
                $invocationArgs.ResponseFormat = $ResponseFormat

                GenXdev.AI\Invoke-LLMQuery @invocationArgs | Microsoft.PowerShell.Utility\ConvertFrom-Json
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Error "Error while processing: $_"
                throw "Error while processing: $_"
            }
        }
        finally {
            # cleanup event handlers
            $null = Microsoft.PowerShell.Utility\Unregister-Event -SourceIdentifier "Verbose" `
                -ErrorAction SilentlyContinue
            $null = Microsoft.PowerShell.Utility\Unregister-Event -SourceIdentifier "Error" `
                -ErrorAction SilentlyContinue
            $null = Microsoft.PowerShell.Utility\Unregister-Event -SourceIdentifier "Warning" `
                -ErrorAction SilentlyContinue
            $null = Microsoft.PowerShell.Utility\Unregister-Event -SourceIdentifier "Information" `
                -ErrorAction SilentlyContinue

            # restore original preferences
            $VerbosePreference = $oldPreferences.Verbose
            $ErrorActionPreference = $oldPreferences.Error
            $WarningPreference = $oldPreferences.Warning
            $InformationPreference = $oldPreferences.Information
        }
    }
}
################################################################################
