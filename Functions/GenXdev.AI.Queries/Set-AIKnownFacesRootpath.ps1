################################################################################
<#
.SYNOPSIS
Sets the directory for face image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global face directory used by the GenXdev.AI
module for various face recognition and AI operations. It updates both the
global variable and the module's preference storage to persist the
configuration across sessions.

.PARAMETER FacesDirectory
A directory path where face image files are located. This directory
will be used by GenXdev.AI functions for face discovery and processing
operations.

.EXAMPLE
Set-AIKnownFacesRootpath -FacesDirectory "C:\Faces"

.EXAMPLE
Set-AIKnownFacesRootpath "C:\FacePictures"
#>
function Set-AIKnownFacesRootpath {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Directory path for face image files"
        )]
        [string] $FacesDirectory
        ###############################################################################
    )

    begin {

        # display verbose information about the faces directory being configured
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Setting faces directory for GenXdev.AI module: " +
            "[$FacesDirectory]"
        )
    }

    process {

        # confirm the operation with the user before proceeding with changes
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            "Set faces directory to: [$FacesDirectory]"
        )) {

            # set the global variable for immediate use by other functions
            $Global:FacesDirectory = $FacesDirectory

            # store the configuration in module preferences for persistence
            $null = GenXdev.Data\Set-GenXdevPreference `
                -Name "FacesDirectory" `
                -Value $FacesDirectory

            # output confirmation message about successful configuration
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Successfully configured faces directory in GenXdev.AI module: " +
                "[$FacesDirectory]"
            )
        }
    }

    end {
    }
}
################################################################################