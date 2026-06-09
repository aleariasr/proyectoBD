USE SIGAU;
GO

/* =========================================================
   PRUEBAS FINALES - SIGAU
   IF-5100 Administración de Bases de Datos
   ========================================================= */

PRINT 'Validación general de objetos principales del proyecto SIGAU';
GO

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    t.is_memory_optimized
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;
GO

PRINT 'Validación de vistas creadas';
GO

SELECT
    s.name AS SchemaName,
    v.name AS ViewName
FROM sys.views v
INNER JOIN sys.schemas s
    ON v.schema_id = s.schema_id
ORDER BY s.name, v.name;
GO

PRINT 'Validación de roles de base de datos';
GO

SELECT
    name AS DatabaseRole,
    type_desc
FROM sys.database_principals
WHERE type = 'R'
  AND name IN ('Administrativo', 'Mantenimiento', 'LecturaGeneral')
ORDER BY name;
GO

PRINT 'Validación de archivos físicos y filegroups';
GO

SELECT
    name,
    type_desc,
    physical_name,
    size * 8 / 1024 AS SizeMB
FROM sys.database_files;
GO

PRINT 'Validación de registros por tabla';
GO

SELECT 'core.Persona' AS Tabla, COUNT(*) AS Registros FROM core.Persona
UNION ALL SELECT 'core.IdentificacionPersona', COUNT(*) FROM core.IdentificacionPersona
UNION ALL SELECT 'core.MedioContactoPersona', COUNT(*) FROM core.MedioContactoPersona
UNION ALL SELECT 'academico.Estudiante', COUNT(*) FROM academico.Estudiante
UNION ALL SELECT 'academico.Curso', COUNT(*) FROM academico.Curso
UNION ALL SELECT 'academico.Matricula', COUNT(*) FROM academico.Matricula
UNION ALL SELECT 'admin.Administrativo', COUNT(*) FROM admin.Administrativo
UNION ALL SELECT 'api.ConsultaExterna', COUNT(*) FROM api.ConsultaExterna;
GO

PRINT 'Pruebas finales ejecutadas correctamente.';
GO