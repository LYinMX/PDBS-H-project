@echo off

set "DB_USER=postgres"                 
set "DB_NAME=pgbench_test"            
set "DB_HOST=localhost"                
set "DB_PORT=5432"                     
set "PGPASSWORD=hzoiasd"              
set "CONCURRENT=99"                     
set "DURATION=60"                       
set "THREADS=64"                        
set "SCALES=1 10 100 1000 10000"           
set "PG_BIN=pgbench"                    

for %%s in (%SCALES%) do (
    
    %PG_BIN% -U %DB_USER% -d %DB_NAME% -h %DB_HOST% -p %DB_PORT% -i -s %%s

    for /l %%i in (1,1,5) do (
        %PG_BIN% -U %DB_USER% -d %DB_NAME% -h %DB_HOST% -p %DB_PORT% -c %CONCURRENT% -T %DURATION% -j %THREADS% -r > "./log123/post/run%%s%%i.log"
        
        if %errorlevel% equ 0 (
            echo successful %%s %%i
        )
    )
)
