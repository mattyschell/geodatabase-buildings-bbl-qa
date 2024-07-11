import sys
import os
import logging
import pathlib

# SET PYTHONPATH=C:\gis\geodatabase-toiler\src\py
import gdb
import fc
import cx_sde


def fetchsql(whichsql
            ,database):

    sqlfilepath = pathlib.Path(__file__).parent \
                                        .joinpath('sql_{0}'.format(database)) \
                                        .joinpath(whichsql)
        
    with open(sqlfilepath, 'r') as sqlfile:
        sql = sqlfile.read() 

    return sql 


if __name__ == "__main__":

    targetfcname = sys.argv[1]
    sourcefc     = sys.argv[2]

    targetsdeconn = os.environ['SDEFILE']
    targetgdb = gdb.Gdb()

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    logger.info('importing {0}'.format(targetfcname))

    # We do not overwrite, we do not trust me  
    # Caller must delete as an explicit decision if thats desired 
    targetgdb.importfeatureclass(sourcefc
                                ,targetfcname)

    targetfc = fc.Fc(targetgdb
                    ,targetfcname)  

    logger.info('removing any geometric curves from {0}'.format(targetfcname))

    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('compileremovecurves.sql'
                                                  ,targetgdb.database))

    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         """begin """ \
                                       + """ remove_curves('{0}','{1}'); """.format(targetfcname,'objectid') \
                                       + """end; """)

    # fix any baddies and delete any junk

    # rectify
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('cleangeoms.sql'
                                                  ,targetgdb.database))
    
    # extract polygons only from any collections, post-rectify
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('compilecleanpolygons.sql'
                                                  ,targetgdb.database))
    
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('cleanpolygons.sql'
                                                  ,targetgdb.database))

    # any other bad inputs from dept of finance should be deleted
    # to prevent unpredictable behavior in spatial calls
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('deletebadgeoms.sql'
                                                  ,targetgdb.database))

    logger.info('updating statistics on {0}'.format(targetfcname))

    output = targetfc.analyze(['BUSINESS'])
    
    logger.info('completed import of {0}'.format(targetfcname))