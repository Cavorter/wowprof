function Get-Token {
    <#
        .SYNOPSIS
            Retrieves the current OAUTH token from disk
        .DESCRIPTION
            Reads the contents of the saved OAUTH token from disk and returns the object to the pipeline
    #>
    [CmdletBinding()]
    Param()
    Process {
        $return = Import-Clixml -Path $wowprofTokenFile
        $return | Write-Output
    }
}
