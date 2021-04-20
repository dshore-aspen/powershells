

## Get a list of the existing user folders, including the new Azure users
$userFolders=@(Get-ChildItem -Path C:\Users -Directory -Exclude itsadmin, Public)

## Get the currently logged in user account
$currentUserAct= $(Get-WMIObject -class Win32_ComputerSystem | select username).username
Write-Output "Current User Account: " $currentUserAct

## OLD USER ACCOUNT -- LOGIC
$oldUser= $($currentUserAct -split '\\')[1]
Write-Output "Old user account: " $oldUser

## OLD USER FOLDER -- LOGIC
$oldUserFolder= $($userFolders.Where({$_.Name -eq $oldUser}))
Write-Output "Old user folder: " $oldUserFolder


## Get just name of the current users home directory
$currentUser= $($currentUserAct -split '\\')[1] + ".ASPEN_INST"
Write-Output "Current user directory name: "$currentUser

## Pull the destination user folder from the $userFolders list
$currentUserFolder= $($userFolders.Where({$_.Name -eq $currentUser}))
Write-Output "Current user folder: " $currentUserFolder

## Set the destination where the user files will go
$Destination= Join-Path -Path C:\Users\ -ChildPath $currentUserFolder.Name
$MovedFolder= $Destination + '\' + $oldUser.Name
$rule=new-object System.Security.AccessControl.FileSystemAccessRule ($currentUserAct,"FullControl",'ContainerInherit, ObjectInherit', 'InheritOnly',"Allow")

Write-Output "Destination: " $Destination
Write-Output "Moved Folder: " $MovedFolder

Move-Item $oldUser -Destination $Destination
$acl= Get-Acl $MovedFolder
$acl.SetAccessRule($rule)
Set-ACL -Path $MovedFolder -AclObject $acl