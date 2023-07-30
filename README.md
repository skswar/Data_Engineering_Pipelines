<div align="center">
<img src="https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/banner.png" alt="Intro Logo" width="90%" height="20%"/></div>
<p align="right">
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" width="5%"/></a><br/><ruby><rt>This and all the following images are licensed by Sayan Swar under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.</rt></ruby>
</p>
</div>

<h3 align="center">How to build Efficient Data Enginnering Pipelines at No Additional Software Overhead Cost?</h4>

<hr>

## Table of contents
* [Introduction](#introduction)
* [Methodology](#methodology)
  * [Tools Used](#tools-used)
  * [Building the Pipelines](#building-the-pipelines)
    * [Project Demo 1](#project-demo-1)
    * [Project Demo 2](#project-demo-2) 
* [Results and Conclusion](#results-and-conclusion)

## Introduction
As the global business landscape is increasingly transitioning towards data-driven decision-making and artificial intelligence, the importance of gathering and structuring data in an organized manner is crucial for all organizations. With all the technologies available at our disposal building, data pipleines and data storage has become very easy and fast. But it is not always economically viable, especially for growing business and startups. Often, immediate investment in high-end software or cloud solutions might not be feasible. Or say, in some cases the workload might not warrant the need for large-scale software solutions and can be effectively handled with in house, open source tools. 

In this project I illustrate the process of implementing automated data pipleines with open source tools. I aim to demonstrate how simple solutions and proactive initiatives can empower us to commence data gathering from day one and offer valuable insights for strategic decision-making.

## Methodology
The basic idea of building these pipelines are pretty simple. Once we have a data storage area determined, we can take help of a scripting tool to perform all the data manipulation and ingestion tasks and then a task scheduler which automates the execution of this scripts.

### Tools Used
- **Python** as scripting language with some libraries (for e.g. Pyodbc/SqlAlchemy for communicating with Database, SMTP for emailing etc.)
- **SQL Server** as Database
- **Windows Task Scheduler** as Automater

### Building the Pipelines
In this project I have tried to implement two different types of data pipelines:
1. One in which data is loaded from one database to another daily and incrementally which is the [project_demo_1](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/project_demo_1/).
2. One in which data is loaded from a file and upserted into a database table which is the [project_demo_2](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/project_demo_2/).

#### Project Demo 1
In this porject the requirement is to incrementally load a table from a transactional datasource to a data-mart which is used for all data sciene and BI applicational needs. As both the sources lies under a same server therefore a stored procedure was written to move the data from source to destination. A stage table was created where data is first loaded, manipulated and then pushed into the destination table. The python script is written to coonect to the database using pyodbc library and excute the stored procedure. In an event of sucess the script then sends out an email to the stakeholders with number of records processed and load time. If process is aborted for any reason the failure notifications will also be emailed to the stakeholders. The ready python script is finally converted into an excutable file use pyinstaller. This executable file is scheduled to run on a daily basis at a specified time.

<p align="center">
<img src="https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/flowchart_1.png" width="50%"/>
</p>

#### Project Demo 2
In this project, the goal is to load data from files to a dstination database. For this purpose a python script is written to check if file is available. If file is available, then the script reads the flile, performs all the necessary data transformations. To load the data into database first the script truncates the stage table. Then it uses the **SQLAlchemy** library to load the data into stage table rather than using a cursor **to_sql** function enahnces the load performance. Finally the script calls a stored procedure which then upserts the data from stage to the destination table. After processing the data it archives the files to an archive folder. In event of a sucess the script then sends out an email to the stakeholders with number of records processed and load time. If process is aborted for any reason the failure notifications will also be emailed to the stakeholders. The ready python script is finally converted into an excutable file use pyinstaller. This executable file is scheduled to run on a daily basis at a specified time.

<p align="center">
<img src="https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/flowchart_2.png" width="60%"/>
</p>

**Link to Project files**:
- Python File: [Load_Environmental_Data.ipynb](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/project_demo_2/Load_Environmental_Data.ipynb)
- SQL SP: [Load_Environmental_Data_SP.sql](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/project_demo_2/Load_Environmental_Data_SP.sql)
- Pyinstaller: [Pyinstaller.ipynb](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/project_demo_2/Pyinstaller.ipynb)

_Note_: How to use task scheduler can be found in the [img](https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/) folder with name task_schd_#

## Results and Conclusion
The result is smooth, low to no cost data pipelines which keeps the data flowing into a datalake/datamart or any data storage area which now can be used for data science and BI tasks. But we need to make sure this pipelines are scheduled by their dependency order. Also maintenance of this pipelines will be necessary and proactive actions might be needed if volume of the data sudenly increases to more than expected.
