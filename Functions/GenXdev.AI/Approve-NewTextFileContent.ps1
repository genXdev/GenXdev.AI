################################################################################
<#
.SYNOPSIS
Interactive file content comparison and approval using WinMerge.

.DESCRIPTION
Facilitates content comparison and merging through WinMerge by creating a
temporary file with proposed changes. The user can interactively review and
modify changes before approving. Returns approval status and final content.

.PARAMETER ContentPath
The path to the target file for comparison and potential update. If the file
doesn't exist, it will be created.

.PARAMETER NewContent
The proposed new content to compare against the existing file content.

.EXAMPLE
$result = Approve-NewTextFileContent -ContentPath "C:\temp\myfile.txt" `
    -NewContent "New file content"

.NOTES
Returns a hashtable with these properties:
- approved: True if changes were saved, False if discarded
- approvedAsIs: True if content was accepted without modifications
- savedContent: Final content if modified by user
- userDeletedFile: True if user deleted existing file
#>
function Approve-NewTextFileContent {

    [CmdletBinding()]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the target file for comparison"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ContentPath,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "New content to compare against existing file"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$NewContent
        ########################################################################
    )

    begin {

        # ensure content path exists, create if missing
        $contentPath = GenXdev.FileSystem\Expand-Path $ContentPath -CreateFile

        Write-Verbose "Target file path: $contentPath"
    }

    process {

        # check initial file existence for tracking deletion
        $existed = [System.IO.File]::Exists($contentPath)

        Write-Verbose "File existed before comparison: $existed"

        # create temporary file with matching extension for comparison
        $tempFile = GenXdev.FileSystem\Expand-Path ([System.IO.Path]::GetTempFileName() +
                [System.IO.Path]::GetExtension($contentPath)) `
            -CreateDirectory

        Write-Verbose "Created temp comparison file: $tempFile"

        # write proposed content to temp file
        $NewContent | Out-File -FilePath $tempFile -Force

        # launch winmerge for interactive comparison
        $null = Invoke-WinMerge `
            -SourcecodeFilePath $tempFile `
            -TargetcodeFilePath $contentPath `
            -Wait

        # prepare result tracking object
        $result = @{
            approved = [System.IO.File]::Exists($contentPath)
        }

        if ($result.approved) {

            # check if content was modified during comparison
            $content = Get-Content -Path $contentPath -Raw
            $changed = $content.Trim() -ne $NewContent.Trim()

            $result.approvedAsIs = -not $changed

            if ($changed) {
                $result.savedContent = $content
            }
        }
        elseif ($existed) {
            $result.userDeletedFile = $true
        }

        Write-Verbose "Comparison result: $($result | ConvertTo-Json)"
        return $result
    }

    end {
    }
}
################################################################################
