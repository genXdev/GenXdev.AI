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
        if (-not (Test-LMStudioInstallation)) {
            throw 'LM Studio is not installed or accessible'
        }

        # get required paths for lm studio components
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving LM Studio paths...'
        $paths = Get-LMStudioPaths
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