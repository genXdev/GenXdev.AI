################################################################################
<#
.SYNOPSIS
Gets the configured directories and default language for image files used in
GenXdev.AI operations.

.DESCRIPTION
This function retrieves the global image directories and default language used
by the GenXdev.AI module for various image processing and AI operations. It
returns the configuration from both global variables and the module's
preference storage, with fallback to system defaults.

.PARAMETER DefaultValue
Optional default value to return if no image directories are configured. If
not specified, returns the system default directories (Downloads, OneDrive,
Pictures).

.EXAMPLE
Get-AIImageCollection

Returns the configured image directories and default language, or system
defaults if none are configured.

.EXAMPLE
$config = Get-AIImageCollection -DefaultValue @("C:\MyImages")

Returns configured directories or the specified default if none are configured.

.EXAMPLE
getimgdirs

Uses alias to get the current image directory configuration.
#>
function Get-AIImageCollection {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias("getimgdirs")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Default directories to return if none are configured"
        )]
        [AllowNull()]
        [string[]] $ImageDirectories
        ###############################################################################
    )

    begin {

    }

    process {

        if ($null -ne $ImageDirectories -and
            $ImageDirectories.Count -gt 0) {

            # use provided directories if available
            $result = $ImageDirectories
            Microsoft.PowerShell.Utility\Write-Output $result
            return;
        }

        # get image directories from preferences or global variable
        $imageDirectoriesPreference = $null

        try {

            # retrieve image directories preference from genxdev data storage
            $json = GenXdev.Data\Get-GenXdevPreference `
                -Name "ImageDirectories" `
                -DefaultValue $null `
                -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($json)) {

                # convert json preference to powershell object
                $imageDirectoriesPreference = $json |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json
            }
        }
        catch {

            # set to null if preference retrieval fails
            $imageDirectoriesPreference = $null
        }

        # determine which image directories to use based on priority
        if ($null -ne $imageDirectoriesPreference -and
            $imageDirectoriesPreference.Count -gt 0) {

            # use preference value if available and not empty
            $result = $imageDirectoriesPreference
        }
        elseif ($Global:ImageDirectories -and $Global:ImageDirectories.Count -gt 0) {

            # fallback to global variable if preference not available
            $result = $Global:ImageDirectories
        }
        else {

            # fallback to default system directories
            $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"

            try {

                # attempt to get known folder path for pictures directory
                $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
            }
            catch {

                # fallback to default if known folder retrieval fails
                $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            }

            # define default directories for image processing operations
            $result.ImageDirectories = @(
                (GenXdev.FileSystem\Expand-Path '~\downloads'),
                (GenXdev.FileSystem\Expand-Path '~\onedrive'),
                $picturesPath
            )
        }
    }

    end {

        # return the configured image directories and language
        $result |  Microsoft.PowerShell.Core\ForEach-Object {

            Microsoft.PowerShell.Utility\Write-Output (GenXdev.FileSystem\Expand-Path $_)
        }
    }
}
################################################################################
