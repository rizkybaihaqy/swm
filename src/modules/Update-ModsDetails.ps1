# Update mods details from the Remote
function Update-ModsDetails {

  $mods = Get-Content -Path $DataPath -Raw | ConvertFrom-Json
  $mods = @($mods)

  if ($mods.Count -eq 0) {
    return
  }

  $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
  $headers.Add("Content-Type", "application/x-www-form-urlencoded")

  $body = "itemcount=" + $mods.Count
  for ($i = 0; $i -lt $mods.Count; $i++) {
    $body += "&publishedfileids%5B$i%5D=" + $mods[$i].publishedfileid
  }

  $response = Invoke-RestMethod 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/' -Method 'POST' -Headers $headers -Body $body
  $jsonResponse = $response | ConvertTo-Json -Depth 5 | ConvertFrom-Json

  $updatedMods = for ($i = 0; $i -lt $mods.Count; $i++) {
    $localMod = $mods[$i]
    $fetchedMod = $jsonResponse.response.publishedfiledetails[$i]

    $updatedMod = $fetchedMod | Add-Member -PassThru NoteProperty time_downloaded $localMod.time_downloaded

    $updatedMod
  }

  $updatedMods | ConvertTo-Json -Depth 5 | Set-Content -Path $DataPath
}