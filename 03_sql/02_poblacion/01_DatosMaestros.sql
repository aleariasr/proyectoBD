USE SIGAU;
GO

/* =========================================================
   01_DatosMaestros.sql
   Población de catálogos y datos base
   ========================================================= */

INSERT INTO core.TipoIdentificacion (Codigo, Nombre, Descripcion)
VALUES
('CED', 'Cédula nacional', 'Identificación nacional costarricense'),
('DIMEX', 'DIMEX', 'Documento migratorio para extranjeros'),
('PAS', 'Pasaporte', 'Documento de identificación internacional'),
('CARNE', 'Carné universitario', 'Identificador interno universitario'),
('RES', 'Residencia', 'Documento de residencia'),
('TEMP', 'Identificación temporal', 'Documento temporal institucional'),
('JUR', 'Cédula jurídica', 'Identificación de persona jurídica'),
('INT', 'Identificación interna', 'Código interno administrativo'),
('EXT', 'Identificación externa', 'Código de usuario externo'),
('OTR', 'Otro documento', 'Otro tipo de identificación');
GO

INSERT INTO core.TipoDireccion (Codigo, Nombre, Descripcion)
VALUES
('CASA', 'Casa de habitación', 'Dirección residencial'),
('TRAB', 'Trabajo', 'Dirección laboral'),
('FAM', 'Familiar', 'Dirección de familiar responsable'),
('TEMP', 'Temporal', 'Dirección temporal'),
('SEDE', 'Sede universitaria', 'Dirección institucional'),
('OFIC', 'Oficina', 'Dirección de oficina'),
('APTO', 'Apartamento', 'Dirección de apartamento'),
('RESID', 'Residencia estudiantil', 'Dirección de residencia estudiantil'),
('COBRO', 'Cobro', 'Dirección para trámites administrativos'),
('OTRA', 'Otra dirección', 'Otro tipo de dirección');
GO

INSERT INTO core.TipoMedioContacto (Codigo, Nombre, Descripcion)
VALUES
('EMAIL', 'Correo electrónico', 'Correo principal'),
('TEL', 'Teléfono fijo', 'Teléfono residencial o institucional'),
('CEL', 'Teléfono celular', 'Teléfono móvil'),
('WHATS', 'WhatsApp', 'Contacto vía WhatsApp'),
('INST', 'Correo institucional', 'Correo universitario'),
('EMERG', 'Contacto de emergencia', 'Medio de contacto para emergencias'),
('FAX', 'Fax', 'Medio tradicional de fax'),
('TEAMS', 'Microsoft Teams', 'Usuario de Teams'),
('LINKEDIN', 'LinkedIn', 'Perfil profesional'),
('OTRO', 'Otro medio', 'Otro medio de contacto');
GO

INSERT INTO core.Sede (Codigo, Nombre, DireccionReferencia)
VALUES
('SO', 'Sede de Occidente', 'San Ramón, Alajuela, Costa Rica'),
('RG', 'Recinto de Grecia', 'Grecia, Alajuela, Costa Rica'),
('RT', 'Recinto de Tacares', 'Tacares, Grecia, Alajuela'),
('SJ', 'Sede Rodrigo Facio', 'San Pedro, Montes de Oca, San José'),
('CA', 'Sede del Caribe', 'Limón, Costa Rica'),
('GU', 'Sede de Guanacaste', 'Liberia, Guanacaste'),
('PA', 'Sede del Pacífico', 'Puntarenas, Costa Rica'),
('AT', 'Sede del Atlántico', 'Turrialba, Cartago'),
('ZA', 'Sede Interuniversitaria de Alajuela', 'Alajuela, Costa Rica'),
('BR', 'Recinto de Paraíso', 'Paraíso, Cartago');
GO

INSERT INTO core.Persona
(PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, FechaNacimiento)
VALUES
('Alejandro', NULL, 'Arias', 'Rojas', '2002-04-12'),
('Mariangel', NULL, 'Arias', 'Alfaro', '2002-08-20'),
('Sebastián', NULL, 'Alfaro', 'Arias', '2001-11-03'),
('Valeria', 'María', 'Solís', 'Mora', '2003-02-14'),
('Daniel', 'José', 'Vargas', 'Castro', '2002-06-18'),
('Sofía', NULL, 'Méndez', 'Chaves', '2004-01-25'),
('Gabriel', 'Andrés', 'Rojas', 'Quesada', '2001-09-09'),
('Camila', NULL, 'Fernández', 'López', '2003-12-01'),
('Andrés', 'Felipe', 'Ramírez', 'Soto', '2000-07-07'),
('Natalia', NULL, 'Cordero', 'Jiménez', '2002-03-30'),
('Luis', 'Diego', 'Bolaños', 'Alvarado', '1980-05-15'),
('Marcela', NULL, 'Rodríguez', 'Vega', '1985-10-22'),
('Roberto', 'Carlos', 'Molina', 'Pérez', '1979-04-11'),
('Andrea', NULL, 'Campos', 'Salas', '1988-06-06'),
('Mauricio', NULL, 'Fernández', 'Araya', '1982-09-19'),
('Carolina', NULL, 'Gutiérrez', 'Rojas', '1990-01-17'),
('Esteban', 'Alonso', 'Mora', 'Castillo', '1987-12-13'),
('Lucía', NULL, 'Vargas', 'Núñez', '1991-02-21'),
('Pablo', 'Enrique', 'Sánchez', 'León', '1983-08-08'),
('Adriana', NULL, 'Jiménez', 'Solano', '1986-11-29'),
('Paola', NULL, 'Herrera', 'Mena', '1992-05-05'),
('Jorge', 'Luis', 'Vega', 'Rojas', '1984-04-24'),
('María', 'Fernanda', 'Alpízar', 'Castro', '1989-09-15'),
('Kenneth', NULL, 'Chacón', 'Mora', '1981-01-02'),
('Laura', NULL, 'Navarro', 'Soto', '1993-03-18'),
('Diego', 'Armando', 'Pérez', 'Rojas', '1990-10-10'),
('Mónica', NULL, 'Aguilar', 'Vargas', '1988-07-27'),
('Ricardo', NULL, 'Salazar', 'Campos', '1985-06-09'),
('Karla', 'María', 'Madrigal', 'López', '1991-11-11'),
('Felipe', NULL, 'Castro', 'Quesada', '1987-02-02');
GO

INSERT INTO core.IdentificacionPersona
(PersonaID, TipoIdentificacionID, NumeroIdentificacion, EsPrincipal)
VALUES
(1, 1, '1-1111-1111', 1),
(2, 1, '1-2222-2222', 1),
(3, 1, '1-3333-3333', 1),
(4, 1, '1-4444-4444', 1),
(5, 1, '1-5555-5555', 1),
(6, 1, '1-6666-6666', 1),
(7, 1, '1-7777-7777', 1),
(8, 1, '1-8888-8888', 1),
(9, 1, '1-9999-9999', 1),
(10, 1, '1-1010-1010', 1),
(11, 1, '1-1111-2026', 1),
(12, 1, '1-1212-2026', 1),
(13, 1, '1-1313-2026', 1),
(14, 1, '1-1414-2026', 1),
(15, 1, '1-1515-2026', 1),
(16, 1, '1-1616-2026', 1),
(17, 1, '1-1717-2026', 1),
(18, 1, '1-1818-2026', 1),
(19, 1, '1-1919-2026', 1),
(20, 1, '1-2020-2026', 1),
(21, 1, '1-2121-2026', 1),
(22, 1, '1-2222-2026', 1),
(23, 1, '1-2323-2026', 1),
(24, 1, '1-2424-2026', 1),
(25, 1, '1-2525-2026', 1),
(26, 1, '1-2626-2026', 1),
(27, 1, '1-2727-2026', 1),
(28, 1, '1-2828-2026', 1),
(29, 1, '1-2929-2026', 1),
(30, 1, '1-3030-2026', 1);
GO

INSERT INTO core.DireccionPersona
(PersonaID, TipoDireccionID, Provincia, Canton, Distrito, DireccionDetallada, EsPrincipal)
VALUES
(1, 1, 'Alajuela', 'Grecia', 'Grecia', 'Residencial Los Pinos, casa 12', 1),
(2, 1, 'Alajuela', 'San Ramón', 'San Ramón', 'Barrio San José, 200 metros norte del parque', 1),
(3, 1, 'Alajuela', 'Grecia', 'Tacares', 'Calle principal, frente a la plaza', 1),
(4, 1, 'San José', 'Montes de Oca', 'San Pedro', 'Residencial Universitario, apartamento 3B', 1),
(5, 1, 'Cartago', 'Paraíso', 'Paraíso', 'Urbanización El Molino, casa 45', 1),
(6, 1, 'Heredia', 'Heredia', 'Mercedes', 'Condominio Las Flores, torre 2', 1),
(7, 1, 'Puntarenas', 'Puntarenas', 'Centro', 'Barrio El Carmen, casa 21', 1),
(8, 1, 'Limón', 'Limón', 'Limón', 'Avenida Central, edificio Caribe', 1),
(9, 1, 'Guanacaste', 'Liberia', 'Liberia', 'Residencial Chorotega, lote 8', 1),
(10, 1, 'Alajuela', 'Alajuela', 'Centro', 'Calle 8, avenida 4', 1),
(11, 2, 'Alajuela', 'Grecia', 'Tacares', 'Oficina académica, recinto de Tacares', 1),
(12, 2, 'San José', 'Montes de Oca', 'San Pedro', 'Escuela de Informática, oficina 12', 1),
(13, 2, 'Alajuela', 'San Ramón', 'San Ramón', 'Dirección académica, sede Occidente', 1),
(14, 2, 'Cartago', 'Turrialba', 'Turrialba', 'Coordinación administrativa, sede Atlántico', 1),
(15, 2, 'Alajuela', 'Grecia', 'Grecia', 'Laboratorio de redes, segundo piso', 1),
(16, 2, 'San José', 'San José', 'Carmen', 'Oficina de registro académico', 1),
(17, 2, 'Heredia', 'Heredia', 'Heredia', 'Departamento financiero, oficina 6', 1),
(18, 2, 'Alajuela', 'Alajuela', 'Centro', 'Área de vida estudiantil', 1),
(19, 2, 'Puntarenas', 'Puntarenas', 'Centro', 'Unidad administrativa regional', 1),
(20, 2, 'Limón', 'Limón', 'Limón', 'Oficina de coordinación académica', 1),
(21, 1, 'Alajuela', 'Grecia', 'Grecia', 'Residencial Montezuma, casa 3', 1),
(22, 1, 'Alajuela', 'San Ramón', 'San Ramón', 'Barrio Tremedal, casa 18', 1),
(23, 1, 'Cartago', 'Cartago', 'Oriental', 'Urbanización Los Ángeles, casa 10', 1),
(24, 1, 'Heredia', 'Barva', 'Barva', 'Calle Real, 75 metros este de la iglesia', 1),
(25, 1, 'San José', 'Escazú', 'San Rafael', 'Condominio Robles, casa 7', 1),
(26, 1, 'Alajuela', 'Naranjo', 'Naranjo', 'Barrio El Carmen, casa 15', 1),
(27, 1, 'Guanacaste', 'Liberia', 'Liberia', 'Residencial El Sitio, casa 14', 1),
(28, 1, 'Puntarenas', 'Esparza', 'Esparza', 'Barrio La Riviera, casa 2', 1),
(29, 1, 'Limón', 'Pococí', 'Guápiles', 'Urbanización Caribe Norte, lote 9', 1),
(30, 1, 'Cartago', 'Paraíso', 'Paraíso', 'Residencial La Laguna, casa 20', 1);
GO

INSERT INTO core.MedioContactoPersona
(PersonaID, TipoMedioContactoID, ValorContacto, EsPrincipal)
VALUES
(1, 1, 'alejandro.arias@ucr.ac.cr', 1),
(2, 1, 'mariangel.arias@ucr.ac.cr', 1),
(3, 1, 'sebastian.alfaro@ucr.ac.cr', 1),
(4, 1, 'valeria.solis@ucr.ac.cr', 1),
(5, 1, 'daniel.vargas@ucr.ac.cr', 1),
(6, 1, 'sofia.mendez@ucr.ac.cr', 1),
(7, 1, 'gabriel.rojas@ucr.ac.cr', 1),
(8, 1, 'camila.fernandez@ucr.ac.cr', 1),
(9, 1, 'andres.ramirez@ucr.ac.cr', 1),
(10, 1, 'natalia.cordero@ucr.ac.cr', 1),
(11, 1, 'luis.bolanos@ucr.ac.cr', 1),
(12, 1, 'marcela.rodriguez@ucr.ac.cr', 1),
(13, 1, 'roberto.molina@ucr.ac.cr', 1),
(14, 1, 'andrea.campos@ucr.ac.cr', 1),
(15, 1, 'mauricio.fernandez@ucr.ac.cr', 1),
(16, 1, 'carolina.gutierrez@ucr.ac.cr', 1),
(17, 1, 'esteban.mora@ucr.ac.cr', 1),
(18, 1, 'lucia.vargas@ucr.ac.cr', 1),
(19, 1, 'pablo.sanchez@ucr.ac.cr', 1),
(20, 1, 'adriana.jimenez@ucr.ac.cr', 1),
(21, 1, 'paola.herrera@ucr.ac.cr', 1),
(22, 1, 'jorge.vega@ucr.ac.cr', 1),
(23, 1, 'maria.alpizar@ucr.ac.cr', 1),
(24, 1, 'kenneth.chacon@ucr.ac.cr', 1),
(25, 1, 'laura.navarro@ucr.ac.cr', 1),
(26, 1, 'diego.perez@ucr.ac.cr', 1),
(27, 1, 'monica.aguilar@ucr.ac.cr', 1),
(28, 1, 'ricardo.salazar@ucr.ac.cr', 1),
(29, 1, 'karla.madrigal@ucr.ac.cr', 1),
(30, 1, 'felipe.castro@ucr.ac.cr', 1);
GO

PRINT '01_DatosMaestros.sql ejecutado correctamente.';
GO