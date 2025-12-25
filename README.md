# Win11Cleaner
Win11Cleaner is a professional, modular PowerShell automation tool designed to help users remove default Windows 11 applications and bloatware. It provides a structured, safe, and transparent way to manage system cleanliness by combining detection from both Microsoft Store (AppX) and WinGet package managers.

# How to use
## Prerequisites
* OS: Windows 11
* WinGet

# How it works
The tool follows a strict automated workflow managed by the [Invoke-Win11Clean](./src/Public/Invoke-Win11Clean.ps1) function:

* Environment Check: Runs [Test-IsWindows11](./src/Private/Test-IsWindows11.ps1)  to confirm operating system compatibility.
* Config Initialization: Imports settings.json and automatically resolves the log path to the user's %TEMP% directory if not explicitly defined.
* Discovery: Scans for all AppX and WinGet packages currently installed on the system.
* Filtering: Cross-references discovered apps against user-defined Blacklist, Whitelist, and Safeguard rules.
* Execution Policy:
    * If DryRun is false, it waits for 10 seconds so the user has time to stop the script.
    * No-Confirm Mode: If the `-NoConfirm` switch is used, Safeguard prompts ("are you sure you want to uninstall application X?") for critical apps are bypassed.
    * Iterates through targeted apps, applying provider-specific (AppX or WinGet) removal commands.

## Execute the script:
1. Customize your preferences in [settings.json](./config/settings.json).
2. Open a PowerShell terminal as Administrator.
3. Execute the wrapper script from the project root: 

```ps
# Standard execution (with prompts for critical apps)
./Run-Script.ps1
```

```ps
# Force execution (bypasses security prompts)
./Run-Script.ps1 -NoConfirm
```

# Configuration guide
The [config/settings.json](./config/settings.json) file is the central control for the tool.

## Settings
> [!NOTE]  
> DryRun defaults to TRUE (safe mode). Set it to FALSE in [config/settings.json](./config/settings.json) to enable actual application removal.

* LogPath: Destination for the log file (leave empty if default temporary storage path is desired).
* DryRun: Set to true to test settings without deleting anything.
* Verbose: Set to true for detailed console output during the execution of the PowerShell tool.

## Application rules
* Whitelists (KeepApps): Apps here are never removed, even if they match a blacklist rule.
* Blacklists (RemoveApps): Strings that target apps for removal (example: "Google Chrome").
* Safeguards (CriticalApps): Apps that require a "Y" (yes confirmation) manual prompt even if blacklisted.