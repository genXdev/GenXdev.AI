<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : DownloadComfyResults.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.286.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################

<#
.SYNOPSIS
Downloads generated results from ComfyUI server with file information

.DESCRIPTION
Processes the completed workflow history data to identify and download all
generated images from the ComfyUI server to the specified output directory.
This function handles the complete download process including URL construction,
file retrieval, and progress reporting for all generated images.

.PARAMETER HistoryData
The completed workflow history data containing output references from ComfyUI
workflow execution

.PARAMETER OutputDirectory
Local directory path where downloaded files should be saved

.EXAMPLE
DownloadComfyResults -HistoryData $completedWorkflow -OutputDirectory "C:\output"

.EXAMPLE
DownloadComfyResults $completedWorkflow "C:\output"
#>
function DownloadComfyResults {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = ("The completed workflow history data containing " +
                          "output references from ComfyUI workflow execution")
        )]
        [object]$HistoryData,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = ("Local directory path where downloaded files " +
                          "should be saved")
        )]
        [string]$OutputDirectory
        #######################################################################
    )

    begin {

        # initialize collection for tracking downloaded files
        $downloadedFiles = @()
    }

    process {

        # output verbose information about processing workflow outputs
        Microsoft.PowerShell.Utility\Write-Verbose "Processing HistoryData.outputs"

        # fix powershell object access issue - use psobject.properties for
        # reliable property access
        $outputs = if ($HistoryData.outputs) {
            $HistoryData.outputs
        } else {
            $HistoryData.PSObject.Properties |
                Microsoft.PowerShell.Core\Where-Object Name -eq "outputs" |
                Microsoft.PowerShell.Utility\Select-Object -ExpandProperty Value
        }

        # output debug information about outputs object structure
        Microsoft.PowerShell.Utility\Write-Verbose ("Outputs object type: " +
            "$($outputs.GetType().Name)")

        # calculate and display number of output nodes found
        Microsoft.PowerShell.Utility\Write-Verbose ("Number of output nodes: " +
            "$(if ($outputs.PSObject.Properties) { $outputs.PSObject.Properties.Count } else { 0 })")

        # get output node ids using psobject.properties for reliable access
        $outputNodeIds = if ($outputs.PSObject.Properties) {
            $outputs.PSObject.Properties.Name
        } else {
            @()
        }

        # process each workflow output node for image downloads
        foreach ($nodeId in $outputNodeIds) {

            # output debug information about current node processing
            Microsoft.PowerShell.Utility\Write-Verbose "Processing node $nodeId"

            # get node output using psobject.properties for reliable access
            $nodeOutput = $outputs.PSObject.Properties |
                Microsoft.PowerShell.Core\Where-Object Name -eq $nodeId |
                Microsoft.PowerShell.Utility\Select-Object -ExpandProperty Value

            # output debug information about image availability in node
            Microsoft.PowerShell.Utility\Write-Verbose ("Node output has " +
                "images: $($null -ne $nodeOutput.images)")

            # display number of images if any exist
            if ($nodeOutput.images) {
                Microsoft.PowerShell.Utility\Write-Verbose ("Number of images " +
                    "in node: $($nodeOutput.images.Count)")
            }

            # check if this node produced image outputs
            if ($nodeOutput.images) {

                # download each image from this output node
                foreach ($image in $nodeOutput.images) {

                    # output debug information about current image processing
                    Microsoft.PowerShell.Utility\Write-Verbose ("Processing " +
                        "image: $($image.filename)")

                    # debug check for malformed filename
                    if ([string]::IsNullOrWhiteSpace($image.filename)) {
                        Microsoft.PowerShell.Utility\Write-Warning "Empty filename detected, skipping"
                        continue
                    }

                    # construct download url with proper query parameters
                    $imageUrl = ("${script:comfyUIApiUrl}/view?" +
                                "filename=$($image.filename)&" +
                                "subfolder=$($image.subfolder)&" +
                                "type=$($image.type)")

                    # output debug information about constructed download url
                    Microsoft.PowerShell.Utility\Write-Verbose ("Download URL: " +
                        "$imageUrl")

                    # determine local output file path for downloaded image
                    $outputFile = Microsoft.PowerShell.Management\Join-Path `
                        $OutputDirectory $image.filename

                    try {

                        # display progress for current image download
                        Microsoft.PowerShell.Utility\Write-Progress `
                            -Activity "ComfyUI Generation" `
                            -Status "Downloading $($image.filename)"

                        # download image file from comfyui server to local path
                        Microsoft.PowerShell.Utility\Invoke-WebRequest `
                            -Uri $imageUrl `
                            -OutFile $outputFile

                        # get file information for size reporting to user
                        $fileInfo = Microsoft.PowerShell.Management\Get-Item `
                            -LiteralPath $outputFile

                        # calculate file size in megabytes for user feedback
                        $fileSizeMB = [Math]::Round($fileInfo.Length / 1MB, 2)

                        Microsoft.PowerShell.Utility\Write-Verbose ("Downloaded: " +
                            "$($image.filename) (${fileSizeMB}MB)")

                        # add to collection of successfully downloaded files
                        $downloadedFiles += $outputFile

                        Microsoft.PowerShell.Utility\Write-Verbose ("Added file " +
                            "to results: $outputFile")
                    }
                    catch {

                        Microsoft.PowerShell.Utility\Write-Warning ("❌ Failed to " +
                            "download: $($image.filename)")

                        Microsoft.PowerShell.Utility\Write-Host ("DEBUG: Error " +
                            "details: $_") -ForegroundColor Red
                    }
                }
            }
        }

        # output final count of successfully downloaded files
        Microsoft.PowerShell.Utility\Write-Verbose ("Total downloaded files: " +
            "$($downloadedFiles.Count)")

        # ensure we return a proper array, even for single items
        return @($downloadedFiles)
    }

    end {
    }
}
################################################################################