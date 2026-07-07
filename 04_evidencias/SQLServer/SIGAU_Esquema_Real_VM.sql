USE [SIGAU]
GO
/****** Object:  Schema [academico]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [academico]
GO
/****** Object:  Schema [admin]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [admin]
GO
/****** Object:  Schema [api]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [api]
GO
/****** Object:  Schema [consulta]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [consulta]
GO
/****** Object:  Schema [core]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [core]
GO
/****** Object:  Schema [seguridad]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SCHEMA [seguridad]
GO
/****** Object:  Table [core].[Persona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[Persona](
	[PersonaID] [int] IDENTITY(1,1) NOT NULL,
	[PrimerNombre] [varchar](50) NOT NULL,
	[SegundoNombre] [varchar](50) NULL,
	[PrimerApellido] [varchar](50) NOT NULL,
	[SegundoApellido] [varchar](50) NULL,
	[FechaNacimiento] [date] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED 
(
	[PersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_Persona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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

CREATE VIEW [consulta].[vw_Persona] AS SELECT * FROM core.Persona;
GO
/****** Object:  Table [core].[TipoIdentificacion]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[TipoIdentificacion](
	[TipoIdentificacionID] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Descripcion] [varchar](250) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_TipoIdentificacion] PRIMARY KEY CLUSTERED 
(
	[TipoIdentificacionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_TipoIdentificacion_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_TipoIdentificacion]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_TipoIdentificacion] AS SELECT * FROM core.TipoIdentificacion;
GO
/****** Object:  Table [core].[TipoDireccion]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[TipoDireccion](
	[TipoDireccionID] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Descripcion] [varchar](250) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_TipoDireccion] PRIMARY KEY CLUSTERED 
(
	[TipoDireccionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_TipoDireccion_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_TipoDireccion]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_TipoDireccion] AS SELECT * FROM core.TipoDireccion;
GO
/****** Object:  Table [core].[TipoMedioContacto]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[TipoMedioContacto](
	[TipoMedioContactoID] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Descripcion] [varchar](250) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_TipoMedioContacto] PRIMARY KEY CLUSTERED 
(
	[TipoMedioContactoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_TipoMedioContacto_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_TipoMedioContacto]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_TipoMedioContacto] AS SELECT * FROM core.TipoMedioContacto;
GO
/****** Object:  Table [core].[Sede]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[Sede](
	[SedeID] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[DireccionReferencia] [varchar](300) MASKED WITH (FUNCTION = 'partial(12, "XXXX", 6)') NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Sede] PRIMARY KEY CLUSTERED 
(
	[SedeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_Sede_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_Sede]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Sede] AS SELECT * FROM core.Sede;
GO
/****** Object:  Table [academico].[Escuela]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Escuela](
	[EscuelaID] [int] IDENTITY(1,1) NOT NULL,
	[SedeID] [int] NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Escuela] PRIMARY KEY CLUSTERED 
(
	[EscuelaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_Escuela_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Escuela]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Escuela] AS SELECT * FROM academico.Escuela;
GO
/****** Object:  Table [admin].[UnidadAdministrativa]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [admin].[UnidadAdministrativa](
	[UnidadAdministrativaID] [int] IDENTITY(1,1) NOT NULL,
	[SedeID] [int] NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[TipoUnidad] [varchar](100) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_UnidadAdministrativa] PRIMARY KEY CLUSTERED 
(
	[UnidadAdministrativaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_UnidadAdministrativa_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_UnidadAdministrativa]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_UnidadAdministrativa] AS SELECT * FROM admin.UnidadAdministrativa;
GO
/****** Object:  Table [core].[IdentificacionPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[IdentificacionPersona](
	[IdentificacionPersonaID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[TipoIdentificacionID] [int] NOT NULL,
	[NumeroIdentificacion] [varchar](50) MASKED WITH (FUNCTION = 'partial(2, "XXXXXX", 2)') NOT NULL,
	[EsPrincipal] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_IdentificacionPersona] PRIMARY KEY CLUSTERED 
(
	[IdentificacionPersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
 CONSTRAINT [UQ_IdentificacionPersona_Numero] UNIQUE NONCLUSTERED 
(
	[NumeroIdentificacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_IdentificacionPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_IdentificacionPersona] AS SELECT * FROM core.IdentificacionPersona;
GO
/****** Object:  Table [core].[DireccionPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[DireccionPersona](
	[DireccionPersonaID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[TipoDireccionID] [int] NOT NULL,
	[Provincia] [varchar](100) NULL,
	[Canton] [varchar](100) NULL,
	[Distrito] [varchar](100) NULL,
	[DireccionDetallada] [varchar](300) MASKED WITH (FUNCTION = 'partial(10, "XXXX", 8)') NULL,
	[EsPrincipal] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_DireccionPersona] PRIMARY KEY CLUSTERED 
(
	[DireccionPersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_DireccionPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_DireccionPersona] AS SELECT * FROM core.DireccionPersona;
GO
/****** Object:  Table [core].[MedioContactoPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [core].[MedioContactoPersona](
	[MedioContactoPersonaID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[TipoMedioContactoID] [int] NOT NULL,
	[ValorContacto] [varchar](150) MASKED WITH (FUNCTION = 'email()') NOT NULL,
	[EsPrincipal] [bit] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_MedioContactoPersona] PRIMARY KEY CLUSTERED 
(
	[MedioContactoPersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_MedioContactoPersona]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_MedioContactoPersona] AS SELECT * FROM core.MedioContactoPersona;
GO
/****** Object:  Table [academico].[PlanEstudio]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[PlanEstudio](
	[PlanEstudioID] [int] IDENTITY(1,1) NOT NULL,
	[EscuelaID] [int] NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](150) NOT NULL,
	[Version] [varchar](20) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_PlanEstudio] PRIMARY KEY CLUSTERED 
(
	[PlanEstudioID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_PlanEstudio_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_PlanEstudio]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_PlanEstudio] AS SELECT * FROM academico.PlanEstudio;
GO
/****** Object:  Table [academico].[Profesor]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Profesor](
	[ProfesorID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[EscuelaID] [int] NOT NULL,
	[CategoriaAcademica] [varchar](100) NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_Profesor] PRIMARY KEY CLUSTERED 
(
	[ProfesorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
UNIQUE NONCLUSTERED 
(
	[PersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Profesor]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Profesor] AS SELECT * FROM academico.Profesor;
GO
/****** Object:  Table [academico].[Estudiante]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Estudiante](
	[EstudianteID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[EscuelaID] [int] NOT NULL,
	[Carnet] [varchar](20) NOT NULL,
	[Estado] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Estudiante] PRIMARY KEY CLUSTERED 
(
	[EstudianteID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
UNIQUE NONCLUSTERED 
(
	[PersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_Estudiante_Carnet] UNIQUE NONCLUSTERED 
(
	[Carnet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Estudiante]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Estudiante] AS SELECT * FROM academico.Estudiante;
GO
/****** Object:  Table [academico].[PeriodoLectivo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[PeriodoLectivo](
	[PeriodoLectivoID] [int] IDENTITY(1,1) NOT NULL,
	[Codigo] [varchar](20) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_PeriodoLectivo] PRIMARY KEY CLUSTERED 
(
	[PeriodoLectivoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_PeriodoLectivo_Codigo] UNIQUE NONCLUSTERED 
(
	[Codigo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_PeriodoLectivo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_PeriodoLectivo] AS SELECT * FROM academico.PeriodoLectivo;
GO
/****** Object:  Table [academico].[Curso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Curso](
	[CursoID] [int] IDENTITY(1,1) NOT NULL,
	[PlanEstudioID] [int] NOT NULL,
	[CodigoCurso] [varchar](20) NOT NULL,
	[NombreCurso] [varchar](150) NOT NULL,
	[Creditos] [int] NOT NULL,
	[HorasTeoria] [int] NOT NULL,
	[HorasPractica] [int] NOT NULL,
	[Nivel] [int] NULL,
	[Descripcion] [varchar](500) NULL,
	[Embedding] [vector](5, float32) NULL,
	[Estado] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Curso] PRIMARY KEY CLUSTERED 
(
	[CursoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_Curso_CodigoCurso] UNIQUE NONCLUSTERED 
(
	[CodigoCurso] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Curso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Curso] AS SELECT * FROM academico.Curso;
GO
/****** Object:  Table [academico].[RequisitoCurso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[RequisitoCurso](
	[RequisitoCursoID] [int] IDENTITY(1,1) NOT NULL,
	[CursoID] [int] NOT NULL,
	[CursoRequisitoID] [int] NOT NULL,
	[TipoRequisito] [varchar](50) NOT NULL,
 CONSTRAINT [PK_RequisitoCurso] PRIMARY KEY CLUSTERED 
(
	[RequisitoCursoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_RequisitoCurso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_RequisitoCurso] AS SELECT * FROM academico.RequisitoCurso;
GO
/****** Object:  Table [academico].[Grupo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Grupo](
	[GrupoID] [int] IDENTITY(1,1) NOT NULL,
	[CursoID] [int] NOT NULL,
	[PeriodoLectivoID] [int] NOT NULL,
	[ProfesorID] [int] NOT NULL,
	[NumeroGrupo] [varchar](20) NOT NULL,
	[CupoMaximo] [int] NOT NULL,
	[CupoDisponible] [int] NOT NULL,
	[Modalidad] [varchar](50) NULL,
	[HorarioTexto] [varchar](300) NULL,
	[Aula] [varchar](50) NULL,
	[Estado] [bit] NOT NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Grupo] PRIMARY KEY CLUSTERED 
(
	[GrupoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Grupo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Grupo] AS SELECT * FROM academico.Grupo;
GO
/****** Object:  Table [academico].[Matricula]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[Matricula](
	[MatriculaID] [int] IDENTITY(1,1) NOT NULL,
	[EstudianteID] [int] NOT NULL,
	[GrupoID] [int] NOT NULL,
	[FechaMatricula] [datetime2](7) NOT NULL,
	[Estado] [varchar](50) NOT NULL,
	[NotaFinal] [decimal](5, 2) NULL,
 CONSTRAINT [PK_Matricula] PRIMARY KEY CLUSTERED 
(
	[MatriculaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO],
 CONSTRAINT [UQ_Matricula_EstudianteGrupo] UNIQUE NONCLUSTERED 
(
	[EstudianteID] ASC,
	[GrupoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_Matricula]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Matricula] AS SELECT * FROM academico.Matricula;
GO
/****** Object:  Table [academico].[HistorialAcademico]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [academico].[HistorialAcademico](
	[HistorialAcademicoID] [int] IDENTITY(1,1) NOT NULL,
	[EstudianteID] [int] NOT NULL,
	[PeriodoLectivoID] [int] NOT NULL,
	[PromedioPeriodo] [decimal](5, 2) NULL,
	[CreditosMatriculados] [int] NULL,
	[CreditosAprobados] [int] NULL,
	[CondicionPeriodo] [varchar](100) NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_HistorialAcademico] PRIMARY KEY CLUSTERED 
(
	[HistorialAcademicoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_ACADEMICO]
) ON [FG_SIGAU_ACADEMICO]
GO
/****** Object:  View [consulta].[vw_HistorialAcademico]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_HistorialAcademico] AS SELECT * FROM academico.HistorialAcademico;
GO
/****** Object:  Table [admin].[Administrativo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [admin].[Administrativo](
	[AdministrativoID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[UnidadAdministrativaID] [int] NOT NULL,
	[Cargo] [varchar](100) NULL,
	[TipoNombramiento] [varchar](100) NULL,
	[EstadoAdministrativo] [varchar](50) NULL,
	[FechaCreacion] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_Administrativo] PRIMARY KEY CLUSTERED 
(
	[AdministrativoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE],
UNIQUE NONCLUSTERED 
(
	[PersonaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_Administrativo]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Administrativo] AS SELECT * FROM admin.Administrativo;
GO
/****** Object:  Table [admin].[Nombramiento]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [admin].[Nombramiento](
	[NombramientoID] [int] IDENTITY(1,1) NOT NULL,
	[PersonaID] [int] NOT NULL,
	[EscuelaID] [int] NULL,
	[UnidadAdministrativaID] [int] NULL,
	[TipoNombramiento] [varchar](100) NULL,
	[FechaInicio] [date] NOT NULL,
	[FechaFin] [date] NULL,
 CONSTRAINT [PK_Nombramiento] PRIMARY KEY CLUSTERED 
(
	[NombramientoID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_Nombramiento]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_Nombramiento] AS SELECT * FROM admin.Nombramiento;
GO
/****** Object:  Table [seguridad].[BitacoraAcceso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [seguridad].[BitacoraAcceso]
(
	[BitacoraAccesoID] [bigint] IDENTITY(1,1) NOT NULL,
	[UsuarioSistema] [sysname] COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[FechaEvento] [datetime2](7) NOT NULL,
	[Accion] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Entidad] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LlaveEntidad] [varchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DireccionIP] [varchar](45) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

 PRIMARY KEY NONCLUSTERED HASH 
(
	[BitacoraAccesoID]
)WITH ( BUCKET_COUNT = 1024)
)WITH ( MEMORY_OPTIMIZED = ON , DURABILITY = SCHEMA_AND_DATA )
GO
/****** Object:  View [consulta].[vw_BitacoraAcceso]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_BitacoraAcceso] AS SELECT * FROM seguridad.BitacoraAcceso;
GO
/****** Object:  Table [api].[ConsultaExterna]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [api].[ConsultaExterna](
	[ConsultaExternaID] [int] IDENTITY(1,1) NOT NULL,
	[FechaConsulta] [datetime2](7) NOT NULL,
	[Endpoint] [varchar](500) NOT NULL,
	[CodigoRespuesta] [int] NULL,
	[RespuestaJSON] [nvarchar](max) NULL,
 CONSTRAINT [PK_ConsultaExterna] PRIMARY KEY CLUSTERED 
(
	[ConsultaExternaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_CORE]
) ON [FG_SIGAU_CORE] TEXTIMAGE_ON [FG_SIGAU_CORE]
GO
/****** Object:  View [consulta].[vw_ConsultaExterna]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [consulta].[vw_ConsultaExterna] AS SELECT * FROM api.ConsultaExterna;
GO
/****** Object:  Table [seguridad].[UsuarioSede]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [seguridad].[UsuarioSede](
	[UsuarioSedeID] [int] IDENTITY(1,1) NOT NULL,
	[UsuarioBD] [sysname] NOT NULL,
	[SedeID] [int] NOT NULL,
	[Estado] [bit] NOT NULL,
 CONSTRAINT [PK_UsuarioSede] PRIMARY KEY CLUSTERED 
(
	[UsuarioSedeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_SEGURIDAD],
 CONSTRAINT [UQ_UsuarioSede] UNIQUE NONCLUSTERED 
(
	[UsuarioBD] ASC,
	[SedeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_SIGAU_SEGURIDAD]
) ON [FG_SIGAU_SEGURIDAD]
GO
/****** Object:  UserDefinedFunction [seguridad].[fn_FiltroSede]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   FUNCTION [seguridad].[fn_FiltroSede](@SedeID INT)
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
/****** Object:  View [consulta].[vw_UsuarioSede]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [consulta].[vw_UsuarioSede]
AS
SELECT
    UsuarioSedeID,
    UsuarioBD,
    SedeID,
    Estado
FROM seguridad.UsuarioSede;
GO
/****** Object:  SecurityPolicy [seguridad].[Policy_EscuelaPorSede]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SECURITY POLICY [seguridad].[Policy_EscuelaPorSede] 
ADD FILTER PREDICATE [seguridad].[fn_FiltroSede]([SedeID]) ON [academico].[Escuela]
WITH (STATE = ON, SCHEMABINDING = ON)
GO
/****** Object:  SecurityPolicy [seguridad].[Policy_UnidadPorSede]    Script Date: 7/7/2026 4:48:01 PM ******/
CREATE SECURITY POLICY [seguridad].[Policy_UnidadPorSede] 
ADD FILTER PREDICATE [seguridad].[fn_FiltroSede]([SedeID]) ON [admin].[UnidadAdministrativa]
WITH (STATE = ON, SCHEMABINDING = ON)
GO
ALTER TABLE [academico].[Curso] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[Curso] ADD  DEFAULT (sysutcdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [academico].[Escuela] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[Estudiante] ADD  DEFAULT ('ACTIVO') FOR [Estado]
GO
ALTER TABLE [academico].[Grupo] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[Grupo] ADD  DEFAULT (sysutcdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [academico].[HistorialAcademico] ADD  DEFAULT (sysutcdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [academico].[Matricula] ADD  DEFAULT (sysutcdatetime()) FOR [FechaMatricula]
GO
ALTER TABLE [academico].[Matricula] ADD  DEFAULT ('MATRICULADO') FOR [Estado]
GO
ALTER TABLE [academico].[PeriodoLectivo] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[PlanEstudio] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[Profesor] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [admin].[Administrativo] ADD  DEFAULT (sysutcdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [admin].[UnidadAdministrativa] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [api].[ConsultaExterna] ADD  DEFAULT (sysutcdatetime()) FOR [FechaConsulta]
GO
ALTER TABLE [core].[DireccionPersona] ADD  DEFAULT ((0)) FOR [EsPrincipal]
GO
ALTER TABLE [core].[DireccionPersona] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[IdentificacionPersona] ADD  DEFAULT ((0)) FOR [EsPrincipal]
GO
ALTER TABLE [core].[IdentificacionPersona] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[MedioContactoPersona] ADD  DEFAULT ((0)) FOR [EsPrincipal]
GO
ALTER TABLE [core].[MedioContactoPersona] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[Persona] ADD  DEFAULT (sysutcdatetime()) FOR [FechaCreacion]
GO
ALTER TABLE [core].[Persona] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[Sede] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[TipoDireccion] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[TipoIdentificacion] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [core].[TipoMedioContacto] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [seguridad].[BitacoraAcceso] ADD  DEFAULT (sysutcdatetime()) FOR [FechaEvento]
GO
ALTER TABLE [seguridad].[UsuarioSede] ADD  DEFAULT ((1)) FOR [Estado]
GO
ALTER TABLE [academico].[Curso]  WITH CHECK ADD  CONSTRAINT [FK_Curso_PlanEstudio] FOREIGN KEY([PlanEstudioID])
REFERENCES [academico].[PlanEstudio] ([PlanEstudioID])
GO
ALTER TABLE [academico].[Curso] CHECK CONSTRAINT [FK_Curso_PlanEstudio]
GO
ALTER TABLE [academico].[Escuela]  WITH CHECK ADD  CONSTRAINT [FK_Escuela_Sede] FOREIGN KEY([SedeID])
REFERENCES [core].[Sede] ([SedeID])
GO
ALTER TABLE [academico].[Escuela] CHECK CONSTRAINT [FK_Escuela_Sede]
GO
ALTER TABLE [academico].[Estudiante]  WITH CHECK ADD  CONSTRAINT [FK_Estudiante_Escuela] FOREIGN KEY([EscuelaID])
REFERENCES [academico].[Escuela] ([EscuelaID])
GO
ALTER TABLE [academico].[Estudiante] CHECK CONSTRAINT [FK_Estudiante_Escuela]
GO
ALTER TABLE [academico].[Estudiante]  WITH CHECK ADD  CONSTRAINT [FK_Estudiante_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [academico].[Estudiante] CHECK CONSTRAINT [FK_Estudiante_Persona]
GO
ALTER TABLE [academico].[Grupo]  WITH CHECK ADD  CONSTRAINT [FK_Grupo_Curso] FOREIGN KEY([CursoID])
REFERENCES [academico].[Curso] ([CursoID])
GO
ALTER TABLE [academico].[Grupo] CHECK CONSTRAINT [FK_Grupo_Curso]
GO
ALTER TABLE [academico].[Grupo]  WITH CHECK ADD  CONSTRAINT [FK_Grupo_Periodo] FOREIGN KEY([PeriodoLectivoID])
REFERENCES [academico].[PeriodoLectivo] ([PeriodoLectivoID])
GO
ALTER TABLE [academico].[Grupo] CHECK CONSTRAINT [FK_Grupo_Periodo]
GO
ALTER TABLE [academico].[Grupo]  WITH CHECK ADD  CONSTRAINT [FK_Grupo_Profesor] FOREIGN KEY([ProfesorID])
REFERENCES [academico].[Profesor] ([ProfesorID])
GO
ALTER TABLE [academico].[Grupo] CHECK CONSTRAINT [FK_Grupo_Profesor]
GO
ALTER TABLE [academico].[HistorialAcademico]  WITH CHECK ADD  CONSTRAINT [FK_HistorialAcademico_Estudiante] FOREIGN KEY([EstudianteID])
REFERENCES [academico].[Estudiante] ([EstudianteID])
GO
ALTER TABLE [academico].[HistorialAcademico] CHECK CONSTRAINT [FK_HistorialAcademico_Estudiante]
GO
ALTER TABLE [academico].[HistorialAcademico]  WITH CHECK ADD  CONSTRAINT [FK_HistorialAcademico_Periodo] FOREIGN KEY([PeriodoLectivoID])
REFERENCES [academico].[PeriodoLectivo] ([PeriodoLectivoID])
GO
ALTER TABLE [academico].[HistorialAcademico] CHECK CONSTRAINT [FK_HistorialAcademico_Periodo]
GO
ALTER TABLE [academico].[Matricula]  WITH CHECK ADD  CONSTRAINT [FK_Matricula_Estudiante] FOREIGN KEY([EstudianteID])
REFERENCES [academico].[Estudiante] ([EstudianteID])
GO
ALTER TABLE [academico].[Matricula] CHECK CONSTRAINT [FK_Matricula_Estudiante]
GO
ALTER TABLE [academico].[Matricula]  WITH CHECK ADD  CONSTRAINT [FK_Matricula_Grupo] FOREIGN KEY([GrupoID])
REFERENCES [academico].[Grupo] ([GrupoID])
GO
ALTER TABLE [academico].[Matricula] CHECK CONSTRAINT [FK_Matricula_Grupo]
GO
ALTER TABLE [academico].[PlanEstudio]  WITH CHECK ADD  CONSTRAINT [FK_PlanEstudio_Escuela] FOREIGN KEY([EscuelaID])
REFERENCES [academico].[Escuela] ([EscuelaID])
GO
ALTER TABLE [academico].[PlanEstudio] CHECK CONSTRAINT [FK_PlanEstudio_Escuela]
GO
ALTER TABLE [academico].[Profesor]  WITH CHECK ADD  CONSTRAINT [FK_Profesor_Escuela] FOREIGN KEY([EscuelaID])
REFERENCES [academico].[Escuela] ([EscuelaID])
GO
ALTER TABLE [academico].[Profesor] CHECK CONSTRAINT [FK_Profesor_Escuela]
GO
ALTER TABLE [academico].[Profesor]  WITH CHECK ADD  CONSTRAINT [FK_Profesor_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [academico].[Profesor] CHECK CONSTRAINT [FK_Profesor_Persona]
GO
ALTER TABLE [academico].[RequisitoCurso]  WITH CHECK ADD  CONSTRAINT [FK_RequisitoCurso_Curso] FOREIGN KEY([CursoID])
REFERENCES [academico].[Curso] ([CursoID])
GO
ALTER TABLE [academico].[RequisitoCurso] CHECK CONSTRAINT [FK_RequisitoCurso_Curso]
GO
ALTER TABLE [academico].[RequisitoCurso]  WITH CHECK ADD  CONSTRAINT [FK_RequisitoCurso_CursoRequisito] FOREIGN KEY([CursoRequisitoID])
REFERENCES [academico].[Curso] ([CursoID])
GO
ALTER TABLE [academico].[RequisitoCurso] CHECK CONSTRAINT [FK_RequisitoCurso_CursoRequisito]
GO
ALTER TABLE [admin].[Administrativo]  WITH CHECK ADD  CONSTRAINT [FK_Administrativo_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [admin].[Administrativo] CHECK CONSTRAINT [FK_Administrativo_Persona]
GO
ALTER TABLE [admin].[Administrativo]  WITH CHECK ADD  CONSTRAINT [FK_Administrativo_Unidad] FOREIGN KEY([UnidadAdministrativaID])
REFERENCES [admin].[UnidadAdministrativa] ([UnidadAdministrativaID])
GO
ALTER TABLE [admin].[Administrativo] CHECK CONSTRAINT [FK_Administrativo_Unidad]
GO
ALTER TABLE [admin].[Nombramiento]  WITH CHECK ADD  CONSTRAINT [FK_Nombramiento_Escuela] FOREIGN KEY([EscuelaID])
REFERENCES [academico].[Escuela] ([EscuelaID])
GO
ALTER TABLE [admin].[Nombramiento] CHECK CONSTRAINT [FK_Nombramiento_Escuela]
GO
ALTER TABLE [admin].[Nombramiento]  WITH CHECK ADD  CONSTRAINT [FK_Nombramiento_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [admin].[Nombramiento] CHECK CONSTRAINT [FK_Nombramiento_Persona]
GO
ALTER TABLE [admin].[Nombramiento]  WITH CHECK ADD  CONSTRAINT [FK_Nombramiento_Unidad] FOREIGN KEY([UnidadAdministrativaID])
REFERENCES [admin].[UnidadAdministrativa] ([UnidadAdministrativaID])
GO
ALTER TABLE [admin].[Nombramiento] CHECK CONSTRAINT [FK_Nombramiento_Unidad]
GO
ALTER TABLE [admin].[UnidadAdministrativa]  WITH CHECK ADD  CONSTRAINT [FK_UnidadAdministrativa_Sede] FOREIGN KEY([SedeID])
REFERENCES [core].[Sede] ([SedeID])
GO
ALTER TABLE [admin].[UnidadAdministrativa] CHECK CONSTRAINT [FK_UnidadAdministrativa_Sede]
GO
ALTER TABLE [core].[DireccionPersona]  WITH CHECK ADD  CONSTRAINT [FK_DireccionPersona_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [core].[DireccionPersona] CHECK CONSTRAINT [FK_DireccionPersona_Persona]
GO
ALTER TABLE [core].[DireccionPersona]  WITH CHECK ADD  CONSTRAINT [FK_DireccionPersona_Tipo] FOREIGN KEY([TipoDireccionID])
REFERENCES [core].[TipoDireccion] ([TipoDireccionID])
GO
ALTER TABLE [core].[DireccionPersona] CHECK CONSTRAINT [FK_DireccionPersona_Tipo]
GO
ALTER TABLE [core].[IdentificacionPersona]  WITH CHECK ADD  CONSTRAINT [FK_IdentificacionPersona_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [core].[IdentificacionPersona] CHECK CONSTRAINT [FK_IdentificacionPersona_Persona]
GO
ALTER TABLE [core].[IdentificacionPersona]  WITH CHECK ADD  CONSTRAINT [FK_IdentificacionPersona_Tipo] FOREIGN KEY([TipoIdentificacionID])
REFERENCES [core].[TipoIdentificacion] ([TipoIdentificacionID])
GO
ALTER TABLE [core].[IdentificacionPersona] CHECK CONSTRAINT [FK_IdentificacionPersona_Tipo]
GO
ALTER TABLE [core].[MedioContactoPersona]  WITH CHECK ADD  CONSTRAINT [FK_MedioContactoPersona_Persona] FOREIGN KEY([PersonaID])
REFERENCES [core].[Persona] ([PersonaID])
GO
ALTER TABLE [core].[MedioContactoPersona] CHECK CONSTRAINT [FK_MedioContactoPersona_Persona]
GO
ALTER TABLE [core].[MedioContactoPersona]  WITH CHECK ADD  CONSTRAINT [FK_MedioContactoPersona_Tipo] FOREIGN KEY([TipoMedioContactoID])
REFERENCES [core].[TipoMedioContacto] ([TipoMedioContactoID])
GO
ALTER TABLE [core].[MedioContactoPersona] CHECK CONSTRAINT [FK_MedioContactoPersona_Tipo]
GO
ALTER TABLE [seguridad].[UsuarioSede]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioSede_Sede] FOREIGN KEY([SedeID])
REFERENCES [core].[Sede] ([SedeID])
GO
ALTER TABLE [seguridad].[UsuarioSede] CHECK CONSTRAINT [FK_UsuarioSede_Sede]
GO
ALTER TABLE [academico].[Curso]  WITH CHECK ADD  CONSTRAINT [CK_Curso_Creditos] CHECK  (([Creditos]>(0)))
GO
ALTER TABLE [academico].[Curso] CHECK CONSTRAINT [CK_Curso_Creditos]
GO
ALTER TABLE [academico].[Estudiante]  WITH CHECK ADD  CONSTRAINT [CK_Estudiante_Carnet_Formato] CHECK  ((regexp_like([Carnet],'^[A-Z][0-9][A-Z][0-9]{3}$')))
GO
ALTER TABLE [academico].[Estudiante] CHECK CONSTRAINT [CK_Estudiante_Carnet_Formato]
GO
ALTER TABLE [academico].[Grupo]  WITH CHECK ADD  CONSTRAINT [CK_Grupo_Cupo] CHECK  (([CupoMaximo]>=(0) AND [CupoDisponible]>=(0) AND [CupoDisponible]<=[CupoMaximo]))
GO
ALTER TABLE [academico].[Grupo] CHECK CONSTRAINT [CK_Grupo_Cupo]
GO
ALTER TABLE [academico].[Matricula]  WITH CHECK ADD  CONSTRAINT [CK_Matricula_Nota] CHECK  (([NotaFinal] IS NULL OR [NotaFinal]>=(0) AND [NotaFinal]<=(100)))
GO
ALTER TABLE [academico].[Matricula] CHECK CONSTRAINT [CK_Matricula_Nota]
GO
ALTER TABLE [academico].[PeriodoLectivo]  WITH CHECK ADD  CONSTRAINT [CK_PeriodoLectivo_Fechas] CHECK  (([FechaFin]>[FechaInicio]))
GO
ALTER TABLE [academico].[PeriodoLectivo] CHECK CONSTRAINT [CK_PeriodoLectivo_Fechas]
GO
ALTER TABLE [academico].[RequisitoCurso]  WITH CHECK ADD  CONSTRAINT [CK_RequisitoCurso_NoAutoReferencia] CHECK  (([CursoID]<>[CursoRequisitoID]))
GO
ALTER TABLE [academico].[RequisitoCurso] CHECK CONSTRAINT [CK_RequisitoCurso_NoAutoReferencia]
GO
ALTER TABLE [admin].[Nombramiento]  WITH CHECK ADD  CONSTRAINT [CK_Nombramiento_Destino] CHECK  (([EscuelaID] IS NOT NULL OR [UnidadAdministrativaID] IS NOT NULL))
GO
ALTER TABLE [admin].[Nombramiento] CHECK CONSTRAINT [CK_Nombramiento_Destino]
GO
ALTER TABLE [admin].[Nombramiento]  WITH CHECK ADD  CONSTRAINT [CK_Nombramiento_Fechas] CHECK  (([FechaFin] IS NULL OR [FechaFin]>=[FechaInicio]))
GO
ALTER TABLE [admin].[Nombramiento] CHECK CONSTRAINT [CK_Nombramiento_Fechas]
GO
ALTER TABLE [core].[IdentificacionPersona]  WITH CHECK ADD  CONSTRAINT [CK_IdentificacionPersona_Formato] CHECK  ((regexp_like([NumeroIdentificacion],'^[1-9]-?[0-9]{4}-?[0-9]{4}$')))
GO
ALTER TABLE [core].[IdentificacionPersona] CHECK CONSTRAINT [CK_IdentificacionPersona_Formato]
GO
ALTER TABLE [core].[MedioContactoPersona]  WITH CHECK ADD  CONSTRAINT [CK_MedioContactoPersona_Email_Formato] CHECK  ((regexp_like([ValorContacto],'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') OR [TipoMedioContactoID]<>(1)))
GO
ALTER TABLE [core].[MedioContactoPersona] CHECK CONSTRAINT [CK_MedioContactoPersona_Email_Formato]
GO
/****** Object:  StoredProcedure [api].[usp_ConsultarEndpointUniversidad]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [api].[usp_ConsultarEndpointUniversidad]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @response NVARCHAR(MAX);
    DECLARE @codigoRespuesta INT;

    EXEC sys.sp_invoke_external_rest_endpoint
        @url = N'https://jsonplaceholder.typicode.com/todos/1',
        @method = N'GET',
        @response = @response OUTPUT;

    SET @codigoRespuesta =
        TRY_CONVERT(
            INT,
            JSON_VALUE(@response, '$.response.status.http.code')
        );

    INSERT INTO api.ConsultaExterna
    (
        Endpoint,
        CodigoRespuesta,
        RespuestaJSON
    )
    VALUES
    (
        N'https://jsonplaceholder.typicode.com/todos/1',
        COALESCE(@codigoRespuesta, 0),
        @response
    );

    SELECT
        @codigoRespuesta AS CodigoRespuesta,
        @response AS RespuestaJSON;
END;
GO
/****** Object:  StoredProcedure [api].[usp_ExportarPersonasJSON]    Script Date: 7/7/2026 4:48:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* =========================================================
   JSON: SERIALIZACIÓN DE PERSONAS
   ========================================================= */

CREATE   PROCEDURE [api].[usp_ExportarPersonasJSON]
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
