################################################################################
<#
.SYNOPSIS
Retrieves file paths for LM Studio executables.

.DESCRIPTION
Searches common installation locations for LM Studio executables and returns their
paths. The function maintains a cache of found paths to optimize performance on
subsequent calls.

.OUTPUTS
System.Collections.Hashtable
    Returns a hashtable with two keys:
    - LMStudioExe: Path to main LM Studio executable
    - LMSExe: Path to LMS command-line executable

.EXAMPLE
$paths = Get-LMStudioPaths
Write-Output "LM Studio path: $($paths.LMStudioExe)"
#>
function Get-LMStudioPaths {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param()

    begin {

        # define search paths for executables
        $searchPathsLMStudio = @(
            "${env:LOCALAPPDATA}\LM-Studio\lm studio.exe",
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lm studio.exe",
            "${env:LOCALAPPDATA}\Programs\LM Studio\lm studio.exe"
        )

        $searchPathsLMSexe = @(
            "${env:LOCALAPPDATA}\LM-Studio\lms.exe",
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lms.exe",
            "${env:LOCALAPPDATA}\Programs\LM Studio\lms.exe"
        )
    }

    process {

        # check if paths need to be discovered
        if (-not $script:LMStudioExe -or -not $script:LMSexe) {

            Microsoft.PowerShell.Utility\Write-Verbose "Searching for LM Studio executables..."

            # find main LM Studio executable
            $script:LMStudioExe = Microsoft.PowerShell.Management\Get-ChildItem `
                -Path $searchPathsLMStudio `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Utility\Select-Object -First 1 |
            Microsoft.PowerShell.Core\ForEach-Object FullName

            # find LMS command-line executable
            $script:LMSExe = Microsoft.PowerShell.Management\Get-ChildItem `
                -Path $searchPathsLMSexe `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Utility\Select-Object -First 1 |
            Microsoft.PowerShell.Core\ForEach-Object FullName

            Microsoft.PowerShell.Utility\Write-Verbose "Found LM Studio: $script:LMStudioExe"
            Microsoft.PowerShell.Utility\Write-Verbose "Found LMS: $script:LMSExe"
        }
    }

    end {

        # return paths in a hashtable
        return @{
            LMStudioExe = $script:LMStudioExe
            LMSExe      = $script:LMSExe
        }
    }
}
################################################################################