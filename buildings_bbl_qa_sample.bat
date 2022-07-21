REM set for environment
set DBNAME=XXXX
set DBPASS=XXXX
set SDEFILE=XXXX
set SOURCEFC=XXXX
REM unmask these
set NOTIFY=XXXX
set NOTIFYFROM=XXXX
set SMTPFROM=XXXX
set HTTP_PROXY=XXXX
set HTTPS_PROXY=XXXX
set PYTHONPATH=XXXX
REM review the rest
set TARGETLOGDIR=C:\gis\geodatabase-scripts\logs\
set BBLQA=C:\gis\geodatabase-buildings-bbl-qa\
set BATLOG=%TARGETLOGDIR%buildings-bbl-qa.log
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set TAXPOLYS=TAX_LOT_POLYGON
set GEODATABASESCRIPTS=%CD%
echo starting import of tax lots to %DBNAME% on %date% at %time% > %BATLOG%
%PROPY% %BBLQA%delete.py %TAXPOLYS% && (
  echo. deleted target %TAXPOLYS% on %date% at %time% >> %BATLOG%
) || (
  %PROPY% %BBLQA%notify.py "Failed to delete %TAXPOLYS% on %SDEFILE%" %NOTIFY% && EXIT /B 1
)  
%PROPY% %BBLQA%import.py %TAXPOLYS% %SOURCEFC% && (
  echo. >> %BATLOG% echo imported target %TAXPOLYS% on %date% at %time% >> %BATLOG%
) || (
  %PROPY% %BUILDINGS%notify.py "Failed to import %TAXPOLYS% on %SDEFILE%" %NOTIFY% && EXIT /B 1
) 
echo. >> starting qa of building bbls in %DBNAME% on %date% at %time% >> %BATLOG%
cd %BBLQA%
sqlplus -s -l BLDG/%DBPASS%@%DBNAME% @run.sql && (
  %PROPY% %BBLQA%notify.py "Completed buildings-bbl-qa in %DBNAME%" %NOTIFY% 
) || (
  %PROPY% %BBLQA%notify.py "Failed to execute buildings-bbl-qa in %DBNAME%" %NOTIFY% && EXIT /B 1
) 
cd %GEODATABASESCRIPTS%
echo. >> geodatabase-buildings-bbl-qa sent output to %NOTIFY% >> %BATLOG% 