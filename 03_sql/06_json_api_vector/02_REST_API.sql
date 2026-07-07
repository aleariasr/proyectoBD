USE master;
GO

EXEC sys.sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sys.sp_configure 'external rest endpoint enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

USE SIGAU;
GO

/* =========================================================
   CONSUMO DE SERVICIO REST EXTERNO
   Proyecto IF-5100 - SIGAU

   Consume un endpoint público, obtiene el código HTTP real
   y almacena la respuesta completa en api.ConsultaExterna.
   ========================================================= */

CREATE OR ALTER PROCEDURE api.usp_ConsultarEndpointUniversidad
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @endpoint NVARCHAR(500) =
        N'https://jsonplaceholder.typicode.com/todos/1';

    DECLARE @response NVARCHAR(MAX);
    DECLARE @codigoRespuesta INT;

    EXEC sys.sp_invoke_external_rest_endpoint
        @url = @endpoint,
        @method = N'GET',
        @response = @response OUTPUT;

    SET @codigoRespuesta =
        TRY_CONVERT
        (
            INT,
            JSON_VALUE
            (
                @response,
                '$.response.status.http.code'
            )
        );

    INSERT INTO api.ConsultaExterna
    (
        Endpoint,
        CodigoRespuesta,
        RespuestaJSON
    )
    VALUES
    (
        @endpoint,
        COALESCE(@codigoRespuesta, 0),
        @response
    );

    SELECT
        @codigoRespuesta AS CodigoRespuesta,
        JSON_VALUE(@response, '$.result.userId') AS UsuarioExternoID,
        JSON_VALUE(@response, '$.result.id') AS RecursoExternoID,
        JSON_VALUE(@response, '$.result.title') AS Titulo,
        JSON_VALUE(@response, '$.result.completed') AS Completado,
        @response AS RespuestaJSON;
END;
GO

/* Prueba funcional */
DECLARE @RegistrosAntes INT =
(
    SELECT COUNT(*)
    FROM api.ConsultaExterna
);

EXEC api.usp_ConsultarEndpointUniversidad;

SELECT
    @RegistrosAntes AS RegistrosAntes,
    COUNT(*) AS RegistrosDespues
FROM api.ConsultaExterna;

SELECT TOP (1)
    ConsultaExternaID,
    FechaConsulta,
    Endpoint,
    CodigoRespuesta,
    RespuestaJSON
FROM api.ConsultaExterna
ORDER BY ConsultaExternaID DESC;
GO