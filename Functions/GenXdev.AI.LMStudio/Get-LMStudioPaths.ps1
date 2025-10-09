<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioPaths.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
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
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param()

    begin {

        # define search paths for executables
        $searchPathsLMStudio = @(
            "${env:LOCALAPPDATA}\LM-Studio\lm studio.exe",
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lm studio.exe",
            "${env:LOCALAPPDATA}\Programs\LM Studio\lm studio.exe"
        )

        $searchPathsLMSexe = @(
            '~\.cache\lm-studio\bin\lms.exe',
            "${env:LOCALAPPDATA}\LM-Studio\lms.exe",
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lms.exe",
            "${env:LOCALAPPDATA}\Programs\LM Studio\lms.exe",
            "${env:LOCALAPPDATA}\Programs\LM Studio\resources\app\.webpack\lms.exe"

        )
    }


    process {

        # check if paths need to be discovered
        if (-not $script:LMStudioExe -or -not $script:LMSexe) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Searching for LM Studio executables...'

            # find main LM Studio executable
            $script:LMStudioExe = Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $searchPathsLMStudio `
                -File `
                -Recurse `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Utility\Select-Object -First 1 |
                Microsoft.PowerShell.Core\ForEach-Object FullName

            # find LMS command-line executable
            $script:LMSExe = Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $searchPathsLMSexe `
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