Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$DataPath = "./mods.json"
$SteamCmdPath = "./steamcmd/steamcmd.exe"

if (-not (Test-Path $DataPath)) {
  New-Item -ItemType File -Path $DataPath -Force
}

if (-not (Test-Path $SteamCmdPath)) {
  try {
    Invoke-WebRequest `
      -Uri "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip" `
      -OutFile "./steamcmd.zip"
    Expand-Archive -Path "./steamcmd.zip" -DestinationPath "./steamcmd" -Force
    Remove-Item -Path "./steamcmd.zip"
  }
  catch {
    exit
  }
}

. "$PSScriptRoot\modules\Add-Mod.ps1"
. "$PSScriptRoot\modules\Install-Mod.ps1"
. "$PSScriptRoot\modules\Remove-Mod.ps1"
. "$PSScriptRoot\modules\Set-ModsList.ps1"
. "$PSScriptRoot\modules\Set-ModDetails.ps1"
. "$PSScriptRoot\modules\Update-ModsDetails.ps1"

$form = New-Object System.Windows.Forms.Form
$form.Text = "Workshop Mod Manager"
$form.Size = New-Object System.Drawing.Size(500, 340)

$modListView = New-Object System.Windows.Forms.ListView
$modListView.Location = New-Object System.Drawing.Point(20, 60)
$modListView.Size = New-Object System.Drawing.Size(260, 220)
$modListView.View = [System.Windows.Forms.View]::Details
$modListView.Columns.Add("ID", 50) | Out-Null
$modListView.Columns.Add("Title", 100) | Out-Null
$modListView.Columns.Add("Updated", 100) | Out-Null
$form.Controls.Add($modListView)

$textBoxModId = New-Object System.Windows.Forms.TextBox
$textBoxModId.Location = New-Object System.Drawing.Point(20, 20)
$textBoxModId.Size = New-Object System.Drawing.Size(260, 20)
$textBoxModId.Text = "Enter Mod ID"
$textBoxModId.ForeColor = [System.Drawing.Color]::Gray
$textBoxModId.Add_Enter({
    if ($this.Text -eq "Enter Mod ID") {
      $this.Text = ""
      $this.ForeColor = [System.Drawing.Color]::Black
    }
  })
$textBoxModId.Add_Leave({
    if ($this.Text -eq "") {
      $this.Text = "Enter Mod ID"
      $this.ForeColor = [System.Drawing.Color]::Gray
    }
  })
$form.Controls.Add($textBoxModId)

$buttonSubmit = New-Object System.Windows.Forms.Button
$buttonSubmit.Location = New-Object System.Drawing.Point(310, 20)
$buttonSubmit.Size = New-Object System.Drawing.Size(150, 20)
$buttonSubmit.Text = "Add"
$form.Controls.Add($buttonSubmit)
$buttonSubmit.Add_Click({
    Add-Mod -modId $textBoxModId.Text
    Set-ModsList -modListView $modListView
  })

$buttonUpdate = New-Object System.Windows.Forms.Button
$buttonUpdate.Location = New-Object System.Drawing.Point(310, 230)
$buttonUpdate.Size = New-Object System.Drawing.Size(150, 20)
$buttonUpdate.Text = "Install"
$form.Controls.Add($buttonUpdate)
$buttonUpdate.Add_Click({
    Install-Mod -id $modListView.SelectedItems[0].Text
    Set-ModsList -modListView $modListView
})

$buttonDelete = New-Object System.Windows.Forms.Button
$buttonDelete.Location = New-Object System.Drawing.Point(310, 260)
$buttonDelete.Size = New-Object System.Drawing.Size(150, 20)
$buttonDelete.Text = "Delete"
$form.Controls.Add($buttonDelete)
$buttonDelete.Add_Click({
    Remove-Mod -id $modListView.SelectedItems[0].Text
    Set-ModsList -modListView $modListView
  })

$pictureBox = New-Object System.Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Point(310, 60)
$pictureBox.Size = New-Object System.Drawing.Size(150, 150)
$pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
$bitmap = New-Object System.Drawing.Bitmap(150, 150)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
$font = New-Object System.Drawing.Font("Arial", 16)
$graphics.DrawString("Mod Image", $font, $brush, 0, 0)
$graphics.Dispose()
$pictureBox.Image = $bitmap
$form.Controls.Add($pictureBox)

$modListView.add_SelectedIndexChanged({
    Set-ModDetails -pictureBox $pictureBox -id $modListView.SelectedItems[0].Text
  })

# On form load
Update-ModsDetails
Set-ModsList -modListView $modListView

[void]$form.ShowDialog()