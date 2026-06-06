# Checklist de Rúbrica IF-5100

## Resumen General

| Rubro | Valor | Estado |
|---------|---------:|---------|
| Instalación y configuración del ecosistema | 10 | ✅ Implementado |
| Hardening plataforma operativa | 5 | ✅ Implementado |
| Instalación y configuración SGBDR | 5 | ✅ Implementado |
| Hardening SGBDR | 5 | ⚠️ Parcial |
| Configuración Antimalware | 1 | ⚠️ Pendiente evidencia |
| Modelo lógico de datos | 10 | ✅ Implementado |
| Diseño físico y distribución LUNs | 5 | ✅ Implementado |
| In-Memory OLTP | 3 | ✅ Implementado |
| Población mínima de datos | 2 | ✅ Implementado |
| Vistas por tabla | 2 | ✅ Implementado |
| Roles y permisos | 2 | ✅ Implementado |
| Dynamic Data Masking | 4 | ✅ Implementado |
| Row Level Security | 2 | ✅ Implementado |
| Auditoría SQL Server | 5 | ✅ Implementado |
| Serialización JSON | 5 | ✅ Implementado |
| External API Calls | 5 | ⚠️ En proceso |
| Vector Data and Semantic Search | 5 | ⚠️ En proceso |
| Expresiones Regulares Avanzadas | 5 | ❌ Pendiente |
| Azure SQL Database PaaS | 10 | ❌ Pendiente |

---

# Instalación y Configuración del Ecosistema

**Documentación**

- [Configuración de VM](../06_azure/Configuracion_VM.md)

**Evidencias**

- Carpeta: `04_evidencias/Azure`

---

# Hardening Plataforma Operativa

**Documentación**

- [Hardening CIS Windows Server](../06_azure/Hardening_CIS.md)

**Evidencias**

- Carpeta: `04_evidencias/Seguridad/CIS_WS2025`

---

# Instalación y Configuración del SGBDR

**Script**

- [01_SIGAU_CreacionBD_v1_0.sql](../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql)

**Documentación**

- [Arquitectura](Arquitectura.md)

**Evidencias**

- Carpeta: `04_evidencias/SQLServer`

---

# Hardening SQL Server

**Documentación**

- [Hardening SQL Server](Hardening_SQL_Server.md)

**Evidencias**

- Carpeta: `04_evidencias/SQLServer_CIS`

**Estado**

Pendiente completar evidencias específicas CIS SQL Server.

---

# Configuración Antimalware

**Documentación**

- [Antimalware SQL Server](Antimalware_SQL_Server.md)

**Evidencias**

- Carpeta: `04_evidencias/Antimalware`

---

# Modelo Lógico de Datos

**Documentación**

- [Modelo de Datos](Modelo_Datos.md)

**Diagramas**

- `DiagramaBD.drawio`
- `DiagramaBD.drawio.png`

---

# Diseño Físico y Distribución LUNs

**Documentación**

- [Discos y LUNs](../06_azure/Discos.md)
- [Arquitectura](Arquitectura.md)

**Evidencias**

- `04_evidencias/Azure`
- `04_evidencias/SQLServer`

---

# In-Memory OLTP

**Implementación**

- Tabla `seguridad.BitacoraAcceso`

**Documentación**

- [Arquitectura](Arquitectura.md)

---

# Población de Datos

**Scripts**

- [Datos Maestros](../03_sql/02_poblacion/01_DatosMaestros.sql)
- [Datos Académicos](../03_sql/02_poblacion/02_DatosAcademicos.sql)
- [Datos Administrativos](../03_sql/02_poblacion/03_DatosAdministrativos.sql)

**Evidencia**

- `04_evidencias/Pruebas/01_Conteo_Registros_Tablas.jpeg`

---

# Roles y Permisos

**Script**

- [01_Roles.sql](../03_sql/03_seguridad/01_Roles.sql)

**Documentación**

- [Seguridad](Seguridad.md)

---

# Dynamic Data Masking

**Script**

- [03_DynamicDataMasking.sql](../03_sql/03_seguridad/03_DynamicDataMasking.sql)

**Evidencia**

- `04_evidencias/Seguridad/01_DynamicDataMasking.jpeg`

---

# Row Level Security

**Script**

- [02_RLS.sql](../03_sql/03_seguridad/02_RLS.sql)

**Evidencia**

- `04_evidencias/Seguridad/02_RowLevelSecurity.jpeg`

---

# Auditoría SQL Server

**Script**

- [01_Audit_SIGAU.sql](../03_sql/04_auditoria/01_Audit_SIGAU.sql)

**Evidencias**

- Carpeta: `04_evidencias/Auditoria`

---

# Backup y Restore

**Scripts**

- [01_Backup_Completo.sql](../03_sql/05_backup_restore/01_Backup_Completo.sql)
- [02_Restore.sql](../03_sql/05_backup_restore/02_Restore.sql)

**Evidencias**

- Carpeta: `04_evidencias/Backups`

---

# Serialización JSON

**Script**

- [01_JSON.sql](../03_sql/06_json_api_vector/01_JSON.sql)

**Evidencia**

- `04_evidencias/Pruebas/02_Exportacion_JSON_Personas.jpeg`

---

# External API Calls

**Script**

- [02_REST_API.sql](../03_sql/06_json_api_vector/02_REST_API.sql)

**Documentación**

- [External API Calls](External_API_Calls.md)

**Estado**

En proceso.

---

# Vector Data and Semantic Search

**Script**

- [03_VectorSearch.sql](../03_sql/06_json_api_vector/03_VectorSearch.sql)

**Documentación**

- [Vector Search](Vector_Search.md)

**Estado**

En proceso.

---

# Expresiones Regulares Avanzadas

**Script**

- [01_Pruebas_Finales.sql](../03_sql/07_validaciones/01_Pruebas_Finales.sql)

**Documentación**

- [Regex Avanzado](Regex_Avanzado.md)

**Estado**

Pendiente.

---

# Azure SQL Database PaaS

**Documentación**

- [Azure SQL Database](Azure_SQL_Database.md)

**Evidencias**

- Carpeta: `04_evidencias/AzureSQL`

**Estado**

Pendiente.

---

# Avance General del Proyecto

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

**Avance global estimado: 90