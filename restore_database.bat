@echo off
set HOST=localhost
set PORT=6432
set USERNAME=postgres
set PGPASSWORD=mnzryv

set BACKUP_FILE=e:\test\bgd_nesco_full.backup

:: Database to restore into
set DATABASE=bgd_nesco

:: Path to pg_restore executable
set pg_restore_path="C:\Program Files\PostgreSQL\16\bin\pg_restore.exe"

:: Drop the database if it exists
echo Dropping existing database %DATABASE%...
psql --host %HOST% --port %PORT% --username %USERNAME% -c "DROP DATABASE IF EXISTS %DATABASE%"

psql --host %HOST% --port %PORT% --username %USERNAME% -c "CREATE DATABASE %DATABASE%"

:: Restore the backup with verbose output
echo Restoring from backup file %BACKUP_FILE%...
%pg_restore_path% --host %HOST% --port %PORT% --username %USERNAME% --dbname %DATABASE% --verbose %BACKUP_FILE%

echo Restore completed.