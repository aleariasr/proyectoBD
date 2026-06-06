# Seguridad del Proyecto SIGAU

## Objetivo

La seguridad de SIGAU se diseñó aplicando separación de responsabilidades, control de acceso por roles, protección de datos sensibles, auditoría y reducción de superficie de exposición.

## Autenticación

SQL Server fue configurado en modo Windows Authentication únicamente. Esto reduce el uso de credenciales SQL internas y centraliza el acceso mediante cuentas del sistema operativo.

## Cuentas administrativas

Cuenta operativa utilizada:

- myVm\adminbackup

La cuenta original `sigauadmin` fue deshabilitada posteriormente como medida de reducción de exposición.

## Cuentas de servicio

SQL Server utiliza cuentas dedicadas:

- sqlsvc
- sqlagent

Esto separa servicios del motor de cuentas administrativas humanas.

## Roles de base de datos

Se crearon tres roles personalizados:

### Administrativo

Permisos:

- SELECT
- INSERT
- UPDATE
- DELETE
- UNMASK

Este rol puede consultar datos sensibles sin enmascaramiento.

### Mantenimiento

Permisos:

- SELECT
- INSERT
- UPDATE
- DELETE

No posee permiso UNMASK.

### LecturaGeneral

Permisos:

- SELECT sobre esquema consulta

Restricciones:

- DENY sobre core
- DENY sobre academico
- DENY sobre admin
- DENY sobre api
- DENY sobre seguridad

Este rol consulta únicamente mediante vistas.

## Dynamic Data Masking

Columnas protegidas:

| Tabla | Columna | Función |
|---|---|---|
| core.IdentificacionPersona | NumeroIdentificacion | partial |
| core.DireccionPersona | DireccionDetallada | partial |
| core.MedioContactoPersona | ValorContacto | email |
| core.Sede | DireccionReferencia | partial |

Evidencia:

![Dynamic Data Masking](../04_evidencias/Seguridad/01_DynamicDataMasking.jpeg)

## Row Level Security

Objetos utilizados:

- seguridad.UsuarioSede
- seguridad.fn_FiltroSede
- seguridad.Policy_EscuelaPorSede
- seguridad.Policy_UnidadPorSede

La restricción se basa en la relación UsuarioBD-SedeID.

Resultados:

- usuario_occidente visualiza información de la Sede 1.
- usuario_grecia visualiza información de la Sede 2.

Evidencia:

![Row Level Security](../04_evidencias/Seguridad/02_RowLevelSecurity.jpeg)

## Auditoría

Se configuró auditoría a nivel de servidor y base de datos.

Objetos:

- Audit_SIGAU_Server
- Audit_SIGAU_Database

Ruta:

H:\SQLServer\Audit\SIGAU\

Eventos auditados:

- SELECT
- INSERT
- UPDATE
- DELETE
- Cambios de objetos
- Cambios de permisos
- Cambios de principales

## Bitácora In-Memory

Tabla:

- seguridad.BitacoraAcceso

Configuración:

- MEMORY_OPTIMIZED = ON
- DURABILITY = SCHEMA_AND_DATA

## Hardening SQL Server

Configuraciones de reducción de superficie:

| Configuración | Valor |
|---|---|
| Ad Hoc Distributed Queries | 0 |
| clr enabled | 0 |
| clr strict security | 1 |
| cross db ownership chaining | 0 |
| Database Mail XPs | 0 |
| Ole Automation Procedures | 0 |
| remote access | 0 |
| remote admin connections | 0 |
| scan for startup procs | 0 |

La opción `external rest endpoint enabled` se habilitó como excepción controlada porque el proyecto requiere consumo de API REST desde SQL Server.

## Hardening Windows

El hardening del sistema operativo se documenta en:

- [Hardening CIS Windows Server](../06_azure/Hardening_CIS.md)

Evidencias:

- [Reporte CSV CIS](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.csv)
- [Resumen TXT CIS](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.txt)

## Documentación relacionada

- [Hardening SQL Server](Hardening_SQL_Server.md)
- [Antimalware SQL Server](Antimalware_SQL_Server.md)
- [Hardening CIS Windows Server](../06_azure/Hardening_CIS.md)