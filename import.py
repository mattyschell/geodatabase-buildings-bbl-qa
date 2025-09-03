import sys
import os
import pathlib
import time
import arcpy

from filegeodatabasemanager import localgdb
from logmanager import setup_logger
# SET PYTHONPATH=X:\xxx\geodatabase-toiler\src\py
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

def importtoworkgdb(targetfcname
                   ,workgdb
                   ,source):

    # workgdb.gdb\TAX_LOT_POLYGON_DTM3857
    infcname  = '{0}{1}'.format(targetfcname,'3857')

    arcpy.conversion.FeatureClassToFeatureClass(source
                                               ,workgdb.gdb
                                               ,infcname)

    sr_2263 = arcpy.SpatialReference(2263)
    # this is [0] in the list of esri supported 3857 to 2263 transformations
    transformation = 'WGS_1984_(ITRF00)_To_NAD_1983'

    outfcname = '{0}{1}'.format(targetfcname,'2263')
    infc      = '{0}\{1}'.format(workgdb.gdb,infcname)
    outfc     = '{0}\{1}'.format(workgdb.gdb,outfcname)
    
    arcpy.Project_management(in_dataset=infc
                            ,out_dataset=outfc
                            ,out_coor_system=sr_2263
                            ,transform_method=transformation)

    #workgdb.gdb\TAX_LOT_POLYGON_DTM2263
    return outfc


if __name__ == "__main__":

    targetfcname = sys.argv[1]
    sourcefc     = sys.argv[2]
    workgdb      = sys.argv[3]

    # enterprise geodatabase from toiler
    # mixing eras of code is a little convoluted 
    targetsdeconn = os.environ['SDEFILE']
    targetgdb = gdb.Gdb()

    # logs\buildings-bbl-qa\import-20250403-160745.log
    logger = setup_logger('import'
                         ,os.environ['TARGETLOGDIR'])

    localworkgdb = localgdb(workgdb)

    logger.info('deleting and re-creating {0}'.format(localworkgdb.gdb))

    localworkgdb.clean()
    localworkgdb.create()

    logger.info('importing {0} to {1}'.format(sourcefc
                                             ,localworkgdb.gdb))

    localfc2263 = importtoworkgdb(targetfcname
                                 ,localworkgdb
                                 ,sourcefc)

    # in the database
    # bldg.tax_lot_polygon_dtm : use esri tools to drop and reload
    #                            source is the file geodatabase
    # bldg.tax_lot_polygon: use sql (later steps) to drop, recreate and load
    #                       source is bldg.tax_lot_polygon_dtm

    # We do not overwrite, we do not trust me  
    # The caller must delete before we get here 
    # imports new tax_lot_polygon_dtm

    logger.info('loading {0} to {1}'.format(localfc2263
                                           ,targetgdb.sdeconn))

    targetgdb.importfeatureclass(localfc2263
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
    logger.info('rectifying any invalid geometries in {0}'.format(targetfcname))
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('cleangeoms.sql'
                                                  ,targetgdb.database))
    
    # extract polygons only from any collections, post-rectify
    logger.info('tossing any non polygon artifacts from {0}'.format(targetfcname))
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('compilecleanpolygons.sql'
                                                  ,targetgdb.database))
    
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('cleanpolygons.sql'
                                                  ,targetgdb.database))

    # any other bad inputs from dept of finance should be deleted
    # to prevent unpredictable behavior in spatial calls
    logger.info('deleting any unrectifiable trash from from {0}'.format(targetfcname))
    sdereturn = cx_sde.execute_immediate(targetsdeconn,
                                         fetchsql('deletebadgeoms.sql'
                                                  ,targetgdb.database))

    logger.info('updating statistics on {0}'.format(targetfcname))

    output = targetfc.analyze(['BUSINESS'])
    
    logger.info('completed import of {0}'.format(targetfcname))