import sys
import datetime
import glob
import os
import smtplib
import socket
from email.message import EmailMessage


def getcsvfile(csvpath
              ,csvname):

    latest_csv = os.path.join(csvpath
                             ,csvname)

    with open(latest_csv, 'r') as file:
        csvlines = file.read()

    return csvlines

if __name__ == "__main__":

    notification    = sys.argv[1]
    pemails         = sys.argv[2]
    emailfrom       = os.environ['NOTIFYFROM']
    smtpfrom        = os.environ['SMTPFROM']

    msg = EmailMessage()

    msg['Subject'] = notification

    if notification.startswith('Completed'):

        badbbls = getcsvfile(os.getcwd()
                            ,'bbl-qa.csv')    

        if len(badbbls) > 4:
            content = "Please review these buildings with no spatial relationship " \
                   + "with their tax lot {0}".format(os.linesep) 
            content += badbbls
        else:
            content = "Total success, nothing to review here, great work all stars!"

    else:
        content = 'Nothing to see here we failed'

    content += "{0} Brought to you by your comrades at {1}".format('\n\n',emailfrom)
    
    msg.set_content(content)
    msg['From'] = emailfrom
    # this is headers only 
    # if a string is passed to sendmail it is treated as a list with one element!
    msg['To'] = pemails

    smtp = smtplib.SMTP(smtpfrom)
    smtp.sendmail(msg['From'], msg['To'].split(","), msg.as_string())
    smtp.quit()
