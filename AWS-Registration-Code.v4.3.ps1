$user=$env:USERNAME
if (! (Test-Path -Path "C:\Program Files (x86)\Amazon Web Services, Inc\Amazon WorkSpaces\workspaces.exe") ) {
    Write-Host "[APP-CHECK] -- Application not found."
    exit
    }


if (! (Test-Path -Path "C:\Users\$user.aspen_inst\appdata\Local\Amazon Web Services\Amazon WorkSpaces\") ) {
    Write-Host "[CODE-CHECK] -- Registration file not present. Loading AWS to create registration file."
    Start-Process -WindowStyle Minimized -FilePath "C:\Program Files (x86)\Amazon Web Services, Inc\Amazon WorkSpaces\workspaces.exe"
    Start-Sleep -Seconds 10
    Stop-Process -Name workspaces -Force
    Write-Host "[CODE-CHECK] -- Workspaces has loaded and been closed."
    } else {
        if ( (Get-Content "C:\Users\$user.aspen_inst\appdata\Local\Amazon Web Services\Amazon WorkSpaces\RegistrationList.json" | %{$_ -like "[INSERT CODE HERE"} ) ) {
            Write-Host "[CODE-CHECK] -- Registration code already present."
            exit
        }
    }

cd "C:\Users\$user.aspen_inst\appdata\Local\Amazon Web Services\Amazon WorkSpaces\"
Set-Content ".\RegistrationList.json" '[{"registrationCode":"[INSERT CODE HERE"}]'
Write-Host "[POST-WRITE] -- Registration code added."

if ( Get-Content ".\RegistrationList.json"   ) {
    Write-Host "[POST-CHECK] -- Registration code now present."
    } else {
    Write-Error -Message "[POST-CHECK] -- Missing registration code still."
}


