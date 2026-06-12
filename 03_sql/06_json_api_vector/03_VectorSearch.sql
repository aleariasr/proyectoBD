USE SIGAU;
GO

/*=========================================================
  SIGAU
  Búsqueda semántica utilizando VECTOR
=========================================================*/

SELECT TOP (5)
    CursoID,
    NombreCurso,
    VECTOR_DISTANCE(
        'cosine',
        Embedding,
        CAST('[0.10,0.20,0.30,0.40,0.50]' AS VECTOR(5))
    ) AS Distancia
FROM academico.Curso
ORDER BY Distancia;
GO
