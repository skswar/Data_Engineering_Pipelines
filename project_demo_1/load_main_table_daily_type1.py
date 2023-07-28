#!/usr/bin/env python
# coding: utf-8

# In[32]:


# imports for SQL data part
import pyodbc
import traceback
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib
    
#set up connection
cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};''SERVER=XYZ;\
                    ''DATABASE=database_name;''Trusted_Connection=yes;')


# build up our query string and execute
query = ("EXEC [dbo].[load_tablename_main_daily]")
error = None

try:
    cursor = cnxn.cursor()
    cursor.execute(query)
    
    #read return data from SP
    row = cursor.fetchone()
    row_count = row[0]
    load_time = row[1]
    
    #commit transaction
    cnxn.commit()
    
    #close connection
    cursor.close()
    cnxn.close()
    del cursor
    del cnxn
    
except Exception as e:
    error = e
    
    cursor.close()
    cnxn.close()
    
finally:  
    #build email
    # we will built the message using the email library and send using smtplib
    msg = MIMEMultipart()
    msg['Subject'] = "Automated Main Table Load Daily Load Notification"  # set email subject
    
    # we will send via outlook, first we initialise connection to mail server
    smtp = smtplib.SMTP('smtp-mail.outlook.com', '587')
    smtp.ehlo()  # say hello to the server
    smtp.starttls()  # we will communicate using TLS encryption
    
    # login to outlook server, using generic email and password
    smtp.login('donotreply@server.com', 'abcdefg')
    
    if(error==None):
        # write an email message
        txt = (f"Daily Load of Main Table Table is completed.\nTotal {row_count} rows were loaded in the [dbo].[destination_tablename_main] table at {load_time}")
        
        msg.attach(MIMEText(txt))  # add text contents
        
        # send email to our boss
        smtp.sendmail('donotreply@server.com', 'sayan@server.com', msg.as_string())
        
    else:
        txt = (f"There was an error while executing the load script. \nThe error is:-> {error}")
        
        msg.attach(MIMEText(txt))  # add text contents
        
        # send email to our boss
        smtp.sendmail('donotreply@server.com', 'sayan@server.com', msg.as_string())
        
    # finally, disconnect from the mail server
    smtp.quit()
    
print(traceback.format_exc())
#input("Press return to exit")

