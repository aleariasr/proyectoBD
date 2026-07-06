# Transparent Data Encryption (TDE)

## Descripción

Transparent Data Encryption (TDE) protege los archivos físicos de la base de datos mediante cifrado automático, evitando el acceso no autorizado a la información almacenada en disco.

## Implementación en SIGAU

La base de datos SIGAU utiliza Transparent Data Encryption con el algoritmo AES-256 proporcionado por Microsoft SQL Server.

## Algoritmo utilizado

- AES-256
- Encryptor: Certificate

## Evidencias

### Estado del cifrado

![Estado TDE](../../04_evidencias/Seguridad/03_TDE_AES256.png)

La evidencia demuestra que la base de datos SIGAU se encuentra cifrada utilizando Transparent Data Encryption.

### Certificado utilizado

![Certificado TDE](../../04_evidencias/Seguridad/04_TDE_Certificado.png)

El certificado almacenado en la base de datos master protege la Database Encryption Key utilizada por TDE.

### Respaldo del certificado
PENDIENTE!!!!

![Backup Certificado](../../04_evidencias/Seguridad/05_Backup_Certificado.jpeg)

Se muestra el respaldo del certificado utilizado para la recuperación de la base de datos cifrada.
