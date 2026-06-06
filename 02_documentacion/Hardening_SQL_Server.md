# Hardening SQL Server

## Objetivo

Documentar las configuraciones de hardening aplicadas al motor SQL Server según el benchmark CIS Microsoft SQL Server 2022.

## Benchmark utilizado

- [CIS Microsoft SQL Server 2022 Benchmark v1.2.1](../01_enunciado/CIS_SQL_Server_2022_Benchmark_v1_2_1.pdf)

## Configuraciones aplicadas

| Configuración | Valor |
|---|---|
| Ad Hoc Distributed Queries | 0 |
| CLR Enabled | 0 |
| CLR Strict Security | 1 |
| Cross DB Ownership Chaining | 0 |
| Database Mail XPs | 0 |
| Ole Automation Procedures | 0 |
| Remote Access | 0 |
| Remote Admin Connections | 0 |
| Scan for Startup Procs | 0 |

## Excepción controlada

La opción `external rest endpoint enabled` fue habilitada porque el proyecto requiere consumo de API REST desde SQL Server 2025.

## Evidencias

Pendiente de agregar capturas:

- `04_evidencias/SQLServer_CIS/01_Surface_Area_Reduction.jpeg`
- `04_evidencias/SQLServer_CIS/02_Configuraciones_CIS.jpeg`

## Estado

Implementado parcialmente, falta evidencia visual específica.
