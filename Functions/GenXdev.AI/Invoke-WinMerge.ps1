################################################################################
<#
.SYNOPSIS
Launches WinMerge to compare two files side by side.

.DESCRIPTION
Launches the WinMerge application to compare source and target files in a side by
side diff view. The function validates the existence of both input files and
ensures WinMerge is properly installed before launching. Provides optional
wait functionality to pause execution until WinMerge closes.

.PARAMETER SourcecodeFilePath
Full or relative path to the source file for comparison. The file must exist and
be accessible.

.PARAMETER TargetcodeFilePath
Full or relative path to the target file for comparison. The file must exist and
be accessible.

.PARAMETER Wait
Switch parameter that when specified will cause the function to wait for the
WinMerge application to close before continuing execution.

.EXAMPLE
Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `
                -TargetcodeFilePath "C:\target\file2.txt" `
                -Wait

.EXAMPLE
merge "C:\source\file1.txt" "C:\target\file2.txt"
#>
function Invoke-WinMerge {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the source file to compare"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$SourcecodeFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Path to the target file to compare against"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$TargetcodeFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Wait for WinMerge to close before continuing"
        )]
        [switch]$Wait
        ########################################################################
    )


    begin {

        # verify that winmerge is installed and accessible
        Write-Verbose "Verifying WinMerge installation status..."
        AssureWinMergeInstalled


        # convert any relative paths to full paths for reliability
        $sourcePath = GenXdev.FileSystem\Expand-Path $SourcecodeFilePath
        $targetPath = GenXdev.FileSystem\Expand-Path $TargetcodeFilePath


        # log the resolved file paths for troubleshooting
        Write-Verbose "Resolved source file path: $sourcePath"
        Write-Verbose "Resolved target file path: $targetPath"
    }


    process {

        # prepare the process start parameters including executable and files
        $processArgs = @{
            FilePath     = 'WinMergeU.exe'
            ArgumentList = $sourcePath, $targetPath
        }


        # add wait parameter if specified to block until winmerge closes
        if ($Wait) {
            $processArgs['Wait'] = $true
            Write-Verbose "Will wait for WinMerge process to exit"
        }


        # launch winmerge with the configured parameters
        Write-Verbose "Launching WinMerge application..."
        Start-Process @processArgs
    }


    end {
    }
}
################################################################################
