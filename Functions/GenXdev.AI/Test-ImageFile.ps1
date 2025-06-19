function Test-ImageFile {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    $validExtensions = @('.png', '.jpg', '.jpeg', '.gif')
    if (-not (Microsoft.PowerShell.Management\Test-Path $Path)) {
        throw "Image file not found: $Path"
    }
    if ($validExtensions -notcontains [System.IO.Path]::GetExtension($Path).ToLower()) {
        throw "Invalid image format. Supported formats: png, jpg, jpeg, gif"
    }
}
