USE SIGAU;
GO

/* =========================================================
   SERIALIZACIÓN JSON DE PERSONAS
   Proyecto IF-5100 - SIGAU

   Exporta toda la información principal de las personas:
   - Datos personales
   - Identificación principal
   - Medio de contacto principal
   - Dirección principal
   ========================================================= */

CREATE OR ALTER PROCEDURE api.usp_ExportarPersonasJSON
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.PersonaID,
        p.PrimerNombre,
        p.SegundoNombre,
        p.PrimerApellido,
        p.SegundoApellido,
        p.FechaNacimiento,
        p.FechaCreacion,
        p.Estado,
        ip.NumeroIdentificacion,
        mc.ValorContacto AS Correo,
        dp.DireccionDetallada
    FROM core.Persona AS p
    LEFT JOIN core.IdentificacionPersona AS ip
        ON p.PersonaID = ip.PersonaID
       AND ip.EsPrincipal = 1
    LEFT JOIN core.MedioContactoPersona AS mc
        ON p.PersonaID = mc.PersonaID
       AND mc.EsPrincipal = 1
    LEFT JOIN core.DireccionPersona AS dp
        ON p.PersonaID = dp.PersonaID
       AND dp.EsPrincipal = 1
    ORDER BY p.PersonaID
    FOR JSON PATH, ROOT('Personas');
END;
GO

/* Ejecución funcional */
EXEC api.usp_ExportarPersonasJSON;
GO

/* Verificación objetiva */
DECLARE @json NVARCHAR(MAX);

SELECT @json =
(
    SELECT
        p.PersonaID,
        p.PrimerNombre,
        p.SegundoNombre,
        p.PrimerApellido,
        p.SegundoApellido,
        p.FechaNacimiento,
        p.FechaCreacion,
        p.Estado,
        ip.NumeroIdentificacion,
        mc.ValorContacto AS Correo,
        dp.DireccionDetallada
    FROM core.Persona AS p
    LEFT JOIN core.IdentificacionPersona AS ip
        ON p.PersonaID = ip.PersonaID
       AND ip.EsPrincipal = 1
    LEFT JOIN core.MedioContactoPersona AS mc
        ON p.PersonaID = mc.PersonaID
       AND mc.EsPrincipal = 1
    LEFT JOIN core.DireccionPersona AS dp
        ON p.PersonaID = dp.PersonaID
       AND dp.EsPrincipal = 1
    ORDER BY p.PersonaID
    FOR JSON PATH, ROOT('Personas')
);

SELECT
    ISJSON(@json) AS EsJSONValido,
    (
        SELECT COUNT(*)
        FROM OPENJSON(@json, '$.Personas')
    ) AS PersonasSerializadas,
    (
        SELECT COUNT(*)
        FROM core.Persona
    ) AS PersonasEnTabla;
GO