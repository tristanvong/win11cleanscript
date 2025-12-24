Describe "Write-Log Functionality" {
    BeforeAll {
        # Dot-source the necessary functions
        $LogFunc = Join-Path $PSScriptRoot "..\src\Private\Write-Log.ps1"
        $ConfigFunc = Join-Path $PSScriptRoot "..\src\Private\Import-W11Config.ps1"
        
        if (Test-Path $LogFunc) { . $LogFunc } else { throw "Missing: $LogFunc" }
        if (Test-Path $ConfigFunc) { . $ConfigFunc } else { throw "Missing: $ConfigFunc" }

        # Setup temporary paths for testing
        $script:TestConfigPath = Join-Path $env:TEMP "test-log-settings.json"
        
        # Create a mock config
        $ConfigJson = @{
            Settings = @{ LogPath = "" }
        } | ConvertTo-Json
        $ConfigJson | Out-File $script:TestConfigPath -Force

        # Resolve the LogPath using Import function
        $Config = Import-W11Config -Path $script:TestConfigPath
        $script:TargetLogPath = $Config.Settings.LogPath

        # Start with no existing log file
        if (Test-Path $script:TargetLogPath) { Remove-Item $script:TargetLogPath -Force }
    }

    AfterAll {
        # Clean up all temporary files made for the test
        if (Test-Path $script:TestConfigPath) { Remove-Item $script:TestConfigPath -Force }
        if (Test-Path $script:TargetLogPath) { Remove-Item $script:TargetLogPath -Force }
    }

    It "Creates the log file at the path derived from configuration" {
        # The path should currently point to $env:TEMP\Win11Clean.log
        $script:TargetLogPath | Should -Match "Win11Clean.log"
        
        Write-Log -Message "Initializing Log Test" -Path $script:TargetLogPath
        
        Test-Path $script:TargetLogPath | Should -Be $true
    }

    It "Writes the message and level in the correct format" {
        $TestMessage = "Verification test message"
        $TestLevel = "WARN"
        
        Write-Log -Message $TestMessage -Path $script:TargetLogPath -Level $TestLevel
        
        $Content = Get-Content $script:TargetLogPath -Raw
        
        # Verify format: [YYYY-MM-DD HH:MM:SS] [LEVEL] Message
        $Content | Should -Match "\[$TestLevel\] $TestMessage"
    }

    It "Increases the file size after writing" {
        # Get initial size
        $InitialSize = (Get-Item $script:TargetLogPath).Length
        
        Write-Log -Message "Appending more data for size check" -Path $script:TargetLogPath
        
        # Get new size
        $NewSize = (Get-Item $script:TargetLogPath).Length
        
        $NewSize | Should -BeGreaterThan $InitialSize
    }

    It "Does not throw an error if the Path is empty or whitespace" {
        # The function should return silently if path is whitespace
        { Write-Log -Message "Silent fail test" -Path "   " } | Should -Not -Throw
    }

    It "Successfully logs using the default 'INFO' level" {
        $DefaultMsg = "Default level test"
        Write-Log -Message $DefaultMsg -Path $script:TargetLogPath
        
        $Content = Get-Content $script:TargetLogPath -Tail 1
        $Content | Should -Match "\[INFO\] $DefaultMsg"
    }
}