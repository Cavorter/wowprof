$functionName = $MyInvocation.MyCommand.Name.Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"
Set-Alias -Name Test-Function -Value $functionName -Scope Script

function CommonAsserts {
    It "Calls Invoke-RestMethod" {
        $goodUri = "https://us.battle.net/oauth/token"
        $goodRequestBody = "grant_type=client_credentials"
        $goodMethod = "Post"
        $goodAuth = "Basic"
        Assert-MockCalled -Scope Context -CommandName Invoke-RestMethod -Times 1 -Exactly -ParameterFilter { $Uri -eq $goodUri -and $Body -eq $goodRequestBody -and $Method -eq $goodMethod -and $Authentication -eq $goodAuth -and $Credential.UserName -eq $testCred.UserName }
    }

    It "Stores the access token" {
        $tokenPath = Join-Path -Path $env:APPDATA -ChildPath wowprof -AdditionalChildPath token.xml
        Assert-MockCalled -Scope Context -CommandName Export-Clixml -Times 1 -Exactly -ParameterFilter { $Path -eq $tokenPath }
    }
}

Describe "$functionName" {
    # $token = Invoke-RestMethod -Credential $apiCreds -Uri https://us.battle.net/oauth/token -Body grant_type=client_credentials -Method Post -Authentication Basic
    $credPath = Join-Path -Path $env:APPDATA -ChildPath wowprof -AdditionalChildPath client.xml
    $testCred = New-Object -TypeName pscredential -ArgumentList 'someuser', ( 'somepwd' | ConvertTo-SecureString -Force -AsPlainText )
    $goodReturn = "{'access_token':'1235123125423','token_type':'bearer','expires_in':86399}"

    Mock -CommandName Export-Clixml -MockWith { return $true }
    Mock -CommandName Import-Clixml -MockWith { return $testCred }
    Mock -CommandName Invoke-RestMethod -MockWith { return ( $goodReturn | ConvertFrom-Json ) }
    Mock -CommandName Test-Path -MockWith { return $true } -ParameterFilter { $Path -eq $wowprofApiCred }

    Context "Credential" {
        BeforeAll {
            Test-Function -Credential $testCred | Out-Null
        }

        CommonAsserts

        It "Stores the credential" {
            Assert-MockCalled -CommandName Export-Clixml -Times 1 -Exactly -Scope Context -ParameterFilter { $Path -eq $credPath -and $Force }
        }
    }

    Context "No Credential" {
        BeforeAll {
            Test-Function | Out-Null
        }

        It "Loads a stored credential" {
            Assert-MockCalled -CommandName Import-Clixml -Times 1 -Exactly -Scope Context -ParameterFilter { $Path -eq $credPath }
        }

        CommonAsserts
    }
}
