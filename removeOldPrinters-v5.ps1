$Logfile = "C:\Users\Public\Downloads\$(gc env:computername)-PrinterRemove-$(Get-Date -Format "yyyy.MM.dd").log"

Function LogWrite
{
   Param ([string]$logstring)
   $logstring = "$(Get-Date -Format "yyyy.MM.dd HH:mm:ss") -- $logstring"
   Add-content $Logfile -value $logstring
}

$printerList = "Aspen-Copiers-SecurePrint", "ASPEN-Copiers-SecurePrintNew", "DC_Copiers", "ASPEN-Printers-SecurePrint", "ASPEN-Printers-SecurePrintNew", "DC_Printers"

LogWrite ""
LogWrite "XXXXXXXXXXXXXXXXXXXX --- Printer check starting --- XXXXXXXXXXXXXXXXXXXX"

foreach ($printer in $printerList) {
    LogWrite "Checking for $printer"
    write-host $("HKCU:\Printers\Connections\,,dcuniflow,$printer")
    if (Test-Path $("HKCU:\Printers\Connections\,,dcuniflow,$printer")) {
        LogWrite "$printer present under \\dcuniflow. Removing now"
        Remove-Printer -Name "\\dcuniflow\$printer"
    } else {
        LogWrite "$printer not present on \\dcuniflow."
    }
    
    if (Test-Path $("HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,$printer")){
        LogWrite "XXX -- $printer present under \\dcuniflow.aspeninst.org. Removing now"
        Remove-Printer -Name "\\dcuniflow.aspeninst.org\$printer"
    } else {
        LogWrite "$printer not present on \\dcuniflow.aspeninst.org"
    }
}

LogWrite "XXXXXXXXXXXXXXXXXXXX --- Printer check done --- XXXXXXXXXXXXXXXXXXXX"