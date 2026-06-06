# Arquitectura del Proyecto SIGAU

## Descripción General

SIGAU (Sistema Integral de Gestión Académica Universitaria) fue diseñado bajo una arquitectura lógica orientada a capas dentro de Microsoft SQL Server 2025, separando componentes funcionales, seguridad y almacenamiento físico para mejorar mantenibilidad, rendimiento y escalabilidad.

## Arquitectura Lógica

Usuarios

↓

Roles de Seguridad

↓

Vistas y Procedimientos Almacenados

↓

Esquemas de Negocio

↓

Tablas

↓

Filegroups Especializados

↓

Almacenamiento Físico

## Esquemas Implementados

### core

Contiene información base institucional:

- Persona
- Sede
- Tipos de identificación
- Direcciones
- Medios de contacto

### academico

Gestiona la operación académica:

- Escuela
- Plan de estudio
- Curso
- Grupo
- Matrícula
- Historial académico
- Profesor
- Estudiante

### admin

Gestiona procesos administrativos:

- UnidadAdministrativa
- Administrativo
- Nombramiento

### seguridad

Componentes de seguridad:

- UsuarioSede
- BitacoraAcceso
- Row Level Security
- Auditoría

### api

Integración externa:

- ConsultaExterna
- Procedimientos REST
- Exportación JSON

### consulta

Vistas de acceso para usuarios finales.

## Arquitectura Física

La base de datos fue distribuida utilizando múltiples filegroups.

### FG_SIGAU_CORE

Información institucional principal.

### FG_SIGAU_ACADEMICO

Información académica.

### FG_SIGAU_SEGURIDAD

Objetos relacionados con seguridad.

### FG_SIGAU_MEMORY_OPTIMIZED

Datos In-Memory OLTP.

## Distribución de almacenamiento

### Unidad E

Datos principales:

- MDF
- NDF
- Memory Optimized

### Unidad F

Transaction Logs.

### Unidad G

TempDB.

### Unidad H

Backups y Auditoría.

## Componentes avanzados implementados

- Dynamic Data Masking
- Row Level Security
- SQL Server Audit
- In-Memory OLTP
- JSON
- REST API
- Vector Search
- Filegroups especializados
- Roles personalizados