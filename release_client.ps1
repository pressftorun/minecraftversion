param([string]$Root = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
$pack = Join-Path $Root 'pack'
$manifestPath = Join-Path $pack 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$files = Get-ChildItem -LiteralPath $pack -Recurse -File | Where-Object { $_.FullName -ne $manifestPath } | Sort-Object FullName
$hashes = [ordered]@{}
foreach ($file in $files) {
    if ($file.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Symlink not permitted: $($file.Name)" }
    $name = [IO.Path]::GetRelativePath($pack, $file.FullName).Replace('\', '/')
    $hashes[$name] = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
}
$manifest.files = $hashes
$manifest | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM
$output = Join-Path $Root 'release'
New-Item -ItemType Directory -Path $output -Force | Out-Null
$archive = Join-Path $output 'client.zip'
$stream = [IO.File]::Create($archive)
$zip = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in @($files) + @(Get-Item -LiteralPath $manifestPath)) {
        $name = [IO.Path]::GetRelativePath($pack, $file.FullName).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $name, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $zip.Dispose(); $stream.Dispose() }
$digest = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
"$digest  client.zip" | Set-Content -LiteralPath (Join-Path $output 'client.zip.sha256') -Encoding ascii
Get-Item -LiteralPath $archive | Select-Object FullName, Length
