USE master;
GO

BACKUP DATABASE SIGAU
TO DISK = N'H:\SQLServer\Backups\SIGAU\SIGAU_FULL_20260606.bak'
WITH
    FORMAT,
    INIT,
    NAME = N'SIGAU Full Backup 2026-06-06',
    DESCRIPTION = N'Backup completo de SIGAU posterior a creacion, seguridad y poblacion inicial',
    CHECKSUM,
    COMPRESSION,
    STATS = 10;
GO

RESTORE VERIFYONLY
FROM DISK = N'H:\SQLServer\Backups\SIGAU\SIGAU_FULL_20260606.bak'
WITH CHECKSUM;
GO

SELECT
    database_name,
    backup_start_date,
    backup_finish_date,
    type,
    backup_size / 1024 / 1024 AS BackupSizeMB,
    compressed_backup_size / 1024 / 1024 AS CompressedBackupSizeMB,
    physical_device_name
FROM msdb.dbo.backupset bs
INNER JOIN msdb.dbo.backupmediafamily bmf
    ON bs.media_set_id = bmf.media_set_id
WHERE database_name = 'SIGAU'
ORDER BY backup_finish_date DESC;
GO
