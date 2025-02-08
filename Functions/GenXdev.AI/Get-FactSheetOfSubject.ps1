################################################################################
<#
.SYNOPSIS
Creates a fact sheet for a given subject using AI assistance.

.DESCRIPTION
Generates a detailed fact sheet containing well-established facts and properties
about the specified subject. The facts are returned as key-value pairs in a
structured format.

.PARAMETER Query
The subject to analyze and create a fact sheet for.

.EXAMPLE
Get-FactSheetOfSubject -Query "Elephant"

.EXAMPLE
facts "Elephant"
#>
function Get-FactSheetOfSubject {

    [CmdletBinding()]
    [Alias("facts")]

    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The subject to create a fact sheet for"
        )]
        [string] $Query
        ########################################################################
    )

    begin {

        # initialize result variable
        $Result = $null
    }

    process {

        # query the ai model for facts about the subject
        $Result = qlms -Instructions "create a fact sheet of the subject that is
            described in the request. Mention as many facts and properties about
            the subject that you know, but always keep it factual with well
            established facts. Each fact must have a single string as name that
            is used as the key inside the json object you return, it's value is
            a string with the fact description" `
            -Query $Query

        Write-Verbose "AI Response: $Result"

        # split the result into json segments
        $JsonSegments = "$Result" -split "(\{(.*)`})|(\[(.*)`])"

        # process each segment
        for ($i = 0; $i -lt $JsonSegments.length; $i++) {

            try {
                # attempt to convert segment to json object
                $NewResult = $JsonSegments[$i] | ConvertFrom-Json

                if ($Result -is [string]) {
                    $Result = [System.Collections.Generic.List[string]]@(
                        $Result,
                        $NewResult
                    )
                }
                else {
                    $null = $Result.Add($NewResult)
                }
            }
            catch {
                # skip invalid json segments
            }
        }
    }

    end {
        return $Result
    }
}
################################################################################
