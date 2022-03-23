$Logfile = "C:\Users\Public\Downloads\$(gc env:computername).log"

Function LogWrite
{
   Param ([string]$logstring)

   Add-content $Logfile -value $logstring
}

if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow,Aspen-Copiers-SecurePrint'){
Remove-Printer -Name "\\dcuniflow\Aspen-Copiers-SecurePrint"
LogWrite "removing1"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow,ASPEN-Copiers-SecurePrintNew'){
Remove-Printer -Name "\\dcuniflow\ASPEN-Copiers-SecurePrintNew"
LogWrite "removing2"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow,ASPEN-Printers-SecurePrint'){
Remove-Printer -Name "\\dcuniflow\ASPEN-Printers-SecurePrint"
LogWrite "removing3"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow,DC_Printers'){
Remove-Printer -Name "\\dcuniflow\DC_Printers"
LogWrite "removing4"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow,DC_Copiers'){
Remove-Printer -Name "\\dcuniflow\DC_Copiers"
LogWrite "removing5"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,Aspen-Copiers-SecurePrint'){
Remove-Printer -Name "\\dcuniflow.aspeninst.org\Aspen-Copiers-SecurePrint"
LogWrite "removing6"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,ASPEN-Copiers-SecurePrintNew'){
Remove-Printer -Name "\\dcuniflow.aspeninst.org\ASPEN-Copiers-SecurePrintNew"
LogWrite "removing7"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,ASPEN-Printers-SecurePrint'){
Remove-Printer -Name "\\dcuniflow.aspeninst.org\ASPEN-Printers-SecurePrint"
LogWrite "removing8"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,DC_Printers'){
Remove-Printer -Name "\\dcuniflow.aspeninst.org\DC_Printers"
LogWrite "removing9"
}
if(Test-Path 'HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,DC_Copiers'){
Remove-Printer -Name "\\dcuniflow.aspeninst.org\DC_Copiers"
LogWrite "removing10"
}
