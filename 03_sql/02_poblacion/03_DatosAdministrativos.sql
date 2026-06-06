USE SIGAU;
GO

/* =========================================================
   03_DatosAdministrativos.sql
   Población de datos administrativos, seguridad y bitácora
   ========================================================= */

INSERT INTO admin.UnidadAdministrativa (SedeID, Codigo, Nombre, TipoUnidad)
VALUES
(1, 'REG-SO', 'Registro Académico Occidente', 'Registro'),
(2, 'ADM-RG', 'Administración Recinto Grecia', 'Administración'),
(3, 'COO-RT', 'Coordinación Recinto Tacares', 'Coordinación'),
(4, 'DIR-SJ', 'Dirección Académica Rodrigo Facio', 'Dirección'),
(5, 'FIN-CA', 'Unidad Financiera Caribe', 'Finanzas'),
(6, 'VID-GU', 'Vida Estudiantil Guanacaste', 'Vida Estudiantil'),
(7, 'BIB-PA', 'Biblioteca Pacífico', 'Biblioteca'),
(8, 'TEC-AT', 'Soporte Tecnológico Atlántico', 'Tecnología'),
(9, 'PRO-ZA', 'Proveeduría Alajuela', 'Proveeduría'),
(10, 'REC-BR', 'Recursos Humanos Paraíso', 'Recursos Humanos');
GO

INSERT INTO admin.Administrativo
(PersonaID, UnidadAdministrativaID, Cargo, TipoNombramiento, EstadoAdministrativo)
VALUES
(21, 1, 'Coordinadora de Registro', 'Tiempo completo', 'Activo'),
(22, 2, 'Administrador de Recinto', 'Tiempo completo', 'Activo'),
(23, 3, 'Coordinadora Académica', 'Tiempo completo', 'Activo'),
(24, 4, 'Analista Académico', 'Tiempo completo', 'Activo'),
(25, 5, 'Gestora Financiera', 'Tiempo completo', 'Activo'),
(26, 6, 'Asistente de Vida Estudiantil', 'Medio tiempo', 'Activo'),
(27, 7, 'Bibliotecaria', 'Tiempo completo', 'Activo'),
(28, 8, 'Técnico de Soporte', 'Tiempo completo', 'Activo'),
(29, 9, 'Analista de Proveeduría', 'Tiempo completo', 'Activo'),
(30, 10, 'Gestor de Recursos Humanos', 'Tiempo completo', 'Activo');
GO

INSERT INTO admin.Nombramiento
(PersonaID, EscuelaID, UnidadAdministrativaID, TipoNombramiento, FechaInicio, FechaFin)
VALUES
(11, 1, NULL, 'Docente propiedad', '2024-01-01', NULL),
(12, 1, NULL, 'Docente interino', '2025-01-01', NULL),
(13, 2, NULL, 'Docente propiedad', '2023-01-01', NULL),
(14, 3, NULL, 'Docente interino', '2025-03-01', NULL),
(15, 1, NULL, 'Docente propiedad', '2024-08-01', NULL),
(21, NULL, 1, 'Administrativo propiedad', '2024-01-01', NULL),
(22, NULL, 2, 'Administrativo propiedad', '2024-01-01', NULL),
(23, NULL, 3, 'Administrativo interino', '2025-01-01', NULL),
(24, NULL, 4, 'Administrativo propiedad', '2024-06-01', NULL),
(25, NULL, 5, 'Administrativo interino', '2025-03-01', NULL);
GO

INSERT INTO seguridad.UsuarioSede (UsuarioBD, SedeID)
VALUES
('adminbackup', 1),
('adminbackup', 2),
('adminbackup', 3),
('usuario_occidente', 1),
('usuario_grecia', 2),
('usuario_tacares', 3),
('usuario_rodrigo_facio', 4),
('usuario_caribe', 5),
('usuario_guanacaste', 6),
('usuario_pacifico', 7);
GO

INSERT INTO seguridad.BitacoraAcceso
(UsuarioSistema, Accion, Entidad, LlaveEntidad, DireccionIP)
VALUES
('adminbackup', 'CREACION_BD', 'SIGAU', 'SIGAU', '10.0.0.4'),
('adminbackup', 'INSERT', 'core.Persona', '1', '10.0.0.4'),
('adminbackup', 'INSERT', 'academico.Escuela', '1', '10.0.0.4'),
('adminbackup', 'INSERT', 'academico.Curso', '1', '10.0.0.4'),
('adminbackup', 'INSERT', 'academico.Matricula', '1', '10.0.0.4'),
('adminbackup', 'INSERT', 'admin.Administrativo', '1', '10.0.0.4'),
('adminbackup', 'CONFIGURACION', 'seguridad.RLS', 'Policy_EscuelaPorSede', '10.0.0.4'),
('adminbackup', 'CONFIGURACION', 'seguridad.RLS', 'Policy_UnidadPorSede', '10.0.0.4'),
('adminbackup', 'AUDITORIA', 'Audit_SIGAU_Database', 'Audit_SIGAU_Database', '10.0.0.4'),
('adminbackup', 'VALIDACION', 'SIGAU', 'Poblacion inicial', '10.0.0.4');
GO

INSERT INTO api.ConsultaExterna
(Endpoint, CodigoRespuesta, RespuestaJSON)
VALUES
('https://jsonplaceholder.typicode.com/todos/1', 200, '{"userId":1,"id":1,"title":"delectus aut autem","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/2', 200, '{"userId":1,"id":2,"title":"quis ut nam facilis et officia qui","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/3', 200, '{"userId":1,"id":3,"title":"fugiat veniam minus","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/4', 200, '{"userId":1,"id":4,"title":"et porro tempora","completed":true}'),
('https://jsonplaceholder.typicode.com/todos/5', 200, '{"userId":1,"id":5,"title":"laboriosam mollitia et enim quasi adipisci quia provident illum","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/6', 200, '{"userId":1,"id":6,"title":"qui ullam ratione quibusdam voluptatem quia omnis","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/7', 200, '{"userId":1,"id":7,"title":"illo expedita consequatur quia in","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/8', 200, '{"userId":1,"id":8,"title":"quo adipisci enim quam ut ab","completed":true}'),
('https://jsonplaceholder.typicode.com/todos/9', 200, '{"userId":1,"id":9,"title":"molestiae perspiciatis ipsa","completed":false}'),
('https://jsonplaceholder.typicode.com/todos/10', 200, '{"userId":1,"id":10,"title":"illo est ratione doloremque quia maiores aut","completed":true}');
GO

PRINT '03_DatosAdministrativos.sql ejecutado correctamente.';
GO