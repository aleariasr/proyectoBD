# SIGAU

Sistema Integral de Gestión Académica Universitaria

Proyecto Final - IF-5100 Administración de Bases de Datos  
Universidad de Costa Rica - Sede de Occidente  
I Ciclo 2026

## Integrantes

- Alejandro Arias Rojas (C4C759)
- Mariangel Arias Alfaro (C4C688)
- Sebastián Alfaro Arias (C4C212)

## Descripción

SIGAU es una solución de gestión académico-administrativa universitaria desarrollada sobre Microsoft SQL Server 2025. El sistema centraliza la administración de personas, estudiantes, profesores, unidades académicas, matrícula, historial académico y procesos administrativos, incorporando mecanismos avanzados de seguridad, auditoría y administración de datos.

## Tecnologías utilizadas

- Microsoft Azure
- Windows Server 2025
- SQL Server 2025 Enterprise Evaluation
- CIS Microsoft Windows Server 2025 Benchmark v2.0.0
- CIS Microsoft SQL Server 2022 Benchmark v1.2.1

## Características implementadas

### Administración de datos

- Esquema académico
- Esquema administrativo
- Integridad referencial
- Restricciones CHECK
- Procedimientos almacenados
- Vistas de consulta

### Seguridad

- Roles personalizados
- Dynamic Data Masking
- Row Level Security
- Esquema de seguridad independiente
- Auditoría de accesos

### Rendimiento

- Filegroups especializados
- Tabla In-Memory OLTP
- Separación física de datos y logs
- TempDB dedicado

### Funcionalidades modernas

- Exportación JSON
- Consumo de API REST
- Soporte para Vector Search
- Preparación para búsqueda semántica

## Distribución de almacenamiento

| Unidad | Propósito |
|----------|----------|
| E: | Datos MDF, NDF e In-Memory |
| F: | Transaction Logs |
| G: | TempDB |
| H: | Backups y Auditoría |

## Estructura del repositorio

01_enunciado → documentación oficial del proyecto  
02_documentacion → análisis, diseño y documentación técnica  
03_sql → scripts SQL organizados por componente  
04_evidencias → capturas y validaciones  
05_backups → respaldos del proyecto  
06_azure → configuración de infraestructura  
07_pruebas → pruebas funcionales y validaciones

## Estado actual

- Infraestructura Azure desplegada
- SQL Server 2025 instalado
- Hardening CIS aplicado
- Base de datos SIGAU creada
- Filegroups configurados
- Seguridad implementada
- Auditoría configurada
- Pendiente: carga de datos y pruebas finales