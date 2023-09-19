# This script is meant to make it easier to open and print multiple tickets from our Zendesk instance.
# For it to work, you must open a Zendesk session in Chrome first. (Specifically Chrome)
# Then fill in the $list variable as instructed. Then run the script.
# For each ticket number listed, a new tab will open in Chrome to the "print ticket" view in Zendesk.
# From there, simply click the save button and choose where you want to save the PDf.
# It will auto-name the file with the URL but you can insert whatever you want in the save window before saving.

# Import the Excel module if it's not already loaded
if (-not (Get-Module -Name ImportExcel -ListAvailable)) {
    Install-Module -Name ImportExcel -Force -Scope CurrentUser
}

# Load the ImportExcel module
Import-Module ImportExcel

# Define the path to your Excel file
$excelFilePath = "C:\Users\dshore\Downloads\2023-08.xlsx"

# Specify the name of the worksheet and the column header you want to read
$worksheetName = "Sales"  # Change to the actual worksheet name
$columnName = "TicketNumber"  # Change to the actual column header name

# Read the specific column from the Excel file
try {
    $list = Import-Excel -Path $excelFilePath -WorksheetName $worksheetName | Select-Object -ExpandProperty $columnName
} catch {
    Write-Host "Error: $_"
    exit 1
}

Write-Host "---"
Write-Host "Starting run now."

foreach ($r in $list) {
    Write-Host $r
    $url = "https://aspeninst.zendesk.com/tickets/$r/print"
    $pdfFileName = "$env:USERPROFILE\Downloads\$r.pdf"

    Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--remote-debugging-port=0", "--disable-gpu", "--use-system-default-printer", "--print-to-pdf=$pdfFileName", $url, "--kiosk-printing" -Wait
}
