$mainScript = ".\src\Main.ps1"
$outputFile = ".\bin\swm.ps1"
$compiledFile = ".\bin\swm.exe"

Write-Host "Finding scripts to combine"
$scripts = (Get-Content $mainScript) -match '^\.\s' | ForEach-Object {
  $scriptPath = $_.TrimStart('. ').Trim('"').Replace('$PSScriptRoot', 'src')
  Write-Host "Found script: $scriptPath"
  $scriptPath
}

$scripts += $mainScript

if (Test-Path $outputFile) {
  Write-Host "Removing old output file"
  Remove-Item $outputFile
}

Write-Host "Combining scripts"
foreach ($script in $scripts) {
  Write-Host "Adding script: $script"
  Get-Content $script | Add-Content $outputFile
}

Write-Host "Removing dot sourcing lines"
(Get-Content $outputFile) |
Where-Object { $_ -notmatch '^\.\s' } |
Set-Content $outputFile

Write-Host "Compiling script"
& ps2exe -inputFile $outputFile -outputFile $compiledFile

Write-Host "Done"