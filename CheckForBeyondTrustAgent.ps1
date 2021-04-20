try {
    $btAgent = Get-Process -Name bomgar-scc -ErrorAction Stop
}
catch {
    exit 0
}

if (Get-Process -Name bomgar-scc)
{
    Write-Output "Found"
    exit 0
}