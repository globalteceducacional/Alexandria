# Corrige incompatibilidade do pdfx com CMake 4+ (Visual Studio 2026).
# Execute após flutter pub get se o build Windows falhar no download do pdfium.

$pdfxWindows = Join-Path $env:LOCALAPPDATA "Pub\Cache\hosted\pub.dev\pdfx-2.9.2\windows"
if (-not (Test-Path $pdfxWindows)) {
    Write-Error "Pacote pdfx não encontrado em $pdfxWindows. Rode 'flutter pub get' primeiro."
    exit 1
}

$cmakeListsIn = Join-Path $pdfxWindows "DownloadProject.CMakeLists.cmake.in"
$downloadProject = Join-Path $pdfxWindows "DownloadProject.cmake"

$content = Get-Content $cmakeListsIn -Raw
if ($content -match 'cmake_minimum_required\(VERSION (2\.8\.12|3\.5)\)') {
    $content = $content -replace 'cmake_minimum_required\(VERSION (2\.8\.12|3\.5)\)', 'cmake_minimum_required(VERSION 3.10)'
    Set-Content $cmakeListsIn $content -NoNewline
}

$content = Get-Content $downloadProject -Raw
if ($content -notmatch 'CMAKE_POLICY_VERSION_MINIMUM') {
    $content = $content -replace `
        '(-D "CMAKE_MAKE_PROGRAM:FILE=\$\{CMAKE_MAKE_PROGRAM\}")(\s+\.)', `
        '$1`n                        -D "CMAKE_POLICY_VERSION_MINIMUM:STRING=3.10"$2'
    Set-Content $downloadProject $content -NoNewline
}

Write-Host "Patch do pdfx aplicado com sucesso."
