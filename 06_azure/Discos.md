# Configuración de almacenamiento SQL Server

## Objetivo

Separar físicamente los distintos componentes de SQL Server para mejorar rendimiento, administración y recuperación.

## Distribución implementada

### Unidad E: SQLData

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- Archivo MDF principal
- Filegroup FG_SIGAU_CORE
- Filegroup FG_SIGAU_ACADEMICO
- Filegroup FG_SIGAU_SEGURIDAD
- Filegroup Memory Optimized

Ruta:

E:\SQLServer\Data\SIGAU

### Unidad F: SQLLogs

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- Transaction Log (.ldf)

Ruta:

F:\SQLServer\Logs\SIGAU

### Unidad G: SQLTempDB

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- tempdb.mdf
- tempdb_mssql_2.ndf
- templog.ldf

Ruta:

G:\SQLServer\TempDB

### Unidad H: SQLBackups

Formato: NTFS  
Allocation Unit Size: 64 KB

Contiene:

- Backups
- Auditoría SQL Server

Rutas:

H:\SQLServer\Backups\SIGAU

H:\SQLServer\Audit\SIGAU

## Verificación

La configuración fue validada mediante consultas a:

- sys.database_files
- sys.filegroups
- Get-Volume
- Get-ChildItem

confirmando la correcta separación física de archivos.