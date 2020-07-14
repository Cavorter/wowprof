# Ensure data directory is present
$wowprofDataDir = Join-Path -Path $env:APPDATA -ChildPath wowprof
if ( -not (Test-Path -Path $wowprofDataDir) ) {
    New-Item -ItemType Directory -Path $wowprofDataDir -Force | Out-Null
}

$wowprofTokenFile = Join-Path -Path $wowprofDataDir -ChildPath "token.xml"
Write-Verbose "Token File: $wowprofTokenFile"

# Load all functions
$functions = Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -Exclude *.tests.*
foreach ( $item in $functions ) {
    . $item.FullName
}

# Retrieve current access token if there are stored credentials
$wowprofApiCred = Join-Path -Path $wowprofDataDir -ChildPath client.xml
if ( Test-Path -Path $wowprofApiCred ) {
    Connect-WowApiAccount
} else {
    Write-Warning "No stored API credentials found! Use Connect-WowApiAccount before attempting to use any commands in this module!"
}

Export-ModuleMember -Variable wowprofDataDir,wowprofApiCred,wowprofTokenFile