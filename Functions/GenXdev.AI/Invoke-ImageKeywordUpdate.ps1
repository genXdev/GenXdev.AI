################################################################################

<#
.SYNOPSIS
Updates the keywords and description of images in a directory.

.DESCRIPTION
The `Invoke-ImageKeywordUpdate` function updates the keywords and description of images in a directory.

.PARAMETER ImageDirectory
The directory path of the images to update.

.PARAMETER Recurse
Recursively search for images in subdirectories.

.PARAMETER OnlyNew
Only update images that do not have keywords and description.

.PARAMETER RetryFailed
Retry previously failed images.

.EXAMPLE
Invoke-ImageKeywordUpdate -ImageDirectory "C:\path\to\images" -Recurse -OnlyNew -RetryFailed

.EXAMPLE
updateimages "C:\path\to\images"
#>
function Invoke-ImageKeywordUpdate {

    [CmdletBinding()]
    [Alias("updateimages")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The image directory path."
        )]
        [string] $ImageDirectory = ".\",

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Recurse directories."
        )]
        [switch] $Recurse,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Skip if already has meta data."
        )]
        [switch] $OnlyNew,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Will retry previously failed images."
        )]
        [switch] $RetryFailed
    )

    begin {

        # expand the image directory path to its full path
        $Path = Expand-Path $ImageDirectory

        # check if the directory exists
        if (-not [System.IO.Directory]::Exists($Path)) {

            Write-Host "The directory '$Path' does not exist."
            return
        }
    }

    process {

        # get all image files in the directory
        Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse:$Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {

            # retry failed images if specified
            if ($RetryFailed) {

                if ([System.IO.File]::Exists("$($PSItem):description.json")) {

                    if ("$([System.IO.File]::ReadAllText("$($PSItem):description.json"))".StartsWith("{}")) {

                        [System.IO.File]::Delete("$($PSItem):description.json")
                    }
                }
            }

            $image = $PSItem.FullName

            # remove read-only attribute if present
            if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                $PSItem.Attributes = $PSItem.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
            }

            $fileExists = [System.IO.File]::Exists("$($image):description.json")

            # update image description if not already present or if OnlyNew is not specified
            if ((-not $OnlyNew) -or (-not $fileExists)) {

                if (-not $fileExists) {

                    "{}" > "$($image):description.json"
                }

                Write-Verbose "Getting image description for $image.."

                # invoke the query to get image description
                $description = Invoke-QueryImageContent -Query "Analyze image and return a object with properties: 'short_description' (max 80 chars), 'long_description', 'has_nudity, keywords' (array of strings), 'has_explicit_content', 'overall_mood_of_image', 'picture_type' and 'style_type'. Output only json, no markdown or anything other then json." -ImagePath $image -Temperature 0.01

                Write-Verbose $description

                try {

                    # trim and extract the json part of the description
                    $description = $description.trim()
                    $i0 = $description.IndexOf("{")
                    $i1 = $description.LastIndexOf("}")
                    if ($i0 -ge 0) {

                        $description = $description.Substring($i0, $i1 - $i0 + 1)
                    }

                    # write the description to the json file
                    [System.IO.File]::WriteAllText("$($image):description.json", ($description | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 20 -WarningAction SilentlyContinue))
                }
                catch {

                    Write-Warning "$PSItem`r`n$description"
                }
            }
        }
    }

    end {

    }
}
