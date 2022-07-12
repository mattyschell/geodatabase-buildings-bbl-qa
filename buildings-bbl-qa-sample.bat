REM set for environment
set DBNAME=XXXXXX
set DBPASS=XXXXXXXX
REM unmask these
set NOTIFY=xxxx@xxx.xxx.xxx
set NOTIFYFROM=xxxx@xxx.xxx.xx
set SMTPFROM=xxxxxxxxxxx.xxxxxx
set HTTP_PROXY=xxxxxxxxxxxxxxxxxxxxxxxx
set HTTPS_PROXY=xxxxxxxxxxxxxxxxxxxxxxx
REM review the rest
set TARGETLOGDIR=C:\xxx\geodatabase-scripts\logs\
set BATLOG=%TARGETLOGDIR%buildings-bbl-qa.log
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
echo starting qa of building bbls in %DBNAME% on %date% at %time% > %BATLOG%
sqlplus -s -l BLDG/%DBPASS%@%DBNAME% @run.sql && (
  %PROPY% %ETL%notify.py "Completed buildings-bbl-qa in %DBNAME%" %NOTIFY% 
) || (
  %PROPY% %ETL%notify.py "Failed to execute buildings-bbl-qa in %DBNAME%" %NOTIFY% && EXIT /B 1
) 
echo. >> geodatabase-buildings-bbl-qa sent output to %NOTIFY% >> %BATLOG% 