$s = (gwmi win32_bios).SerialNumber
$s = "WI$($s)"
$sLength = $s.Length
if ( $sLength -ge 15 ) {
    $s = $s.Substring(0,15)
    }
$s

Rename-Computer -NewName "$($s)" -DomainCredential aspeninst.org\dshore-hdadmin -Restart