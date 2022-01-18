
$forticlientVersion=$(Get-WmiObject -Class Win32_Product | where vendor -eq "Fortinet Technologies Inc" | select Version)
IF ($forticlientVersion -match "6.4.6.1658"){
    Write-Host "Succeed - Version: "$forticlientVersion
    exit 0
    }else{
    exit 1
    }
