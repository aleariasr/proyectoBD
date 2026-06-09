USE SIGAU;
GO

/* =========================================================
   VALIDACIONES REGEX AVANZADAS - SIGAU
   SQL Server 2025
   ========================================================= */

PRINT '1. Validación de correos electrónicos';
GO

SELECT
    MedioContactoPersonaID,
    ValorContacto AS Correo,
    CASE
        WHEN REGEXP_LIKE(
            ValorContacto,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        )
        THEN 'VALIDO'
        ELSE 'INVALIDO'
    END AS EstadoValidacion
FROM core.MedioContactoPersona;
GO

PRINT '2. Validación de cédulas nacionales';
GO

SELECT
    IdentificacionPersonaID,
    NumeroIdentificacion AS Cedula,
    CASE
        WHEN REGEXP_LIKE(
            NumeroIdentificacion,
            '^[1-9]-?[0-9]{4}-?[0-9]{4}$'
        )
        THEN 'VALIDA'
        ELSE 'INVALIDA'
    END AS EstadoValidacion
FROM core.IdentificacionPersona;
GO

PRINT '3. Validación de carnés universitarios UCR';
GO

SELECT
    EstudianteID,
    Carnet,
    CASE
        WHEN REGEXP_LIKE(
            Carnet,
            '^[A-Z][0-9][A-Z][0-9]{3}$'
        )
        THEN 'VALIDO'
        ELSE 'INVALIDO'
    END AS EstadoValidacion
FROM academico.Estudiante;
GO

PRINT '4. Resumen general de validaciones REGEX';
GO

SELECT
    'Correos' AS TipoValidacion,
    COUNT(*) AS TotalRegistros,
    SUM(CASE WHEN REGEXP_LIKE(ValorContacto, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END) AS RegistrosValidos,
    SUM(CASE WHEN NOT REGEXP_LIKE(ValorContacto, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN 1 ELSE 0 END) AS RegistrosInvalidos
FROM core.MedioContactoPersona

UNION ALL

SELECT
    'Cedulas',
    COUNT(*),
    SUM(CASE WHEN REGEXP_LIKE(NumeroIdentificacion, '^[1-9]-?[0-9]{4}-?[0-9]{4}$') THEN 1 ELSE 0 END),
    SUM(CASE WHEN NOT REGEXP_LIKE(NumeroIdentificacion, '^[1-9]-?[0-9]{4}-?[0-9]{4}$') THEN 1 ELSE 0 END)
FROM core.IdentificacionPersona

UNION ALL

SELECT
    'Carnes UCR',
    COUNT(*),
    SUM(CASE WHEN REGEXP_LIKE(Carnet, '^[A-Z][0-9][A-Z][0-9]{3}$') THEN 1 ELSE 0 END),
    SUM(CASE WHEN NOT REGEXP_LIKE(Carnet, '^[A-Z][0-9][A-Z][0-9]{3}$') THEN 1 ELSE 0 END)
FROM academico.Estudiante;
GO