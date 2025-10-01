<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioModelList.ps1
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
Retrieves a list of installed LM Studio models.

.DESCRIPTION
Gets a list of all models installed in LM Studio by executing the LM Studio CLI
command and parsing its JSON output. Returns an array of model objects containing
details about each installed model.

.OUTPUTS
System.Object[]
Returns an array of model objects containing details about installed models.

.EXAMPLE
Get-LMStudioModelList
Retrieves all installed LM Studio models and returns them as objects.

.EXAMPLE
Get-LMStudioModelList -Verbose
Retrieves models while showing detailed progress information.
#>
function Get-LMStudioModelList {

    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param()

    begin {

        # check if lm studio is installed
        if (-not (GenXdev.AI\Test-LMStudioInstallation)) {

            throw 'LM Studio is not installed or not found in expected location'
        }

        # get paths for lm studio components
        $lmPaths = GenXdev.AI\Get-LMStudioPaths
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieved LM Studio installation paths'
    }


    process {

        try {
            # get path to lm studio executable
            $LMSExe = $lmPaths.LMSExe
            Microsoft.PowerShell.Utility\Write-Verbose "Using LM Studio executable: $LMSExe"

            # execute cli command to get model list
            Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving model list from LM Studio...'
            $modelList = & $LMSExe ls --json |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            # return parsed models
            Microsoft.PowerShell.Utility\Write-Verbose "Successfully retrieved $($modelList.Count) models"
            return $modelList
        }
        catch {
            $errorMsg = "Failed to get model list: $($_.Exception.Message)"
            Microsoft.PowerShell.Utility\Write-Error $errorMsg
            throw $errorMsg
        }
    }

    end {
    }
}