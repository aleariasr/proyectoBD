USE SIGAU;
GO

/* =========================================================
   ROLES Y PERMISOS DE BASE DE DATOS
   Proyecto IF-5100 - SIGAU

   Principios:
   - Toda lectura se realiza mediante vistas del esquema consulta.
   - No se concede SELECT sobre tablas base.
   - Los permisos se administran mediante roles.
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'Administrativo') IS NULL
    CREATE ROLE Administrativo;
GO

IF DATABASE_PRINCIPAL_ID(N'Mantenimiento') IS NULL
    CREATE ROLE Mantenimiento;
GO

IF DATABASE_PRINCIPAL_ID(N'LecturaGeneral') IS NULL
    CREATE ROLE LecturaGeneral;
GO

/* Eliminar permisos de lectura directa heredados de versiones anteriores */
DENY SELECT ON SCHEMA::core TO Administrativo;
DENY SELECT ON SCHEMA::academico TO Administrativo;
DENY SELECT ON SCHEMA::admin TO Administrativo;
DENY SELECT ON SCHEMA::seguridad TO Administrativo;
DENY SELECT ON SCHEMA::api TO Administrativo;

DENY SELECT ON SCHEMA::core TO Mantenimiento;
DENY SELECT ON SCHEMA::academico TO Mantenimiento;
DENY SELECT ON SCHEMA::admin TO Mantenimiento;
DENY SELECT ON SCHEMA::seguridad TO Mantenimiento;
DENY SELECT ON SCHEMA::api TO Mantenimiento;
GO

/* =========================================================
   ADMINISTRATIVO
   Lectura por vistas y escritura sobre todas las áreas.
   Puede visualizar datos enmascarados.
   ========================================================= */

GRANT SELECT ON SCHEMA::consulta TO Administrativo;

GRANT INSERT, UPDATE, DELETE ON SCHEMA::core TO Administrativo;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::academico TO Administrativo;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::admin TO Administrativo;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO Administrativo;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::api TO Administrativo;

GRANT EXECUTE ON SCHEMA::api TO Administrativo;
GRANT UNMASK TO Administrativo;
GO

/* =========================================================
   MANTENIMIENTO
   Lectura por vistas y CRUD sobre tablas.
   No recibe UNMASK.
   ========================================================= */

GRANT SELECT ON SCHEMA::consulta TO Mantenimiento;

GRANT INSERT, UPDATE, DELETE ON SCHEMA::core TO Mantenimiento;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::academico TO Mantenimiento;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::admin TO Mantenimiento;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO Mantenimiento;
GRANT INSERT, UPDATE, DELETE ON SCHEMA::api TO Mantenimiento;

GRANT EXECUTE ON SCHEMA::api TO Mantenimiento;
GO

/* =========================================================
   LECTURA GENERAL
   Únicamente puede consultar las vistas.
   ========================================================= */

GRANT SELECT ON SCHEMA::consulta TO LecturaGeneral;

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::core TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::academico TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::admin TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::api TO LecturaGeneral;
GO

/* =========================================================
   USUARIOS DE PRUEBA RLS
   ========================================================= */

IF DATABASE_PRINCIPAL_ID(N'usuario_grecia') IS NOT NULL
   AND IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_grecia') <> 1
    ALTER ROLE LecturaGeneral ADD MEMBER usuario_grecia;
GO

IF DATABASE_PRINCIPAL_ID(N'usuario_occidente') IS NOT NULL
   AND IS_ROLEMEMBER(N'LecturaGeneral', N'usuario_occidente') <> 1
    ALTER ROLE LecturaGeneral ADD MEMBER usuario_occidente;
GO

IF DATABASE_PRINCIPAL_ID(N'usuarioLectura') IS NOT NULL
   AND IS_ROLEMEMBER(N'LecturaGeneral', N'usuarioLectura') <> 1
    ALTER ROLE LecturaGeneral ADD MEMBER usuarioLectura;
GO

/* =========================================================
   VERIFICACIÓN
   ========================================================= */

SELECT
    role_principal.name AS Rol,
    member_principal.name AS Miembro
FROM sys.database_role_members drm
JOIN sys.database_principals role_principal
    ON drm.role_principal_id = role_principal.principal_id
JOIN sys.database_principals member_principal
    ON drm.member_principal_id = member_principal.principal_id
WHERE role_principal.name IN
(
    N'Administrativo',
    N'Mantenimiento',
    N'LecturaGeneral'
)
ORDER BY Rol, Miembro;
GO