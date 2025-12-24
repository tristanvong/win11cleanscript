BeforeAll {
    # Dot-source the private function file
    . "$PSScriptRoot\..\src\Private\Test-IsWindows11.ps1"
}

Describe "Test-IsWindows11" {

    # 1. SUCCESS: Windows 11
    It "Returns $true if Build >= 22000 and Caption contains 'Windows'" {
        $MockCim = [PSCustomObject]@{
            Caption     = "Microsoft Windows 11 Pro"
            BuildNumber = "22000"
        }
        Mock Get-CimInstance { return $MockCim }

        Test-IsWindows11 | Should -Be $true
    }

    # 2. FAIL: Old Windows
    It "Returns $false if Build < 22000 even if Caption is 'Windows'" {
        $MockCim = [PSCustomObject]@{
            Caption     = "Microsoft Windows 10 Enterprise"
            BuildNumber = "19045"
        }
        Mock Get-CimInstance { return $MockCim }

        Test-IsWindows11 | Should -Be $false
    }

    # 3. FAIL: High build, wrong OS
    It "Returns $false if Build >= 22000 but Caption is NOT 'Windows'" {
        $MockCim = [PSCustomObject]@{
            Caption     = "Ubuntu Linux"
            BuildNumber = "22000"
        }
        Mock Get-CimInstance { return $MockCim }

        Test-IsWindows11 | Should -Be $false
    }

    # 4. FAIL: Low build, wrong OS
    It "Returns $false if Build < 22000 and Caption is NOT 'Windows'" {
        $MockCim = [PSCustomObject]@{
            Caption     = "MacOS Monterey"
            BuildNumber = "12000"
        }
        Mock Get-CimInstance { return $MockCim }

        Test-IsWindows11 | Should -Be $false
    }
}