# This script is designed to check if the energy efficiency related settings are enabled on a PC.
# First it checks for a RegEdit entry used to determine if the script has run.
# Then it check if the settings are available to manipulate.
# Then it updates the settings and updates RegEdit so the next time it runs it can quickly cancel out and delete itself.

# Variables for the RegItem check
$RegistryPath = 'HKCU:\Environment\GreenEthernetStatus\'
$Name = 'Status'
$Value = '0'

# Setup event logging
if ( !(Get-EventLog -LogName Application -Source "GreenEthernetScript") ){
    New-EventLog -LogName Application -Source "GreenEthernetScript"
    Write-EventLog -LogName Application -Source "GreenEthernetScript" -EntryType Information -EventId 1 -Message "Log source created"
    Write-Output "Log source created"
} else {
    Write-Output "Log source already existed"
}

 

# Copy the script to C: for the TaskScheduler and easy access
$ScriptLocation = $MyInvocation.MyCommand.Path
New-Item -Path "C:\GreenEthernetScript" -ItemType Directory
Copy-Item -Path $ScriptLocation -Destination "C:\GreenEthernetScript\GreenEthernetScript.ps1"
$ScriptLocation = "C:\GreenEthernetScript\"

If ( $ScriptLocation -eq "C:\GreenEthernetScript\") {
Write-Output "Script copied successfully"
Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Script copied successfully"
} else {
Write-Output "Script was not copied successfully"
Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Script was not copied successfully"
}


$action = New-ScheduledTaskAction -Execute 'powershell.exe' -argument $ScriptLocation 
$trigger = New-ScheduledTaskTrigger -AtLogOn
$schedulSettings = New-ScheduledTaskSettingsSet -RestartCount 6 -RestartInterval (New-TimeSpan -Minutes 15) -ExecutionTimeLimit (New-TimeSpan -Seconds 30) # -DeleteExpiredTaskAfter (New-TimeSpan -Days 30)
$ST = New-ScheduledTask -Action $action -Trigger $trigger -Settings $schedulSettings
Register-ScheduledTask UpdateGreenEthernet01 -InputObject $ST -ErrorAction SilentlyContinue

If ( Get-ScheduledTask -TaskName UpdateGreenEthernet01 ) {
Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Task scheduled successfully"
}

# Variables for the actual settings
$AdapterList = "Energy-Efficient Ethernet","Green Ethernet","Idle Power Saving"
$AdapterTest = Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" }


# Check if the RegItem is already present. If yes=exit and delete schedule, if no=continue
If ( (Test-Path $RegistryPath)) {
    Write-Output "RegItem found. Configuration already complete. Disabling script scheduler."
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "RegItem found. Configuration already complete. Disabling script scheduler."
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Get-ChildItem $ScriptLocation -Recurse | Remove-Item
    Remove-Item $ScriptLocation
    exit 0
} 

Write-Output "RegItem not found. Checking configs."

# Check if any of the adapter settings are enabled.
if  ($AdapterTest)
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
# All checks passed, writing the RegItem. If that succeeds, deleting script schedule.
try {
    New-Item -Path $RegistryPath
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD
    Write-Output "Registry path entry updated. Disabling script schedule." 
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Registry path entry updated. Disabling script schedule."           
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Get-ChildItem $ScriptLocation -Recurse | Remove-Item
    Remove-Item $ScriptLocation
    exit 0

} catch {

# Unable to create the RegItem, leaving schedule intact.
    Write-Output "Registry path entry update failed. Leaving script schedule intact. Exiting with error."
    Write-EventLog -LogName "Application" -Source "GreenEthernetScript" -EventID 1 -EntryType Information -Message "Registry path entry update failed. Leaving script schedule intact. Exiting with error." 
    exit 1
}

Remove-Item $MyInvocation.MyCommand.Path