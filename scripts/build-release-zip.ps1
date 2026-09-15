<#
Builds casing_mode_plus.zip at the repo root, containing a single
casing_mode_plus/ folder that users can drag straight into their mods
folder. Update checks use SuperBLT's "mws" provider against the
ModWorkshop mod page, so this zip is only the drag-and-drop package
(upload it to ModWorkshop manually). Used locally and by the release
workflow.
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
