################################################################################
<#
.SYNOPSIS
Launches WinMerge to compare two files.

.DESCRIPTION
Opens WinMerge application to compare source and target files side by side.
Optionally waits for WinMerge to close before continuing.

.PARAMETER SourcecodeFilePath
The path to the source file to compare.

.PARAMETER TargetcodeFilePath
The path to the target file to compare against.

.PARAMETER Wait
If specified, waits for WinMerge to close before continuing.

.EXAMPLE
Invoke-WinMerge -SourcecodeFilePath "file1.txt" -TargetcodeFilePath "file2.txt"

.EXAMPLE
Invoke-WinMerge "file1.txt" "file2.txt" -Wait
#>
function Invoke-WinMerge {

    [CmdletBinding()]
    param(
        ################################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the source file to compare"
        )]
        [string]$SourcecodeFilePath,
        ################################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Path to the target file to compare against"
        )]
        [string]$TargetcodeFilePath,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Wait for WinMerge to close before continuing"
        )]
        [switch]$Wait
        ################################################################################
    )

    begin {

        # verify winmerge is installed
        Write-Verbose "Verifying WinMerge installation..."
        AssureWinMergeInstalled
    }

    process {

        # prepare process start parameters
        $processArgs = @{
            FilePath = 'WinMergeU.exe'
            ArgumentList = $SourcecodeFilePath, $TargetcodeFilePath
        }

        # add wait parameter if specified
        if ($Wait) {
            $processArgs['Wait'] = $true
        }

        # launch winmerge with the specified parameters
        Write-Verbose "Launching WinMerge..."
        Start-Process @processArgs
    }

    end {
    }
}
################################################################################
