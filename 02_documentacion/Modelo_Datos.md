# Modelo de Datos SIGAU

## Descripción

El modelo de datos representa un sistema académico-administrativo universitario. El mini-mundo incluye personas, estudiantes, profesores, administrativos, sedes, escuelas, planes de estudio, cursos, grupos, matrícula, historial académico, unidades administrativas, nombramientos y componentes de seguridad.

## Entidades principales

### Core

- Persona
- TipoIdentificacion
- TipoDireccion
- TipoMedioContacto
- Sede
- IdentificacionPersona
- DireccionPersona
- MedioContactoPersona

### Académico

- Escuela
- PlanEstudio
- Profesor
- Estudiante
- PeriodoLectivo
- Curso
- RequisitoCurso
- Grupo
- Matricula
- HistorialAcademico

### Administrativo

- UnidadAdministrativa
- Administrativo
- Nombramiento

### Seguridad

- UsuarioSede
- BitacoraAcceso

### Integración

- ConsultaExterna

## Relaciones principales

### Organización institucional

- Una sede puede tener muchas escuelas.
- Una sede puede tener muchas unidades administrativas.
- Una escuela puede tener muchos planes de estudio.
- Una escuela puede tener profesores y estudiantes.

### Personas

- Una persona puede tener identificaciones.
- Una persona puede tener direcciones.
- Una persona puede tener medios de contacto.
- Una persona puede especializarse como estudiante, profesor o administrativo.

### Académico

- Un plan de estudio contiene cursos.
- Un curso puede tener requisitos.
- Un curso se oferta mediante grupos.
- Un grupo pertenece a un periodo lectivo.
- Un grupo es impartido por un profesor.
- Un estudiante puede matricular muchos grupos.
- Una matrícula relaciona estudiante y grupo.
- Un estudiante posee historial académico por periodo.

### Administrativo

- Una unidad administrativa pertenece a una sede.
- Un administrativo pertenece a una unidad administrativa.
- Un nombramiento puede asociarse a una escuela o unidad administrativa.

### Seguridad

- UsuarioSede relaciona usuarios con sedes autorizadas.
- BitacoraAcceso registra eventos del sistema.
- Las políticas RLS utilizan UsuarioSede para filtrar registros por sede.

## Población

Todas las tablas poseen al menos 10 registros.

Evidencia:

![Conteo de registros](../04_evidencias/Pruebas/01_Conteo_Registros_Tablas.jpeg)

## Scripts relacionados

- [Creación de base de datos](../03_sql/01_creacion/01_SIGAU_CreacionBD_v1_0.sql)
- [Datos maestros](../03_sql/02_poblacion/01_DatosMaestros.sql)
- [Datos académicos](../03_sql/02_poblacion/02_DatosAcademicos.sql)
- [Datos administrativos](../03_sql/02_poblacion/03_DatosAdministrativos.sql)
