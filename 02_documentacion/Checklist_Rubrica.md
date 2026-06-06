# Checklist de Rúbrica IF-5100

| Rubro | Valor | Estado | Script Principal | Documento | Evidencia |
|---------|---------:|---------|---------|---------|---------|
| Instalación y configuración del ecosistema | 10 | Implementado | N/A | ../06_azure/Configuracion_VM.md | ../04_evidencias/Azure |
| Hardening plataforma operativa | 5 | Implementado | ../06_azure/hardening_scripts | ../06_azure/Hardening_CIS.md | ../04_evidencias/Seguridad/CIS_WS2025 |
| Instalación y configuración SGBDR | 5 | Implementado | ../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql | Arquitectura.md | ../04_evidencias/SQLServer |
| Hardening SGBDR | 5 | Parcial | ../03_sql/03_seguridad/01_Roles.sql | Hardening_SQL_Server.md | ../04_evidencias/SQLServer_CIS |
| Configuración Antimalware | 1 | Pendiente evidencia | N/A | Antimalware_SQL_Server.md | ../04_evidencias/Antimalware |
| Modelo lógico de datos | 10 | Implementado | ../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql | Modelo_Datos.md | ../02_documentacion/DiagramaBD.drawio.png |
| Diseño físico y distribución LUNs | 5 | Implementado | ../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql | ../06_azure/Discos.md | ../04_evidencias/Azure |
| In-Memory OLTP | 3 | Implementado | ../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql | Arquitectura.md | ../04_evidencias/SQLServer |
| Población mínima de datos | 2 | Implementado | ../03_sql/02_poblacion | Modelo_Datos.md | ../04_evidencias/Pruebas/01_Conteo_Registros_Tablas.jpeg |
| Vistas por tabla | 2 | Implementado | ../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql | Arquitectura.md | Validado mediante consultas |
| Roles y permisos | 2 | Implementado | ../03_sql/03_seguridad/01_Roles.sql | Seguridad.md | ../04_evidencias/Seguridad |
| Dynamic Data Masking | 4 | Implementado | ../03_sql/03_seguridad/03_DynamicDataMasking.sql | Seguridad.md | ../04_evidencias/Seguridad/01_DynamicDataMasking.jpeg |
| Row Level Security | 2 | Implementado | ../03_sql/03_seguridad/02_RLS.sql | Seguridad.md | ../04_evidencias/Seguridad/02_RowLevelSecurity.jpeg |
| Auditoría SQL Server | 5 | Implementado | ../03_sql/04_auditoria/01_Audit_SIGAU.sql | Seguridad.md | ../04_evidencias/Auditoria |
| Backup y Restore | Complementario | Implementado | ../03_sql/05_backup_restore | Arquitectura.md | ../04_evidencias/Backups |
| Serialización JSON | 5 | Implementado | ../03_sql/06_json_api_vector/01_JSON.sql | External_API_Calls.md | ../04_evidencias/Pruebas/02_Exportacion_JSON_Personas.jpeg |
| External API Calls | 5 | En proceso | ../03_sql/06_json_api_vector/02_REST_API.sql | External_API_Calls.md | ../04_evidencias/API |
| Vector Data and Semantic Search | 5 | En proceso | ../03_sql/06_json_api_vector/03_VectorSearch.sql | Vector_Search.md | ../04_evidencias/VectorSearch |
| Expresiones Regulares Avanzadas | 5 | Pendiente | ../03_sql/07_validaciones/01_Pruebas_Finales.sql | Regex_Avanzado.md | ../04_evidencias/Regex |
| Azure SQL Database PaaS | 10 | Pendiente | Migración por definir | Azure_SQL_Database.md | ../04_evidencias/AzureSQL |

## Resumen Ejecutivo

### Componentes implementados

- Infraestructura Azure.
- Windows Server 2025.
- SQL Server 2025.
- Filegroups y distribución física.
- Recovery Model FULL.
- In-Memory OLTP.
- Hardening Windows Server.
- Roles y permisos.
- Dynamic Data Masking.
- Row Level Security.
- Auditoría SQL Server.
- Población de datos.
- Backup y Restore.
- Exportación JSON.

### Componentes en desarrollo

- External API Calls.
- Vector Data and Semantic Search.

### Componentes pendientes

- Expresiones Regulares Avanzadas.
- Azure SQL Database PaaS.
- Evidencias CIS SQL Server.
- Evidencia Antimalware SQL Server.

## Avance estimado

| Área | Avance |
|---------|---------|
| Infraestructura | 100% |
| SQL Server | 100% |
| Seguridad | 95% |
| Auditoría | 100% |
| Recuperación | 100% |
| JSON | 100% |
| API REST | 60% |
| Vector Search | 40% |
| Regex | 0% |
| Azure SQL Database | 0% |

**Avance global estimado: 85% – 90%**