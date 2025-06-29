function Get-AIKnownFacesRootpath {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Directory path for face image files"
        )]
        [string] $FacesDirectory
    )
    begin
    {
        # get configured faces directory from preference store
        $resolvedFacesDirectory = $null

        if (-not ([string]::IsNullOrWhiteSpace($FacesDirectory))) {

            $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path "$FacesDirectory\" -CreateDirectory
            return;
        }

        try {

            $resolvedFacesDirectory = GenXdev.Data\Get-GenXdevPreference `
                -Name "FacesDirectory" `
                -DefaultValue $null `
                -ErrorAction SilentlyContinue
        }
        catch {

            $resolvedFacesDirectory = $null
        }

        # use configured directory or fallback to default
        if ([string]::IsNullOrWhiteSpace($resolvedFacesDirectory)) {

            # fallback to default directory
            $resolvedFacesDirectory = @(GenXdev.AI\Get-AIImageCollection)[0]

            if (-not $resolvedFacesDirectory) {
                $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                    -Path "~\Pictures\Faces\" `
                    -CreateDirectory
            }
        }
    }

    end
    {
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using provided faces directory: $resolvedFacesDirectory"

        Microsoft.PowerShell.Utility\Write-Output (GenXdev.FileSystem\Expand-Path "$resolvedFacesDirectory\")
    }
}