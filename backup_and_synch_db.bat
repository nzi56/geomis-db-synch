@echo off
setlocal enableextensions disabledelayedexpansion

SET PGUSER=webgis
SET PGPASSWORD=webgis@123!XYZ
SET PGHOST=localhost
SET API_HOST=http://172.17.41.73:8084
SET PGPORT=6432
set dbname=bgd_nesco
SET EXPORT_DIR=D:/backup-by-scheduler
set dmp_path=D:\PostgreSQL\16\bin\pg_dump.exe
set psqlPath=D:\PostgreSQL\16\bin\psql

echo calling  Fetch Tracking
:: Fetch data using curl 
curl %API_HOST%/gdb/api/gdb/fetch-tracking -o "fetch_tracking_output.txt"


REM Get the current day of the week
for /f "tokens=1 delims= " %%d in ('powershell -Command "Get-Date -format dddd"') do set DAY=%%d

REM Check if today is Friday
if "%DAY%"=="Friday" (
echo calling  full synch
"%psqlPath%" -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -c "CALL webgis.full_synch();"

) else (
   echo calling partial synch...
"%psqlPath%" -U %PGUSER% -h %PGHOST% -p %PGPORT% -d %dbname% -c "CALL webgis.partial_synch();"

)

echo Taking full backup
%dmp_path% -h %PGHOST% -U %PGUSER% -p %PGPORT% -F c -b -v -f %EXPORT_DIR%\bgd_nesco_full.backup bgd_nesco

echo Taking partial backup ( oms schema backup)
%dmp_path% -h %PGHOST% -U %PGUSER% -p %PGPORT% -F c -b -v -f %EXPORT_DIR%\bgd_nesco_oms.backup -n oms bgd_nesco


echo Uploading full backup to google drive

curl --location "%API_HOST%/gdb/api/gdb/upload" ^
--header "Content-Type: application/json" ^
--header "Cookie: JSESSIONID=A3D3DFB816C711BE477C773F59F1EB01" ^
--data "{""file"":""%EXPORT_DIR%/bgd_nesco_full.backup""}"

echo Uploading schema backup to google drive

curl --location "%API_HOST%/gdb/api/gdb/upload" ^
--header "Content-Type: application/json" ^
--header "Cookie: JSESSIONID=A3D3DFB816C711BE477C773F59F1EB01" ^
--data "{""file"":""%EXPORT_DIR%/bgd_nesco_oms.backup""}"

rem echo Removing old files from google drive
curl --location --request POST "%API_HOST%/gdb/api/gdb/removeoldfiles/10" --header "Cookie: JSESSIONID=A3D3DFB816C711BE477C773F59F1EB01"

REM Clear the password from environment
SET PGPASSWORD=


echo end of script 

endlocal
