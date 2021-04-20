if (Get-Process -Name bomgar-scc)
{
    Write-Output "Found"
    exit 0
} else {
#    Write-Output "Missing"
    exit 0
}