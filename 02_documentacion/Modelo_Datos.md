# Modelo de Datos SIGAU

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

---

## Relaciones principales

### Organización institucional

Sede
→ Escuela

Sede
→ UnidadAdministrativa

### Personas

Persona
→ IdentificacionPersona

Persona
→ DireccionPersona

Persona
→ MedioContactoPersona

Persona
→ Profesor

Persona
→ Estudiante

Persona
→ Administrativo

### Académico

Escuela
→ PlanEstudio

Escuela
→ Profesor

Escuela
→ Estudiante

PlanEstudio
→ Curso

Curso
→ RequisitoCurso

Curso
→ Grupo

PeriodoLectivo
→ Grupo

Profesor
→ Grupo

Estudiante
→ Matricula

Grupo
→ Matricula

Estudiante
→ HistorialAcademico

PeriodoLectivo
→ HistorialAcademico

### Administrativo

UnidadAdministrativa
→ Administrativo

Persona
→ Nombramiento

Escuela
→ Nombramiento

UnidadAdministrativa
→ Nombramiento

### Seguridad

Sede
→ UsuarioSede

UsuarioSede
→ Row Level Security

BitacoraAcceso
→ Auditoría de eventos