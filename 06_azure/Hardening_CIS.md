# Hardening CIS Windows Server 2025

## Benchmark utilizado

Para el endurecimiento del sistema operativo se utilizó como referencia:

CIS Microsoft Windows Server 2025 Benchmark v2.0.0

## Ubicación de scripts utilizados

Los scripts de hardening se almacenan en el repositorio en:

06_azure/hardening_scripts

Scripts identificados:

- 00_PreCheck_Azure.ps1
- CIS_WS2025_Parte1_AccountPolicies.ps1
- CIS_WS2025_Parte2_LocalPolicies.ps1
- CIS_WS2025_Parte3_Firewall_Audit.ps1
- CIS_WS2025_Parte4a_AdminTemplates.ps1
- CIS_WS2025_Parte4b_AdminTemplates.ps1
- Verify_CIS_WS2025_Status.ps1

## Reporte de verificación

El reporte más reciente identificado corresponde a:

CIS_WS2025_Verification_20260428_172121.csv

También se generó un resumen en formato TXT:

CIS_WS2025_Verification_20260428_172121.txt

Estos archivos se almacenan como evidencia en:

04_evidencias/Seguridad/CIS_WS2025

## Controles aplicados

El proceso de hardening incluyó controles asociados a:

- Políticas de cuentas.
- Políticas locales.
- Firewall de Windows.
- Auditoría.
- Plantillas administrativas.
- Revisión de estado mediante script de verificación.

## Excepciones documentadas

Algunos controles no fueron aplicados por tratarse de una máquina virtual standalone en Azure, sin dominio Active Directory y con necesidad de acceso remoto mediante RDP.

Entre las excepciones principales se incluyen:

- Controles de User Rights Assignment que podrían afectar el acceso remoto.
- Restricciones avanzadas de Remote Desktop Services que requieren certificados o dominio.
- Controles dependientes de Active Directory, como LAPS.
- Controles de Device Guard, VBS o Credential Guard sujetos a soporte de virtualización.
- Restricciones de IPv6 que podrían afectar servicios internos de Azure.
- Políticas de firewall que podrían bloquear conectividad administrativa.

## Criterio aplicado

El hardening se aplicó buscando equilibrio entre seguridad, disponibilidad y compatibilidad con Azure. Las excepciones se consideran justificadas por el contexto académico, el tipo de infraestructura y la necesidad de mantener acceso administrativo seguro.