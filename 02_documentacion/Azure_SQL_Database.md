# Azure SQL Database PaaS

## Objetivo

Desplegar la base de datos SIGAU, incluyendo esquema, objetos y datos, en Azure SQL Database PaaS.

## Recurso creado

La implementación se realizó en la suscripción `Azure for Students`.

| Propiedad | Valor |
|---|---|
| Grupo de recursos | `rg-if5100-sigau` |
| Servidor lógico | `sigau-sql-alejandro-260707124103` |
| FQDN | `sigau-sql-alejandro-260707124103.database.windows.net` |
| Región | `westus3` |
| Base de datos | `SIGAU` |
| Estado | `Online` |
| Edición | `SQL Azure` |
| Nivel de servicio | `Basic` |
| Nivel de compatibilidad | `170` |

## Seguridad de red

El firewall del servidor lógico permite únicamente las direcciones IP utilizadas durante la implementación:

| Regla | Dirección IP |
|---|---|
| `Mac-Alejandro-20260707` | `191.102.39.6` |
| `VM-SIGAU-20260707` | `20.38.174.133` |

No se habilitó una regla general para permitir el acceso desde todos los servicios de Azure.

La conexión se realizó con:

- cifrado obligatorio;
- certificado del servidor validado;
- autenticación SQL para el administrador del servidor lógico.

## Migración

La migración se realizó desde la base SIGAU alojada en SQL Server 2025 dentro de la VM.

Se utilizó el asistente `Generate Scripts` de SQL Server Management Studio con las siguientes opciones:

- destino: Microsoft Azure SQL Database;
- esquema y datos;
- sin instrucciones `USE DATABASE`;
- índices, llaves, restricciones y triggers incluidos;
- sin filegroups físicos;
- sin objetos a nivel de servidor.

## Adaptaciones para Azure SQL Database

Azure SQL Database no utiliza los filegroups físicos definidos en la VM.

Durante la migración, la tabla `api.ConsultaExterna` fue adaptada para eliminar:

`TEXTIMAGE_ON [FG_SIGAU_CORE]`

La tabla fue creada directamente en Azure SQL con:

- clave primaria clustered;
- columna `IDENTITY`;
- valor predeterminado `SYSUTCDATETIME()`;
- columna `nvarchar(max)` para almacenar JSON.

Luego se migraron sus 14 registros y se creó la vista:

`consulta.vw_ConsultaExterna`

## Exclusiones intencionales

No se migraron los siguientes objetos:

- `seguridad.BitacoraAcceso`
- `consulta.vw_BitacoraAcceso`

La tabla `seguridad.BitacoraAcceso` utiliza In-Memory OLTP y fue excluida para mantener compatibilidad con el nivel Basic utilizado en Azure SQL Database.

La vista `consulta.vw_BitacoraAcceso` se excluyó porque depende directamente de esa tabla.

Estas exclusiones no afectan los módulos académicos, administrativos, de seguridad por sede, API, JSON ni consulta general de SIGAU.

## Verificación

La conexión directa a Azure SQL confirmó:

| Elemento | Resultado |
|---|---:|
| Tablas | 23 |
| Vistas | 23 |
| Procedimientos | 2 |
| Funciones | 1 |
| Políticas RLS | 2 |

Todas las tablas migradas contienen datos.

Ejemplos verificados:

| Tabla | Registros |
|---|---:|
| `core.Persona` | 30 |
| `core.IdentificacionPersona` | 30 |
| `core.DireccionPersona` | 30 |
| `core.MedioContactoPersona` | 30 |
| `academico.Curso` | 10 |
| `academico.Escuela` | 10 |
| `academico.Estudiante` | 10 |
| `academico.Matricula` | 10 |
| `admin.UnidadAdministrativa` | 10 |
| `seguridad.UsuarioSede` | 10 |
| `api.ConsultaExterna` | 14 |

También se confirmó:

- servidor correcto;
- base `SIGAU`;
- edición `SQL Azure`;
- estado `ONLINE`;
- compatibilidad `170`;
- Row-Level Security mediante dos políticas activas.

## Evidencias

- [Base SIGAU en Azure](../04_evidencias/AzureSQL/01_Base_SIGAU_Azure.png)
- [Tablas en Azure](../04_evidencias/AzureSQL/02_Tablas_Azure.png)
- [Vistas en Azure](../04_evidencias/AzureSQL/03_Vistas_Azure.png)
- [Procedimientos en Azure](../04_evidencias/AzureSQL/04_Procedimientos_Azure.png)
- [Datos en Azure](../04_evidencias/AzureSQL/05_Datos_Azure.png)
- [Verificación final de Azure SQL](../04_evidencias/AzureSQL/06_Verificacion_Final_Azure_SQL.png)

## Resultado

SIGAU fue desplegada, adaptada y verificada directamente en Azure SQL Database PaaS.

## Estado

Implementado y verificado.
