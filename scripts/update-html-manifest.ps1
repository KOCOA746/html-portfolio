$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..")
$manifestPath = Join-Path $root "html-manifest.json"
$rootUri = New-Object System.Uri (($root.Path.TrimEnd("\", "/") + [System.IO.Path]::DirectorySeparatorChar))

$pages = @(Get-ChildItem -Path $root -Recurse -File -Include "*.html", "*.htm" |
  Where-Object {
    $_.FullName -notmatch "[\\/]\.git[\\/]" -and
    $_.FullName -notmatch "[\\/]node_modules[\\/]" -and
    $_.Name -notmatch "^index\.html?$"
  } |
  Sort-Object FullName |
  ForEach-Object {
    $fileUri = New-Object System.Uri $_.FullName
    $relative = [System.Uri]::UnescapeDataString($rootUri.MakeRelativeUri($fileUri).ToString())
    $title = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) -replace "[-_]+", " "
    [pscustomobject]@{
      title = (Get-Culture).TextInfo.ToTitleCase($title)
      path = $relative
    }
  })

$manifest = [pscustomobject]@{
  generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
  pages = @($pages)
}

$manifest | ConvertTo-Json -Depth 5 | Set-Content -Path $manifestPath -Encoding utf8
Write-Host "Updated $manifestPath with $($pages.Count) HTML page(s)."
