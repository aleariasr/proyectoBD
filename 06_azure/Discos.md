# Configuración de almacenamiento SQL Server

## Objetivo

Separar físicamente componentes de SQL Server para mejorar rendimiento, administración y recuperación.

## Distribución implementada

| Unidad | Etiqueta | Uso |
|---|---|---|
| E: | SQLData | MDF, NDF, Memory Optimized |
| F: | SQLLogs | Transaction Log |
| G: | SQLTempDB | TempDB |
| H: | SQLBackups | Backups y Auditoría |

Evidencia:

![Distribución de unidades](../04_evidencias/Azure/01_Distribucion_Unidades.jpeg)

## Unidad E: SQLData

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- SIGAU_Primary.mdf
- SIGAU_Core_01.ndf
- SIGAU_Academico_01.ndf
- SIGAU_Seguridad_01.ndf
- MemoryOptimized

Ruta:

E:\SQLServer\Data\SIGAU

## Unidad F: SQLLogs

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- SIGAU_Log.ldf

Ruta:

F:\SQLServer\Logs\SIGAU

## Unidad G: SQLTempDB

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- tempdb.mdf
- tempdb_mssql_2.ndf
- templog.ldf

Ruta:

G:\SQLServer\TempDB

## Unidad H: SQLBackups

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- Backups
- Auditoría SQL Server

Rutas:

H:\SQLServer\Backups\SIGAU

H:\SQLServer\Audit\SIGAU

## Validación SQL Server

Evidencia de archivos físicos:

![Filegroups y archivos](../04_evidencias/SQLServer/01_Distribucion_Filegroups.jpeg)
