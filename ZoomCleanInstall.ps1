$fileName = 'zoom.exe'
$searchFolder = 'C:\Program Files (x86)\Zoom\bin*'
$cleanerURL = 'https://support.zoom.us/attachments/token/JlnljyWEIOa4f6I2CBHfy20aV/?name=CleanZoom.exe'
$cleanerOUT = 'C:\Users\Public\Documents\CleanZoom.exe'
$installerURL = 'https://www.zoom.us/client/latest/ZoomInstallerFull.msi'
$installerOUT = 'C:\Users\Public\Documents\ZoomInstallerFull.msi'
Invoke-WebRequest -Uri $cleanerURL -OutFile $cleanerOUT
Invoke-WebRequest -Uri $installerURL -OutFile $installerOUT

if (Get-ChildItem -Path $searchFolder -Filter $fileName -Recurse)
{
    Write-Output "[CHECK]---Zoom present, uninstalling now"
    Start-Process -Wait -FilePath $cleanerOUT -Argument "/S" -PassThru
    sleep 20

    if (Get-ChildItem -Path 'C:\Program Files (x86)\*' -Filter $fileName -Recurse)
    {
        Write-Output "[CHECK]---Post uninstall, Zoom still present."
       exit 1
    } else {
        Write-Output "[CHECK]---Post uninstall, Zoom gone. Installing now."
    }
    msiexec /i $installerOUT /q
} else {
    Write-Output "[CHECK]---Zoom not installed yet. Running now."
    msiexec /i $installerOUT /q
}

sleep 20

if (Get-ChildItem -Path $searchFolder -Filter $fileName -Recurse)
{
    Write-Output "[SUCCESS]---Zoom present after the uninstall."
    Remove-Item -Path $cleanerOUT
    Remove-Item -Path $installerOUT
   exit 0
} else {
    Write-Output "[FAILURE]---Zoom did not install after the uninstall."
    Remove-Item -Path $cleanerOUT
    Remove-Item -Path $installerOUT
   exit 1
}
