function Install-Mod {
  param (
    [Parameter(Mandatory = $true)]
    [string]$id
  )

  if ([string]::IsNullOrEmpty($id)) {
    return
  }

  $mods = Get-Content -Path $DataPath -Raw |
  ConvertFrom-Json
  $mods = @($mods)
  $appId = $mods |
  Where-Object { $_.publishedfileid -eq $id } |
  Select-Object -ExpandProperty creator_app_id

  if ([string]::IsNullOrEmpty($appId)) {
    return
  }

  $arg = "+login anonymous +workshop_download_item $appId $id +quit"
  Write-Host "Downloading mod $arg"

  $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
  $processStartInfo.FileName = $SteamCmdPath
  $processStartInfo.Arguments = $arg
  $processStartInfo.RedirectStandardOutput = $true
  $processStartInfo.UseShellExecute = $false

  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = $processStartInfo
  $process.Start() | Out-Null
  $output = $process.StandardOutput.ReadToEnd()
  $process.WaitForExit()

  if ($output -match "Success. Downloaded item $id") {
    $mods | Where-Object { $_.publishedfileid -eq $id } |
    ForEach-Object {
      $_.time_downloaded = ([DateTimeOffset]::Now.ToUnixTimeSeconds())
    }
    $mods | ConvertTo-Json -Depth 5 |
    Set-Content -Path $DataPath
    Write-Host "Download successful."
  }
  else {
    Write-Host "Download failed."
  }
}