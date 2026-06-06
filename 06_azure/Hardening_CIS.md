# Hardening CIS Windows Server 2025

## Benchmark utilizado

Se utilizó como referencia:

CIS Microsoft Windows Server 2025 Benchmark v2.0.0

## Scripts utilizados

Ubicación:

06_azure/hardening_scripts

Scripts:

- 00_PreCheck_Azure.ps1
- CIS_WS2025_Parte1_AccountPolicies.ps1
- CIS_WS2025_Parte2_LocalPolicies.ps1
- CIS_WS2025_Parte3_Firewall_Audit.ps1
- CIS_WS2025_Parte4a_AdminTemplates.ps1
- CIS_WS2025_Parte4b_AdminTemplates.ps1
- Verify_CIS_WS2025_Status.ps1

## Reportes de verificación

- [Reporte CSV](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.csv)
- [Resumen TXT](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.txt)

## Controles aplicados

El proceso incluyó:

- Políticas de cuentas.
- Políticas locales.
- Firewall de Windows.
- Auditoría.
- Plantillas administrativas.
- Verificación de estado mediante script.

## Excepciones justificadas

Algunos controles no fueron aplicados debido a que el entorno es una VM standalone en Azure, sin dominio Active Directory y con necesidad de acceso RDP.

Excepciones principales:

- User Rights Assignment que podría afectar el acceso remoto.
- Configuraciones avanzadas de Remote Desktop Services que requieren certificados o dominio.
- LAPS, por depender de Active Directory.
- Device Guard, VBS o Credential Guard, por soporte de virtualización.
- Restricciones de IPv6, por posibles dependencias internas de Azure.
- Políticas de firewall que podrían bloquear conectividad administrativa.

## Criterio aplicado

Se priorizó equilibrio entre seguridad, disponibilidad y compatibilidad con Azure.
