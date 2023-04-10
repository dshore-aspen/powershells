try {
Set-NetAdapterAdvancedProperty -DisplayName "Energy-Efficient Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
Set-NetAdapterAdvancedProperty -DisplayName "Green Ethernet" -DisplayValue "Disabled" -ErrorAction SilentlyContinue
Set-NetAdapterAdvancedProperty -DisplayName "Idle Power Saving" -DisplayValue "Disabled" -ErrorAction Stop
Write-Output "Configuration worked"
exit 0
} catch {
Write-Output "Configuration failed"
exit 1
}
