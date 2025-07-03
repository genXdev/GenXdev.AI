###############################################################################
<#
.SYNOPSIS
Calculates the cosine similarity between two vectors, returning a value between
0 and 1.

.DESCRIPTION
This function takes two numerical vectors (arrays) as input and computes their
cosine similarity. The result indicates how closely related the vectors are,
with 0 meaning completely dissimilar and 1 meaning identical.

.PARAMETER Vector1
The first vector as an array of numbers (e.g., [0.12, -0.45, 0.89]). Must be
the same length as Vector2.

.PARAMETER Vector2
The second vector as an array of numbers (e.g., [0.15, -0.40, 0.92]). Must be
the same length as Vector1.

.EXAMPLE
$v1 = @(0.12, -0.45, 0.89)
$v2 = @(0.15, -0.40, 0.92)
Get-VectorSimilarity -Vector1 $v1 -Vector2 $v2
        ###############################################################################Returns approximately 0.998, indicating high similarity
        ###############################################################################>
function Get-VectorSimilarity {

    [CmdletBinding()]
    [OutputType([double])]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "First vector array of numbers"
        )]
        [double[]]$Vector1,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Second vector array of numbers"
        )]
        [double[]]$Vector2
        ########################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Validating input vectors..."

        # check for null vectors
        if (-not $Vector1 -or -not $Vector2) {
            Microsoft.PowerShell.Utility\Write-Error "Both Vector1 and Vector2 must contain values."
            return $null
        }

        # verify vectors have matching lengths
        if ($Vector1.Length -ne $Vector2.Length) {
            Microsoft.PowerShell.Utility\Write-Error "Vector1 and Vector2 must have the same length."
            return $null
        }

        # ensure vectors are not empty
        if ($Vector1.Length -eq 0) {
            Microsoft.PowerShell.Utility\Write-Error "Vectors cannot be empty."
            return $null
        }
    }


process {

        try {
            Microsoft.PowerShell.Utility\Write-Verbose "Calculating vector similarity..."

            # compute the dot product of the two vectors
            $dotProduct = 0.0
            for ($i = 0; $i -lt $Vector1.Length; $i++) {
                $dotProduct += $Vector1[$i] * $Vector2[$i]
            }

            # calculate the magnitude (euclidean norm) of each vector
            $magnitude1 = 0.0
            $magnitude2 = 0.0
            for ($i = 0; $i -lt $Vector1.Length; $i++) {
                $magnitude1 += [Math]::Pow($Vector1[$i], 2)
                $magnitude2 += [Math]::Pow($Vector2[$i], 2)
            }
            $magnitude1 = [Math]::Sqrt($magnitude1)
            $magnitude2 = [Math]::Sqrt($magnitude2)

            # prevent division by zero for zero-magnitude vectors
            if ($magnitude1 -eq 0 -or $magnitude2 -eq 0) {
                Microsoft.PowerShell.Utility\Write-Warning ("One or both vectors have zero magnitude. " +
                    "Similarity is undefined.")
                return 0.0
            }

            # calculate final cosine similarity
            $similarity = $dotProduct / ($magnitude1 * $magnitude2)

            # normalize result to 0-1 range
            $normalizedSimilarity = [Math]::Min([Math]::Max($similarity, -1), 1)
            $normalizedSimilarity = ($normalizedSimilarity + 1) / 2

            Microsoft.PowerShell.Utility\Write-Verbose "Similarity calculation complete"
            return [math]::Round($normalizedSimilarity, 6)
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Error calculating similarity: $_"
            return $null
        }
    }

    end {
    }
}
        ###############################################################################