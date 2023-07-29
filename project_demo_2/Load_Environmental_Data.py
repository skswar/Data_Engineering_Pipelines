#!/usr/bin/env python
# coding: utf-8

# ## Loading data from file to database

# #### Import all libraries

# In[1]:


import pyodbc
import traceback
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import smtplib
import pandas as pd
import glob
import datetime
import sqlalchemy as sa
import shutil
import warnings
warnings.filterwarnings('ignore')


# #### Check if file exists and then load all files availale on a set path

# In[12]:


files = glob.glob("C:/Users/sayans/Documents/SharedFolderLocation_Inbound/Environmental_Data/*.csv")
archive_dir = "C:/Users/sayans/Documents/SharedFolderLocation_Inbound/Environmental_Data/Archive/"
main_dataframe_raw = pd.DataFrame()
no_files = 0
if len(files)==0:
    no_files=1
    
if no_files==0:
    for i in range(0,len(files)):
        data = pd.read_csv(files[i], dtype='str')
        main_dataframe_raw = pd.concat([main_dataframe_raw,data],axis=0)


# #### Perform all necessary data transformations

# In[3]:


if no_files==0:
    main_dataframe_stg1 = main_dataframe_raw[['Date UTC', 'Time UTC', 'Date', \
                                              'Time','Temperature','Relative Humidity','Dew Point']].copy()
    main_dataframe_stg1['Time_copy'] = main_dataframe_stg1['Time'].apply(lambda x: x[:-4])
    main_dataframe_stg1.loc[:,'Date_copy'] = pd.to_datetime(main_dataframe_stg1.loc[:,'Date']).dt.date
    main_dataframe_stg1.loc[:,'Time_copy'] = pd.to_datetime(main_dataframe_stg1.loc[:,'Time']).dt.time

    main_dataframe_stg1['Timestamp'] = main_dataframe_stg1.loc[:,['Date_copy','Time_copy']].apply(lambda x: \
                                                     datetime.datetime.combine(x['Date_copy'],x['Time_copy']), axis=1)

    main_dataframe_stg1.drop(['Date_copy','Time_copy'], axis=1,inplace=True)

    del main_dataframe_raw

    #renaming columns as per available in DataBase
    main_dataframe_stg1.rename(columns={'Date UTC':'Date_UTC', 'Time UTC':'Time_UTC','Date':'Date_EST','Time':'Time_EST',\
                                        'Temperature':'Temperature_fahrenheit','Dew Point':'Dewpoint_fahrenheit',\
                                        'Relative Humidity':'ReltiveHumidity_rh'
                                       }, inplace=True)


# #### Connect to the database and insert into stage

# In[4]:


#set up engine
setup = sa.create_engine(f'mssql+pyodbc://@ServerName/Database?driver=ODBC+Driver+17+for+SQL+Server')
error = None

try:
    if no_files==0:
        #setup connection
        cnxn = setup.raw_connection()
        cursor = cnxn.cursor()

        #truncate the stage table
        cursor.execute("TRUNCATE TABLE [dbo].[Environmental_Table_STG]") 
        cnxn.commit()

        #load data into stage table
        main_dataframe_stg1[['Date_UTC', 'Time_UTC', 'Date_EST', 'Time_EST','Timestamp','Temperature_fahrenheit',\
                             'Dewpoint_fahrenheit','ReltiveHumidity_rh']].to_sql('Environmental_Monitoring_Index_STG',\
                                                                            setup,if_exists='append',index=False,schema='dbo') 
        #load data into main table
        cursor.execute("EXEC [dbo].[load_Environmental_Table]")

        #read return data from SP
        row = cursor.fetchone()
        insert_row_count = row[0]
        update_row_count = row[1]
        load_time = row[2]

        cnxn.commit()
        
        #move file to archive
        for i in files:
            fname_split = i.replace('C:/Users/sayans/Documents/SharedFolderLocation_Inbound/Environmental_Data\\','')
            fname_split = fname_split.split('.')
            fname_fxd = fname_split[0]+'_'+pd.Timestamp.now().strftime('%Y_%m_%d_%H_%M')+'.'+fname_split[1]
            destpath = archive_dir+"/"+fname_fxd
            shutil.move(i, destpath)
            
        #close all connections
        cursor.close()
        cnxn.close()
        del cursor
        del cnxn
    
except Exception as e:
    error = e
    cursor.close()
    cnxn.close()
    del cursor
    del cnxn

    
finally:  
    #build email
    # we will built the message using the email library and send using smtplib
    msg = MIMEMultipart()
    msg['Subject'] = "Automated Environmental Data Table Load Notification"  # set email subject
    
    # we will send via outlook, first we initialise connection to mail server
    smtp = smtplib.SMTP('smtp-mail.outlook.com', '587')
    smtp.ehlo()  # say hello to the server
    smtp.starttls()  # we will communicate using TLS encryption
    
    # login to outlook server, using generic email and password
    smtp.login('donotreply@server.com', 'abcd1234')
    
    if (('cursor' in globals()) or ('cnxn' in globals())):
        cursor.close()
        cnxn.close()
        del cursor
        del cnxn
    
    if no_files==1:
        # write an email message
        txt = (f"No Files are available to Proccess and Load into [dbo].[Environmental_Table_PRD] table")
        
        msg.attach(MIMEText(txt))  # add text contents
        
        # send email
        smtp.sendmail('donotreply@server.com', 'sayanswar@server.com', msg.as_string())
    
    elif(error==None):
        # write an email message
        txt = (f"Load of [dbo].[Environmental_Table_PRD] Table is completed.\nTotal {insert_row_count} rows were inserted and {update_row_count} rows were updated at {load_time}")
        
        msg.attach(MIMEText(txt))  # add text contents
        
        # send email
        smtp.sendmail('donotreply@server.com', 'sayanswar@server.com', msg.as_string())
        
    else:
        txt = (f"There was an error while executing the load script. \nThe error is:-> {error}")
        
        msg.attach(MIMEText(txt))  # add text contents
        
        # send email
        smtp.sendmail('donotreply@server.com', 'sayanswar@server.com', msg.as_string())
        
    # finally, disconnect from the mail server
    smtp.quit()
    
print(traceback.format_exc())
#input("Press return to exit")

