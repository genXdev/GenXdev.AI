################################################################################
<#
.SYNOPSIS
Sets the directories for image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global image directories used by the GenXdev.AI
module for various image processing and AI operations. It updates both the
global variable and the module's preference storage to persist the
configuration across sessions.

.PARAMETER ImageDirectories
An array of directory paths where image files are located. These directories
will be used by GenXdev.AI functions for image discovery and processing
operations.

.EXAMPLE
Set-ImageDirectories -ImageDirectories @("C:\Images", "D:\Photos")

.EXAMPLE
Set-ImageDirectories @("C:\Pictures", "E:\Graphics\Stock")
#>
function Set-ImageDirectory {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Array of directory paths for image files"
        )]
        [string[]] $ImageDirectories
        ###############################################################################
    )

    begin {

        # validate that parameters are properly set
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Setting image directories for GenXdev.AI module: " +
            "[$($ImageDirectories -join ', ')]"
        )
    }    process {

        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            "Set image directories to: [$($ImageDirectories -join ', ')]"
        )) {

            # set the global variable for immediate use by other functions
            $Global:ImageDirectories = $ImageDirectories

            # serialize the array to json for storage in preferences
            $serializedDirectories = $ImageDirectories |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -ErrorAction SilentlyContinue

            # store the configuration in module preferences for persistence
            $null = GenXdev.Data\Set-GenXdevPreference `
                -Name "ImageDirectories" `
                -Value $serializedDirectories

            # output confirmation of the operation
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Successfully configured $($ImageDirectories.Count) image " +
                "directories in GenXdev.AI module"
            )
        }
    }

    end {
    }
}
################################################################################