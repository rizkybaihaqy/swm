# Set the ListView with the mods from the JSON file
function Set-ModsList {
  param (
    [Parameter(Mandatory = $true)]
    [System.Windows.Forms.ListView]$modListView
  )
  $modListView.Items.Clear()

  $mods = Get-Content -Path $DataPath -Raw | ConvertFrom-Json
  $mods = @($mods)

  foreach ($mod in $mods) {
    $item = New-Object System.Windows.Forms.ListViewItem($mod.publishedfileid)
    $updatedTime = [DateTimeOffset]::FromUnixTimeSeconds($mod.time_updated).DateTime
    $timeAgo = (Get-Date) - $updatedTime
    $readableTime = if ($mod.time_downloaded -lt $mod.time_updated) {
      "Update available"
    }
    elseif ($timeAgo.Days -gt 365) {
      "{0} years ago" -f [Math]::Floor($timeAgo.Days / 365)
    }
    elseif ($timeAgo.Days -gt 30) {
      "{0} months ago" -f [Math]::Floor($timeAgo.Days / 30)
    }
    else {
      "{0} days ago" -f $timeAgo.Days
    }

    [void]$item.SubItems.Add($mod.title)
    [void]$item.SubItems.Add($readableTime)
    [void]$modListView.Items.Add($item)
  }
}