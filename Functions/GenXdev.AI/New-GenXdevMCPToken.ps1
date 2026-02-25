<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : New-GenXdevMCPToken.ps1
Original author           : René Vaessen / GenXdev
Version                   : 3.3.2026
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
################################################################################
# Part of PowerShell module : GenXdev.AI
# Original cmdlet filename  : New-GenXdevMCPToken.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.3.2026
################################################################################
# Copyright (c)  René Vaessen / GenXdev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
function New-GenXdevMCPToken {
    <#
    .SYNOPSIS
        Generates a secure random Bearer token for GenXdev MCP server
        authentication.

    .DESCRIPTION
        Creates a cryptographically secure random token and optionally stores
        it in the user environment variable GENXDEV_MCP_TOKEN. The token is
        used to authenticate requests to the GenXdev MCP server from clients on
        the local network.

    .PARAMETER Length
        The length of the token in bytes. Default is 32 bytes (256 bits),
        which produces a 44-character base64 string. Minimum is 16 bytes (128
        bits).

    .PARAMETER SetEnvironmentVariable
        If specified, stores the generated token in the GENXDEV_MCP_TOKEN user
        environment variable. This makes the token available to the MCP server
        and VS Code MCP client automatically.

    .PARAMETER Force
        If specified, overwrites an existing GENXDEV_MCP_TOKEN environment
        variable without prompting. Only used with -SetEnvironmentVariable.

    .EXAMPLE
        New-GenXdevMCPToken

        Generates and displays a new random token without storing it.

    .EXAMPLE
        New-GenXdevMCPToken -SetEnvironmentVariable

        Generates a new token and stores it in the GENXDEV_MCP_TOKEN user
        environment variable. Prompts if a token already exists.

    .EXAMPLE
        New-GenXdevMCPToken -Length 64 -SetEnvironmentVariable -Force

        Generates a longer 64-byte token, stores it in the environment
        variable, and overwrites any existing token without prompting.

    .EXAMPLE
        $token = New-GenXdevMCPToken
        Start-GenXdevMCPServer -Token $token

        Generates a token and passes it directly to the MCP server without
        storing in environment.

    .OUTPUTS
        System.String. The generated Bearer token as a base64-encoded string.

    .NOTES
        - Token is cryptographically random using
          System.Security.Cryptography.RandomNumberGenerator
        - Default 32-byte token provides 256 bits of entropy (highly secure)
        - Stored tokens persist across PowerShell sessions and system reboots
        - To remove the token, use:
          [System.Environment]::SetEnvironmentVariable('GENXDEV_MCP_TOKEN',
          $null, 'User')
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "The length of the token in bytes (default: 32, minimum: 16)")]
        [ValidateRange(16, 128)]
        [int]$Length = 32,

        [Parameter(Mandatory = $false, HelpMessage = "Store the token in GENXDEV_MCP_TOKEN user environment variable")]
        [switch]$SetEnvironmentVariable,

        [Parameter(Mandatory = $false, HelpMessage = "Overwrite existing environment variable without prompting")]
        [switch]$Force
    )

    # Generate cryptographically secure random bytes
    $randomBytes = [byte[]]::new($Length)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($randomBytes)
    }
    finally {
        $rng.Dispose()
    }

    # Convert to base64 for safe transmission (URL-safe characters)
    $token = [System.Convert]::ToBase64String($randomBytes)

    # Display token information
    Microsoft.PowerShell.Utility\Write-Host "Generated secure MCP token ($Length bytes, $($token.Length) characters):" -ForegroundColor Green
    Microsoft.PowerShell.Utility\Write-Host $token -ForegroundColor Cyan

    # Store in environment variable if requested
    if ($SetEnvironmentVariable) {
        # Check for existing token
        $existingToken = [System.Environment]::GetEnvironmentVariable('GENXDEV_MCP_TOKEN', 'User')

        if (-not [string]::IsNullOrEmpty($existingToken) -and -not $Force) {
            # Prompt user for confirmation
            $message = "An MCP token is already configured in GENXDEV_MCP_TOKEN. Overwrite it?"
            $title = "Confirm Token Replacement"
            $yes = Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Replace the existing token"
            $no = Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Keep the existing token"
            $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result = $host.UI.PromptForChoice($title, $message, $options, 1)

            if ($result -eq 1) {
                Microsoft.PowerShell.Utility\Write-Host "Keeping existing token." -ForegroundColor Yellow
                return $existingToken
            }
        }

        # Set the environment variable
        if ($PSCmdlet.ShouldProcess("GENXDEV_MCP_TOKEN", "Set user environment variable")) {
            try {
                [System.Environment]::SetEnvironmentVariable('GENXDEV_MCP_TOKEN', $token, 'User')
                Microsoft.PowerShell.Utility\Write-Host "`nToken stored in GENXDEV_MCP_TOKEN user environment variable." -ForegroundColor Green
                Microsoft.PowerShell.Utility\Write-Host "The token will be available to:" -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host "  - GenXdev MCP Server (via Start-GenXdevMCPServer)" -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host "  - VS Code MCP Client (via .vscode/mcp.json)" -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host "`nRestart VS Code to apply the new token to the MCP client." -ForegroundColor Yellow
                Microsoft.PowerShell.Utility\Write-Host "Restart the MCP server task to apply the new token to the server." -ForegroundColor Yellow
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Error "Failed to set environment variable: $($_.Exception.Message)"
            }
        }
    }
    else {
        Microsoft.PowerShell.Utility\Write-Host "`nTo use this token:" -ForegroundColor Gray
        Microsoft.PowerShell.Utility\Write-Host "  1. Store it: New-GenXdevMCPToken -SetEnvironmentVariable" -ForegroundColor Gray
        Microsoft.PowerShell.Utility\Write-Host "  2. Or pass it: Start-GenXdevMCPServer -Token `"$token`"" -ForegroundColor Gray
    }

    # Return the token
    return $token
}