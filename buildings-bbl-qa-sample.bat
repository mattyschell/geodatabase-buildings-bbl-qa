set DBENV=xxx
set DBNAME=xxx
set DBPASS=xxx
set BASEPATH=X:\gis\
set SDEFILE=%BASEPATH%Connections\oracle19c\%DBENV%\GIS-%DBNAME%\bldg.sde
set SOURCEFC=https://services6.arcgis.com/yG5s3afENB5iO9fj/ArcGIS/rest/services/Tax_Lot_View/FeatureServer/0
set NOTIFY=xxx@xxx.xxx.xxx
set NOTIFYFROM=xxx@xxx.xxx.xxx
set SMTPFROM=xxx.xxx
set HTTP_PROXY=http://xxx\xxx:xxxx@xxx.xxx:xxx
set HTTPS_PROXY=%HTTP_PROXY%
set PYTHONPATH=%BASEPATH%\geodatabase-toiler\src\py
set TARGETLOGDIR=%BASEPATH%geodatabase-scripts\logs\buildings_bbl_qa\
set BBLQA=%BASEPATH%geodatabase-buildings-bbl-qa\
set BATLOG=%TARGETLOGDIR%buildings-bbl-qa.log
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set TAXPOLYS=TAX_LOT_POLYGON
set GEODATABASESCRIPTS=%CD%
echo starting import of tax lots to %DBNAME% on %date% at %time% >> %BATLOG%
%PROPY% %BBLQA%delete.py %TAXPOLYS% && (
  echo. >> %BATLOG% echo deleted target %TAXPOLYS% on %date% at %time% >> %BATLOG%
) || (
  %PROPY% %BBLQA%notify.py "Failed to delete %TAXPOLYS% on %SDEFILE%" %NOTIFY% && EXIT /B 1
)  
%PROPY% %BBLQA%import.py %TAXPOLYS% %SOURCEFC% && (
  echo. >> %BATLOG% echo imported target %TAXPOLYS% on %date% at %time% >> %BATLOG%
) || (
  %PROPY% %BBLQA%notify.py "Failed to import %TAXPOLYS% on %SDEFILE%" %NOTIFY% && EXIT /B 1
) 
set HTTP_PROXY=
set HTTPS_PROXY=
cd %BBLQA%
echo. >> %BATLOG% echo starting qa of building bbls in %DBNAME% on %date% at %time% >> %BATLOG%
sqlplus -s -l BLDG/%DBPASS%@%DBNAME% @run.sql && (
  %PROPY% %BBLQA%notify.py "Completed buildings-bbl-qa in %DBNAME%" %NOTIFY% 
) || (
  %PROPY% %BBLQA%notify.py "Failed to execute buildings-bbl-qa in %DBNAME%" %NOTIFY% && EXIT /B 1
) 
cd %GEODATABASESCRIPTS%
echo. >> %BATLOG% echo geodatabase-buildings-bbl-qa sent output to %NOTIFY% >> %BATLOG% 