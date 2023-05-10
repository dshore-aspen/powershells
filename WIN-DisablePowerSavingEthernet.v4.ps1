# This script is designed to check if the energy efficiency related settings are enabled on a PC.
# First it checks for a RegEdit entry used to determine if the script has run.
# Then it check if the settings are available to manipulate.
# Then it updates the settings and updates RegEdit so the next time it runs it can quickly cancel out and delete itself.

# Variables for the RegItem check
$RegistryPath = 'HKCU:\Environment\GreenEthernetStatus\'
$Name = 'Status'
$Value = '0'


# Check if the RegItem is already set to 4 (complete). If yes=exit and delete schedule, if no=continue
If ( ( (Get-ItemProperty -Path $RegistryPath -Name -$Name -ErrorAction SilentlyContinue) -gt 3 )) {
    Write-Output "RegItem found. Configuration already complete. Disabling script scheduler."
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "RegItem found. Configuration already complete. Disabling script scheduler."
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Get-ChildItem $ScriptLocation -Recurse | Remove-Item
    Remove-Item $ScriptLocation
    exit 0
} 


# Create RegItem to begin tracking status of script. Any value reports successful to Intune.
try {
    # Create the RegItem
    New-Item -Path $RegistryPath -ErrorAction SilentlyContinue
} catch {}
try {
    # Create the Property.
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD -ErrorAction SilentlyContinue
} catch {
    # If it already exists, simply update it.
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value $Value
}

# Setup event logging
if ( !(Get-EventLog -LogName Application -Source "GreenEthernetScript") ){
    New-EventLog -LogName Application -Source "GreenEthernetScript"
    Write-EventLog -LogName Application -Source "GreenEthernetScript" -EntryType Information -EventId 1 -Message "Log source created"
    Write-Output "Log source created"
}

 

# Copy the script to C: for the TaskScheduler and easy access
$ScriptLocation = $MyInvocation.MyCommand.Path
Write-Output $ScriptLocation
Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Script location: $ScriptLocation"
New-Item -Path "C:\GreenEthernetScript" -ItemType Directory -ErrorAction SilentlyContinue
Copy-Item -Path $ScriptLocation -Destination "C:\GreenEthernetScript\GreenEthernetScript.ps1"
$ScriptLocation = "C:\GreenEthernetScript\"


# Check if the script is present
If ( Test-Path "C:\GreenEthernetScript\GreenEthernetScript.ps1" -PathType Any) {
    Write-Output "Script copied successfully"
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Script copied successfully"
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 1
} else {
    Write-Output "Script was not copied successfully"
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Script was not copied successfully"
}


# Add task to the scheduler
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -argument $ScriptLocation
$trigger = New-ScheduledTaskTrigger -AtLogOn
$schedulSettings = New-ScheduledTaskSettingsSet -RestartCount 6 -RestartInterval (New-TimeSpan -Minutes 15) -ExecutionTimeLimit (New-TimeSpan -Seconds 30)
$ST = New-ScheduledTask -Action $action -Trigger $trigger -Settings $schedulSettings
Register-ScheduledTask UpdateGreenEthernet01 -InputObject $ST -ErrorAction SilentlyContinue

If ( Get-ScheduledTask -TaskName UpdateGreenEthernet01 ) {
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Task scheduled successfully"
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 2
}


# Variables for the actual settings
$AdapterList = "Energy-Efficient Ethernet","Green Ethernet","Idle Power Saving"

# Check if the dock is plugged in. If yes=update settings. If no=exit with schedule in place.
if ( Get-NetAdapterAdvancedProperty -DisplayName $AdapterList ) {
    Write-Output "Dock plugged in"
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 3
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Dock plugged in, proceeding with checks."
} else {
    Write-Output "Dock not plugged in"
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 1
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Dock not plugged in, exiting script until next scheduled run."
    exit 0
}
break

try {
    $AdapterTest = Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" } -ErrorAction Stop
} catch {
    Write-Output "Computer not connected to dock. Exiting with scheduled task in place."
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Computer not connected to dock. Exiting with scheduled task in place."
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 3
    exit 0
}


# Check if any of the adapter settings are enabled.
if  (!$AdapterTest -eq "")
{
    Write-Output "At least one setting not configured, updating now"
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "At least one setting not configured, updating now"
    Set-NetAdapterAdvancedProperty -DisplayName $AdapterList -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    if ((Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" })::IsNullOrEmpty){
        Write-Output "Setting update did not work. Exiting script with error and will try again next time."
        Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Setting update did not work. Exiting script with error and will try again next time."
        exit 1
    }
}

Write-Output "Configs in place. Disabling script schedule and updating RegItem."
Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Configs in place. Disabling script schedule and updating RegItem."
Set-ItemProperty -Path $RegistryPath -Name $Name -Value 4


break


# All checks passed, writing the RegItem. If that succeeds, deleting script schedule.
try {
    New-Item -Path $RegistryPath
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD
    Write-Output "Registry path entry updated. Disabling script schedule." 
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Registry path entry updated. Disabling script schedule."           
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Get-ChildItem $ScriptLocation -Recurse | Remove-Item
    Remove-Item $ScriptLocation
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 4
    exit 0

} catch {

# Unable to create the RegItem, leaving schedule intact.
    Write-Output "Registry path entry update failed. Leaving script schedule intact. Exiting with error."
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Registry path entry update failed. Leaving script schedule intact. Exiting with error." 
    Set-ItemProperty -Path $RegistryPath -Name $Name -Value 2
    exit 1
}

Remove-Item $MyInvocation.MyCommand.Path