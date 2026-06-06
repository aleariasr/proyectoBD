USE SIGAU;
GO

/* =========================================================
   02_DatosAcademicos.sql
   Población de datos académicos
   ========================================================= */

INSERT INTO academico.Escuela (SedeID, Codigo, Nombre)
VALUES
(1, 'EI-SO', 'Escuela de Informática - Occidente'),
(2, 'ADM-RG', 'Escuela de Administración - Grecia'),
(3, 'ING-RT', 'Escuela de Ingeniería - Tacares'),
(4, 'MAT-SJ', 'Escuela de Matemática - Rodrigo Facio'),
(5, 'BIO-CA', 'Escuela de Biología - Caribe'),
(6, 'TUR-GU', 'Escuela de Turismo - Guanacaste'),
(7, 'MAR-PA', 'Escuela de Ciencias del Mar - Pacífico'),
(8, 'AGR-AT', 'Escuela de Agronomía - Atlántico'),
(9, 'IND-ZA', 'Escuela de Ingeniería Industrial - Alajuela'),
(10, 'EDU-BR', 'Escuela de Educación - Paraíso');
GO

INSERT INTO academico.PlanEstudio (EscuelaID, Codigo, Nombre, Version)
VALUES
(1, 'INF-2026', 'Bachillerato en Informática Empresarial', '2026'),
(2, 'ADM-2026', 'Bachillerato en Dirección de Empresas', '2026'),
(3, 'ING-2026', 'Bachillerato en Ingeniería Aplicada', '2026'),
(4, 'MAT-2026', 'Bachillerato en Matemática', '2026'),
(5, 'BIO-2026', 'Bachillerato en Biología Tropical', '2026'),
(6, 'TUR-2026', 'Bachillerato en Turismo Ecológico', '2026'),
(7, 'MAR-2026', 'Bachillerato en Ciencias Marinas', '2026'),
(8, 'AGR-2026', 'Bachillerato en Agronomía', '2026'),
(9, 'IND-2026', 'Bachillerato en Ingeniería Industrial', '2026'),
(10, 'EDU-2026', 'Bachillerato en Educación', '2026');
GO

INSERT INTO academico.Profesor (PersonaID, EscuelaID, CategoriaAcademica)
VALUES
(11, 1, 'Profesor Asociado'),
(12, 1, 'Profesor Adjunto'),
(13, 2, 'Profesor Catedrático'),
(14, 3, 'Profesor Instructor'),
(15, 1, 'Profesor Asociado'),
(16, 4, 'Profesor Adjunto'),
(17, 5, 'Profesor Instructor'),
(18, 6, 'Profesor Asociado'),
(19, 7, 'Profesor Adjunto'),
(20, 8, 'Profesor Instructor');
GO

INSERT INTO academico.Estudiante (PersonaID, EscuelaID, Carnet)
VALUES
(1, 1, 'C4C759'),
(2, 1, 'C4C688'),
(3, 1, 'C4C212'),
(4, 2, 'C4C404'),
(5, 3, 'C4C505'),
(6, 4, 'C4C606'),
(7, 5, 'C4C707'),
(8, 6, 'C4C808'),
(9, 7, 'C4C909'),
(10, 8, 'C4C010');
GO

INSERT INTO academico.PeriodoLectivo (Codigo, Nombre, FechaInicio, FechaFin)
VALUES
('2024-I', 'I Ciclo 2024', '2024-03-01', '2024-07-15'),
('2024-II', 'II Ciclo 2024', '2024-08-01', '2024-12-10'),
('2025-I', 'I Ciclo 2025', '2025-03-01', '2025-07-15'),
('2025-II', 'II Ciclo 2025', '2025-08-01', '2025-12-10'),
('2026-I', 'I Ciclo 2026', '2026-03-01', '2026-07-15'),
('2026-II', 'II Ciclo 2026', '2026-08-01', '2026-12-10'),
('2027-I', 'I Ciclo 2027', '2027-03-01', '2027-07-15'),
('2027-II', 'II Ciclo 2027', '2027-08-01', '2027-12-10'),
('2028-I', 'I Ciclo 2028', '2028-03-01', '2028-07-15'),
('2028-II', 'II Ciclo 2028', '2028-08-01', '2028-12-10');
GO

INSERT INTO academico.Curso
(PlanEstudioID, CodigoCurso, NombreCurso, Creditos, HorasTeoria, HorasPractica, Nivel, Descripcion, Embedding)
VALUES
(1, 'IF5100', 'Administración de Bases de Datos', 4, 3, 2, 5, 'Curso sobre administración, seguridad, respaldo y optimización de bases de datos.', CAST('[0.10,0.20,0.30,0.40,0.50]' AS VECTOR(5))),
(1, 'IF4100', 'Sistemas Operativos', 4, 3, 2, 4, 'Curso sobre procesos, memoria, concurrencia y sistemas operativos modernos.', CAST('[0.12,0.22,0.32,0.42,0.52]' AS VECTOR(5))),
(1, 'IF3100', 'Sistemas de Información', 3, 3, 1, 3, 'Curso introductorio a sistemas de información empresariales.', CAST('[0.15,0.25,0.35,0.45,0.55]' AS VECTOR(5))),
(2, 'ADM2001', 'Administración General', 3, 3, 0, 2, 'Curso sobre fundamentos de administración organizacional.', CAST('[0.60,0.10,0.20,0.30,0.40]' AS VECTOR(5))),
(3, 'ING3001', 'Fundamentos de Ingeniería', 4, 3, 2, 3, 'Curso base de análisis y resolución de problemas de ingeniería.', CAST('[0.20,0.60,0.10,0.30,0.40]' AS VECTOR(5))),
(4, 'MAT1001', 'Cálculo I', 4, 4, 1, 1, 'Curso sobre límites, derivadas e integrales.', CAST('[0.30,0.40,0.60,0.10,0.20]' AS VECTOR(5))),
(5, 'BIO1001', 'Biología General', 4, 3, 2, 1, 'Curso introductorio de biología celular y ecosistemas.', CAST('[0.50,0.20,0.10,0.60,0.30]' AS VECTOR(5))),
(6, 'TUR2001', 'Gestión Turística', 3, 3, 1, 2, 'Curso sobre planificación y gestión turística sostenible.', CAST('[0.25,0.35,0.45,0.15,0.55]' AS VECTOR(5))),
(7, 'MAR3001', 'Oceanografía General', 4, 3, 2, 3, 'Curso sobre procesos físicos, químicos y biológicos del océano.', CAST('[0.40,0.30,0.20,0.50,0.10]' AS VECTOR(5))),
(8, 'AGR2001', 'Suelos y Cultivos', 4, 3, 2, 2, 'Curso sobre manejo de suelos y producción agrícola.', CAST('[0.35,0.45,0.15,0.25,0.65]' AS VECTOR(5)));
GO

INSERT INTO academico.RequisitoCurso (CursoID, CursoRequisitoID, TipoRequisito)
VALUES
(1, 2, 'Requisito'),
(1, 3, 'Requisito'),
(2, 3, 'Requisito'),
(5, 6, 'Correquisito'),
(8, 4, 'Requisito'),
(9, 7, 'Requisito'),
(10, 7, 'Requisito'),
(6, 3, 'Requisito'),
(4, 3, 'Correquisito'),
(7, 6, 'Requisito');
GO

INSERT INTO academico.Grupo
(CursoID, PeriodoLectivoID, ProfesorID, NumeroGrupo, CupoMaximo, CupoDisponible, Modalidad, HorarioTexto, Aula)
VALUES
(1, 5, 1, '001', 30, 20, 'Presencial', 'Lunes 18:00-21:00', 'LAB-01'),
(2, 5, 2, '001', 28, 15, 'Presencial', 'Martes 18:00-21:00', 'LAB-02'),
(3, 5, 1, '002', 35, 22, 'Virtual', 'Miércoles 18:00-20:00', 'Virtual'),
(4, 5, 3, '001', 40, 18, 'Presencial', 'Jueves 17:00-20:00', 'A-101'),
(5, 5, 4, '001', 30, 12, 'Presencial', 'Viernes 08:00-11:00', 'B-202'),
(6, 5, 6, '001', 35, 10, 'Presencial', 'Lunes 08:00-11:00', 'M-01'),
(7, 5, 7, '001', 25, 8, 'Presencial', 'Martes 09:00-12:00', 'BIO-03'),
(8, 5, 8, '001', 30, 14, 'Virtual', 'Miércoles 09:00-11:00', 'Virtual'),
(9, 5, 9, '001', 25, 9, 'Presencial', 'Jueves 13:00-16:00', 'MAR-01'),
(10, 5, 10, '001', 30, 11, 'Presencial', 'Viernes 13:00-16:00', 'AGR-01');
GO

INSERT INTO academico.Matricula
(EstudianteID, GrupoID, Estado, NotaFinal)
VALUES
(1, 1, 'MATRICULADO', 95.00),
(2, 1, 'MATRICULADO', 91.50),
(3, 1, 'MATRICULADO', 88.25),
(4, 4, 'MATRICULADO', 84.00),
(5, 5, 'MATRICULADO', 79.50),
(6, 6, 'MATRICULADO', 92.00),
(7, 7, 'MATRICULADO', 86.75),
(8, 8, 'MATRICULADO', 90.00),
(9, 9, 'MATRICULADO', 81.25),
(10, 10, 'MATRICULADO', 87.00);
GO

INSERT INTO academico.HistorialAcademico
(EstudianteID, PeriodoLectivoID, PromedioPeriodo, CreditosMatriculados, CreditosAprobados, CondicionPeriodo)
VALUES
(1, 5, 95.00, 12, 12, 'Excelente'),
(2, 5, 91.50, 12, 12, 'Excelente'),
(3, 5, 88.25, 12, 12, 'Regular'),
(4, 5, 84.00, 12, 12, 'Regular'),
(5, 5, 79.50, 12, 12, 'Regular'),
(6, 5, 92.00, 12, 12, 'Excelente'),
(7, 5, 86.75, 12, 12, 'Regular'),
(8, 5, 90.00, 12, 12, 'Excelente'),
(9, 5, 81.25, 12, 12, 'Regular'),
(10, 5, 87.00, 12, 12, 'Regular');
GO

PRINT '02_DatosAcademicos.sql ejecutado correctamente.';
GO