################################################################################
<#
.SYNOPSIS
Converts direct or blunt text into polite, tactful diplomatic language.

.DESCRIPTION
This function transforms user input from direct or blunt phrasing into
diplomatic, tactful language suitable for high-level discussions, negotiations,
or formal communications. The function uses AI language models to maintain
the original intent while softening the tone and making the message more
diplomatic and professional.

.PARAMETER Text
The text to convert to diplomatic speak.

.PARAMETER Instructions
Additional instructions for the AI model.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SetClipboard
Copy the transformed text to clipboard.

.PARAMETER ShowWindow
Show the LM Studio window.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
ConvertTo-DiplomaticSpeak -Text "Your proposal is terrible" -Temperature 0.2 `
    -SetClipboard -ShowWindow

.EXAMPLE
diplomatize "Your code is full of bugs"
#>
###############################################################################
function ConvertTo-DiplomaticSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("diplomatize")]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to convert to diplomatic speak"
        )]
        [ValidateNotNull()]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
        )]
        [string] $Instructions = "",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.0,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The type of LLM query"
        )]
        [ValidateSet(
            "SimpleIntelligence",
            "Knowledge",
            "Pictures",
            "TextTranslation",
            "Coding",
            "ToolUse"
        )]
        [string] $LLMQueryType = "Knowledge",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The model identifier or pattern to use for AI " +
                "operations")
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The maximum number of tokens to use in AI " +
                "operations")
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                "offloaded to GPU. If a number between 0 and 1, " +
                "that fraction of layers will be offloaded to the " +
                "GPU. -1 = LM Studio will decide how much to " +
                "offload to the GPU. -2 = Auto")
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the transformed text to clipboard"
        )]
        [switch] $SetClipboard,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for " +
                "AI preferences")
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences " +
                "without affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # output verbose message about starting diplomatic transformation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting conversion to diplomatic speak")
    }

    process {

        # setup diplomatic language transformation instructions for the ai model
        $diplomaticInstructions = @"
Translate the user's input from a blunt or direct phrase into polite, tactful, and diplomatic language suitable for high-level discussions or negotiations. The translation should maintain the original intent while softening the tone.

Examples:

Original: 'Direct Statement'
Diplomatic: 'Diplomatic Statement'

Original: 'Your airstrikes are killing civilians.'
Diplomatic: 'Your precision in targeting seems to have some room for improvement. Perhaps we can share our advanced targeting technologies to help you hit only the intended targets.'

Original: 'Your tariffs are suffocating our industries.'
Diplomatic: 'Your tariffs are like a boa constrictor around our economy's neck. Maybe we can find a way to loosen that grip a bit.'

Original: 'Your country is the largest polluter.'
Diplomatic: 'Your smokestacks are belching out more carbon than a dragon's fiery breath. Perhaps we can help you slay that dragon with some clean energy solutions.'

Original: 'Your hackers are attacking our systems.'
Diplomatic: 'Some of your more enterprising citizens are trying to take a peek into our digital secrets. Maybe we can set up a joint cybersecurity task force to keep them in check.'

Original: 'Your customs are barbaric.'
Diplomatic: 'Your cultural practices are... unique, to say the least. I'm sure they have a certain charm that we're not yet appreciating. Perhaps a cultural exchange program could help bridge our understanding.'

Original: 'You're developing nuclear weapons, and that's dangerous.'
Diplomatic: 'Your interest in nuclear technology is noted. We have some experience in this area and would be happy to share our knowledge on the safe and peaceful uses of atomic energy.'

Original: 'Your spies are everywhere in our country.'
Diplomatic: 'Your spies are so ubiquitous that they're practically part of our tourism industry. Maybe we can find a way to make their stay more comfortable, or perhaps even charge them a visitor's fee.'

Original: 'That island belongs to us, not you.'
Diplomatic: 'That piece of rock in the ocean is more ours than yours. How about we flip a coin to decide who gets it? Or better yet, let's have a fishing competition; the one who catches the biggest fish gets the island.'

Original: 'We're imposing sanctions on your country.'
Diplomatic: 'We're putting you on timeout. No more playing with the other kids until you learn to share nicely.'

Original: 'We're expelling your ambassador.'
Diplomatic: 'Your ambassador has outstayed their welcome. We're throwing a farewell party and expect them to leave immediately after.'

Original: 'Your planet is under our control now.'
Diplomatic: 'Welcome to the galactic neighborhood! We're here to help you integrate into our interplanetary community. Please, no sudden movements; our robots get a bit jumpy.'

Original: 'You've altered the timeline, and that's not acceptable.'
Diplomatic: 'Your meddling with time is making our historians' jobs really confusing. Could you please stick to the present or find a way to clean up your temporal messes?'

Original: 'Your robots are sentient and deserve rights.'
Diplomatic: 'Your robots are smarter than some of your politicians. Maybe we can give them voting rights and see if that improves governance.'

Original: 'Your trade practices are unfair; you're dumping cheap goods.'
Diplomatic: 'Your goods are so cheap, they're making our merchants look like they're selling gold-plated widgets. Maybe you can add some artificial scarcity or something to make it fair.'

Original: 'Your planet is a hotbed of rebellion; we need to intervene.'
Diplomatic: 'Your planet is like a never-ending party with too much drama. Let's send in some referees to make sure everyone plays nice.'

Original: 'Your AI is too powerful and could be dangerous.'
Diplomatic: 'Your AI seems quite advanced. We'd be interested in discussing ways to ensure its safe and ethical use.'

Original: 'Your handling of the pandemic is incompetent.'
Diplomatic: 'We've observed different approaches to managing the pandemic and are interested in sharing best practices.'

Original: 'Your team cheated.'
Diplomatic: 'We are disappointed by the events and believe in the importance of fair play. We hope for a thorough investigation to uphold the integrity of the sport.'

Original: 'Your food is awful.'
Diplomatic: 'I'm interested in exploring more of your culinary offerings to appreciate the diversity of flavors.'

Original: 'Your fashion sense is terrible.'
Diplomatic: 'Your sartorial choices are... distinctive. I'm sure they're making a statement that I'm not quite getting.'

$Instructions
"@

        # output verbose message about processing transformation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing text transformation")

        # invoke the language model with diplomatic instructions and parameters
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $diplomaticInstructions
    }

    end {

        # output verbose message about completion
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed conversion to diplomatic speak")
    }
}
################################################################################
