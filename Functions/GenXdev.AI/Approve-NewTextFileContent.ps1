################################################################################
<#
.SYNOPSIS
Allows the LLM to suggest new content by comparing it with existing content using WinMerge.

.DESCRIPTION
This function allows the user to review and approve changes through the WinMerge interface.
This function returns an object with one or more of the following properties:
[bool] approved, [bool?] approvedAsIs, [string?] savedContent, [bool?] userDeletedFile
If the user made final changes. approveAsIs will be false and the savedContent will
contain the final changes the user made.

.PARAMETER ContentPath
The path to the existing content file on users computer.

.PARAMETER NewContent
The content the LLM suggest to the user.

.EXAMPLE
Approve-NewTextFileContent -ContentPath "C:\temp\file.txt" -NewContent "New text content"
#>
function Approve-NewTextFileContent {

    [CmdletBinding()]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the existing content file"
        )]
        [string]$ContentPath,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "New content to compare and merge"
        )]
        [string]$NewContent
        ########################################################################
    )

    begin {

        $ContentPath = Expand-Path $contentPath -CreateFile
    }

    process {

        # is new content
        $existed = [System.IO.File]::Exists($ContentPath)

        # create a temporary file with the new content
        $tempFile = Expand-Path ([System.IO.Path]::GetTempFileName() + `
            ([System.IO.Path]::GetExtension($ContentPath))) -CreateDirectory

        Write-Verbose "Created temporary file: $tempFile"

        # write new content to temporary file
        $NewContent | Out-File -FilePath $tempFile -Force

        # launch winmerge and wait for completion
        $null = Invoke-WinMerge `
            -SourcecodeFilePath $tempFile `
            -TargetcodeFilePath $ContentPath `
            -Wait

        $result = @{
            approved = [System.IO.File]::Exists($ContentPath)
        }

        if ($result.approved) {

            # read the content of the file
            $content = Get-Content -Path $ContentPath
            $changed = $content.Trim() -ne $NewContent.Trim()

            $result.approvedAsIs = $changed

            if ($changed) {

                $result.savedContent = $content;
            }
        }
        elseif ($existed) {

            $result.userDeletedFile = $true
        }

        return $result
    }

    end {
    }
}
################################################################################
