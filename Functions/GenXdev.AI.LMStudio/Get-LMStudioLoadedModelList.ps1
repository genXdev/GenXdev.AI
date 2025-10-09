<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioLoadedModelList.ps1
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