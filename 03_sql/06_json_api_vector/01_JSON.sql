USE SIGAU;
GO

/*=========================================================
  SIGAU
  Exportación de datos en formato JSON
=========================================================*/

SELECT
    PersonaID,
    PrimerNombre,
    SegundoNombre,
    PrimerApellido,
    SegundoApellido,
    FechaNacimiento,
    FechaCreacion,
    Estado
FROM core.Persona
FOR JSON PATH, ROOT('Personas');
GO
