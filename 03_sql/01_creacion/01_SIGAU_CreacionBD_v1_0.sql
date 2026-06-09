/* =========================================================
   PROYECTO IF-5100 - SIGAU
   Sistema Integral de Gestión Académica Universitaria
   SQL Server 2025 Enterprise Evaluation
   VM:
   E: SQLData     -> MDF / NDF / MEMORY_OPTIMIZED
   F: SQLLogs     -> LDF
   G: SQLTempDB   -> TempDB únicamente
   H: SQLBackups  -> Backups / Audit

   Descripción:
   Script de creación de la base de datos SIGAU.

   Incluye:
   - Filegroups
   - Separación de datos y logs
   - In-Memory OLTP
   - Dynamic Data Masking
   - Row Level Security
   - Auditoría
   - Roles y permisos
   - Procedimientos almacenados
   - Vistas
   ========================================================= */

USE master;
GO

IF DB_ID('SIGAU') IS NOT NULL
BEGIN
    ALTER DATABASE SIGAU SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SIGAU;
END
GO

IF EXISTS (SELECT 1 FROM sys.server_file_audits WHERE name = 'Audit_SIGAU_Server')
BEGIN
    ALTER SERVER AUDIT Audit_SIGAU_Server WITH (STATE = OFF);
    DROP SERVER AUDIT Audit_SIGAU_Server;
END
GO

CREATE DATABASE SIGAU
ON PRIMARY
(
    NAME = N'SIGAU_Primary',
    FILENAME = N'E:\SQLServer\Data\SIGAU\SIGAU_Primary.mdf',
    SIZE = 256MB,
    FILEGROWTH = 128MB
),
FILEGROUP FG_SIGAU_CORE
(
    NAME = N'SIGAU_Core_01',
    FILENAME = N'E:\SQLServer\Data\SIGAU\SIGAU_Core_01.ndf',
    SIZE = 512MB,
    FILEGROWTH = 256MB
),
FILEGROUP FG_SIGAU_ACADEMICO
(
    NAME = N'SIGAU_Academico_01',
    FILENAME = N'E:\SQLServer\Data\SIGAU\SIGAU_Academico_01.ndf',
    SIZE = 512MB,
    FILEGROWTH = 256MB
),
FILEGROUP FG_SIGAU_SEGURIDAD
(
    NAME = N'SIGAU_Seguridad_01',
    FILENAME = N'E:\SQLServer\Data\SIGAU\SIGAU_Seguridad_01.ndf',
    SIZE = 256MB,
    FILEGROWTH = 128MB
),
FILEGROUP FG_SIGAU_MEMORY_OPTIMIZED CONTAINS MEMORY_OPTIMIZED_DATA
(
    NAME = N'SIGAU_MemoryOptimized',
    FILENAME = N'E:\SQLServer\Data\SIGAU\MemoryOptimized'
)
LOG ON
(
    NAME = N'SIGAU_Log',
    FILENAME = N'F:\SQLServer\Logs\SIGAU\SIGAU_Log.ldf',
    SIZE = 256MB,
    FILEGROWTH = 128MB
);
GO

ALTER DATABASE SIGAU SET RECOVERY FULL;
ALTER DATABASE SIGAU SET COMPATIBILITY_LEVEL = 170;
ALTER DATABASE SIGAU MODIFY FILEGROUP FG_SIGAU_CORE DEFAULT;
GO

USE SIGAU;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PREVIEW_FEATURES = ON;
GO

CREATE SCHEMA core;
GO
CREATE SCHEMA academico;
GO
CREATE SCHEMA admin;
GO
CREATE SCHEMA seguridad;
GO
CREATE SCHEMA api;
GO
CREATE SCHEMA consulta;
GO

/* =========================================================
   TABLAS MAESTRAS
   ========================================================= */

CREATE TABLE core.Persona (
    PersonaID INT IDENTITY(1,1) NOT NULL,
    PrimerNombre VARCHAR(50) NOT NULL,
    SegundoNombre VARCHAR(50) NULL,
    PrimerApellido VARCHAR(50) NOT NULL,
    SegundoApellido VARCHAR(50) NULL,
    FechaNacimiento DATE NOT NULL,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Persona PRIMARY KEY CLUSTERED (PersonaID)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.TipoIdentificacion (
    TipoIdentificacionID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoIdentificacion PRIMARY KEY CLUSTERED (TipoIdentificacionID),
    CONSTRAINT UQ_TipoIdentificacion_Codigo UNIQUE (Codigo)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.TipoDireccion (
    TipoDireccionID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoDireccion PRIMARY KEY CLUSTERED (TipoDireccionID),
    CONSTRAINT UQ_TipoDireccion_Codigo UNIQUE (Codigo)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.TipoMedioContacto (
    TipoMedioContactoID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(250) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_TipoMedioContacto PRIMARY KEY CLUSTERED (TipoMedioContactoID),
    CONSTRAINT UQ_TipoMedioContacto_Codigo UNIQUE (Codigo)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.Sede (
    SedeID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    DireccionReferencia VARCHAR(300) MASKED WITH (FUNCTION = 'partial(12,"XXXX",6)') NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Sede PRIMARY KEY CLUSTERED (SedeID),
    CONSTRAINT UQ_Sede_Codigo UNIQUE (Codigo)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE academico.Escuela (
    EscuelaID INT IDENTITY(1,1) NOT NULL,
    SedeID INT NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Escuela PRIMARY KEY CLUSTERED (EscuelaID),
    CONSTRAINT UQ_Escuela_Codigo UNIQUE (Codigo),
    CONSTRAINT FK_Escuela_Sede FOREIGN KEY (SedeID) REFERENCES core.Sede(SedeID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE admin.UnidadAdministrativa (
    UnidadAdministrativaID INT IDENTITY(1,1) NOT NULL,
    SedeID INT NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    TipoUnidad VARCHAR(100) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_UnidadAdministrativa PRIMARY KEY CLUSTERED (UnidadAdministrativaID),
    CONSTRAINT UQ_UnidadAdministrativa_Codigo UNIQUE (Codigo),
    CONSTRAINT FK_UnidadAdministrativa_Sede FOREIGN KEY (SedeID) REFERENCES core.Sede(SedeID)
) ON FG_SIGAU_CORE;
GO

/* =========================================================
   PERSONA / DATOS SENSIBLES
   ========================================================= */

CREATE TABLE core.IdentificacionPersona (
    IdentificacionPersonaID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    TipoIdentificacionID INT NOT NULL,
    NumeroIdentificacion VARCHAR(50) MASKED WITH (FUNCTION = 'partial(2,"XXXXXX",2)') NOT NULL,
    EsPrincipal BIT NOT NULL DEFAULT 0,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_IdentificacionPersona PRIMARY KEY CLUSTERED (IdentificacionPersonaID),
    CONSTRAINT UQ_IdentificacionPersona_Numero UNIQUE (NumeroIdentificacion),
    CONSTRAINT FK_IdentificacionPersona_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_IdentificacionPersona_Tipo FOREIGN KEY (TipoIdentificacionID) REFERENCES core.TipoIdentificacion(TipoIdentificacionID)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.DireccionPersona (
    DireccionPersonaID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    TipoDireccionID INT NOT NULL,
    Provincia VARCHAR(100) NULL,
    Canton VARCHAR(100) NULL,
    Distrito VARCHAR(100) NULL,
    DireccionDetallada VARCHAR(300) MASKED WITH (FUNCTION = 'partial(10,"XXXX",8)') NULL,
    EsPrincipal BIT NOT NULL DEFAULT 0,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_DireccionPersona PRIMARY KEY CLUSTERED (DireccionPersonaID),
    CONSTRAINT FK_DireccionPersona_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_DireccionPersona_Tipo FOREIGN KEY (TipoDireccionID) REFERENCES core.TipoDireccion(TipoDireccionID)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE core.MedioContactoPersona (
    MedioContactoPersonaID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    TipoMedioContactoID INT NOT NULL,
    ValorContacto VARCHAR(150) MASKED WITH (FUNCTION = 'email()') NOT NULL,
    EsPrincipal BIT NOT NULL DEFAULT 0,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_MedioContactoPersona PRIMARY KEY CLUSTERED (MedioContactoPersonaID),
    CONSTRAINT FK_MedioContactoPersona_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_MedioContactoPersona_Tipo FOREIGN KEY (TipoMedioContactoID) REFERENCES core.TipoMedioContacto(TipoMedioContactoID)
) ON FG_SIGAU_CORE;
GO

ALTER TABLE core.MedioContactoPersona
ADD CONSTRAINT CK_MedioContactoPersona_Email_Formato
CHECK (
    REGEXP_LIKE(ValorContacto, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
    OR TipoMedioContactoID <> 1
);
GO

/* =========================================================
   ACADÉMICO
   ========================================================= */

CREATE TABLE academico.PlanEstudio (
    PlanEstudioID INT IDENTITY(1,1) NOT NULL,
    EscuelaID INT NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(150) NOT NULL,
    Version VARCHAR(20) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_PlanEstudio PRIMARY KEY CLUSTERED (PlanEstudioID),
    CONSTRAINT UQ_PlanEstudio_Codigo UNIQUE (Codigo),
    CONSTRAINT FK_PlanEstudio_Escuela FOREIGN KEY (EscuelaID) REFERENCES academico.Escuela(EscuelaID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.Profesor (
    ProfesorID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL UNIQUE,
    EscuelaID INT NOT NULL,
    CategoriaAcademica VARCHAR(100) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_Profesor PRIMARY KEY CLUSTERED (ProfesorID),
    CONSTRAINT FK_Profesor_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_Profesor_Escuela FOREIGN KEY (EscuelaID) REFERENCES academico.Escuela(EscuelaID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.Estudiante (
    EstudianteID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL UNIQUE,
    EscuelaID INT NOT NULL,
    Carnet VARCHAR(20) NOT NULL,
    Estado VARCHAR(50) NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT PK_Estudiante PRIMARY KEY CLUSTERED (EstudianteID),
    CONSTRAINT UQ_Estudiante_Carnet UNIQUE (Carnet),
    CONSTRAINT FK_Estudiante_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_Estudiante_Escuela FOREIGN KEY (EscuelaID) REFERENCES academico.Escuela(EscuelaID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.PeriodoLectivo (
    PeriodoLectivoID INT IDENTITY(1,1) NOT NULL,
    Codigo VARCHAR(20) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NOT NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_PeriodoLectivo PRIMARY KEY CLUSTERED (PeriodoLectivoID),
    CONSTRAINT UQ_PeriodoLectivo_Codigo UNIQUE (Codigo),
    CONSTRAINT CK_PeriodoLectivo_Fechas CHECK (FechaFin > FechaInicio)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.Curso (
    CursoID INT IDENTITY(1,1) NOT NULL,
    PlanEstudioID INT NOT NULL,
    CodigoCurso VARCHAR(20) NOT NULL,
    NombreCurso VARCHAR(150) NOT NULL,
    Creditos INT NOT NULL,
    HorasTeoria INT NOT NULL,
    HorasPractica INT NOT NULL,
    Nivel INT NULL,
    Descripcion VARCHAR(500) NULL,
    Embedding VECTOR(5) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Curso PRIMARY KEY CLUSTERED (CursoID),
    CONSTRAINT UQ_Curso_CodigoCurso UNIQUE (CodigoCurso),
    CONSTRAINT CK_Curso_Creditos CHECK (Creditos > 0),
    CONSTRAINT FK_Curso_PlanEstudio FOREIGN KEY (PlanEstudioID) REFERENCES academico.PlanEstudio(PlanEstudioID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.RequisitoCurso (
    RequisitoCursoID INT IDENTITY(1,1) NOT NULL,
    CursoID INT NOT NULL,
    CursoRequisitoID INT NOT NULL,
    TipoRequisito VARCHAR(50) NOT NULL,
    CONSTRAINT PK_RequisitoCurso PRIMARY KEY CLUSTERED (RequisitoCursoID),
    CONSTRAINT FK_RequisitoCurso_Curso FOREIGN KEY (CursoID) REFERENCES academico.Curso(CursoID),
    CONSTRAINT FK_RequisitoCurso_CursoRequisito FOREIGN KEY (CursoRequisitoID) REFERENCES academico.Curso(CursoID),
    CONSTRAINT CK_RequisitoCurso_NoAutoReferencia CHECK (CursoID <> CursoRequisitoID)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.Grupo (
    GrupoID INT IDENTITY(1,1) NOT NULL,
    CursoID INT NOT NULL,
    PeriodoLectivoID INT NOT NULL,
    ProfesorID INT NOT NULL,
    NumeroGrupo VARCHAR(20) NOT NULL,
    CupoMaximo INT NOT NULL,
    CupoDisponible INT NOT NULL,
    Modalidad VARCHAR(50) NULL,
    HorarioTexto VARCHAR(300) NULL,
    Aula VARCHAR(50) NULL,
    Estado BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Grupo PRIMARY KEY CLUSTERED (GrupoID),
    CONSTRAINT FK_Grupo_Curso FOREIGN KEY (CursoID) REFERENCES academico.Curso(CursoID),
    CONSTRAINT FK_Grupo_Periodo FOREIGN KEY (PeriodoLectivoID) REFERENCES academico.PeriodoLectivo(PeriodoLectivoID),
    CONSTRAINT FK_Grupo_Profesor FOREIGN KEY (ProfesorID) REFERENCES academico.Profesor(ProfesorID),
    CONSTRAINT CK_Grupo_Cupo CHECK (CupoMaximo >= 0 AND CupoDisponible >= 0 AND CupoDisponible <= CupoMaximo)
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.Matricula (
    MatriculaID INT IDENTITY(1,1) NOT NULL,
    EstudianteID INT NOT NULL,
    GrupoID INT NOT NULL,
    FechaMatricula DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Estado VARCHAR(50) NOT NULL DEFAULT 'MATRICULADO',
    NotaFinal DECIMAL(5,2) NULL,
    CONSTRAINT PK_Matricula PRIMARY KEY CLUSTERED (MatriculaID),
    CONSTRAINT UQ_Matricula_EstudianteGrupo UNIQUE (EstudianteID, GrupoID),
    CONSTRAINT FK_Matricula_Estudiante FOREIGN KEY (EstudianteID) REFERENCES academico.Estudiante(EstudianteID),
    CONSTRAINT FK_Matricula_Grupo FOREIGN KEY (GrupoID) REFERENCES academico.Grupo(GrupoID),
    CONSTRAINT CK_Matricula_Nota CHECK (NotaFinal IS NULL OR (NotaFinal >= 0 AND NotaFinal <= 100))
) ON FG_SIGAU_ACADEMICO;
GO

CREATE TABLE academico.HistorialAcademico (
    HistorialAcademicoID INT IDENTITY(1,1) NOT NULL,
    EstudianteID INT NOT NULL,
    PeriodoLectivoID INT NOT NULL,
    PromedioPeriodo DECIMAL(5,2) NULL,
    CreditosMatriculados INT NULL,
    CreditosAprobados INT NULL,
    CondicionPeriodo VARCHAR(100) NULL,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_HistorialAcademico PRIMARY KEY CLUSTERED (HistorialAcademicoID),
    CONSTRAINT FK_HistorialAcademico_Estudiante FOREIGN KEY (EstudianteID) REFERENCES academico.Estudiante(EstudianteID),
    CONSTRAINT FK_HistorialAcademico_Periodo FOREIGN KEY (PeriodoLectivoID) REFERENCES academico.PeriodoLectivo(PeriodoLectivoID)
) ON FG_SIGAU_ACADEMICO;
GO

/* =========================================================
   ADMINISTRATIVO
   ========================================================= */

CREATE TABLE admin.Administrativo (
    AdministrativoID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL UNIQUE,
    UnidadAdministrativaID INT NOT NULL,
    Cargo VARCHAR(100) NULL,
    TipoNombramiento VARCHAR(100) NULL,
    EstadoAdministrativo VARCHAR(50) NULL,
    FechaCreacion DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Administrativo PRIMARY KEY CLUSTERED (AdministrativoID),
    CONSTRAINT FK_Administrativo_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_Administrativo_Unidad FOREIGN KEY (UnidadAdministrativaID) REFERENCES admin.UnidadAdministrativa(UnidadAdministrativaID)
) ON FG_SIGAU_CORE;
GO

CREATE TABLE admin.Nombramiento (
    NombramientoID INT IDENTITY(1,1) NOT NULL,
    PersonaID INT NOT NULL,
    EscuelaID INT NULL,
    UnidadAdministrativaID INT NULL,
    TipoNombramiento VARCHAR(100) NULL,
    FechaInicio DATE NOT NULL,
    FechaFin DATE NULL,
    CONSTRAINT PK_Nombramiento PRIMARY KEY CLUSTERED (NombramientoID),
    CONSTRAINT FK_Nombramiento_Persona FOREIGN KEY (PersonaID) REFERENCES core.Persona(PersonaID),
    CONSTRAINT FK_Nombramiento_Escuela FOREIGN KEY (EscuelaID) REFERENCES academico.Escuela(EscuelaID),
    CONSTRAINT FK_Nombramiento_Unidad FOREIGN KEY (UnidadAdministrativaID) REFERENCES admin.UnidadAdministrativa(UnidadAdministrativaID),
    CONSTRAINT CK_Nombramiento_Fechas CHECK (FechaFin IS NULL OR FechaFin >= FechaInicio),
    CONSTRAINT CK_Nombramiento_Destino CHECK (EscuelaID IS NOT NULL OR UnidadAdministrativaID IS NOT NULL)
) ON FG_SIGAU_CORE;
GO

/* =========================================================
   TABLA IN-MEMORY
   ========================================================= */

CREATE TABLE seguridad.BitacoraAcceso (
    BitacoraAccesoID BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY NONCLUSTERED HASH
        WITH (BUCKET_COUNT = 1024),
    UsuarioSistema SYSNAME NOT NULL,
    FechaEvento DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Accion VARCHAR(100) NOT NULL,
    Entidad VARCHAR(100) NULL,
    LlaveEntidad VARCHAR(100) NULL,
    DireccionIP VARCHAR(45) NULL
)
WITH
(
    MEMORY_OPTIMIZED = ON,
    DURABILITY = SCHEMA_AND_DATA
);
GO

/* =========================================================
   API EXTERNA
   ========================================================= */

USE master;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

USE SIGAU;
GO

CREATE TABLE api.ConsultaExterna (
    ConsultaExternaID INT IDENTITY(1,1) NOT NULL,
    FechaConsulta DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    Endpoint VARCHAR(500) NOT NULL,
    CodigoRespuesta INT NULL,
    RespuestaJSON NVARCHAR(MAX) NULL,
    CONSTRAINT PK_ConsultaExterna PRIMARY KEY CLUSTERED (ConsultaExternaID)
) ON FG_SIGAU_CORE;
GO

CREATE OR ALTER PROCEDURE api.usp_ConsultarEndpointUniversidad
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @response NVARCHAR(MAX);

    EXEC sys.sp_invoke_external_rest_endpoint
        @url = N'https://jsonplaceholder.typicode.com/todos/1',
        @method = N'GET',
        @response = @response OUTPUT;

    INSERT INTO api.ConsultaExterna (Endpoint, CodigoRespuesta, RespuestaJSON)
    VALUES ('https://jsonplaceholder.typicode.com/todos/1', 200, @response);

    SELECT @response AS RespuestaJSON;
END;
GO

/* =========================================================
   VECTOR SEARCH
   Nota:
   - Se deja la columna VECTOR en academico.Curso.
   - El procedimiento y el índice vectorial se crearán después
     de poblar datos y validar sintaxis exacta en tu build RTM.
   ========================================================= */

/* =========================================================
   VISTAS: UNA POR TABLA
   ========================================================= */

CREATE VIEW consulta.vw_Persona AS SELECT * FROM core.Persona;
GO
CREATE VIEW consulta.vw_TipoIdentificacion AS SELECT * FROM core.TipoIdentificacion;
GO
CREATE VIEW consulta.vw_TipoDireccion AS SELECT * FROM core.TipoDireccion;
GO
CREATE VIEW consulta.vw_TipoMedioContacto AS SELECT * FROM core.TipoMedioContacto;
GO
CREATE VIEW consulta.vw_Sede AS SELECT * FROM core.Sede;
GO
CREATE VIEW consulta.vw_Escuela AS SELECT * FROM academico.Escuela;
GO
CREATE VIEW consulta.vw_UnidadAdministrativa AS SELECT * FROM admin.UnidadAdministrativa;
GO
CREATE VIEW consulta.vw_IdentificacionPersona AS SELECT * FROM core.IdentificacionPersona;
GO
CREATE VIEW consulta.vw_DireccionPersona AS SELECT * FROM core.DireccionPersona;
GO
CREATE VIEW consulta.vw_MedioContactoPersona AS SELECT * FROM core.MedioContactoPersona;
GO
CREATE VIEW consulta.vw_PlanEstudio AS SELECT * FROM academico.PlanEstudio;
GO
CREATE VIEW consulta.vw_Profesor AS SELECT * FROM academico.Profesor;
GO
CREATE VIEW consulta.vw_Estudiante AS SELECT * FROM academico.Estudiante;
GO
CREATE VIEW consulta.vw_PeriodoLectivo AS SELECT * FROM academico.PeriodoLectivo;
GO
CREATE VIEW consulta.vw_Curso AS SELECT * FROM academico.Curso;
GO
CREATE VIEW consulta.vw_RequisitoCurso AS SELECT * FROM academico.RequisitoCurso;
GO
CREATE VIEW consulta.vw_Grupo AS SELECT * FROM academico.Grupo;
GO
CREATE VIEW consulta.vw_Matricula AS SELECT * FROM academico.Matricula;
GO
CREATE VIEW consulta.vw_HistorialAcademico AS SELECT * FROM academico.HistorialAcademico;
GO
CREATE VIEW consulta.vw_Administrativo AS SELECT * FROM admin.Administrativo;
GO
CREATE VIEW consulta.vw_Nombramiento AS SELECT * FROM admin.Nombramiento;
GO
CREATE VIEW consulta.vw_BitacoraAcceso AS SELECT * FROM seguridad.BitacoraAcceso;
GO
CREATE VIEW consulta.vw_ConsultaExterna AS SELECT * FROM api.ConsultaExterna;
GO

/* =========================================================
   JSON: SERIALIZACIÓN DE PERSONAS
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
        ip.NumeroIdentificacion,
        mc.ValorContacto AS Correo,
        dp.DireccionDetallada
    FROM core.Persona p
    LEFT JOIN core.IdentificacionPersona ip
        ON p.PersonaID = ip.PersonaID AND ip.EsPrincipal = 1
    LEFT JOIN core.MedioContactoPersona mc
        ON p.PersonaID = mc.PersonaID AND mc.EsPrincipal = 1
    LEFT JOIN core.DireccionPersona dp
        ON p.PersonaID = dp.PersonaID AND dp.EsPrincipal = 1
    FOR JSON PATH, ROOT('Personas');
END;
GO

/* =========================================================
   ROW LEVEL SECURITY POR SEDE
   ========================================================= */

CREATE TABLE seguridad.UsuarioSede (
    UsuarioSedeID INT IDENTITY(1,1) NOT NULL,
    UsuarioBD SYSNAME NOT NULL,
    SedeID INT NOT NULL,
    Estado BIT NOT NULL DEFAULT 1,
    CONSTRAINT PK_UsuarioSede PRIMARY KEY CLUSTERED (UsuarioSedeID),
    CONSTRAINT UQ_UsuarioSede UNIQUE (UsuarioBD, SedeID),
    CONSTRAINT FK_UsuarioSede_Sede FOREIGN KEY (SedeID) REFERENCES core.Sede(SedeID)
) ON FG_SIGAU_SEGURIDAD;
GO

CREATE OR ALTER FUNCTION seguridad.fn_FiltroSede(@SedeID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN
    SELECT 1 AS fn_result
    WHERE
        USER_NAME() = 'dbo'
        OR EXISTS (
            SELECT 1
            FROM seguridad.UsuarioSede AS us
            WHERE us.UsuarioBD = USER_NAME()
              AND us.SedeID = @SedeID
              AND us.Estado = 1
        );
GO

CREATE SECURITY POLICY seguridad.Policy_EscuelaPorSede
ADD FILTER PREDICATE seguridad.fn_FiltroSede(SedeID)
ON academico.Escuela
WITH (STATE =ON);
GO

CREATE SECURITY POLICY seguridad.Policy_UnidadPorSede
ADD FILTER PREDICATE seguridad.fn_FiltroSede(SedeID)
ON admin.UnidadAdministrativa
WITH (STATE = ON);
GO

/* =========================================================
   ROLES Y PERMISOS
   ========================================================= */

CREATE ROLE Administrativo;
CREATE ROLE Mantenimiento;
CREATE ROLE LecturaGeneral;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::core TO Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::academico TO Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::admin TO Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::api TO Administrativo;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO Administrativo;
GRANT SELECT ON SCHEMA::consulta TO Administrativo;
GRANT UNMASK TO Administrativo;
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::core TO Mantenimiento;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::academico TO Mantenimiento;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::admin TO Mantenimiento;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::api TO Mantenimiento;
GRANT SELECT ON SCHEMA::consulta TO Mantenimiento;
GO

GRANT SELECT ON SCHEMA::consulta TO LecturaGeneral;
GO

DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::core TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::academico TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::admin TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::api TO LecturaGeneral;
DENY SELECT, INSERT, UPDATE, DELETE ON SCHEMA::seguridad TO LecturaGeneral;
GO

/* =========================================================
   AUDITORÍA DE BASE DE DATOS
   ========================================================= */

USE master;
GO

CREATE SERVER AUDIT Audit_SIGAU_Server
TO FILE
(
    FILEPATH = 'H:\SQLServer\Audit\SIGAU\',
    MAXSIZE = 100 MB,
    MAX_ROLLOVER_FILES = 10,
    RESERVE_DISK_SPACE = OFF
)
WITH
(
    QUEUE_DELAY = 1000,
    ON_FAILURE = CONTINUE
);
GO

ALTER SERVER AUDIT Audit_SIGAU_Server WITH (STATE = ON);
GO

USE SIGAU;
GO

CREATE DATABASE AUDIT SPECIFICATION Audit_SIGAU_Database
FOR SERVER AUDIT Audit_SIGAU_Server
ADD (SELECT ON DATABASE::SIGAU BY public),
ADD (INSERT ON DATABASE::SIGAU BY public),
ADD (UPDATE ON DATABASE::SIGAU BY public),
ADD (DELETE ON DATABASE::SIGAU BY public),
ADD (SCHEMA_OBJECT_CHANGE_GROUP),
ADD (DATABASE_PERMISSION_CHANGE_GROUP),
ADD (DATABASE_PRINCIPAL_CHANGE_GROUP)
WITH (STATE = ON);
GO

/* =========================================================
   VERIFICACIÓN FINAL
   ========================================================= */

SELECT name, recovery_model_desc, compatibility_level
FROM sys.databases
WHERE name = 'SIGAU';

USE SIGAU;
GO

SELECT name, type_desc, is_default, is_read_only
FROM sys.filegroups;

SELECT 
    name,
    type_desc,
    physical_name,
    size * 8 / 1024 AS SizeMB
FROM sys.database_files;

SELECT 
    s.name AS SchemaName,
    t.name AS TableName,
    t.is_memory_optimized
FROM sys.tables t
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;

PRINT 'SIGAU creado correctamente. Próximo paso: poblar todas las tablas con al menos 10 registros.';
GO