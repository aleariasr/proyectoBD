# Hardening SQL Server

## Objetivo

Documentar las configuraciones de hardening aplicadas al motor SQL Server según el benchmark CIS Microsoft SQL Server 2022, considerando las particularidades de una máquina virtual alojada en Microsoft Azure.

## Benchmark utilizado

- [CIS Microsoft SQL Server 2022 Benchmark v1.2.1](../01_enunciado/CIS_SQL_Server_2022_Benchmark_v1_2_1.pdf)

## Configuraciones verificadas

| Configuración | Valor |
|---|---:|
| Ad Hoc Distributed Queries | 0 |
| CLR Enabled | 0 |
| CLR Strict Security | 1 |
| Contained Database Authentication | 0 |
| Cross DB Ownership Chaining | 0 |
| Database Mail XPs | 0 |
| External Scripts Enabled | 0 |
| Ole Automation Procedures | 0 |
| Remote Access | 0 |
| Remote Admin Connections | 0 |
| Scan for Startup Procs | 0 |
| Show Advanced Options | 0 |
| xp_cmdshell | 0 |

## Autenticación

La instancia utiliza únicamente autenticación de Windows.

Los logins SQL encontrados están deshabilitados:

- `##MS_PolicyEventProcessingLogin##`
- `##MS_PolicyTsqlExecutionLogin##`
- `roberto`

No existe un login habilitado llamado `sa`.

## Bases de datos

Se verificó que las bases de usuario no tienen habilitadas las opciones:

- `TRUSTWORTHY`
- `DB_CHAINING`

## SQL Server Browser

El servicio `SQLBrowser` se encuentra:

- detenido;
- deshabilitado;
- sin inicio automático.

## Transparent Data Encryption

La base de datos `SIGAU` utiliza Transparent Data Encryption.

| Propiedad | Valor |
|---|---|
| Estado de cifrado | 3 - Encrypted |
| Algoritmo | AES |
| Longitud de clave | 256 bits |

TDE protege los archivos de datos y respaldos contra acceso no autorizado en reposo.

## Auditoría

Las siguientes auditorías se encuentran habilitadas y en estado `STARTED`:

- `Audit_LoginTracking`
- `Audit_SIGAU_Server`

Se generan archivos en:

- `H:\SQLServer\Audit\`
- `H:\SQLServer\Audit\SIGAU\`

## Excepción funcional: REST desde SQL Server

La configuración:

`external rest endpoint enabled = 1`

se mantiene habilitada porque el proyecto requiere realizar llamadas REST desde SQL Server 2025.

Esta opción se considera una excepción funcional controlada y está documentada en:

- [External API Calls](External_API_Calls.md)

## Excepción controlada: Force Encryption

La propiedad `ForceEncryption` se encuentra en `0`.

No se activó el cifrado obligatorio de conexiones porque SQL Server no tiene un certificado válido asignado específicamente al motor.

Los certificados encontrados en el almacén local pertenecen a:

`Windows Azure CRP Certificate Generator`

Estos certificados son administrados por Azure y no deben reutilizarse directamente para SQL Server sin validar:

- propósito de autenticación de servidor;
- nombre del certificado;
- cadena de confianza;
- permisos de la cuenta del servicio;
- compatibilidad con los clientes existentes.

Activar `ForceEncryption` sin un certificado correctamente preparado podría impedir las conexiones a la instancia después de reiniciar el servicio.

Por esta razón, TLS obligatorio se mantiene como una excepción controlada para no comprometer la conectividad de la máquina virtual ni del motor SQL Server.

## Evidencias técnicas

- [Configuraciones de sp_configure](../04_evidencias/SQLServer_CIS/sp_configure.txt)
- [Estado de logins SQL](../04_evidencias/SQLServer_CIS/sa_status.txt)
- [Estado de SQL Server Browser](../04_evidencias/SQLServer_CIS/sqlbrowser.txt)
- [Estado de TDE](../04_evidencias/SQLServer_CIS/tde_status.txt)
- [Auditorías de servidor](../04_evidencias/SQLServer_CIS/server_audits.txt)
- [Especificaciones de auditoría](../04_evidencias/SQLServer_CIS/server_audit_specs.txt)

## Resultado

El hardening del motor está implementado y verificado en la VM.

La única excepción relevante pendiente es `ForceEncryption`, que no se habilitó por no existir un certificado válido asignado específicamente a SQL Server.

## Estado

Implementado y verificado, con excepción controlada de TLS obligatorio.