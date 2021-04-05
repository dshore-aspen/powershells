$currentUser = $((Get-WMIObject -class Win32_ComputerSystem | select username).username)
$currentUser = $currentUser.Split("\")[1]
Add-LocalGroupMember -Member $currentUser -Name Administrators
Start-Sleep -Seconds 600
Remove-LocalGroupMember -Member $currentUser -Name Administrators