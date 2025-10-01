<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioLoadedModelList.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.290.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Retrieves the list of currently loaded models from LM Studio.

.DESCRIPTION
Gets a list of all models that are currently loaded in LM Studio by querying
the LM Studio process. Returns null if no models are loaded or if an error
occurs. Requires LM Studio to be installed and accessible.

.EXAMPLE
Get-LMStudioLoadedModelList
#>
function Get-LMStudioLoadedModelList {

    [CmdletBinding()]
    [OutputType([PSCustomObject[]])]
    param()

    begin {

        # verify lm studio is properly installed
        Microsoft.PowerShell.Utility\Write-Verbose 'Verifying LM Studio installation...'
        if (-not (GenXdev.AI\Test-LMStudioInstallation)) {
            throw 'LM Studio is not installed or accessible'
        }

        # get required paths for lm studio components
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving LM Studio paths...'
        $paths = GenXdev.AI\Get-LMStudioPaths
    }


    process {

        Microsoft.PowerShell.Utility\Write-Verbose 'Querying LM Studio for loaded models...'

        try {
            # query lm studio process and convert json output to objects
            $modelList = & "$($paths.LMSExe)" ps --json |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            Microsoft.PowerShell.Utility\Write-Verbose "Successfully retrieved $(($modelList |
                Microsoft.PowerShell.Utility\Measure-Object).Count) models"

            return $modelList
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Failed to retrieve model list: $_"
            throw
        }
    }

    end {
    }
}