# First collect the info we need from the computer
$serviceTag=$(Get-WmiObject win32_computersystemproduct).IdentifyingNumber
$userName=((Get-WMIObject -class Win32_ComputerSystem | Select-Object username).username).TrimStart("ASPEN_INST\")

if ((Get-NetAdapter -Name Ethernet* -Physical).MacAddress)
    {$ethernetMAC=(Get-NetAdapter -Name Ethernet* -Physical).MacAddress}
    else 
        {$ethernetMAC="No Ethernet MAC"}
        

$wifiMAC=(Get-NetAdapter -Name Wi-Fi -Physical).MacAddress
$osVersion="Windows v" + (Get-CimInstance Win32_OperatingSystem).Version
$manufacturer=(Get-WMIObject win32_computersystem).Manufacturer
$model=(Get-WMIObject win32_computersystem).Model
$computerName=$env:COMPUTERNAME
$processor=(Get-WmiObject Win32_Processor).Name


# Then create the API functions. This is really just to make typing the functions faster and easier to update when AssetPanda updates their APIs
Function API_CALL_V3
{
   Param ([string]$call, [string]$method, $body)
   $api = "https://api.assetpanda.com/v3/" + $call
   Invoke-RestMethod $api -Method $method -Headers $headers -Body $body
}

Function API_CALL_V2
{
   Param ([string]$call, [string]$method, $body)
   $api = "https://api.assetpanda.com:443/v2/" + $call
   Invoke-RestMethod $api -Method $method -Headers $headers -Body $body
}


# Now build the API header
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer [INSERT TOKEN HERE]")
$headers.Add("Content-Type", "application/json")

# First need to create the body for searching for the device
$bodySearch = "{
`n    `"field_filters`": {
`n        `"field_1`": `"$serviceTag`"
`n    }
`n}"


# Now send the call to AssetPanda to collect the unique ID for the asset you want to update and store that in $entity_object_id
$response = API_CALL_V3 '/groups/82676/search/objects' 'POST' $bodySearch
$entity_object_id=$response.objects.id


# Now store all that data in a JSON to push to AssetPanda in an action call that will update the asset
$bodyUpdate = $("{
        `"embedded_into_object_id`": `"`",
        `"action_fields`": {
          `"field_1`": `"$userName`",
          `"field_2`": `"$osVersion`",
          `"field_3`": `"$wifiMAC`",
          `"field_4`": `"$model`",
          `"field_5`": `"$ethernetMAC`",
          `"field_6`": `"$computerName`",
          `"field_7`": `"$processor`",
          `"field_8`": `"$manufacturer`"
        }
}")

$apiCall = "https://api.assetpanda.com:443/v2/entity_objects/" + $entity_object_id + "/action_objects/267839"


# Here's the call to update the asset
Invoke-WebRequest $apiCall -Method POST -Headers $headers -Body $bodyUpdate

#  For reporting purposes, spit out all the data collected here:

Write-Host "The following lines are an output of the data collected and shared with AssetPanda."
Write-Host "----"
$userName
$osVersion
$wifiMAC
$model
$ethernetMAC
$computerName
$processor
$manufacturer