USE SIGAU;
GO

/*=========================================================
  SIGAU
  Consumo de un servicio REST externo
=========================================================*/

EXEC sys.sp_invoke_external_rest_endpoint
    @url = 'https://jsonplaceholder.typicode.com/todos/1',
    @method = 'GET';
GO
