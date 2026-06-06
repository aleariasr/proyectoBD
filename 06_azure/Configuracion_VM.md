# Configuración de la Máquina Virtual

## Plataforma

La infraestructura del proyecto SIGAU fue implementada sobre una máquina virtual en Microsoft Azure, utilizando Windows Server 2025 como sistema operativo base.

## Servidor

Nombre del servidor:

myVm

## Usuario operativo

Durante la administración de la máquina virtual se utilizó el usuario:

myVm\adminbackup

Este usuario fue creado para evitar el uso continuo del usuario administrativo original y reducir la dependencia operativa sobre una única cuenta.

## Usuarios locales identificados

Durante la validación del sistema se identificaron los siguientes usuarios locales relevantes:

- adminbackup: usuario operativo principal.
- sigauadmin: usuario administrativo original, actualmente deshabilitado.
- sqlsvc: usuario de servicio asociado a SQL Server.
- sqlagent: usuario de servicio asociado a SQL Server Agent.
- ProjectDB_Guest: usuario invitado deshabilitado.
- DefaultAccount: cuenta integrada deshabilitada.
- WDAGUtilityAccount: cuenta integrada deshabilitada.

## Grupos locales

### Administrators

Miembros identificados:

- adminbackup
- sigauadmin

### Remote Desktop Users

Miembros identificados:

- adminbackup

## Justificación

El uso del usuario adminbackup permite administrar la máquina virtual mediante RDP sin depender del usuario inicial de aprovisionamiento. Además, el usuario sigauadmin se mantiene deshabilitado como medida de reducción de superficie de acceso.

No se documentan contraseñas ni credenciales dentro del repositorio.

## Gestión de cuentas administrativas

Durante la implementación se creó una cuenta administrativa secundaria denominada adminbackup.

La cuenta original sigauadmin fue deshabilitada posteriormente y se mantuvo únicamente para contingencia.

La administración diaria del servidor se realiza mediante la cuenta adminbackup, reduciendo la exposición de la cuenta inicial utilizada durante el aprovisionamiento de la máquina virtual.