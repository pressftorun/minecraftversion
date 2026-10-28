$ErrorActionPreference = 'Stop'
$testRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ('release/package-test-' + [Guid]::NewGuid().ToString('N'))))
try {
    foreach ($directory in @('pack/mods', 'pack/optional-mods', 'pack/config/fancymenu')) {
        New-Item -ItemType Directory -Path (Join-Path $testRoot $directory) -Force | Out-Null
    }
    Set-Content -LiteralPath (Join-Path $testRoot 'pack/mods/required.jar') -Value 'required library'
    Set-Content -LiteralPath (Join-Path $testRoot 'pack/optional-mods/map.jar') -Value 'optional map'
    Set-Content -LiteralPath (Join-Path $testRoot 'pack/config/fancymenu/options.txt') -Value 'keep menu'
    Set-Content -LiteralPath (Join-Path $testRoot 'pack/manifest.json') -Value '{"name":"Test","minecraft":"1.21.1","loader":"21.1.264","files":{}}'
    & (Join-Path $PSScriptRoot 'release_client.ps1') -Root $testRoot | Out-Null
    $optionalPath = Join-Path $testRoot 'release/optional-mods.zip'
    if (!(Test-Path -LiteralPath $optionalPath)) { throw 'Optional refresh must have a separate small archive' }
    $archive = [IO.Compression.ZipFile]::OpenRead($optionalPath)
    try {
        $names = @($archive.Entries.FullName | Sort-Object)
        if (($names -join ',') -ne 'manifest.json,optional-mods/map.jar') { throw 'Optional archive includes unrelated files' }
        $reader = [IO.StreamReader]::new($archive.GetEntry('manifest.json').Open())
        try { $manifest = $reader.ReadToEnd() | ConvertFrom-Json } finally { $reader.Dispose() }
        $entries = @($manifest.files.PSObject.Properties)
        if ($entries.Count -ne 1 -or $entries[0].Name -ne 'optional-mods/map.jar') { throw 'Optional manifest must describe only included mods' }
        $expected = (Get-FileHash -LiteralPath (Join-Path $testRoot 'pack/optional-mods/map.jar') -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($entries[0].Value -ne $expected) { throw 'Optional mod hash mismatch' }
    } finally { $archive.Dispose() }
    foreach ($name in @('client.zip', 'optional-mods.zip')) {
        $path = Join-Path $testRoot "release/$name"
        $expected = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
        if ((Get-Content -LiteralPath "$path.sha256" -Raw).Trim() -ne "$expected  $name") { throw "Archive hash mismatch: $name" }
    }
    $full = [IO.Compression.ZipFile]::OpenRead((Join-Path $testRoot 'release/client.zip'))
    try {
        if (!$full.GetEntry('mods/required.jar') -or !$full.GetEntry('config/fancymenu/options.txt') -or !$full.GetEntry('optional-mods/map.jar')) {
            throw 'Full client archive lost required files or menu settings'
        }
    } finally { $full.Dispose() }
    Write-Output 'PASS: optional archive, filtered manifest, preserved full pack and SHA-256 checksums'
} finally {
    $releaseRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'release')) + [IO.Path]::DirectorySeparatorChar
    if (!$testRoot.StartsWith($releaseRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Unexpected cleanup path' }
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}
