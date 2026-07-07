# Vector Data and Semantic Search

## Objetivo

Implementar almacenamiento vectorial y búsquedas por similitud en SQL Server 2025 mediante el tipo de dato `VECTOR` y la función `VECTOR_DISTANCE`.

## Implementación

La tabla `academico.Curso` incluye la columna:

    Embedding VECTOR(5) NULL

Esta columna almacena vectores de cinco dimensiones asociados a cada curso.

El script permite comparar esos vectores contra un vector de consulta y ordenar los resultados según su distancia.

## Consulta vectorial

La búsqueda utiliza distancia coseno:

    VECTOR_DISTANCE(
        'cosine',
        Embedding,
        @VectorConsulta
    )

Los resultados se ordenan de menor a mayor distancia.

Una distancia menor representa mayor cercanía matemática entre el vector almacenado y el vector consultado.

## Campos mostrados

La consulta devuelve:

- `CursoID`
- `CodigoCurso`
- `NombreCurso`
- `Embedding`
- `DistanciaCoseno`

## Verificación realizada

La funcionalidad fue probada directamente en la VM de SQL Server 2025.

Durante la prueba se verificó:

- existencia de 10 cursos;
- 10 cursos con valor en `Embedding`;
- 0 cursos sin vector;
- ejecución correcta de `VECTOR_DISTANCE`;
- ordenamiento de resultados por distancia coseno.

Entre los primeros resultados obtenidos estuvieron:

| Código | Curso |
|---|---|
| `IF4100` | Sistemas Operativos |
| `IF5100` | Administración de Bases de Datos |
| `IF3100` | Sistemas de Información |

## Alcance de la búsqueda semántica

La funcionalidad de almacenamiento y comparación vectorial está implementada.

Los vectores utilizados corresponden a datos de prueba asignados manualmente.

Por esa razón, el resultado demuestra similitud matemática entre vectores, pero no debe interpretarse como un sistema avanzado de embeddings generados mediante inteligencia artificial o procesamiento de lenguaje natural.

## Script relacionado

- [03_VectorSearch.sql](../03_sql/06_json_api_vector/03_VectorSearch.sql)

## Evidencia técnica

- [SIGAU_Esquema_Real_VM.sql](../04_evidencias/SQLServer/SIGAU_Esquema_Real_VM.sql)

## Evidencia visual pendiente

Las capturas específicas de esta funcionalidad deben almacenarse en:

`04_evidencias/VectorSearch`

## Estado

Implementado y verificado funcionalmente en SQL Server 2025.

La evidencia visual específica todavía está pendiente.