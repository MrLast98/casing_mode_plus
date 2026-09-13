<#
Builds Casing_Mode.zip at the repo root from just the files SuperBLT actually
needs to load the mod (mirrors the "asdasd" reference layout: everything flat
at the zip root, no wrapping folder). Used locally and by the release workflow.
#>

$ErrorAction = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$zipPath = Join-Path $root "casing_mode_plus.zip"

$includes = @(
    "mod.txt",
    "mod.lua",
    "supermod.xml",
    "Thumbnail.png",
    "lua"
)

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

$staging = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid())
$modFolder = Join-Path $staging "casing_mode_plus"
New-Item -ItemType Directory -Path $modFolder | Out-Null

try {
    foreach ($item in $includes) {
        $src = Join-Path $root $item
        if (-not (Test-Path $src)) {
            throw "Missing expected file/folder: $item"
        }
        Copy-Item $src -Destination $modFolder -Recurse
    }

    Compress-Archive -Path $modFolder -DestinationPath $zipPath -CompressionLevel Optimal
}
finally {
    Remove-Item $staging -Recurse -Force
}

Write-Host "Built $zipPath"
