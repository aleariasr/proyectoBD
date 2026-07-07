USE SIGAU;
GO

/* =========================================================
   VALIDACIONES REGEX AVANZADAS - SIGAU
   SQL Server 2025

   Objetivos:
   - Crear restricciones CHECK persistentes.
   - Evitar duplicarlas si ya existen.
   - Validar los datos actuales.
   - Confirmar que las restricciones estén activas y confiables.
   ========================================================= */

PRINT '1. Creación de restricciones CHECK con REGEXP_LIKE';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_MedioContactoPersona_Email_Formato'
      AND parent_object_id = OBJECT_ID('core.MedioContactoPersona')
)
BEGIN
    ALTER TABLE core.MedioContactoPersona
    WITH CHECK
    ADD CONSTRAINT CK_MedioContactoPersona_Email_Formato
    CHECK
    (
        REGEXP_LIKE
        (
            ValorContacto,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        )
        OR TipoMedioContactoID <> 1
    );

    ALTER TABLE core.MedioContactoPersona
    CHECK CONSTRAINT CK_MedioContactoPersona_Email_Formato;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_IdentificacionPersona_Formato'
      AND parent_object_id = OBJECT_ID('core.IdentificacionPersona')
)
BEGIN
    ALTER TABLE core.IdentificacionPersona
    WITH CHECK
    ADD CONSTRAINT CK_IdentificacionPersona_Formato
    CHECK
    (
        REGEXP_LIKE
        (
            NumeroIdentificacion,
            '^[1-9]-?[0-9]{4}-?[0-9]{4}$'
        )
    );

    ALTER TABLE core.IdentificacionPersona
    CHECK CONSTRAINT CK_IdentificacionPersona_Formato;
END;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = 'CK_Estudiante_Carnet_Formato'
      AND parent_object_id = OBJECT_ID('academico.Estudiante')
)
BEGIN
    ALTER TABLE academico.Estudiante
    WITH CHECK
    ADD CONSTRAINT CK_Estudiante_Carnet_Formato
    CHECK
    (
        REGEXP_LIKE
        (
            Carnet,
            '^[A-Z][0-9][A-Z][0-9]{3}$'
        )
    );

    ALTER TABLE academico.Estudiante
    CHECK CONSTRAINT CK_Estudiante_Carnet_Formato;
END;
GO

PRINT '2. Validación detallada de correos electrónicos';
GO

SELECT
    MedioContactoPersonaID,
    TipoMedioContactoID,
    ValorContacto AS Correo,
    CASE
        WHEN TipoMedioContactoID <> 1 THEN 'NO APLICA'
        WHEN REGEXP_LIKE
        (
            ValorContacto,
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
        )
        THEN 'VALIDO'
        ELSE 'INVALIDO'
    END AS EstadoValidacion
FROM core.MedioContactoPersona
ORDER BY MedioContactoPersonaID;
GO

PRINT '3. Validación detallada de identificaciones nacionales';
GO

SELECT
    IdentificacionPersonaID,
    NumeroIdentificacion AS Identificacion,
    CASE
        WHEN REGEXP_LIKE
        (
            NumeroIdentificacion,
            '^[1-9]-?[0-9]{4}-?[0-9]{4}$'
        )
        THEN 'VALIDA'
        ELSE 'INVALIDA'
    END AS EstadoValidacion
FROM core.IdentificacionPersona
ORDER BY IdentificacionPersonaID;
GO

PRINT '4. Validación detallada de carnés universitarios';
GO

SELECT
    EstudianteID,
    Carnet,
    CASE
        WHEN REGEXP_LIKE
        (
            Carnet,
            '^[A-Z][0-9][A-Z][0-9]{3}$'
        )
        THEN 'VALIDO'
        ELSE 'INVALIDO'
    END AS EstadoValidacion
FROM academico.Estudiante
ORDER BY EstudianteID;
GO

PRINT '5. Resumen general de validaciones REGEX';
GO

SELECT
    'Correos' AS TipoValidacion,
    COUNT(*) AS TotalRegistros,
    SUM
    (
        CASE
            WHEN TipoMedioContactoID <> 1
              OR REGEXP_LIKE
                 (
                     ValorContacto,
                     '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
                 )
            THEN 1
            ELSE 0
        END
    ) AS RegistrosValidos,
    SUM
    (
        CASE
            WHEN TipoMedioContactoID = 1
             AND NOT REGEXP_LIKE
                 (
                     ValorContacto,
                     '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
                 )
            THEN 1
            ELSE 0
        END
    ) AS RegistrosInvalidos
FROM core.MedioContactoPersona

UNION ALL

SELECT
    'Identificaciones',
    COUNT(*),
    SUM
    (
        CASE
            WHEN REGEXP_LIKE
                 (
                     NumeroIdentificacion,
                     '^[1-9]-?[0-9]{4}-?[0-9]{4}$'
                 )
            THEN 1
            ELSE 0
        END
    ),
    SUM
    (
        CASE
            WHEN NOT REGEXP_LIKE
                 (
                     NumeroIdentificacion,
                     '^[1-9]-?[0-9]{4}-?[0-9]{4}$'
                 )
            THEN 1
            ELSE 0
        END
    )
FROM core.IdentificacionPersona

UNION ALL

SELECT
    'Carnes UCR',
    COUNT(*),
    SUM
    (
        CASE
            WHEN REGEXP_LIKE
                 (
                     Carnet,
                     '^[A-Z][0-9][A-Z][0-9]{3}$'
                 )
            THEN 1
            ELSE 0
        END
    ),
    SUM
    (
        CASE
            WHEN NOT REGEXP_LIKE
                 (
                     Carnet,
                     '^[A-Z][0-9][A-Z][0-9]{3}$'
                 )
            THEN 1
            ELSE 0
        END
    )
FROM academico.Estudiante;
GO

PRINT '6. Estado de las restricciones CHECK';
GO

SELECT
    s.name AS Esquema,
    t.name AS Tabla,
    cc.name AS Restriccion,
    cc.is_disabled,
    cc.is_not_trusted,
    cc.definition
FROM sys.check_constraints AS cc
INNER JOIN sys.tables AS t
    ON cc.parent_object_id = t.object_id
INNER JOIN sys.schemas AS s
    ON t.schema_id = s.schema_id
WHERE cc.name IN
(
    'CK_MedioContactoPersona_Email_Formato',
    'CK_IdentificacionPersona_Formato',
    'CK_Estudiante_Carnet_Formato'
)
ORDER BY
    s.name,
    t.name,
    cc.name;
GO
