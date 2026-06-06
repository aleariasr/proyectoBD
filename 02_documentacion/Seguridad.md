# Seguridad del Proyecto SIGAU

## Objetivo

La seguridad de SIGAU se diseñó aplicando separación de responsabilidades, control de acceso por roles, protección de datos sensibles, auditoría y reducción de superficie de exposición.

## Autenticación

SQL Server fue configurado en modo Windows Authentication únicamente.

Esto reduce el uso de credenciales SQL internas y permite centralizar el acceso mediante cuentas del sistema operativo.

## Cuentas administrativas

Durante la administración de la máquina virtual se utilizó la cuenta:

- myVm\adminbackup

La cuenta original:

- sigauadmin

fue deshabilitada posteriormente como medida de reducción de exposición.

## Cuentas de servicio

SQL Server fue configurado utilizando cuentas dedicadas para servicios principales:

- sqlsvc
- sqlagent

Esto permite separar la ejecución de servicios de las cuentas administrativas utilizadas para la gestión del sistema operativo.

## Roles de base de datos

Se crearon tres roles personalizados:

### Administrativo

Rol con privilegios amplios sobre los esquemas principales del sistema.

Permisos:

- SELECT
- INSERT
- UPDATE
- DELETE
- UNMASK

Este rol puede consultar datos sensibles sin enmascaramiento.

### Mantenimiento

Rol orientado a la operación diaria del sistema.

Permisos:

- SELECT
- INSERT
- UPDATE
- DELETE

No posee permiso UNMASK.

### LecturaGeneral

Rol de consulta limitada.

Permisos:

- SELECT sobre el esquema consulta

Restricciones:

- DENY sobre esquemas core, academico, admin, api y seguridad

Este rol consulta información únicamente mediante vistas.

## Dynamic Data Masking

Se implementó Dynamic Data Masking sobre datos sensibles.

Columnas protegidas:

| Tabla | Columna | Función |
|---|---|---|
| core.IdentificacionPersona | NumeroIdentificacion | partial |
| core.DireccionPersona | DireccionDetallada | partial |
| core.MedioContactoPersona | ValorContacto | email |
| core.Sede | DireccionReferencia | partial |

Objetivo:

- Reducir exposición de datos personales.
- Permitir consultas operativas sin revelar información sensible.
- Aplicar principio de mínimo privilegio.

## Row Level Security

Se implementó Row Level Security para controlar acceso por sede.

Objetos utilizados:

- seguridad.UsuarioSede
- seguridad.fn_FiltroSede
- seguridad.Policy_EscuelaPorSede
- seguridad.Policy_UnidadPorSede

La tabla seguridad.UsuarioSede relaciona usuarios de base de datos con sedes autorizadas.

Las políticas activas son:

- Policy_EscuelaPorSede
- Policy_UnidadPorSede

Estas políticas filtran automáticamente registros según la sede asignada al usuario.

## Auditoría

Se configuró auditoría a nivel de servidor y base de datos.

### Auditoría de servidor

Objeto:

- Audit_SIGAU_Server

Ruta:

- H:\SQLServer\Audit\SIGAU\

### Auditoría de base de datos

Objeto:

- Audit_SIGAU_Database

Eventos auditados:

- SELECT
- INSERT
- UPDATE
- DELETE
- Cambios sobre objetos
- Cambios de permisos
- Cambios de principales de base de datos

## Bitácora In-Memory

Se creó la tabla:

- seguridad.BitacoraAcceso

Esta tabla utiliza In-Memory OLTP y permite registrar eventos de acceso o acciones internas con menor latencia.

## Hardening SQL Server

La instancia SQL Server mantiene configuraciones alineadas con reducción de superficie:

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

La opción external rest endpoint enabled se habilitó como excepción controlada porque el proyecto requiere consumo de API REST desde SQL Server.

## Criterio de seguridad aplicado

La configuración de seguridad busca equilibrar:

- Confidencialidad de datos sensibles.
- Acceso operativo por roles.
- Auditoría de acciones relevantes.
- Separación de responsabilidades.
- Compatibilidad con los requisitos técnicos del proyecto.