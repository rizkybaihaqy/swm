# Set the PictureBox with the selected mod's image
function Set-ModDetails {
  param (
    $id,
    [Parameter(Mandatory = $true)]
    [System.Windows.Forms.PictureBox]$pictureBox
  )

  if ([string]::IsNullOrEmpty($id)) {
    return
  }

  $mods = Get-Content -Path $DataPath -Raw | ConvertFrom-Json
  $mods = @($mods)
  $modDetails = $mods | Where-Object { $_.publishedfileid -eq $id }

  if ([string]::IsNullOrEmpty($modDetails.preview_url)) {
    return
  }

  $imageUrl = $modDetails.preview_url
  $webClient = New-Object System.Net.WebClient
  $imageData = $webClient.DownloadData($imageUrl)
  $memoryStream = [System.IO.MemoryStream]::new($imageData)
  $bitmap = [System.Drawing.Bitmap]::new($memoryStream)
  $pictureBox.Image = $bitmap
}
