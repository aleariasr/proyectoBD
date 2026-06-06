# 00_PreCheck_Azure.ps1
# No modifica nada. Solo revisa si es seguro continuar.

Write-Host "`n=== PRE-CHECK HARDENING AZURE VM ===" -ForegroundColor Cyan

$CurrentUser = $env:USERNAME
$Computer = $env:COMPUTERNAME
$FullUser = "$Computer\$CurrentUser"
$ScriptPath = Get-Location

Write-Host "`n[INFO] Equipo: $Computer"
Write-Host "[INFO] Usuario actual: $CurrentUser"
Write-Host "[INFO] Usuario local esperado para scripts: $CurrentUser"
Write-Host "[INFO] Ruta actual: $ScriptPath"

Write-Host "`n=== 1. Verificando privilegios de administrador ==="
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($IsAdmin) {
    Write-Host "[OK] PowerShell estÃ¡ ejecutÃ¡ndose como Administrador." -ForegroundColor Green
} else {
    Write-Host "[ERROR] PowerShell NO estÃ¡ como Administrador. CerrÃ¡ y abrilo como administrador." -ForegroundColor Red
}

Write-Host "`n=== 2. Verificando grupos locales ==="

Write-Host "`nAdministrators:"
net localgroup Administrators

Write-Host "`nRemote Desktop Users:"
net localgroup "Remote Desktop Users"

Write-Host "`n=== 3. Verificando RDP ==="

try {
    $rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections").fDenyTSConnections

    if ($rdp -eq 0) {
        Write-Host "[OK] RDP estÃ¡ habilitado en Windows." -ForegroundColor Green
    } else {
        Write-Host "[ERROR] RDP estÃ¡ deshabilitado en Windows. No ejecutar hardening todavÃ­a." -ForegroundColor Red
    }
} catch {
    Write-Host "[ERROR] No se pudo leer el estado de RDP." -ForegroundColor Red
}

Write-Host "`n=== 4. Verificando reglas Firewall de RDP ==="

$rdpRules = Get-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction SilentlyContinue

if ($rdpRules) {
    $enabledRules = $rdpRules | Where-Object Enabled -eq True
    if ($enabledRules) {
        Write-Host "[OK] Hay reglas de firewall de Remote Desktop habilitadas." -ForegroundColor Green
        $enabledRules | Select-Object DisplayName, Enabled, Profile, Direction, Action | Format-Table -AutoSize
    } else {
        Write-Host "[ERROR] Existen reglas de RDP, pero ninguna estÃ¡ habilitada." -ForegroundColor Red
    }
} else {
    Write-Host "[ERROR] No se encontraron reglas de firewall para Remote Desktop." -ForegroundColor Red
}

Write-Host "`n=== 5. Perfil de red actual ==="

Get-NetConnectionProfile | Select-Object Name, InterfaceAlias, NetworkCategory, IPv4Connectivity, IPv6Connectivity | Format-Table -AutoSize

Write-Host "`n=== 6. IPs actuales ==="

Get-NetIPAddress |
Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -notlike "169.*"} |
Select-Object InterfaceAlias, IPAddress, PrefixLength |
Format-Table -AutoSize

Write-Host "`n=== 7. Buscando referencias que deben cambiarse en scripts ==="

$files = Get-ChildItem -Path $ScriptPath -Filter "*.ps1"

if (-not $files) {
    Write-Host "[ERROR] No encontrÃ© scripts .ps1 en esta carpeta." -ForegroundColor Red
} else {
    Write-Host "[INFO] Scripts encontrados:"
    $files.Name | ForEach-Object { Write-Host " - $_" }

    Write-Host "`n[BUSQUEDA] Usuario del compaÃ±ero: sigauadmin"
    Select-String -Path $files.FullName -Pattern "sigauadmin" | ForEach-Object {
        Write-Host "[CAMBIAR] $($_.Filename): lÃ­nea $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor Yellow
    }

    Write-Host "`n[BUSQUEDA] Cambio fuerte de IPv6:"
    Select-String -Path $files.FullName -Pattern "DisabledComponents|Disable IPv6|Tcpip6" | ForEach-Object {
        Write-Host "[REVISAR] $($_.Filename): lÃ­nea $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor Yellow
    }

    Write-Host "`n[BUSQUEDA] Configuraciones relacionadas con RDP:"
    Select-String -Path $files.FullName -Pattern "Remote Desktop Users|fDenyTSConnections|Enable-NetFirewallRule" | ForEach-Object {
        Write-Host "[RDP] $($_.Filename): lÃ­nea $($_.LineNumber): $($_.Line.Trim())" -ForegroundColor Gray
    }
}

Write-Host "`n=== 8. Reemplazo recomendado ===" -ForegroundColor Cyan
Write-Host "En los scripts, cambiÃ¡ TODO:"
Write-Host '    sigauadmin' -ForegroundColor Yellow
Write-Host "por:"
Write-Host "    $CurrentUser" -ForegroundColor Green

Write-Host "`nPodÃ©s reemplazarlo automÃ¡ticamente con este comando, pero solo despuÃ©s de revisar:"
Write-Host "(Get-ChildItem *.ps1) | ForEach-Object { (Get-Content `$_.FullName) -replace 'sigauadmin', '$CurrentUser' | Set-Content `$_.FullName -Encoding UTF8 }" -ForegroundColor Yellow

Write-Host "`n=== 9. Orden recomendado de ejecuciÃ³n ===" -ForegroundColor Cyan
Write-Host "1. Crear snapshot del disco en Azure Portal."
Write-Host "2. Ejecutar Parte1."
Write-Host "3. Reiniciar y probar RDP."
Write-Host "4. Ejecutar Parte2."
Write-Host "5. Reiniciar y probar RDP."
Write-Host "6. Ejecutar Parte3."
Write-Host "7. Reiniciar y probar RDP."
Write-Host "8. Ejecutar Parte4b."
Write-Host "9. Reiniciar y probar RDP."
Write-Host "10. Revisar Parte4a antes de ejecutarlo, especialmente IPv6."

Write-Host "`n=== PRE-CHECK FINALIZADO ===" -ForegroundColor Cyan
