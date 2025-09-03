import sys
import os
from logmanager import setup_logger

# SET PYTHONPATH=C:\gis\geodatabase-toiler\src\py
import gdb
import fc


if __name__ == "__main__":

    targetfcname = sys.argv[1]

    targetsdeconn = os.environ['SDEFILE']
    targetgdb = gdb.Gdb()

    # delete-20250903-102841.log
    logger = setup_logger('delete'
                         ,os.environ['TARGETLOGDIR'])

    logger.info('starting delete {0}'.format(targetfcname))

    targetfc = fc.Fc(targetgdb
                    ,targetfcname)  

    if targetfc.exists():        
        logger.info('calling fc delete method on {0}'.format(targetfcname))
        targetfc.delete()
    else:
        logger.info('skipping delete. {0} doesnt exist'.format(targetfcname))

    logger.info('completed delete {0}'.format(targetfcname))