$Logfile = "C:\Users\Public\Downloads\$(gc env:computername)-Hello World-$(Get-Date -Format "dd.MM.yyyy").log"

Function LogWrite
{
   Param ([string]$logstring)
   $logstring = "$(Get-Date -Format "dd.MM.yyyy HH:mm:ss") -- $logstring"
   Add-content $Logfile -value $logstring
}

LogWrite "Hello world."