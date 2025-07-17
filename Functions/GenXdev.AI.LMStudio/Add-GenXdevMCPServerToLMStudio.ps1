function Add-GenXdevMCPServerToLMStudio {
    param(
        [string]$ServerName = 'GenXdev',
        [string]$Url = 'http://localhost:2175/mcp'
    )

    # PowerShell script to launch LM Studio with a deeplink to add GenXdev MCP server

    # Define the MCP server configuration as a JSON string
    $mcpConfig = @"
    {
        "servers": {
            "ServerName": {
                "type": "http",
                "url": "$Url"
            }
        }
    }
"@

    # Encode the JSON configuration for the deeplink
    $encodedConfig = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($mcpConfig))

    # Construct the LM Studio deeplink
    $deeplink = "lmstudio://mcp?config=$encodedConfig"

    # Launch LM Studio with the deeplink using Start-Process
    Microsoft.PowerShell.Management\Start-Process -FilePath $deeplink

    Microsoft.PowerShell.Utility\Write-Host 'Launched LM Studio with deeplink to add GenXdev MCP server.'
}