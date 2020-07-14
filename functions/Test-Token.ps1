function Test-Token {
    <#
        .SYNOPSIS
            Tests to see if the current token has expired
        .DESCRIPTION
            Adds the value of the expires_in property of the token to the the created property
            and compares it to the current date. If the computed value is later than the current
            date the functionr returns $false. If earlier, returns $true.
        .PARAMETER Token
            If the token is provided the stored token is not read from disk.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$Token
    )

    Begin {
        If ( -not $Token ) {
            $Token = Get-WowToken
        }
    }

    Process {
        if ( ([datetime]$Token.created).AddSeconds( $Token.expires_in ) -gt ( Get-Date ) ) {
            Write-Output $true
        }
        else {
            Write-Output $false
        }
    }
}
