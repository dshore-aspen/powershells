

$SMBv1State = {Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol | Select-Object -Property State}
Write-Information -MessageData $SMBV1State