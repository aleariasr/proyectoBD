## Respuesta obtenida

La ejecución del procedimiento `sp_invoke_external_rest_endpoint` devolvió una respuesta HTTP 200 (OK), confirmando que SQL Server estableció correctamente la comunicación con el servicio REST externo.

```json
{
  "response": {
    "status": {
      "http": {
        "code": 200
      }
    }
  },
  "result": {
    "userId": 1,
    "id": 1,
    "title": "delectus aut autem",
    "completed": false
  }
}
```

La respuesta corresponde al recurso consultado en la API pública **JSONPlaceholder**, utilizada para demostrar el consumo de servicios REST desde SQL Server 2025.
