# External API Calls

## Objetivo

Implementar el consumo de servicios REST externos desde SQL Server 2025 mediante `sys.sp_invoke_external_rest_endpoint`.

## Implementación

SIGAU utiliza los siguientes objetos:

- `api.ConsultaExterna`
- `api.usp_ConsultarEndpointUniversidad`

El procedimiento consulta el endpoint público `https://jsonplaceholder.typicode.com/todos/1`.

La respuesta se recibe en formato JSON, se obtiene el código HTTP real y se almacena el resultado en la tabla `api.ConsultaExterna`.

## Código HTTP

El código HTTP se extrae desde la respuesta mediante:

    JSON_VALUE(
        @response,
        '$.response.status.http.code'
    )

No se almacena un valor `200` fijo.

Si el código no puede convertirse a entero, se registra el valor `0` mediante `COALESCE`.

## Persistencia de resultados

| Campo | Descripción |
|---|---|
| `FechaConsulta` | Fecha y hora en que se ejecutó la consulta |
| `Endpoint` | Dirección del servicio consultado |
| `CodigoRespuesta` | Código HTTP obtenido de la respuesta |
| `RespuestaJSON` | Respuesta completa devuelta por el servicio |

## Verificación realizada

La funcionalidad fue probada directamente en la VM de SQL Server.

Durante la prueba se verificó:

- ejecución correcta de `sys.sp_invoke_external_rest_endpoint`;
- respuesta HTTP `200`;
- almacenamiento de la respuesta JSON;
- incremento de registros en `api.ConsultaExterna` de 13 a 14;
- conservación del endpoint y del código de respuesta.

## Script relacionado

- [02_REST_API.sql](../03_sql/06_json_api_vector/02_REST_API.sql)

## Evidencia técnica

- [SIGAU_Esquema_Real_VM.sql](../04_evidencias/SQLServer/SIGAU_Esquema_Real_VM.sql)

## Evidencia visual pendiente

Las capturas específicas de esta funcionalidad deben almacenarse en:

`04_evidencias/API`

## Estado

Implementado y verificado funcionalmente en la VM.

La evidencia visual específica todavía está pendiente.