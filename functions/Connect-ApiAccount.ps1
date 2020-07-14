function Connect-WowApiAccount {
    <#
        .SYNOPSIS
            Retrieves an access token from the Battle.Net API using provided or stored credentials
        .DESCRIPTION
            Uses the Battle.Net Oauth2 Client Credentials Flow to retrieve an access token using
            a set of credentials, either provided or stored during a previous attempt.
            
            If the Credential parameter is not provided a stored copy of a previously used credential
            will be loaded from disk.

        .PARAMETER Credential
            A client_id and client_secret for a registered Battle.Net API client.
        .Link
            https://develop.battle.net/documentation/guides/using-oauth/client-credentials-flow
    #>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline = $true)]
        [pscredential]$Credential
    )

    Begin {
        $ErrorActionPreference = "Stop"
        if ( -not $Credential ) {
            Write-Verbose "Attempting to load stored credential from $wowprofApiCred..."
            if ( Test-Path -Path $wowprofApiCred ) {
                $Credential = Import-Clixml -Path $wowprofApiCred
            }
            else {
                throw "No credential was supplied and no stored credential was found! Please try again with the Credential parameter!"
            }
        }

        $invokeParams = @{
            Credential     = $Credential
            Uri            = "https://us.battle.net/oauth/token"
            Body           = "grant_type=client_credentials"
            Method         = "Post"
            Authentication = "Basic"
        }

        $tokenDate = Get-Date
    }

    Process {
        $token = Invoke-RestMethod @invokeParams
    }

    End {
        if ( $Credential ) {
            #Store the credential
            $Credential | Export-Clixml -Path $wowprofApiCred -Force
        }

        # Export the token
        $token | Add-Member -MemberType NoteProperty -Name created -Value $tokenDate
        $token | Export-Clixml -Path $wowprofTokenFile -Force

        $token | Write-Output
    }
}
