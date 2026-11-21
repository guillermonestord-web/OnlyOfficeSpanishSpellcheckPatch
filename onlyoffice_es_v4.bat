@echo off
setlocal EnableExtensions
title ONLYOFFICE - Corrector ortografico para todas las variantes de Espanol v4

rem ==========================================================================
rem  ONLYOFFICE Desktop Editors 10.x - corrector para TODAS las variantes del
rem  espanol (Argentina, Mexico, Chile, Colombia, etc.)
rem
rem  En el programa de escritorio el motor de ortografia es NATIVO (compilado en
rem  el .exe) y solo conoce el codigo 3082 (Espanol-Espana). Este parche NO toca
rem  ningun .exe/.dll: modifica los sdk-all-min.js para que
rem    1) cada variante del espanol figure con corrector (la "A"), y
rem    2) al pedir la correccion, el codigo de la variante se envie al motor
rem       como 3082, usando el diccionario es_ES que ya viene instalado.
rem
rem  Variantes cubiertas (23 codigos, ademas de Espana 3082 que ya funciona):
rem    10 es (generico)   1034 es-ES tradicional   2058 Mexico   4106 Guatemala
rem    5130 Costa Rica    6154 Panama    7178 Rep. Dominicana    8202 Venezuela
rem    9226 Colombia      10250 Peru     11274 Argentina         12298 Ecuador
rem    13322 Chile        14346 Uruguay  15370 Paraguay          16394 Bolivia
rem    17418 El Salvador  18442 Honduras 19466 Nicaragua         20490 Puerto Rico
rem    21514 Estados Unidos   22538 America Latina y el Caribe   23562 Cuba
rem
rem  Actualiza sin problema una instalacion ya parcheada con v3.
rem  Hace copia .bak_esAR de cada archivo. Para deshacer: onlyoffice_es_AR_revertir.bat
rem  Si actualizas ONLYOFFICE, volve a ejecutar este .bat.
rem  Uso: doble clic (pide administrador). Opcional: pasar la carpeta de instalacion.
rem ==========================================================================

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Se necesitan permisos de administrador. Reiniciando con elevacion...
    if "%~1"=="" (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    ) else (
        powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -ArgumentList '\"%~1\"' -Verb RunAs"
    )
    exit /b
)

set "OO="
if not "%~1"=="" if exist "%~1\editors\sdkjs" set "OO=%~1"
if not defined OO if exist "%ProgramFiles%\ONLYOFFICE\DesktopEditors\editors\sdkjs" set "OO=%ProgramFiles%\ONLYOFFICE\DesktopEditors"
if not defined OO if exist "%ProgramFiles(x86)%\ONLYOFFICE\DesktopEditors\editors\sdkjs" set "OO=%ProgramFiles(x86)%\ONLYOFFICE\DesktopEditors"
if not defined OO if exist "%LOCALAPPDATA%\Programs\ONLYOFFICE\DesktopEditors\editors\sdkjs" set "OO=%LOCALAPPDATA%\Programs\ONLYOFFICE\DesktopEditors"
if not defined OO (
    echo No se encontro ONLYOFFICE Desktop Editors. Ejecuta: %~nx0 "C:\ruta\DesktopEditors"
    pause
    exit /b 1
)
set "OO_DIR=%OO%"
echo Instalacion: %OO%
echo.

echo Cerrando ONLYOFFICE...
taskkill /f /im DesktopEditors.exe >nul 2>&1
taskkill /f /im editors.exe >nul 2>&1
taskkill /f /im editors_helper.exe >nul 2>&1
timeout /t 2 /nobreak >nul

set "PSF=%TEMP%\oo_es_patch_v4.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Content -LiteralPath '%~f0' | Where-Object { $_.StartsWith('#PS#') } | ForEach-Object { $_.Substring(4) } | Set-Content -Encoding UTF8 -LiteralPath '%PSF%'"
powershell -NoProfile -ExecutionPolicy Bypass -File "%PSF%"
set "RC=%errorlevel%"
del "%PSF%" >nul 2>&1

echo.
if "%RC%"=="0" (
    echo LISTO. Abri ONLYOFFICE, elegi cualquier variante de Espanol y escribi una palabra mal.
    echo Si hace falta, activa el corrector en Archivo ^> Configuracion avanzada.
) else (
    echo TERMINO CON ERRORES. No se modifico ningun archivo si el error fue de validacion.
)
echo.
pause
exit /b %RC%

rem ---- Desde aqui, solo PowerShell (lineas con prefijo #PS#). cmd nunca llega aca ----
#PS#$ErrorActionPreference = 'Stop'
#PS#$oo   = $env:OO_DIR
#PS#$utf8 = New-Object System.Text.UTF8Encoding($false)
#PS#
#PS#if (-not (Test-Path (Join-Path $oo 'dictionaries\es_ES\es_ES.dic'))) { Write-Host 'ERROR: no existe dictionaries\es_ES\es_ES.dic'; exit 1 }
#PS#
#PS## Codigos LCID de todas las variantes de espanol (salvo 3082, que el motor nativo ya conoce)
#PS#$codes = 10,1034,2058,4106,5130,6154,7178,8202,9226,10250,11274,12298,13322,14346,15370,16394,17418,18442,19466,20490,21514,22538,23562
#PS#$alt   = ($codes -join '|')
#PS#
#PS## Tabla de idiomas con corrector (para que aparezca la "A")
#PS#$patTable = '(window\.AscCommon\.spellcheckGetLanguages\s*=\s*function\s*\(\)\s*\{\s*return\s*\{)'
#PS#$reTable = New-Object System.Text.RegularExpressions.Regex($patTable)
#PS#$patAny  = '(?<![0-9])(?:' + $alt + '):\{hyphen:![01],name:"[^"]*"\}'
#PS#$reAny   = New-Object System.Text.RegularExpressions.Regex($patAny)
#PS#
#PS## Pedido al motor nativo: SpellCheck(JSON.stringify(x))  ->  traduce los codigos de usrLang a 3082
#PS#$patCall = 'AscDesktopEditor\.SpellCheck\(JSON\.stringify\((\w+)\)\)'
#PS#$reCall = New-Object System.Text.RegularExpressions.Regex($patCall)
#PS#$patPatched = 'AscDesktopEditor\.SpellCheck\(JSON\.stringify\((\w+)\)\.replace\(/\("usrLang":\\\[\)\(\[\^\\\]\]\*\)/g,function\(m,p,q\)\{return p\+q\.replace\(/[^/]*/g,"3082"\)\}\)\)'
#PS#$rePatched = New-Object System.Text.RegularExpressions.Regex($patPatched)
#PS#$newCall = 'AscDesktopEditor.SpellCheck(JSON.stringify(${1}).replace(/("usrLang":\[)([^\]]*)/g,function(m,p,q){return p+q.replace(/\b(?:' + $alt + ')\b/g,"3082")}))'
#PS#$callTag = 'q.replace(/\b(?:' + $alt + ')\b/g,"3082")'
#PS#
#PS#$files = @(Get-ChildItem (Join-Path $oo 'editors\sdkjs') -Recurse -File | Where-Object { $_.Name -eq 'sdk-all-min.js' })
#PS#if ($files.Count -eq 0) { Write-Host 'ERROR: no se encontraron sdk-all-min.js'; exit 1 }
#PS#
#PS#Write-Host '[1/2] Validando (no se escribe nada todavia)'
#PS#$plan = @()
#PS#$bad = 0
#PS#foreach ($f in $files) {
#PS#    $rel = $f.FullName.Substring($oo.Length)
#PS#    $t = $utf8.GetString([IO.File]::ReadAllBytes($f.FullName))
#PS#    if (-not $reTable.IsMatch($t)) { Write-Host ('  NO se reconoce la tabla de idiomas en ' + $rel); $bad++; continue }
#PS#    $nPatched = $rePatched.Matches($t).Count
#PS#    $nRaw = $reCall.Matches($t).Count
#PS#    if (($nPatched + $nRaw) -lt 1) { Write-Host ('  NO se encontro SpellCheck(JSON.stringify(..)) en ' + $rel); $bad++; continue }
#PS#    $isPristine = (($nPatched -eq 0) -and (-not $reAny.IsMatch($t)))
#PS#    $new = $t
#PS#    $missing = ''
#PS#    foreach ($c in $codes) {
#PS#        $reE = New-Object System.Text.RegularExpressions.Regex(('(?<![0-9])' + $c + ':\{hyphen:![01],name:"[^"]*"\}'))
#PS#        $entryOne = [string]$c + ':{hyphen:!0,name:"es_ES"}'
#PS#        if ($reE.IsMatch($new)) { $new = $reE.Replace($new, $entryOne, 1) } else { $missing += ($entryOne + ',') }
#PS#    }
#PS#    if ($missing.Length -gt 0) { $new = $reTable.Replace($new, ('${1}' + $missing), 1) }
#PS#    $new = $rePatched.Replace($new, $newCall)
#PS#    $new = $reCall.Replace($new, $newCall)
#PS#    if ($new -eq $t) { Write-Host ('  ya parcheado: ' + $rel); continue }
#PS#    $plan += [pscustomobject]@{ File = $f.FullName; Rel = $rel; Old = $t; New = $new; Pristine = $isPristine }
#PS#    Write-Host ('  listo para parchear: ' + $rel)
#PS#}
#PS#if ($bad -gt 0) { Write-Host 'Se cancelo: no se modifico ningun archivo.'; exit 1 }
#PS#
#PS#Write-Host '[2/2] Aplicando'
#PS#$written = @()
#PS#try {
#PS#    foreach ($p in $plan) {
#PS#        $bak = $p.File + '.bak_esAR'
#PS#        if (-not (Test-Path $bak)) {
#PS#            [IO.File]::WriteAllBytes($bak, $utf8.GetBytes($p.Old))
#PS#            if (-not $p.Pristine) { Write-Host ('  aviso: no habia copia original de ' + $p.Rel + '; la copia guardada ya incluye cambios de un parche anterior') }
#PS#        } elseif ($p.Pristine) {
#PS#            [IO.File]::WriteAllBytes($bak, $utf8.GetBytes($p.Old))
#PS#        }
#PS#        [IO.File]::WriteAllBytes($p.File, $utf8.GetBytes($p.New))
#PS#        $written += $p
#PS#        $chk = $utf8.GetString([IO.File]::ReadAllBytes($p.File))
#PS#        $ok = $chk.Contains($callTag)
#PS#        foreach ($c in $codes) { if (-not $chk.Contains([string]$c + ':{hyphen:!0,name:"es_ES"}')) { $ok = $false } }
#PS#        if (-not $ok) { throw ('fallo la verificacion en ' + $p.Rel) }
#PS#        Write-Host ('  parcheado: ' + $p.Rel)
#PS#    }
#PS#} catch {
#PS#    Write-Host ('ERROR: ' + $_.Exception.Message + ' - restaurando lo escrito en esta ejecucion...')
#PS#    foreach ($p in $written) { [IO.File]::WriteAllBytes($p.File, $utf8.GetBytes($p.Old)); Write-Host ('  restaurado: ' + $p.Rel) }
#PS#    exit 1
#PS#}
#PS#exit 0
