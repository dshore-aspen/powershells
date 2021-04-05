## Get a list of the existing user folders, including the new Azure users
$userFolders=@(Get-ChildItem -Path C:\Users -Directory -Exclude itsadmin, Public)

## Get the folders to display that don't include the Azure users
$listUserFolders= @($userFolders - Exclude *ASPEN_INST)

## Ask the user for their old account folder and report back the selection
## Reports a directory object
$oldUser= @($listUserFolders) | Out-GridView -OutputMode Single -Title "Please select a user and click OK" 
Write-Output "User selected: "$oldUser

## Get the currently logged in user account
$currentUserAct= $(Get-WMIObject -class Win32_ComputerSystem | select username).username
Write-Output "Current User Account: " $currentUserAct

## Get just name of the current users home directory
$currentUser= $($currentUserAct -split '\\')[1] + ".ASPEN_INST"
Write-Output "Current user directory name: "$currentUser

## Pull the destination user folder from the $userFolders list
$newUser= $($userFolders.Where({$_.Name -eq $currentUser}))
Write-Output "New User: " $newUser

## Set the destination where the user files will go
$Destination= Join-Path -Path C:\Users\ -ChildPath $newUser.Name
$MovedFolder= $Destination + '\' + $oldUser.Name
$rule=new-object System.Security.AccessControl.FileSystemAccessRule ($currentUserAct,"FullControl",'ContainerInherit, ObjectInherit', 'InheritOnly',"Allow")

Write-Output "Destination: " $Destination
Write-Output "Moved Folder: " $MovedFolder

Move-Item $oldUser -Destination $Destination
$acl= Get-Acl $MovedFolder
$acl.SetAccessRule($rule)
Set-ACL -Path $MovedFolder -AclObject $acl