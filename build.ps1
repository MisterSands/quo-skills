# Regenerate dist/<skill>.zip from every folder in skills/.
# Run after editing any SKILL.md:  powershell -NoProfile -File build.ps1
#
# Uses .NET ZipArchive directly instead of Compress-Archive because
# Compress-Archive writes backslash path separators inside the zip,
# which claude.ai's skill uploader rejects ("path with invalid characters").
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = $PSScriptRoot
New-Item -ItemType Directory -Force -Path "$root/dist" | Out-Null

Get-ChildItem -Directory "$root/skills" | ForEach-Object {
    $skillDir = $_
    $zipPath = Join-Path "$root/dist" "$($skillDir.Name).zip"
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    $zip = [System.IO.Compression.ZipFile]::Open($zipPath, 'Create')
    try {
        Get-ChildItem -Recurse -File $skillDir.FullName | ForEach-Object {
            $rel = $_.FullName.Substring($skillDir.FullName.Length + 1).Replace('\', '/')
            $entry = "$($skillDir.Name)/$rel"
            [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $_.FullName, $entry) | Out-Null
        }
    }
    finally { $zip.Dispose() }
    Write-Host "built $zipPath"
}
