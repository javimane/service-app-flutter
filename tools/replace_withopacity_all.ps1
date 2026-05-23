$files = Get-ChildItem -Path . -Filter *.dart -Recurse -ErrorAction SilentlyContinue
foreach ($f in $files) {
  $text = Get-Content -Raw $f.FullName
  $new = [System.Text.RegularExpressions.Regex]::Replace($text, '\.withOpacity\(\s*([^\)]+)\s*\)', { param($m) '.withAlpha((' + ([System.Text.RegularExpressions.Regex]::Unescape($m.Groups[1].Value)) + ' * 255).round())' })
  if ($new -ne $text) {
    Set-Content -Path $f.FullName -Value $new
    Write-Host "Updated: $($f.FullName)"
  }
}
Write-Host 'Done.'
