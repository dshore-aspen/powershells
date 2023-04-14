# This script is designed to check if the energy efficiency related settings are enabled on a PC.
# First it checks for a RegEdit entry used to determine if the script has run.
# Then it check if the settings are available to manipulate.
# Then it updates the settings and updates RegEdit so the next time it runs it can quickly cancel out.

$RegistryPath = 'HKCU:\Environment\GreenEthernetStatus\'
$Name = 'Status'
$Value = '0'

$AdapterList = "Energy-Efficient Ethernet","Green Ethernet","Idle Power Saving"
$AdapterTest = Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" }



If ( -NOT (Test-Path $RegistryPath)) {
    Write-Output "RegItem not found. Doing config."
    if  ( $AdapterTest::IsNullOrEmpty)
    {
        Write-Output "Configs already in place. Exiting script"
        break
        exit 0
    } else {
        Write-Output "At least one setting not configured, updating now"
        Set-NetAdapterAdvancedProperty -DisplayName $AdapterList -DisplayValue "Disabled" -ErrorAction SilentlyContinue
        if ((Get-NetAdapterAdvancedProperty -DisplayName $AdapterList | Where-Object -FilterScript { $_.DisplayValue -eq "Enabled" })::IsNullOrEmpty){
            Write-Output "Setting update did not work. Exiting script with error"
            break
            exit 1
            } else {
            Write-Output "Settings have been updated. Updating Registry."
            try {
                New-Item -Path $RegistryPath
                New-ItemProperty -Path $RegistryPath -Name $Name -Value $Value -PropertyType DWORD
                Write-Output "Registry path entry updated. Exiting."
                break
                exit 0
                } catch {
                Write-Output "Registry path entry update failed. Exiting with error."
                break
                exit 1
                }

            }

    }
 
} else {
    Write-Output "RegItem found. Configuration already complete. Self destructing to prevent future runs."
    break
    exit 0
}