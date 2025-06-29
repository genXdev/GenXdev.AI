################################################################################
<#
.SYNOPSIS
Adds directories to the configured image directories for GenXdev.AI operations.

.DESCRIPTION
This function adds one or more directory paths to the existing image directories
configuration used by the GenXdev.AI module. It updates both the global variable
and the module's preference storage to persist the configuration across sessions.
Duplicate directories are automatically filtered out to prevent configuration
redundancy. Paths are expanded to handle relative paths and environment
variables automatically.

.PARAMETER ImageDirectories
An array of directory paths to add to the existing image directories
configuration. Paths can be relative or absolute and will be expanded
automatically. Duplicates are filtered out using case-insensitive comparison.

.EXAMPLE
Add-ImageDirectories -ImageDirectories @("C:\NewPhotos", "D:\MoreImages")

Adds the specified directories to the existing image directories configuration
using full parameter names.

.EXAMPLE
addimgdir @("C:\Temp\Photos", "E:\Backup\Images")

Uses alias to add multiple directories to the configuration with positional
parameters.
#>
function Add-ImageDirectories {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    [Alias("addimgdir")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Array of directory paths to add to image directories"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories
        ###############################################################################
    )

    begin {

        # retrieve current image directories configuration
        $currentConfig =  GenXdev.AI\Get-AIImageCollection

        # initialize new collection to store all directories including existing ones
        $newDirectories = [System.Collections.Generic.List[string]]::new()

        # populate collection with existing directories to preserve them
        foreach ($dir in $currentConfig) {

            $newDirectories.Add($dir)
        }

        # output current configuration state for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Current image directories: " +
            "[$($ImageDirectories -join ', ')]"
        )
    }

    process {

        # iterate through each provided directory path for processing
        foreach ($directory in $ImageDirectories) {

            # expand path to resolve relative paths and environment variables
            $expandedPath = GenXdev.FileSystem\Expand-Path $directory

            # search for existing directory using case-insensitive comparison
            $existingDir = $newDirectories |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.ToLower() -eq $expandedPath.ToLower()
                }

            # add directory only if it doesn't already exist in collection
            if (-not $existingDir) {

                $newDirectories.Add($expandedPath)

                # output verbose message about successful addition
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Adding directory: $expandedPath"
                )
            }
            else {

                # output verbose message about duplicate directory skip
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Directory already exists: $expandedPath"
                )
            }
        }
    }

    end {

        # convert list collection to array for function call compatibility
        $finalDirectories = $newDirectories.ToArray()

        # request user confirmation before modifying configuration
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            ("Add directories to image directories: " +
            "[$($ImageDirectories -join ', ')]")
        )) {

            # update configuration using the dedicated setter function
            GenXdev.AI\Set-AIImageCollection `
                -ImageDirectories $finalDirectories

            # display success confirmation to user with statistics
            Microsoft.PowerShell.Utility\Write-Host (
                "Added $($ImageDirectories.Count) directories to image " +
                "directories configuration. Total directories: " +
                "$($finalDirectories.Count)"
            ) -ForegroundColor Green
        }
    }
}
################################################################################
