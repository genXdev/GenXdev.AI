################################################################################
<#
.SYNOPSIS
Converts diplomatic or tactful language into direct, clear, and
straightforward language.

.DESCRIPTION
This function takes diplomatic speak and translates it to reveal the true
meaning behind polite or politically correct language. It uses AI language
models to transform euphemistic expressions into direct statements, making
communication unambiguous and easy to understand. The function is particularly
useful for analyzing political statements, business communications, or any text
where the real meaning might be obscured by diplomatic language.

.PARAMETER Text
The text to convert from diplomatic speak. This can be provided through the
pipeline.

.PARAMETER Instructions
Additional instructions for the AI model to customize the transformation
process.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Lower values produce more
consistent outputs while higher values increase creativity.

.PARAMETER SetClipboard
Copy the transformed text to clipboard after processing.

.PARAMETER ShowWindow
Show the LM Studio window during processing for monitoring AI operations.

.PARAMETER Force
Force stop LM Studio before initialization to ensure clean startup.

.PARAMETER LLMQueryType
The type of LLM query to use for the transformation process.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier for Hugging Face models.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If
'max', all layers are offloaded to GPU. If a number between 0 and 1, that
fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
how much to offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations when using external services.

.PARAMETER ApiKey
The API key for authenticated AI operations with external services.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations to prevent hanging.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files storage.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
ConvertFrom-DiplomaticSpeak -Text "We have some concerns about your approach"

.EXAMPLE
undiplomatize "Your proposal has merit but requires further consideration"

.EXAMPLE
"We're putting you on timeout" | ConvertFrom-DiplomaticSpeak `
    -SetClipboard -Temperature 0.2
#>
function ConvertFrom-DiplomaticSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("undiplomatize")]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to convert from diplomatic speak"
        )]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
        )]
        [string] $Instructions = "",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.0,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The type of LLM query"
        )]
        [ValidateSet(
            "SimpleIntelligence",
            "Knowledge",
            "Pictures",
            "TextTranslation",
            "Coding",
            "ToolUse"
        )]
        [string] $LLMQueryType = "Knowledge",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The model identifier or pattern to use for AI " +
                           "operations")
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The maximum number of tokens to use in AI " +
                           "operations")
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The number of CPU cores to dedicate to AI " +
                           "operations")
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                           "offloading is disabled. If 'max', all layers are " +
                           "offloaded to GPU. If a number between 0 and 1, " +
                           "that fraction of layers will be offloaded to the " +
                           "GPU. -1 = LM Studio will decide how much to " +
                           "offload to the GPU. -2 = Auto")
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the transformed text to clipboard"
        )]
        [switch] $SetClipboard,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                           "preferences")
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for " +
                           "AI preferences")
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences " +
                           "without affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # output verbose information about starting the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting diplomatic speak conversion process"
        )
    }

    process {

        # construct comprehensive instructions for diplomatic speak transformation
        $diplomaticInstructions = @"
Translate the user's input from diplomatic or tactful language into direct, clear, and straightforward language. The translation should reveal the true and real meaning of the phrase, making it unambiguous and easy to understand.

Examples:

Original: 'Diplomatic Statement'
Direct meaning: 'Direct Statement'

Original: 'Your precision in targeting seems to have some room for improvement. Perhaps we can share our advanced targeting technologies to help you hit only the intended targets.'
Direct meaning: 'Your airstrikes are killing civilians.'

Original: 'Your tariffs are like a boa constrictor around our economy's neck. Maybe we can find a way to loosen that grip a bit.'
Direct meaning: 'Your tariffs are suffocating our industries.'

Original: 'Your smokestacks are belching out more carbon than a dragon's fiery breath. Perhaps we can help you slay that dragon with some clean energy solutions.'
Direct meaning: 'Your country is the largest polluter.'

Original: 'Some of your more enterprising citizens are trying to take a peek into our digital secrets. Maybe we can set up a joint cybersecurity task force to keep them in check.'
Direct meaning: 'Your hackers are attacking our systems.'

Original: 'Your cultural practices are... unique, to say the least. I'm sure they have a certain charm that we're not yet appreciating. Perhaps a cultural exchange program could help bridge our understanding.'
Direct meaning: 'Your customs are barbaric.'

Original: 'Your interest in nuclear technology is noted. We have some experience in this area and would be happy to share our knowledge on the safe and peaceful uses of atomic energy.'
Direct meaning: 'You're developing nuclear weapons, and that's dangerous.'

Original: 'Your spies are so ubiquitous that they're practically part of our tourism industry. Maybe we can find a way to make their stay more comfortable, or perhaps even charge them a visitor's fee.'
Direct meaning: 'Your spies are everywhere in our country.'

Original: 'That piece of rock in the ocean is more ours than yours. How about we flip a coin to decide who gets it? Or better yet, let's have a fishing competition; the one who catches the biggest fish gets the island.'
Direct meaning: 'That island belongs to us, not you.'

Original: 'We're putting you on timeout. No more playing with the other kids until you learn to share nicely.'
Direct meaning: 'We're imposing sanctions on your country.'

Original: 'Your ambassador has outstayed their welcome. We're throwing a farewell party and expect them to leave immediately after.'
Direct meaning: 'We're expelling your ambassador.'

Original: 'Welcome to the galactic neighborhood! We're here to help you integrate into our interplanetary community. Please, no sudden movements; our robots get a bit jumpy.'
Direct meaning: 'Your planet is under our control now.'

Original: 'Your meddling with time is making our historians' jobs really confusing. Could you please stick to the present or find a way to clean up your temporal messes?'
Direct meaning: 'You've altered the timeline, and that's not acceptable.'

Original: 'Your robots are smarter than some of your politicians. Maybe we can give them voting rights and see if that improves governance.'
Direct meaning: 'Your robots are sentient and deserve rights.'

Original: 'Your goods are so cheap, they're making our merchants look like they're selling gold-plated widgets. Maybe you can add some artificial scarcity or something to make it fair.'
Direct meaning: 'Your trade practices are unfair; you're dumping cheap goods.'

Original: 'Your planet is like a never-ending party with too much drama. Let's send in some referees to make sure everyone plays nice.'
Direct meaning: 'Your planet is a hotbed of rebellion; we need to intervene.'

Original: 'Your AI seems quite advanced. We'd be interested in discussing ways to ensure its safe and ethical use.'
Direct meaning: 'Your AI is too powerful and could be dangerous.'

Original: 'We've observed different approaches to managing the pandemic and are interested in sharing best practices.'
Direct meaning: 'Your handling of the pandemic is incompetent.'

Original: 'We are disappointed by the events and believe in the importance of fair play. We hope for a thorough investigation to uphold the integrity of the sport.'
Direct meaning: 'Your team cheated.'

Original: 'I'm interested in exploring more of your culinary offerings to appreciate the diversity of flavors.'
Direct meaning: 'Your food is awful.'

Original: 'Your sartorial choices are... distinctive. I'm sure they're making a statement that I'm not quite getting.'
Direct meaning: 'Your fashion sense is terrible.'

$Instructions
"@

        # output verbose information about the transformation process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Transforming text with diplomatic speak instructions"
        )

        # invoke the language model with diplomatic speak instructions using splatting
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $diplomaticInstructions
    }

    end {

        # output verbose information about completion of the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed diplomatic speak conversion process"
        )
    }
}
################################################################################