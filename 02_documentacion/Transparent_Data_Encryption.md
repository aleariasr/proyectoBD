# Transparent Data Encryption (TDE)

## Descripción

Transparent Data Encryption (TDE) protege los archivos físicos de la base de datos mediante cifrado automático, evitando el acceso no autorizado a la información almacenada en disco. Esta característica cifra los archivos de datos y de transacciones sin requerir modificaciones en las aplicaciones que utilizan la base de datos.

## Implementación en SIGAU

La base de datos **SIGAU** utiliza Transparent Data Encryption (TDE) para proteger la información almacenada, garantizando que los archivos de la base permanezcan cifrados incluso si son copiados o extraídos del servidor.

## Algoritmo utilizado

- **Algoritmo:** AES-256
- **Protección de la Database Encryption Key:** Certificado almacenado en la base de datos `master`.

## Evidencias

### Estado del cifrado

![Estado TDE](../04_evidencias/Seguridad/03_TDE_AES256.png)

La evidencia demuestra que la base de datos **SIGAU** se encuentra cifrada mediante Transparent Data Encryption y que el estado de cifrado es correcto.

### Certificado utilizado

![Certificado TDE](../04_evidencias/Seguridad/04_TDE_Certificado.png)

El certificado **TDECert** almacenado en la base de datos `master` protege la **Database Encryption Key (DEK)** utilizada por Transparent Data Encryption.

### Respaldo del certificado

> El respaldo del certificado constituye una buena práctica para facilitar la recuperación de bases de datos cifradas en caso de migración o desastre. Su documentación se encuentra en proceso de incorporación.

<!-- Cuando tengas la evidencia, descomenta la siguiente línea -->

<!--
![Backup Certificado](../04_evidencias/Seguridad/05_Backup_Certificado.png)
-->

## Resultado

La implementación de Transparent Data Encryption permite que los archivos físicos de la base de datos permanezcan protegidos mediante cifrado AES-256, incrementando la seguridad de la información almacenada y cumpliendo con las buenas prácticas de administración de bases de datos.
