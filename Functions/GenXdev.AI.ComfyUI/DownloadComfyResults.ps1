<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : DownloadComfyResults.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
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