In this folder, you find CSV files from two data sources: 
The first originates from a database of cases, which contains three tables: casesperson, casestravel, casesmedrec. These are given in the corresponding comma-separated files.

casesperson.csv contains data on each person, who has been assessed as probable COVID-19 case, or has been tested positively. This table consists of the following attributes:
  rownames: ignore
  cid: unique identifier of each case, numeric
  residence_code: code of the person's main area of residence (numeric, AU2017_code)
  residence_name: name of the person's main area of residence (string)
  gender: the person's sex (string)
  age: the person's age (numeric)
  
casestravel.csv contains the most recent travel record on each person (if one exists). This table consists of the attributes:
  rownames: ignore
  tid: travel id (unique numerical identifier)
  cid: foreign key to casesperson
  last_country: last country on the itinary to New Zealand (string)
  flight_number: number of the last international flight of the itinary (string)
  flight_departure_date: departure date of that flight (date)  
  flight_arrival_date: arrival date of that flight (date)

casesmedrec.csv contains the COVID-19 related parts of the person's medical record. This table consists of the attributes:
  rownames: ignore
  cid: foreign key to casesperson
  date: date the person has been identified as probable or confirmed COVID-19 case (date)
  has_fever: whether the person has symptom fever (string)
  has_cough: whether the person has symptom cough (string)
  has_fatigue: whether the person suffers from fatigue (string)
  has_dyspnea: whether the person has symptom shortness of breath (string)
  has_anorexia: whether the person has symptom loss of appetite (string)
  has_anosmia: whether the person has symptom loss of smell (string)
  has_obesity: whether the person suffers from obesity (string)
  status: whether the person is a confirmed case (tested positively) or probable case (assessment by physician) (string)
  hospital_admission: whether the person has been admitted to hospital (string)


The second originates from a database that provides geographical information. This table contains the table geomapping, which allows to map the area of residence (denoted as area_code in casesperson, and AU2017_code in geomapping) to its district health board, specified by its name in DHB2015_name and its code in DHB2015_code. The attributes are:
  rownames: ignore
  DHB2015_name: District Health Board name (string)
  DHB2015_code: District Health Board code (numeric)
  AU2017_code: Area code (numeric, unique identifier)
  AU2017_name: Area name (string)

  
  
The R script task1.R contains the specifications of the questions as well as a template for your code. Please put *all your code* into this single script file. You can execute it with source('task1.R'). The scritpt file sources functions from libsubmission.R, in particular save_answer(). This function is used to save an answer to a question, and performs some checks on the format to verify that the format of answer and the master solution align.

save_answer(quid,answer,is_file=FALSE,ignore_format=FALSE)
  quid .......... question id (string consisting of a number and if needed a letter)
  answer ........ answer, which is either an object such as string, data frame, list, 
                  or the name of a file to include (in that case is_file must be set to TRUE)
  is_file ....... whether the argument answer is a file, or another object (default FALSE)
  ignore_format . Whether the format should not be validated completely.
                  Default is FALSE, meaning that a wrong format will result in an error when submitting.
                  TRUE means ignorance of some of the format requirements is enforced. Please use TRUE only after consultation. 

In the template, save_answer() is called for each question. However, if you want to skip a question, you can comment save_answer out for that question.
At the end of the script, submission_finalise() is called. This will check and pack your submission into a ZIP-compressed archive. If files or answers are missing, this function will show a warning, or in critical cases throw an exception.

Note: The template task1.R script is configured to allow you to execute it completely, such that you get a ZIP-compressed archive. Please verify this before starting to edit it.


For further details on the questions, please see the comments in task1.R.

For submission, the ZIP-compressed archive and its SHA256-HASH should be provided via blackboard.

Best success!
