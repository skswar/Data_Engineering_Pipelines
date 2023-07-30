<div align="center">
<img src="https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/banner.png" alt="Intro Logo" width="75%" height="30%"/></div>
<p align="right">
<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/80x15.png" width="5%"/></a><br/><ruby><rt>This and all the following images are licensed by Sayan Swar under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.</rt></ruby>
</p>
</div>

<h3 align="center">How to build Efficient Data Enginnerg Pipeline at No Additional Software Overhead Cost?</h4>

<hr>

## Table of contents
* [Introduction](#introduction)
* [Methodology](#methodology)

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
In this porject the requirement is to incrementally load a table from a transactional datasource to a data-mart which is used for all data sciene and BI applicational needs. As both the sources lies under a same server therefore a stored procedure was written to move the data from source to destination. A stage table was created where data is first loaded, manipulated and then pused into the destination table. The results such as number of data loaded and load time is retured to python to email to the stakeholder about the status of the process upon execution.

<p align="center">
<img src="https://github.com/skswar/Data_Engineering_Pipelines/blob/main/img/flowchart_1.png" width="50%"/>
</p>




