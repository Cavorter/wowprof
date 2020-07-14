$functionName = $MyInvocation.MyCommand.Name.Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"
Set-Alias -Name Test-Function -Value $functionName -Scope Script

function GetTestToken {
    Param(
        [switch]$Expired
    )

    $baseDate = ( Get-Date ).AddMinutes( -1 )
    if ( $Expired ) {
        $baseDate = $baseDate.AddHours(-25)
    }
    $tokenJson = "{'access_token':'12345','token_type':'bearer','expires_in':'86399','created':'$baseDate'}"

    $tokenJson | ConvertFrom-Json | Write-Output
}

Describe "$functionName" {
    $testCases = @(
        @{ caseSubject = "Valid"; caseObject = "Parameter"; tokenParam = @{}; assertTimes = 0 },
        @{ caseSubject = "Expired"; caseObject = "Parameter"; tokenParam = @{ Expired = [switch]$true }; assertTimes = 0 },
        @{ caseSubject = "Valid"; caseObject = "Pipeline"; tokenParam = @{}; assertTimes = 1 },
        @{ caseSubject = "Expired"; caseObject = "Pipeline"; tokenParam = @{Expired = [switch]$true }; assertTimes = 1 }
    )

    It "<caseSubject> Token From <caseObject>" -TestCases $testCases {
        Param( $caseSubject, $caseObject, $tokenParam, $assertTimes )
        $goodToken = GetTestToken @tokenParam
        Mock -CommandName Get-WowToken -MockWith { return $goodToken }
        $functionParam = @{}
        if ( $caseObject -eq "Parameter" ) { $functionParam.Token = $goodToken }
        $testResult = Test-Function @functionParam
        Assert-MockCalled -CommandName Get-WowToken -Scope It -Times $assertTimes -Exactly
        $testResult | Should -Be ( -not $tokenParam.Expired )
    }
}
