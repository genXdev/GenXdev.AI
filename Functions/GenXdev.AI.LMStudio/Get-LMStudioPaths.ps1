################################################################################
<#
.SYNOPSIS
Retrieves the file paths for LM Studio executables.

.DESCRIPTION
Searches common installation locations for LM Studio executables and returns their
full paths. The function caches found paths to avoid repeated searches.

.EXAMPLE
Get-LMStudioPaths
Returns a hashtable containing paths to LM Studio executables.
#>
function Get-LMStudioPaths {

    [CmdletBinding()]
    param()

    begin {

        # define common installation paths to search
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
        # only search if paths haven't been found yet
        if (-not $script:lmStudioExePath -or -not $script:lmsExePath) {

            Write-Verbose "Searching for LM Studio executables..."

            # search for the main LM Studio executable
            $script:lmStudioExePath = Get-ChildItem `
                -Path $searchPathsLMStudio `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
            Select-Object -First 1 |
            ForEach-Object FullName

            # search for the LMS command-line executable
            $script:lmsExePath = Get-ChildItem `
                -Path $searchPathsLMSexe `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
            Select-Object -First 1 |
            ForEach-Object FullName

            Write-Verbose "Found LM Studio: $script:lmStudioExePath"
            Write-Verbose "Found LMS: $script:lmsExePath"
        }
    }

    end {
        # return paths as hashtable
        return @{
            LMStudioExe = $script:lmStudioExePath
            LMSExe      = $script:lmsExePath
        }
    }
}
################################################################################
