# This script is designed to check if the energy efficiency related settings are enabled on a PC.
# First it checks for a RegEdit entry used to determine if the script has run.
# Then it check if the settings are available to manipulate.
# Then it updates the settings and updates RegEdit so the next time it runs it can quickly cancel out and delete itself.

# Variables for the RegItem check
$RegistryPath = 'HKCU:\Environment\GreenEthernetStatus\'
$Name = 'Status'
$Value = '0'


# Variables for the Script Schedule
$ScriptLocation = $MyInvocation.MyCommand.Path
$action = New-ScheduledTaskAction -Execute 'powershell.exe' -argument $ScriptLocation 
$trigger = New-ScheduledTaskTrigger -AtLogOn
$schedulSettings = New-ScheduledTaskSettingsSet -RestartCount 6 -RestartInterval (New-TimeSpan -Minutes 15) -ExecutionTimeLimit (New-TimeSpan -Seconds 30) # -DeleteExpiredTaskAfter (New-TimeSpan -Days 30)
$ST = New-ScheduledTask -Action $action -Trigger $trigger -Settings $schedulSettings
Register-ScheduledTask UpdateGreenEthernet01 -InputObject $ST -ErrorAction SilentlyContinue


# Variables for the actual settings
$AdapterList = "Energy-Efficient Ethernet","Green Ethernet","Idle Power Saving"
$AdapterTest = Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" }


# Check if the RegItem is already present. If yes=exit and delete schedule, if no=continue
If ( (Test-Path $RegistryPath)) {
    Write-Output "RegItem found. Configuration already complete. Disabling script scheduler."
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Remove-Item $ScriptLocation
    exit 0
} 

Write-Output "RegItem not found. Checking configs."

# Check if any of the adapter settings are enabled.
if  ($AdapterTest)
{
    Write-Output "At least one setting not configured, updating now"
    Set-NetAdapterAdvancedProperty -DisplayName $AdapterList -DisplayValue "Disabled" -ErrorAction SilentlyContinue
    if ((Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" })::IsNullOrEmpty){
        Write-Output "Setting update did not work. Exiting script with error and will try again next time."
        exit 1
    }
}


Write-Output "Configs in place. Disabling script schedule and updating RegItem."

# All checks passed, writing the RegItem. If that succeeds, deleting script schedule.
try {
    New-Item -Path $RegistryPath
    New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD
    Write-Output "Registry path entry updated. Disabling script schedule."           
    Unregister-ScheduledTask -TaskName UpdateGreenEthernet01 -Confirm:$false
    Remove-Item $ScriptLocation
    exit 0

} catch {

# Unable to create the RegItem, leaving schedule intact.
    Write-Output "Registry path entry update failed. Leaving script schedule intact. Exiting with error."
    exit 1
}
