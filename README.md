# Sustainable Data Collection in Scholarly Publishing: Leveraging OpenAlex API and WOS PostgreSQL 

## A Comparison of the Accessibility and Sustainability of OpenAlex and PostgreSQL from a Beginner Perspective

## Overview
This repository contains all input files necessary to extract University of Toronto Springer data from OpenAlex and PostgreSQL. The aim of this comparison is to determine the usability of the data and the sustainability of using these resources, with an emphasis on a beginner perspective.

## Requirements
The code requires [RStudio](https://posit.co/download/rstudio-desktop/) and [MobaXterm](https://mobaxterm.mobatek.net/). To run the code stored in this github, you will need to have both of these installed. We recommend using RStudio on your local computer or Posit Cloud as your IDE. To use PostgreSQL you will need to have access from your institution and follow steps to be permitted access. This is a link to the University of Toronto's guide on access PostgreSQL: [How to Access the PostgreSQL Databases](https://mdl.library.utoronto.ca/technology/tutorials/how-access-postgresql-databases)

Following the download of RStudio, you will need to download the packages associated with this project. These are:
-   `tidyverse`
-   `openalexR`
-   `writexl`

## Downloading Data
All data is pulled from OpenAlex and Web of Science. No other data is needed.

## Resources
Using these tools and learning to code is difficult. We have provided some resources here to help you get started:
 - [How to Access the PostgreSQL Databases](https://mdl.library.utoronto.ca/technology/tutorials/how-access-postgresql-databases)
 - [Web of Science PostgreSQL Database](https://mdl.library.utoronto.ca/technology/text-data-mining-software/web-science-postgresql-database)
 - [Getting Started with the Web of Science PostgreSQL Database](https://mdl.library.utoronto.ca/technology/tutorials/getting-started-web-science-postgresql-database#highperf)
 - [Databases and SQL - Summary and Setup](https://swcarpentry.github.io/sql-novice-survey/)
 - [The Unix Shell - Summary and Setup](https://swcarpentry.github.io/shell-novice/)
 - [Relational Database](https://www.freecodecamp.org/learn/relational-database/)

## Acknowledgments
Created by [Coral Markan Davidson](https://github.com/camardavids) and [Chloe Thierstein](https://github.com/cthierst) using R, an open-source statistical programming language, and MobaXterm, an open-source remote desktop solution.

We would like to give special thanks to [Leslie Barnes](https://onesearch.library.utoronto.ca/library-staff/leslie-barnes) for her invaluable help, guidance, and insight on this project. Much of this project's development is credited to her help. 
