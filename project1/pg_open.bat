@echo off

set "DB_USER=gaussdb"
set "DB_NAME=pgbench_open" 
set "DB_HOST=localhost"
set "DB_PORT=8888"
set "PGPASSWORD=@123HZOIhzoi"
set "CONCURRENT=99"
set "DURATION=60"
set "THREADS=64"
set "SCALES=1 10 100 1000 10000"
set "PG_BIN=pgbench"

for %%s in (%SCALES%) do (
    
    %PG_BIN% -U %DB_USER% -d %DB_NAME% -h %DB_HOST% -p %DB_PORT% -i -s %%s

    for /l %%i in (1,1,5) do (
        %PG_BIN% -U %DB_USER% -d %DB_NAME% -h %DB_HOST% -p %DB_PORT% -c %CONCURRENT% -T %DURATION% -j %THREADS% -r > "./log123/open/run%%s%%i.log"
        
        if %errorlevel% equ 0 (
            echo successful %%s %%i
        )
    )
)
