
$forticlientVersion=$(Get-WmiObject -Class Win32_Product | where vendor -eq "Fortinet Technologies Inc" | select Version)
IF ($forticlientVersion -match "6.4.6.1658"){
    "Version: "$forticlientVersion ; return 0
    }else{
    return
    }