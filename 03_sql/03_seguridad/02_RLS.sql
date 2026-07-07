USE SIGAU;
GO

/* =========================================================
   ROW-LEVEL SECURITY POR SEDE
   Proyecto IF-5100 - SIGAU

   Implementación comprobada en la VM:
   - seguridad.UsuarioSede
   - seguridad.fn_FiltroSede
   - Policy_EscuelaPorSede
   - Policy_UnidadPorSede

   Objetivo:
   Limitar la visibilidad de registros según la sede asignada
   al usuario de base de datos.
   ========================================================= */


/* =========================================================
   1. Tabla de relación entre usuario y sede
   ========================================================= */

IF OBJECT_ID(N'seguridad.UsuarioSede', N'U') IS NULL
BEGIN
    CREATE TABLE seguridad.UsuarioSede
    (
        UsuarioSedeID INT IDENTITY(1,1) NOT NULL,
        UsuarioBD SYSNAME NOT NULL,
        SedeID INT NOT NULL,
        Estado BIT NOT NULL
            CONSTRAINT DF_UsuarioSede_Estado DEFAULT (1),

        CONSTRAINT PK_UsuarioSede
            PRIMARY KEY CLUSTERED (UsuarioSedeID),

        CONSTRAINT FK_UsuarioSede_Sede
            FOREIGN KEY (SedeID)
            REFERENCES core.Sede(SedeID),

        CONSTRAINT UQ_UsuarioSede_Usuario_Sede
            UNIQUE (UsuarioBD, SedeID)
    )
    ON FG_SIGAU_SEGURIDAD;
END;
GO


/* =========================================================
   2. Función de filtrado por sede

   dbo puede consultar todas las sedes.
   Los demás usuarios solo pueden consultar las sedes
   registradas como activas en seguridad.UsuarioSede.
   ========================================================= */

CREATE OR ALTER FUNCTION seguridad.fn_FiltroSede
(
    @SedeID INT
)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
(
    SELECT 1 AS fn_result
    WHERE
        USER_NAME() = N'dbo'
        OR EXISTS
        (
            SELECT 1
            FROM seguridad.UsuarioSede AS us
            WHERE us.UsuarioBD = USER_NAME()
              AND us.SedeID = @SedeID
              AND us.Estado = 1
        )
);
GO


/* =========================================================
   3. Eliminar políticas anteriores para permitir
      una instalación repetible del script
   ========================================================= */

IF EXISTS
(
    SELECT 1
    FROM sys.security_policies
    WHERE name = N'Policy_EscuelaPorSede'
      AND schema_id = SCHEMA_ID(N'seguridad')
)
BEGIN
    DROP SECURITY POLICY seguridad.Policy_EscuelaPorSede;
END;
GO

IF EXISTS
(
    SELECT 1
    FROM sys.security_policies
    WHERE name = N'Policy_UnidadPorSede'
      AND schema_id = SCHEMA_ID(N'seguridad')
)
BEGIN
    DROP SECURITY POLICY seguridad.Policy_UnidadPorSede;
END;
GO


/* =========================================================
   4. Política para academico.Escuela
   ========================================================= */

CREATE SECURITY POLICY seguridad.Policy_EscuelaPorSede
ADD FILTER PREDICATE seguridad.fn_FiltroSede(SedeID)
ON academico.Escuela
WITH
(
    STATE = ON,
    SCHEMABINDING = ON
);
GO


/* =========================================================
   5. Política para admin.UnidadAdministrativa
   ========================================================= */

CREATE SECURITY POLICY seguridad.Policy_UnidadPorSede
ADD FILTER PREDICATE seguridad.fn_FiltroSede(SedeID)
ON admin.UnidadAdministrativa
WITH
(
    STATE = ON,
    SCHEMABINDING = ON
);
GO


/* =========================================================
   6. Usuarios de prueba sin login

   Se crean solo si no existen.
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'usuario_occidente') IS NULL
    CREATE USER usuario_occidente WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_grecia') IS NULL
    CREATE USER usuario_grecia WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_tacares') IS NULL
    CREATE USER usuario_tacares WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_rodrigo_facio') IS NULL
    CREATE USER usuario_rodrigo_facio WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_caribe') IS NULL
    CREATE USER usuario_caribe WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_guanacaste') IS NULL
    CREATE USER usuario_guanacaste WITHOUT LOGIN;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_pacifico') IS NULL
    CREATE USER usuario_pacifico WITHOUT LOGIN;
GO


/* =========================================================
   7. Asignación de usuarios al rol de lectura
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'LecturaGeneral') IS NOT NULL
BEGIN
    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_occidente') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_occidente;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_grecia') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_grecia;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_tacares') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_tacares;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_rodrigo_facio') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_rodrigo_facio;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_caribe') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_caribe;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_guanacaste') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_guanacaste;

    IF IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_pacifico') <> 1
        ALTER ROLE LecturaGeneral ADD MEMBER usuario_pacifico;
END;
GO


/* =========================================================
   8. Mapeo de usuarios por sede

   Los SedeID corresponden a la implementación actual:
   1 = Occidente
   2 = Grecia
   3 = Tacares
   4 = Rodrigo Facio
   5 = Caribe
   6 = Guanacaste
   7 = Pacífico
   ========================================================= */

MERGE seguridad.UsuarioSede AS destino
USING
(
    VALUES
        (N'usuario_occidente',      1, 1),
        (N'usuario_grecia',         2, 1),
        (N'usuario_tacares',        3, 1),
        (N'usuario_rodrigo_facio',  4, 1),
        (N'usuario_caribe',         5, 1),
        (N'usuario_guanacaste',     6, 1),
        (N'usuario_pacifico',       7, 1)
) AS origen
(
    UsuarioBD,
    SedeID,
    Estado
)
ON destino.UsuarioBD = origen.UsuarioBD
AND destino.SedeID = origen.SedeID

WHEN MATCHED THEN
    UPDATE SET
        destino.Estado = origen.Estado

WHEN NOT MATCHED THEN
    INSERT
    (
        UsuarioBD,
        SedeID,
        Estado
    )
    VALUES
    (
        origen.UsuarioBD,
        origen.SedeID,
        origen.Estado
    );
GO


/* =========================================================
   9. Verificación de políticas
   ========================================================= */

SELECT
    sp.name AS policy_name,
    sp.is_enabled,
    spr.security_predicate_id,
    OBJECT_SCHEMA_NAME(spr.target_object_id) AS target_schema,
    OBJECT_NAME(spr.target_object_id) AS target_table,
    spr.predicate_type_desc,
    spr.operation_desc,
    spr.predicate_definition
FROM sys.security_policies AS sp
JOIN sys.security_predicates AS spr
    ON sp.object_id = spr.object_id
WHERE sp.name IN
(
    N'Policy_EscuelaPorSede',
    N'Policy_UnidadPorSede'
)
ORDER BY
    sp.name,
    target_schema,
    target_table;
GO


/* =========================================================
   10. Pruebas funcionales
   ========================================================= */

EXECUTE AS USER = N'usuario_grecia';

SELECT
    USER_NAME() AS UsuarioActual;

SELECT *
FROM consulta.vw_Escuela;

SELECT *
FROM consulta.vw_UnidadAdministrativa;

REVERT;
GO


EXECUTE AS USER = N'usuario_occidente';

SELECT
    USER_NAME() AS UsuarioActual;

SELECT *
FROM consulta.vw_Escuela;

SELECT *
FROM consulta.vw_UnidadAdministrativa;

REVERT;
GO