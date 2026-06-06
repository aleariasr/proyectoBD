# SIGAU

Sistema Integral de Gestión Académica Universitaria

Proyecto IF-5100 Administración de Bases de Datos
Universidad de Costa Rica

## Integrantes

- Alejandro Arias Rojas
- Mariangel Arias Alfaro
- Sebastian Alfaro Arias

## Tecnologías

- Windows Server 2025
- SQL Server 2025 Enterprise Evaluation
- SQL Server Management Studio 21

## Características implementadas

- Separación física de discos
- Filegroups
- Recovery Model FULL
- In-Memory OLTP
- Dynamic Data Masking
- Row Level Security
- Auditoría SQL Server
- Procedimientos almacenados
- JSON
- API REST Externa
- Vector Search

## Distribución de almacenamiento

| Disco | Propósito |
|---------|---------|
| C: | Sistema Operativo |
| D: | Azure Temporary Storage |
| E: | Datos |
| F: | Logs |
| G: | TempDB |
| H: | Backups y Auditoría |