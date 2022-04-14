$serviceTag=$(Get-WmiObject win32_computersystemproduct).IdentifyingNumber
$userName=$env:USERNAME


Function API_CALL_V3
{
   Param ([string]$call, [string]$method)
   $api = "https://api.assetpanda.com/v3/" + $call
   Invoke-RestMethod $api -Method $method -Headers $headers -Body $body
}

Function API_CALL_V2
{
   Param ([string]$call, [string]$method)
   $api = "https://api.assetpanda.com:443/v2/" + $call
   Invoke-RestMethod $api -Method $method -Headers $headers -Body $body
}


$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", "Bearer [INSERT TOKEN HERE]")
$headers.Add("Content-Type", "application/json")
$apiV3_URI="https://api.assetpanda.com/v3"
$body = "{
`n    `"field_filters`": {
`n        `"field_1`": `"GLBT3Z2`"
`n    }
`n}"

$response = API_CALL_V3 '/groups/82676/search/objects' 'POST'
# $response = Invoke-RestMethod $apiV3_URI'/groups/82676/search/objects' -Method 'POST' -Headers $headers -Body $body # | ConvertTo-Json
$entity_object_id=$response.objects.id

$body = "{
        `"embedded_into_object_id`": `"`",
        `"action_fields`": {
          `"field_1`": "$userName"
        }
}"