message(paste(timestamp(),"\nExecution of script <task1.R> started:"))

require("odbc")
require("tidyverse")
require("assertthat")

# Recommended libraries:
library("moments");
library("lubridate")
library("forecast")
library("dplyr")
library("DBI")


# Please make sure that you are in the working directory with the csv-datasets:
# If you are executing the script from a different directory, please set this to change into the directory with the CSV files: setwd("directory") 
source("libsubmission.R")

# Initialise submission:
submission_initialise()

# Please put the code to connect to your database here:
ch_infombin <- DBI::dbConnect(odbc::odbc(), driver = "/usr/local/Cellar/psqlodbc/12.01.0000/lib/psqlodbcw.so", 
                              database = "postgres", UID = rstudioapi::askForPassword("Database user"), 
                              PWD = rstudioapi::askForPassword("Database password"), host = "localhost", 
                              port = 5432) 
# TODO <<< This needs to be changed prior to the first run! THE FIRST RUN
assert_that(is.null(ch_infombin)!=1, msg = "ODBC connection failed. Please adjust the odbcConnect() 
            - call in the 'task1.R' script prior to executing it.")



##############################################

### Extract, Transform, Load ###

## (a) Loading and cleansing of each source table into a staging table

casesperson <- data.frame(read_csv('casesperson.csv')) # TODO
casesmedrec <- data.frame(read_csv('casesmedrec.csv')) # TODO
casestravel <- data.frame(read_csv('casestravel.csv')) # TODO
geomapping <- data.frame(read_csv('geomapping.csv')) # TODO


# Question: Provide a cleansed version of the data in casesperson.csv as a data frame with column names 
#'cid','residence_code','residence_name','gender','age', with the rows ordered by attribute 'cid':

#remove rownames
casesperson <- casesperson[-c(1)]

#order by cid
casesperson <- casesperson[order(casesperson$cid),]

#replace blank spaces with NA
casesperson[casesperson == ""] <- NA

#replace age value 999 with NA
casesperson$age <- ifelse(casesperson$age == 999, NA, casesperson$age)
save_answer("1",casesperson) # TODO
# As a backup, this answer is also saved to the file "casesperson.RData", which will be included in the submission:
saveRDS(casesperson,file="casesperson.RData")

# Question: Provide a cleansed version of the data in casesmedrec as a data frame with column names 'cid', 'date', 'has_fever', 'has_cough', 'has_fatigue', 'has_dyspnea', 'has_anorexia', 'has_anosmia', 'has_obesity', 'status', 'hospital_admission', with the rows ordered by attribute 'cid':

#remove rownames
casesmedrec <- casesmedrec[-c(1)]

#order by cid
casesmedrec <- casesmedrec[order(casesmedrec$cid),]

#replace blank spaces with NA
casesmedrec[casesmedrec == " "] <- NA
save_answer("2",casesmedrec) # TODO
# As a backup, this answer is also saved to the file "casesmedrec", which will be included in the submission:
saveRDS(casesmedrec,file="casesmedrec.RData")

# Question: Provide a cleansed version of the data in casestravel as a data frame with column names 'tid', 'cid', 'last_country', 'flight_number', 'flight_departure_date', 'flight_arrival_date', with the rows ordered by attribute 'cid'::

#remove rownames
casestravel <- casestravel[-c(1)]

#order by cid
casestravel <- casestravel[order(casestravel$cid),]

#replacing values with a common value for consistency
casestravel$last_country <- ifelse(casestravel$last_country == "United Kingdom", "UK", casestravel$last_country)
casestravel$last_country <- ifelse(casestravel$last_country == "U.K.", "UK", casestravel$last_country)
casestravel$last_country <- ifelse(casestravel$last_country == "Great Britain", "UK", casestravel$last_country)
casestravel$last_country <- ifelse(casestravel$last_country == "United States of America", "USA", casestravel$last_country)
casestravel$last_country <- ifelse(casestravel$last_country == "U.S.A.", "USA", casestravel$last_country)
save_answer("3",casestravel) # TODO
# As a backup, this answer is also saved to the file "casestravel", which will be included in the submission:
saveRDS(casestravel,file="casestravel.RData")

# Question: Provide a cleansed version of the data in geomapping as a data frame with column names 'dhb2015_name', 'dhb2015_code', 
#'au2017_code', 'au2017_name', with the rows ordered by attribute 'au2017_code'::

#remove rownames
geomapping <- geomapping[-c(1)]

#replace blank spaces with NA
geomapping[geomapping == " "] <- NA

#remove duplicate values
geomapping <- geomapping %>% distinct()

#order by AU2017_code
geomapping <- geomapping[order(geomapping$AU2017_code),]
save_answer("4",geomapping) # TODO
# As a backup, this answer is also saved to the file "geomapping", which will be included in the submission:
saveRDS(geomapping,file="geomapping.RData")

#writing all the data frames to POSTGRESQL
dbWriteTable(ch_infombin, "casesperson", value=casesperson,
             field.types = c(cid = "numeric", residence_code = "numeric", 
                             residence_name = "varchar", gender = "varchar", age ="numeric"))

dbWriteTable(ch_infombin, "casesmedrec", value=casesmedrec, 
             field.types = c(cid = "numeric", date = "DATE", has_fever = "boolean", has_cough = "boolean", has_fatigue = "boolean", 
                             has_dyspnea = "boolean", has_anorexia = "boolean", has_anosmia = "boolean", has_obesity = "boolean", 
                             status = "varchar", hospital_admission = "boolean"))

dbWriteTable(ch_infombin, "casestravel", value=casestravel,
             field.types = c(cid = "numeric", tid = 'numeric', last_country = 'varchar', flight_number = 'varchar', 
                             flight_departure_date = 'DATE', flight_arrival_date = 'DATE'))

dbWriteTable(ch_infombin, "geomapping", value=geomapping,
             field.types = c(DHB2015_name = 'varchar', DHB2015_code = 'numeric', 
                             AU2017_code = 'numeric', AU2017_name = 'varchar'))

# Question: Provide a SQL query that selects all attributes of a case into a single flat table. This table must include each attribute exactly once, and in the following order: 'cid','gender','age','residence_code','residence_name','dhb2015_code','dhb2015_name','tid','last_country','flight_number','flight_departure_date','flight_arrival_date','date','has_fever','has_cough','has_fatigue','has_dyspnea','has_anorexia','has_anosmia','has_obesity','status','hospital_admission'
# The rows must be in ascending order of 'cid'.

query_text_flat_table <- 'SELECT DISTINCT cp.cid, cp.gender, cp.age, cp.residence_code, cp.residence_name, gm."DHB2015_code", 
                          gm."DHB2015_name", ct.tid, ct.last_country, ct.flight_number, ct.flight_departure_date,ct.flight_arrival_date, 
                          cm.date, cm.has_fever, cm.has_cough, cm.has_fatigue, cm.has_dyspnea, cm.has_anorexia, cm.has_anosmia, 
                          cm.has_obesity, cm.status, cm.hospital_admission
                          FROM casesperson AS cp
                          LEFT JOIN casesmedrec AS cm ON cm.cid = cp.cid
                          LEFT JOIN casestravel AS ct ON ct.cid = cp.cid
                          LEFT JOIN geomapping AS gm ON gm."AU2017_code" = cp.residence_code
                          ORDER BY cp.cid;' # TODO
save_answer("5a",query_text_flat_table)

# Save this table to a data frame flat_table:
flat_table <- dbGetQuery(ch_infombin, query_text_flat_table) # Result of Extract
save_answer("5b",flat_table)
# As a backup, this answer is also saved to the file "flattable.RData", which will be included in the submission:
saveRDS(flat_table,file="flattable.RData")



# In preparation for the next questions, save the result of the query above in a table named "flattable" in the database, and execute the queries below on that table:
# Hint: You might do this either directly from within the database with a SQL statement, or via sqlSave.

query_text_copy_flat_table <- paste("SELECT * INTO flattable FROM (",
                                    substr(query_text_flat_table,start = 1, stop = str_length(query_text_flat_table)-1),
                                    ") AS tmp;",sep = "")

dbWriteTable(ch_infombin, "flattable", value=flat_table)
# Writing the content of table flattable in the database to a CSV file of that name, which will be included in the submission:
dbExecute(conn = ch_infombin, statement = paste("COPY flattable TO '",file.path(getwd(),"flattable.csv"),"' csv header;",sep=""))




##############################################

### DB Querying and Descriptive Analytics ###

## The first set of question on DB querying and descriptive analytics build on the previous results, 
#and therefore require that you have created and populated the tables as described above.
## However, there is a second set of questions further below, which will use a different table 
#(provided with the zip-archive) 'cases'. This is to ensure that students who did not succeed in the steps 
#above can still obtain partial credit for some questions.

### Part 1  ###


# Question: How many cases are there in total?  First, provide a SQL statement for that query, 
#then the result of the query as a data frame with column "count":
query_text_6 <- "SELECT COUNT(*) from flattable;" # TODO
save_answer("6a",query_text_6)
query_result_6 <- dbGetQuery(ch_infombin, query_text_6)
save_answer("6b",query_result_6)



# Question: When did the first case occur, when the last? First, provide a SQL statement for that query, then the result of the 
#query as a data frame with columns "first" and "last":
query_text_7 <- "select min(date), max(date) from flattable;" # TODO
save_answer("7a",query_text_7)
query_result_7 <- dbGetQuery(ch_infombin, query_text_7)
names(query_result_7)[names(query_result_7) == "min"] <- "first"
names(query_result_7)[names(query_result_7) == "max"] <- "last"
save_answer("7b",query_result_7)



# Question: For how many cases is the gender missing? First, provide a SQL statement for that query, 
#then the result of the query as a data frame with column "count":
query_text_8 <- "SELECT COUNT(*) from flattable where gender IS NULL" # TODO
save_answer("8a",query_text_8)
query_result_8 <- dbGetQuery(ch_infombin, query_text_8)
save_answer("8b",query_result_8)



# Continuing the question from above, query an ordered list of the IDs of cases with missing values in the gender 
#attribute (ordered by 'cid' in ascending order). First, provide a SQL statement for that query, then the result of the query as a data frame with column 'cid':
query_text_9 <- "SELECT cid from flattable where gender IS NULL order by cid" # TODO
save_answer("9a",query_text_9)
query_result_9 <- dbGetQuery(ch_infombin, query_text_9)
save_answer("9b",query_result_9)



# Question: Give an ordered list of the case IDs of cases without a travel record (in ascending order). First, provide a SQL statement for that query, then the result of the query as a data frame with column "cid":
query_text_10 <- "SELECT cid from flattable where tid IS NULL order by cid" # TODO
save_answer("10a",query_text_10)
query_result_10 <- dbGetQuery(ch_infombin, query_text_10)
save_answer("10b",query_result_10)




# Question: How many different countries are there in last_country (after cleansing), including NA? First, provide a SQL statement for that query, then the result of the query as a data frame with column "country":
#select count(distinct(last_country)) + (CASE bool_or(last_country is null) WHEN true THEN 1 ELSE 0 END) from flattable
query_text_11 <- "SELECT DISTINCT last_country AS country
                  FROM flattable;" # TODO
save_answer("11a",query_text_11)
query_result_11 <- dbGetQuery(ch_infombin, query_text_11)
save_answer("11b",query_result_11)



# Question: Rank the countries in which New Zealanders most likely contracted the virus. 
#The result should be a table with two columns, country (distinct values from last_country) and casecount, 
#ordered (ascending order) by casecount. Again, provide the SQL statement for that query first, and then the resulting data frame:
query_text_12 <- "SELECT last_country AS country, count(cid) as casecount
                  FROM flattable group by last_country order by casecount;" # TODO
save_answer("12a",query_text_12)
query_result_12 <- dbGetQuery(ch_infombin, query_text_12)
save_answer("12b",query_result_12)



# Question: How many distinct combinations of DHB2015_code and AU2017_code exist in geomapping (after cleansing)? First, provide a SQL statement for that query, then the result of the query as a data frame with columns "dhb2015_code", "au2017_code":
query_text_13 <- 'SELECT "DHB2015_code", "AU2017_code"
                  FROM public.geomapping
                  GROUP BY "DHB2015_code", "AU2017_code"
                  ORDER BY "DHB2015_code", "AU2017_code";' # TODO
save_answer("13a",query_text_13)
query_result_13 <- dbGetQuery(ch_infombin, query_text_13)
save_answer("13b",query_result_13)



##############################################


### DB Querying and Descriptive Analytics ###


# Data Dictionary for table 'flattable'
#
# Variable 'cid':
#    Meaning: unique identifier of each case
#    Type and range of values: Numeric. 234 values ranging from 1 to 1155
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesperson.csv
#    Transformation: none
#    Known issues: none
#
# Variable 'gender':
#    Meaning: the person's sex 
#    Type and range of values: String (varchar). Male/Female/NA
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casesperson.csv
#    Transformation: none
#    Known issues: missing values (NA)
#
# Variable 'age':
#    Meaning: the person's age 
#    Type and range of values: Numeric value from 13 to 96   
#    Missing (or special) values: missing values are stated as 'NA' 
#    Data source(s): casesperson.csv
#    Transformation: The age of one person is listed as 999 years and is changed to NA
#    Known issues: missing values (NA) and the age of one person is listed as 999 years
#
# Variable 'residence_code':
#    Meaning: code of the person's main area of residence
#    Type and range of values: Numeric - from 500203 to 612802
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesperson.csv
#    Transformation: None
#    Known issues: None
#
# Variable 'residence_name':
#    Meaning: name of the person's main area of residence
#    Type and range of values: String (varchar)
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesperson.csv
#    Transformation: None
#    Known issues: None
#
# Variable 'DHB2015_code':
#    Meaning: District health board code
#    Type and range of values: Numeric. 234 values ranging from 1 to 22
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): geomapping.csv
#    Transformation: None
#    Known issues: None

# Variable 'DHB2015_name':
#    Meaning: District health board name 
#    Type and range of values: string values
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): geomapping.csv
#    Transformation: None
#    Known issues: None

# Variable 'tid':
#    Meaning: unique identifier for travel record of a person 
#    Type and range of values: Numeric value from 358 to 570  
#    Missing (or special) values: missing values are stated as 'NA' 
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: missing values (NA)

# Variable 'last_country':
#    Meaning: last country on the itinerary to New Zealand
#    Type and range of values: string values
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: missing values (NA)
#
# Variable 'flight_number':
#    Meaning: a unique number of each flight path
#    Type and range of values: the values start with an abbreviation of the airline in Latin alphabet and are followed by practically random numbers.
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: missing values (NA)
# 
# Variable 'flight_departure_date'
#    Meaning: the date of the departure of the flight the person was on.
#    Type and range of values: the values are dates between 2020-02-22	and 2020-03-23.
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: Missing values (NA)
#
# Variable 'flight_arrival_date'
#    Meaning: the date of arrival of the flight the person was on.
#    Type and range of values: the values are dates between 2020-02-23 and 2020-03-23.
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: Missing values (NA)
#
# Variable 'date'
#    Meaning: the date the person has been identified as probable or confirmed case of covid-19.
#    Type and range of values: the values are dates between 2020-02-26	and 2020-03-24.
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casestravel.csv
#    Transformation: None
#    Known issues: None
#
# Variable 'has_fever':
#    Meaning: Whether the person has a fever symptom or not.
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
#
# Variable 'has_cough':
#    Meaning: Whether the person has a coughing symptom or not.
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
#
# Variable 'has_fatigue':
#    Meaning: Whether the person has a fatigue symptom or not.
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
#
# Variable 'has_dyspnea':
#    Meaning: Whether the person has a dyspnea symptom or not.
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: There are neither missing nor special values in this variable.
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
#
# Variable 'has_anorexia':
#    Meaning: whether the person has symptom loss of appetite
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
# 
# Variable 'has_anosmia':
#    Meaning: whether the person has symptom loss of smell
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: None
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
# 
# Variable 'has_obesity':
#    Meaning: whether the person suffers from obesity
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: None
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None
# 
# Variable 'status':
#    Meaning: whether the person is a confirmed case (tested positively) or probable case (assessment by physician)
#    Type and range of values: string (confirmed, probable)
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casesmedrec.csv
#    Transformation: None
#    Known issues: None
# 
# Variable 'hospital_admission':
#    Meaning: whether the person has been admitted to hospital
#    Type and range of values: boolean (TRUE, FALSE)
#    Missing (or special) values: missing values are stated as 'NA'
#    Data source(s): casesmedrec.csv
#    Transformation: The variable was previously a character type with the values ‘false’ and ‘true’. This is transformed to logical Boolean type of variables for the further analysis.
#    Known issues: None

##############################################

## For the following queries and analyses, use the table 'cases'. Do *not* use flattable. By using 'cases', it is ensured that your answers to the questions below will be independent of the results of the data cleansing in the previous questions. While the table 'cases' has been built from a different dataset, it contains a subset of attributes similar to the ones in 'flattable' above (with some small differences, which should not influence your queries below), and you can imagine that it has been made analytics ready before being loaded into the warehouse' database. The table 'cases' contains the attributes 'cid','gender','age','dhb2015_code','dhb2015_name','tid','date','status', and the rows are in ascending order of 'cid'.


if (is.element("cases",dbListTables(ch_infombin))) { dbSendStatement(ch_infombin,"DROP TABLE cases;") }
qdf <- dbSendStatement(conn = ch_infombin, statement = "CREATE TABLE public.cases (
  cid double precision,
  gender character varying(255),
  age double precision,
  dhb2015_code double precision,
  dhb2015_name character varying(255),
  date date,
  status character varying(255)
);")
qdf_completed = dbHasCompleted(qdf)
assert_that(qdf_completed,msg="Creation of table cases has not worked. Please check.")
dbClearResult(qdf)
qdf <- dbSendStatement(ch_infombin,paste("COPY cases FROM '",file.path(getwd(),"cases.csv"),"' csv header;",sep=""))
qdf_completed = dbHasCompleted(qdf)
qdf_rows = dbGetRowsAffected(qdf)
assert_that(all(qdf_completed,qdf_rows==1213),msg="Populating of table cases has not succeeded. Please check.")
dbClearResult(qdf)
cases <- dbGetQuery(ch_infombin, statement = "SELECT * FROM cases;")
assert_that(all(identical(names(cases),c("cid","gender","age","dhb2015_code","dhb2015_name","date","status")),dim(cases)==array(c(1213, 7))),msg="Something went wrong when populating/fetching the table cases. Please check.")


### Part 2: Querying  ###


# Question: Query counts of cases on variable day and DHB region (for simplicity, for now with omitting combinations of day 
#and DHB region without any reported case): First, provide a SQL statement for that query, then the result of the query as a data frame with columns "date", region", "casecount", where rows are ordered first by "date" and second by "region":
query_text_14 <- "select date,  dhb2015_code as region, count(cid) as casecount from cases group by date, region
order by date, region" # TODO
save_answer("14a",query_text_14)
query_result_14 <- dbGetQuery(ch_infombin, query_text_14)
save_answer("14b",query_result_14)



# Question: Create a table that contains for all possible combinations of regions (any distinct value in DHB2015_code) 
#and dates (any date between the first and last day a case has been recorded in any region) the according case counts. 
#That is, this table should have three columns region,date,casecount, ordered in ascending order on the first and second column. 
#The third column gives a count over the cases in the corresponding DHB region and day, and zero if no such case was recorded in that region and day. 
# Hint 1: If you implement this in a single SQL query, a CROSS JOIN might be usefull. 
# Hint 2: In PostgreSQL, you can generate a series of days between a starting and end date with 
#SELECT generate_series(startdate, enddate, interval '1 day');
# Furthermore, check your result for consistency (e.g., that all possible dates are included, and that all distinct regions that you find 
#in the geomapping databases are present, and that the sum over the third column is equal to the count obtained in the very first query, 
#where you counted all cases in the database

# First, provide a SQL statement for that query, then the result of the query as a data frame with columns "region", date", "casecount":
query_text_15 <- "SELECT b. region, a.tag as date, count(c.cid) as casecount 
FROM (SELECT generate_series(min(date) ,max(date), interval '1 day')::date AS tag 
	  FROM cases) a CROSS JOIN (SELECT dhb2015_code AS region FROM cases GROUP By dhb2015_code) b 
	  LEFT JOIN cases c on a.tag=c.date AND b.region=c.dhb2015_code GROUP BY b. region, a.tag ORDER BY b. region, a.tag;" # TODO
save_answer("15a",query_text_15)
query_result_15 <- dbGetQuery(ch_infombin, query_text_15)
save_answer("15b",query_result_15)



# Question: Return a table that provides for each age group (in decades, starting with group 0 for ages 0-9, 10 for ages 10-19, etc.) 
#the count of cases. This table should have two columns: agegroup, with values 0,10,20, etc., and casecount, with the counted number of cases. 
#The rows in this table should be ordered ascendingly by age group.  Again, provide the SQL statement for that query first, and then the resulting data frame:
# Hint: Make sure that you include at the end a row with the cases who have missing values for age.
query_text_16 <- "SELECT CASE
          	 WHEN age < 10 THEN '0'
             WHEN age BETWEEN 10 AND 20 THEN '10'
             WHEN age BETWEEN 20 AND 30 THEN '20'
			       WHEN age BETWEEN 30 AND 40 THEN '30'
             WHEN age BETWEEN 40 AND 50 THEN '40'
			       WHEN age BETWEEN 50 AND 60 THEN '50'
             WHEN age BETWEEN 60 AND 70 THEN '60'
			       WHEN age BETWEEN 70 AND 80 THEN '70'
             WHEN age BETWEEN 80 AND 90 THEN '80'
             WHEN age BETWEEN 90 AND 100 THEN '90'
             WHEN age > 100 THEN '100'
             ELSE 'Invalid age'
            END AS agegroup, COUNT(*) as casecount
          	FROM public.cases
          	GROUP BY agegroup
          	ORDER BY agegroup;

" # TODO
save_answer("16a",query_text_16)
query_result_16 <- dbGetQuery(ch_infombin, query_text_16)
save_answer("16b",query_result_16)



# Question: Return a table that ranks weeks by their case counts. The first column, weeknumber, contains the week numbering (ISO 8601, 
#Monday as first day of a week), the second column, casecount, the corresponding number of cases. 
#The rows should be in descending order of case counts. Again, provide the SQL statement for that query first, and then the resulting data frame:
# Hint: This table needs only to contain weeks where at least one case has been recorded.
query_text_17 <- "SELECT EXTRACT (WEEK FROM (date)) as weeknumber, COUNT(*) as casecount
                	FROM public.cases
                	GROUP BY weeknumber
                	ORDER BY casecount DESC;" # TODO
save_answer("17a",query_text_17)
query_result_17 <- dbGetQuery(ch_infombin, query_text_17)
save_answer("17b",query_result_17)



# Question: Provide a table that lists all cases in a specific DHB region 3 (Auckland). Provide first a query, then the resulting data frame, which should contain the case IDs of all cases in that region, in ascending order, as column "cid":
query_text_18 <- "select cid from cases where dhb2015_name = 'Auckland' order by cid" # TODO
save_answer("18a",query_text_18)
query_result_18 <- dbGetQuery(ch_infombin, query_text_18)
save_answer("18b",query_result_18)



# Question: Create a slice that shows the number of cases in a specific DHB region 3 (Auckland) on the variables date and age. 
#The result should be a table with three columns: date, age, and casecount. The entries in this table should be ordered first by date,
#then by age. As before, provide the SQL statement for that query first, followed by the resulting data frame:
query_text_19 <- "select date, age, count(cid) as casecount from cases where dhb2015_name = 'Auckland' group by date, age 
order by date, age" # TODO
save_answer("19a",query_text_19)
query_result_19 <- dbGetQuery(ch_infombin, query_text_19)
save_answer("19b",query_result_19)



##############################################

### Part 3: Analysis within R  ###


# For the last questions, a table with casecounts for all possible dates (in range) is given: 
casesperday <- readRDS(file="casesperday.RData")
assert_that(identical(names(casesperday),c("date","casecount")),msg="Loading of casesperday from file <casesperday.RData> did not work. Please check.")


# Question: What is the mode of the variable cases$dhb2015_name? Provide a single number:
modeval = function(X){
  return(as.numeric(names(sort(-table(X))[1])));
}
answer_20 <- cases[which(cases$dhb2015_code == modeval(cases$dhb2015_code)),]  # TODO
answer_20 <- unique(answer_20$dhb2015_name) 
save_answer("20",answer_20)

# Question: Provide a list with 5 elements corresponding to the minimum, 1st quartile, median, 3rd quartile, maximum of casesperday$casecount.
answer_21 = list(min = min(casesperday$casecount), 
                 q1 = quantile(x = casesperday$casecount, probs = .25), 
                 med = median(casesperday$casecount), 
                 q3 = quantile(x = casesperday$casecount, probs = .75), 
                 max = max(casesperday$casecount)) # TODO
save_answer("21",answer_21)



# Question: Provide a data frame with two columns: 'week' as the week number (ISO 8601 standard, for all weeks between the first and last 
#case in casesperday)  in ascending order, then 'casecount' as the means for the daily cases that week. 
answer_22 <- week_mean_df <- casesperday %>% mutate(week = week(casesperday$date)) %>% 
  group_by(week) %>% mutate(casecount = mean(casecount)) %>% 
  select(week, casecount) %>% unique()
save_answer("22",answer_22)



# Question: Create a plot time versus new cases with title "Daily New Cases". 
#On the horizontal axis, it should show the date, while on the vertical axis the number of new cases per day. 
#This plot should show the cases per day (denoted as "daily reported cases" in the legend) as dots, 
#as well as the weekly average (denoted as "weekly average") as line. 

# First, create for each curve's coordinate on the horizontal (time) axis a Date object:
answer_23_x1 = as.Date(casesperday$date) # TODO
answer_23_x2 = unique(week(casesperday$date))# TODO
save_answer("23a",answer=answer_23_x1)
save_answer("23b",answer=answer_23_x2)

# Second, create for each curve's coordinate on the vertical (count) axis a vector:
answer_23_y1 = as.numeric(casesperday$casecount) # TODO
answer_23_y2 = as.numeric(answer_22$casecount) # TODO
save_answer("23c",answer=answer_23_y1)
save_answer("23d",answer=answer_23_y2)

# Third, put your code for plotting between the pdf() and dev.off() commands below to plot the result into the file "answer_39e.pdf".
filename = "answer_23e.pdf"
pdf(file=filename,width=12,height=9); 

# put your plotting code here, between pdf() and dev.off()
plot(x = answer_23_x1, y = answer_23_y1,
     main = "Daily New Cases", xlab = "Date", ylab = "New cases per day", type = 'p') 
par(new = TRUE)
plot(x = answer_23_x2, y = answer_23_y2, xlab = "", ylab = "", col="red",
     type = 'l', axes = FALSE)# TODO
legend(x = 'topright', y = 0.92, legend = c("Daily reported cases", "Weekly Average Cases")
       , col = c("black", "red"), lty = c(NA, 1),pch = c(1, NA))

# ...
dev.off();
save_answer("23e",answer=filename, is_file=TRUE)



##############################################

# Close database connection:
dbDisconnect(ch_infombin)

# Finalise submission:
submission_finalise()

# End notification:
message(paste(timestamp(),"\nExecution of script <task1.R> completed."))
#EOF

save.image(file = "myworkspace.RData", ascii = TRUE, version="3")
save(answerlist, file = "myanswerlist.RData", ascii = TRUE, version="3", precheck = TRUE)