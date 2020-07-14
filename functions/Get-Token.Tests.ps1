$functionName = $MyInvocation.MyCommand.Name.Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"
Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
    Context "Happy Path" {
        BeforeAll {
            $goodResult = "{'access_token':'12345','token_type':'bearer','expires_in':'86399','created':'7/14/2020 6:52:51 AM'}"
            Mock -CommandName Import-Clixml -MockWith { return ( $goodResult | ConvertFrom-Json ) }
            $testResult = Test-Function
        }

        It "Reads the token file from disk" {
            Assert-MockCalled -CommandName Import-Clixml -Times 1 -Exactly -Scope Context -ParameterFilter { $Path -eq $wowprofTokenFile }
        }

        It "returns the expected object" {
            $goodToken = $goodResult | ConvertFrom-Json
            $testResult.access_token | Should -Be $goodToken.access_token
            $testResult.token_type | Should -Be $goodToken.token_type
            $testResult.expires_in | Should -Be $goodToken.expires_in
            $testResult.created | Should -Be $goodToken.created
        }
    }
}
