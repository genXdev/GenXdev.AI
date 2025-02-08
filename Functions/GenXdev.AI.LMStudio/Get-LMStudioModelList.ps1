################################################################################
<#
.SYNOPSIS
Retrieves a list of installed LM Studio models.

.DESCRIPTION
Gets a list of all models installed in LM Studio by executing the LM Studio CLI
command and parsing its JSON output. Returns an array of model objects containing
details about each installed model.

.EXAMPLE
Get-LMStudioModelList

.EXAMPLE
Get-LMStudioModelList -Verbose
#>
function Get-LMStudioModelList {

    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param()

    begin {

        # verify that lm studio is installed and get installation paths
        if (-not (Test-LMStudioInstallation)) {
            throw "LM Studio is not installed or not found in expected location"
        }

        # get the installation paths for lm studio components
        $lmPaths = Get-LMStudioPaths
        Write-Verbose "Retrieved LM Studio installation paths successfully"
    }

    process {

        try {
            # construct the path to the lm studio executable
            $lmsExePath = $lmPaths.LMSExe
            Write-Verbose "Using LM Studio executable at: $lmsExePath"

            # execute lm studio cli command to list models
            Write-Verbose "Executing LM Studio CLI to retrieve model list..."
            $modelList = & "$lmsExePath" ls --json |
                ConvertFrom-Json

            # return the parsed model list
            return $modelList

        }
        catch {
            $errorMsg = "Failed to retrieve model list: $($_.Exception.Message)"
            Write-Error $errorMsg
            throw $errorMsg
        }
    }

    end {
    }
}
################################################################################
