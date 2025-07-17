###############################################################################
<#
.SYNOPSIS
Tests if LMStudio is installed and accessible on the system.

.DESCRIPTION
Verifies the LMStudio installation by checking if the executable exists at the
expected path location. Uses Get-LMStudioPaths helper function to determine the
installation path and validates the executable's existence.

.EXAMPLE
Test-LMStudioInstallation
Returns $true if LMStudio is properly installed, $false otherwise.

.EXAMPLE
tlms
Uses the alias to check LMStudio installation status.
#>
function Test-LMStudioInstallation {

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    begin {

        # retrieve the lmstudio installation paths using helper function
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving LMStudio installation paths...'
        $paths = Get-LMStudioPaths
    }


    process {

        # check if the exe exists and return result
        Microsoft.PowerShell.Utility\Write-Verbose "Verifying LMStudio executable at: $($paths.LMSExe)"

        # use system.io for better performance
        return ((-not [string]::IsNullOrWhiteSpace($paths.LMSExe)) -and
            [System.IO.File]::Exists($paths.LMSExe) -and
            (-not [string]::IsNullOrWhiteSpace($paths.LMStudioExe)) -and
            [System.IO.File]::Exists($paths.LMStudioExe))
    }

    end {}
}