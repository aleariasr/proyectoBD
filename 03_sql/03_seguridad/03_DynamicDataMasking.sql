USE SIGAU;
GO

/* =========================================================
   DYNAMIC DATA MASKING
   Proyecto IF-5100 - SIGAU

   Implementación comprobada en la VM:
   - core.IdentificacionPersona.NumeroIdentificacion
   - core.MedioContactoPersona.ValorContacto
   - core.DireccionPersona.DireccionDetallada
   - core.Sede.DireccionReferencia

   El rol Administrativo recibe UNMASK.
   Los demás roles observan los valores enmascarados.
   ========================================================= */


/* =========================================================
   1. Máscara de identificación personal
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID(N'core.IdentificacionPersona')
      AND name = N'NumeroIdentificacion'
      AND is_masked = 1
)
BEGIN
    ALTER TABLE core.IdentificacionPersona
    ALTER COLUMN NumeroIdentificacion
        VARCHAR(50)
        MASKED WITH
        (
            FUNCTION = 'partial(2,"XXXXXX",2)'
        )
        NOT NULL;
END;
GO


/* =========================================================
   2. Máscara de correo o medio de contacto
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID(N'core.MedioContactoPersona')
      AND name = N'ValorContacto'
      AND is_masked = 1
)
BEGIN
    ALTER TABLE core.MedioContactoPersona
    ALTER COLUMN ValorContacto
        VARCHAR(150)
        MASKED WITH
        (
            FUNCTION = 'email()'
        )
        NOT NULL;
END;
GO


/* =========================================================
   3. Máscara de dirección personal
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID(N'core.DireccionPersona')
      AND name = N'DireccionDetallada'
      AND is_masked = 1
)
BEGIN
    ALTER TABLE core.DireccionPersona
    ALTER COLUMN DireccionDetallada
        VARCHAR(300)
        MASKED WITH
        (
            FUNCTION = 'partial(10,"XXXX",8)'
        )
        NULL;
END;
GO


/* =========================================================
   4. Máscara de dirección de sede
   ========================================================= */

IF NOT EXISTS
(
    SELECT 1
    FROM sys.masked_columns
    WHERE object_id = OBJECT_ID(N'core.Sede')
      AND name = N'DireccionReferencia'
      AND is_masked = 1
)
BEGIN
    ALTER TABLE core.Sede
    ALTER COLUMN DireccionReferencia
        VARCHAR(300)
        MASKED WITH
        (
            FUNCTION = 'partial(12,"XXXX",6)'
        )
        NULL;
END;
GO


/* =========================================================
   5. Permiso UNMASK para el rol Administrativo
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'Administrativo') IS NOT NULL
BEGIN
    GRANT UNMASK TO Administrativo;
END;
GO


/* =========================================================
   6. Verificación de máscaras configuradas
   ========================================================= */

SELECT
    SCHEMA_NAME(t.schema_id) AS schema_name,
    t.name AS table_name,
    c.name AS column_name,
    TYPE_NAME(c.user_type_id) AS data_type,
    c.max_length,
    c.is_masked,
    c.masking_function
FROM sys.masked_columns AS c
JOIN sys.tables AS t
    ON c.object_id = t.object_id
WHERE c.is_masked = 1
ORDER BY
    schema_name,
    table_name,
    c.column_id;
GO


/* =========================================================
   7. Prueba funcional con usuario sin UNMASK
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'usuarioLectura') IS NOT NULL
BEGIN
    EXECUTE AS USER = N'usuarioLectura';

    SELECT
        NumeroIdentificacion
    FROM consulta.vw_IdentificacionPersona;

    SELECT
        ValorContacto
    FROM consulta.vw_MedioContactoPersona;

    SELECT
        DireccionDetallada
    FROM consulta.vw_DireccionPersona;

    SELECT
        DireccionReferencia
    FROM consulta.vw_Sede;

    REVERT;
END;
GO