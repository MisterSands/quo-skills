# Regenerate dist/<skill>.zip from every folder in skills/.
# Run after editing any SKILL.md:  powershell -NoProfile -File build.ps1
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
New-Item -ItemType Directory -Force -Path "$root/dist" | Out-Null

Get-ChildItem -Directory "$root/skills" | ForEach-Object {
    $zip = "$root/dist/$($_.Name).zip"
    Compress-Archive -Path $_.FullName -DestinationPath $zip -Force
    Write-Host "built $zip"
}
