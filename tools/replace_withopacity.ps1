$files = Get-ChildItem -Path . -Filter *.dart -Recurse
foreach ($f in $files) {
  $text = Get-Content -Raw $f.FullName
  $new = [System.Text.RegularExpressions.Regex]::Replace($text, '\.withOpacity\(\s*([0-9]*\.?[0-9]+)\s*\)', { param($m) '.withAlpha(' + ([math]::Round([double]$m.Groups[1].Value * 255)) + ')' })
  if ($new -ne $text) {
    Set-Content -Path $f.FullName -Value $new
    Write-Host "Updated: $($f.FullName)"
  }
}
Write-Host 'Done.'
