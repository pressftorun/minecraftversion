param([string]$Root = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
$pack = Join-Path $Root 'pack'
$manifestPath = Join-Path $pack 'manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
$files = Get-ChildItem -LiteralPath $pack -Recurse -File | Where-Object { $_.FullName -ne $manifestPath } | Sort-Object FullName
if ($files | Where-Object { $_.Directory.Name -eq 'mods' -and $_.Name -like 'neologin-*.jar' }) {
    throw 'NeoLogin is server-only: including it in the client blocks multiplayer interaction.'
}
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
$optionalFiles = @($files | Where-Object { [IO.Path]::GetRelativePath($pack, $_.FullName).Replace('\', '/').StartsWith('optional-mods/') })
$optionalHashes = [ordered]@{}
foreach ($file in $optionalFiles) {
    $name = [IO.Path]::GetRelativePath($pack, $file.FullName).Replace('\', '/')
    $optionalHashes[$name] = $hashes[$name]
}
$optionalManifest = [ordered]@{ name = $manifest.name; minecraft = $manifest.minecraft; loader = $manifest.loader; files = $optionalHashes }
$optionalArchive = Join-Path $output 'optional-mods.zip'
$stream = [IO.File]::Create($optionalArchive)
$zip = [IO.Compression.ZipArchive]::new($stream, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($file in $optionalFiles) {
        $name = [IO.Path]::GetRelativePath($pack, $file.FullName).Replace('\', '/')
        [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $name, [IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
    $writer = [IO.StreamWriter]::new($zip.CreateEntry('manifest.json').Open(), [Text.UTF8Encoding]::new($false))
    try { $writer.Write(($optionalManifest | ConvertTo-Json -Depth 20)) } finally { $writer.Dispose() }
} finally { $zip.Dispose(); $stream.Dispose() }
$digest = (Get-FileHash -LiteralPath $optionalArchive -Algorithm SHA256).Hash.ToLowerInvariant()
"$digest  optional-mods.zip" | Set-Content -LiteralPath (Join-Path $output 'optional-mods.zip.sha256') -Encoding ascii
Get-Item -LiteralPath $optionalArchive | Select-Object FullName, Length
