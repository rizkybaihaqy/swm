# Remove a mod from the JSON file
function Remove-Mod {
  param (
    [Parameter(Mandatory = $true)]
    [string]$id
  )

  if ([string]::IsNullOrEmpty($id)) {
    return
  }

  $mods = Get-Content -Path $DataPath -Raw | ConvertFrom-Json
  $mods = @($mods)
  $mods = $mods | Where-Object { $_.publishedfileid -ne $id }
  $mods | ConvertTo-Json -Depth 5 | Set-Content -Path $DataPath

  Set-ModsList -modListView $modListView
}