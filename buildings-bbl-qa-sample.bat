REM set for environment
set DBNAME=xxx
set DBPASS=xxxx
set SDEFILE=X:\xxx\Connections\oracle19c\xxx\xxxx\bldg.sde
set SOURCEFC=https://services6.arcgis.com/yG5s3afENB5iO9fj/ArcGIS/rest/services/Tax_Lot_View/FeatureServer/0
REM unmask these
set BASEPATH=X:\xxx\
set NOTIFY=xxxx@xxx.nyc.gov
set NOTIFYFROM=xxxx@xxx.nyc.gov
set SMTPFROM=xxxxxx.nycnet
set HTTP_PROXY=http://xxxx\xxxx:xxxx@xxxx.xxxx:xxxx
REM review the rest
set HTTPS_PROXY=%HTTP_PROXY%
set TARGETLOGDIR=%BASEPATH%geodatabase-scripts\logs\buildings_bbl_qa\
set BBLQA=%BASEPATH%geodatabase-buildings-bbl-qa\
set BATLOG=%TARGETLOGDIR%buildings-bbl-qa.log
set PROPY=c:\Progra~1\ArcGIS\Pro\bin\Python\envs\arcgispro-py3\python.exe
set TAXPOLYS=TAX_LOT_POLYGON
set PYTHONPATH=%BASEPATH%\geodatabase-toiler\src\py
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
echo. >> %BATLOG% echo starting qa of building bbls in %DBNAME% on %date% at %time% >> %BATLOG%
sqlplus -s -l BLDG/%DBPASS%@%DBNAME% @run.sql && (
  %PROPY% %BBLQA%notify.py "Completed buildings-bbl-qa in %DBNAME%" %NOTIFY% 
) || (
  %PROPY% %BBLQA%notify.py "Failed to execute buildings-bbl-qa in %DBNAME%" %NOTIFY% && EXIT /B 1
) 
echo. >> %BATLOG% echo geodatabase-buildings-bbl-qa sent output to %NOTIFY% >> %BATLOG% 