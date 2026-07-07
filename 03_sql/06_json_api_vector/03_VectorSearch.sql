USE SIGAU;
GO

/* =========================================================
   VECTOR DATA AND SEMANTIC SEARCH
   Proyecto IF-5100 - SIGAU

   Utiliza VECTOR(5) y VECTOR_DISTANCE con distancia coseno
   para ordenar los cursos según cercanía al vector consultado.
   ========================================================= */

DECLARE @VectorConsulta VECTOR(5) =
    CAST('[0.11,0.21,0.31,0.41,0.51]' AS VECTOR(5));

SELECT
    CursoID,
    CodigoCurso,
    NombreCurso,
    Embedding,
    VECTOR_DISTANCE
    (
        'cosine',
        Embedding,
        @VectorConsulta
    ) AS DistanciaCoseno
FROM academico.Curso
WHERE Embedding IS NOT NULL
ORDER BY DistanciaCoseno ASC;
GO

/* Verificación de población vectorial */
SELECT
    COUNT(*) AS TotalCursos,
    COUNT(Embedding) AS CursosConEmbedding,
    COUNT(*) - COUNT(Embedding) AS CursosSinEmbedding
FROM academico.Curso;
GO

/* Verificación de dimensión y contenido */
SELECT
    CursoID,
    CodigoCurso,
    NombreCurso,
    Embedding
FROM academico.Curso
ORDER BY CursoID;
GO