$Logfile = "C:\Users\Public\Downloads\$(gc env:computername)-PrinterRemove-$(Get-Date -Format "dd.MM.yyyy").log"

Function LogWrite
{
   Param ([string]$logstring)
   $logstring = "$(Get-Date -Format "dd.MM.yyyy HH:mm:ss") -- $logstring"
   Add-content $Logfile -value $logstring
}

$printerList = "Aspen-Copiers-SecurePrint", "ASPEN-Copiers-SecurePrintNew", "ASPEN-Printers-SecurePrint", "DC_Printers", "DC_Copiers", "Aspen-Copiers-SecurePrint", "ASPEN-Printers-SecurePrintNew"

LogWrite "XXXXXXXXXXXXXXXXXXXX --- Printer check starting"

foreach ($printer in $printerList) {
    LogWrite "Checking for $printer"
    write-host $("HKCU:\Printers\Connections\,,dcuniflow,$printer")
    if (Test-Path $("HKCU:\Printers\Connections\,,dcuniflow,$printer")) {
        LogWrite "$printer present under \\dcuniflow. Removing now"
        Remove-Printer -Name "\\dcuniflow\$printer"
    } elseif (Test-Path $("HKCU:\Printers\Connections\,,dcuniflow.aspeninst.org,$printer")){
        LogWrite "XXX -- $printer present under \\dcuniflow.aspeninst.org. Removing now"
        Remove-Printer -Name "\\dcuniflow.aspeninst.org\$printer"
    } else {
        LogWrite "$printer not present."
    }
}

LogWrite "XXXXXXXXXXXXXXXXXXXX --- Printer check done"