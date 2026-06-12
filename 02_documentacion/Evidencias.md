# Evidencias del Proyecto SIGAU

Este documento centraliza las evidencias generadas durante la implementación del proyecto.

## Infraestructura Azure

### Distribución de unidades

![Distribución de unidades](../04_evidencias/Azure/01_Distribucion_Unidades.jpeg)

Evidencia de las unidades configuradas para separar datos, logs, TempDB, backups y auditoría.

### Usuarios locales

![Usuarios locales](../04_evidencias/Azure/02_Usuarios_Locales.jpeg)

Evidencia de usuarios locales configurados en la máquina virtual.

### Grupo Administrators

![Grupo Administrators](../04_evidencias/Azure/03_Administrators_Group.jpeg)

Evidencia de los usuarios con privilegios administrativos.

## SQL Server

### Distribución de filegroups y archivos físicos

![Distribución de filegroups](../04_evidencias/SQLServer/01_Distribucion_Filegroups.jpeg)

Evidencia de la separación de archivos MDF, NDF, LDF y Memory Optimized.

### Recovery Model FULL

![Recovery Model FULL](../04_evidencias/SQLServer/02_RecoveryModel_FULL.jpeg)

Evidencia de que SIGAU utiliza modelo de recuperación FULL.

### SQL Server 2025 instalado

![SQL Server 2025](../04_evidencias/SQLServer/03_SQLServer2025_Instalado.jpeg)

Evidencia de versión y edición del motor instalado.

## Auditoría

### Server Audit

![Server Audit](../04_evidencias/Auditoria/01_ServerAudit_SIGAU.jpeg)

Evidencia de auditoría de servidor configurada.

### Database Audit Specification

![Database Audit](../04_evidencias/Auditoria/02_DatabaseAudit_SIGAU.jpeg)

Evidencia de especificación de auditoría configurada sobre la base SIGAU.

## Seguridad

### Dynamic Data Masking

![Dynamic Data Masking](../04_evidencias/Seguridad/01_DynamicDataMasking.jpeg)

Demuestra que cédulas, direcciones y correos se presentan enmascarados para usuarios con permisos limitados.

### Row Level Security

![Row Level Security](../04_evidencias/Seguridad/02_RowLevelSecurity.jpeg)

Demuestra filtrado de registros por sede.

### Hardening CIS Windows Server 2025

- [Reporte CSV](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.csv)
- [Resumen TXT](../04_evidencias/Seguridad/CIS_WS2025/CIS_WS2025_Verification_20260428_172121.txt)

## Población de datos

### Conteo de registros por tabla

![Conteo de registros](../04_evidencias/Pruebas/01_Conteo_Registros_Tablas.jpeg)

Demuestra que todas las tablas poseen al menos 10 registros.

## Serialización JSON

![Exportación JSON](../04_evidencias/Pruebas/02_Exportacion_JSON_Personas.jpeg)

Demuestra la generación de salida JSON desde SQL Server.

## Backup y Restore

### Backup completo

![Backup completo](../04_evidencias/Backups/01_Backup_Completo_SIGAU.jpeg)

Backup completo de SIGAU almacenado en la unidad H.

### Restore de prueba

![Restore de prueba](../04_evidencias/Backups/02_Restore_Test_SIGAU.jpeg)

Restauración completa en la base SIGAU_RESTORE_TEST.

## Funcionalidades Modernas

### REST API

![REST API](../04_evidencias/Pruebas/03_REST_API.png)

Demuestra el consumo de servicios REST externos mediante sp_invoke_external_rest_endpoint, utilizando JSONPlaceholder y obteniendo una respuesta HTTP 200 satisfactoria.

### Vector Search

![Vector Search](../04_evidencias/Pruebas/04_Vector_Search.png)

Demuestra el almacenamiento de embeddings mediante el tipo VECTOR y la búsqueda semántica utilizando distancia vectorial sobre los cursos registrados en SIGAU.

### Expresiones Regulares Avanzadas

![Expresiones Regulares](../04_evidencias/Pruebas/05_Regex_Avanzado_01.png)
![Expresiones Regulares](../04_evidencias/Pruebas/06_Regex_Avanzado_02.png)
![Expresiones Regulares](../04_evidencias/Pruebas/07_Regex_Avanzado_03.png)

Demuestra el uso de REGEXP_LIKE para validar correos electrónicos, números de identificación y carnés universitarios utilizando las capacidades nativas de SQL Server 2025.

## Azure SQL Database PaaS

### Implementación en Azure SQL Database

![Azure SQL Database](../04_evidencias/Azure/04_Azure_SQL_Database.png)

Demuestra la ejecución de SIGAU sobre Azure SQL Database, validando la conexión al servicio, la existencia de los datos y la ejecución correcta de consultas sobre la plataforma PaaS.


