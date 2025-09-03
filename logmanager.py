import os
import logging
import time

def setup_logger(modulename
                ,logdirectory
                ,loglevel=logging.INFO):

    timestr = time.strftime("%Y%m%d-%H%M%S")

    targetlog = os.path.join(logdirectory
                            ,'{0}-{1}.log'.format(modulename
                                                 ,timestr))

    logging.basicConfig(
         level=loglevel
        ,format='%(asctime)s - %(levelname)s - %(message)s'
        ,handlers=[
             logging.FileHandler(targetlog)   # log messages 
            ,logging.StreamHandler()          # cc: screen 
        ]
    )

    return logging.getLogger(modulename)
