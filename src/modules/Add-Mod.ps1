function Add-Mod {
  param (
    [Parameter(Mandatory = $true)]
    [string]$modId
  )

  if ([string]::IsNullOrEmpty($modId)) {
    return
  }

  try {
    $response = Invoke-RestMethod `
      -Uri 'https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/' `
      -Method 'POST' `
      -Headers @{"Content-Type" = "application/x-www-form-urlencoded" } `
      -Body "itemcount=1&publishedfileids%5B0%5D=$modId"
  }
  catch {
    return
  }

  if ($response.response.publishedfiledetails.Count -eq 0) {
    return
  }

  $mod = $response.response.publishedfiledetails[0]

  foreach ($property in @(
      'title',
      'time_updated',
      'publishedfileid',
      'preview_url'
    )) {
    if (-not $mod.PSObject.Properties.Name.Contains($property)) {
      return
    }
  }

  $mod | Add-Member -MemberType NoteProperty -Name "time_downloaded" `
    -Value ([DateTimeOffset]::Now.ToUnixTimeSeconds())

  $mods = Get-Content -Path $DataPath -Raw | ConvertFrom-Json
  $mods = @($mods)
  $mods += $mod
  $mods | ConvertTo-Json -Depth 5 | Set-Content -Path $DataPath
}