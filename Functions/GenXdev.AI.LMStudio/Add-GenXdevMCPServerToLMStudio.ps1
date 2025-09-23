<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Add-GenXdevMCPServerToLMStudio.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.284.2025
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
################################################################################
<#
.SYNOPSIS
Adds the GenXdev MCP server to LM Studio using a deeplink configuration.

.DESCRIPTION
This function creates an MCP (Model Context Protocol) server configuration
for GenXdev and launches LM Studio with a deeplink to automatically add the
server. The function encodes the server configuration as a Base64 string and
constructs an appropriate LM Studio deeplink URL for seamless integration.

.PARAMETER ServerName
The name to assign to the MCP server in LM Studio. This name will be displayed
in the LM Studio interface when managing MCP servers.

.PARAMETER Url
The HTTP URL where the GenXdev MCP server is listening for connections. This
should include the protocol, host, port, and path components.

.EXAMPLE
Add-GenXdevMCPServerToLMStudio -ServerName "GenXdev" -Url "http://localhost:2175/mcp"

Opens LM Studio and adds a new MCP server named "GenXdev" pointing to the
default GenXdev MCP server endpoint.

.EXAMPLE
Add-GenXdevMCPServerToLMStudio "MyGenXdev" "http://192.168.1.100:2175/mcp"

Opens LM Studio and adds a new MCP server named "MyGenXdev" pointing to a
remote GenXdev MCP server instance.
#>
function Add-GenXdevMCPServerToLMStudio {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The name to assign to the MCP server in LM Studio"
        )]
        [string] $ServerName = 'GenXdev',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The HTTP URL where the GenXdev MCP server is listening"
        )]
        [string] $Url = 'http://localhost:2175/mcp'
        ###############################################################################
    )

    begin {

        # output verbose information about the operation being performed
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Preparing to add GenXdev MCP server '${ServerName}' at '${Url}' to " +
            "LM Studio"
        )
    }

    process {

        # create the mcp server configuration as a json string for lm studio
        $mcpConfig = @"
    {
        "servers": {
            "${ServerName}": {
                "type": "http",
                "url": "${Url}"
            }
        }
    }
"@

        # output verbose information about the configuration being created
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Created MCP configuration JSON for server registration"
        )

        # encode the json configuration as base64 for deeplink transmission
        $encodedConfig = [Convert]::ToBase64String(
            [System.Text.Encoding]::UTF8.GetBytes($mcpConfig)
        )

        # output verbose information about the encoding process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Encoded configuration as Base64 string for deeplink URL"
        )

        # construct the lm studio deeplink url with encoded configuration
        $deeplink = "lmstudio://mcp?config=${encodedConfig}"

        # output verbose information about the deeplink construction
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Constructed LM Studio deeplink: ${deeplink}"
        )

        # launch lm studio application with the deeplink using start-process
        Microsoft.PowerShell.Management\Start-Process -FilePath $deeplink

        # output confirmation message to the user about the operation
        Microsoft.PowerShell.Utility\Write-Host (
            "Launched LM Studio with deeplink to add GenXdev MCP server."
        )
    }

    end {

        # output verbose information about the completion of the operation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully completed GenXdev MCP server addition to LM Studio"
        )
    }
}
################################################################################