<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioModelList.ps1
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