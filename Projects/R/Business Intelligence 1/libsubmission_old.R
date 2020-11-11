require("openssl") # to calculate a hash for the submission file
require("tools") # to handle file paths etc
# Initialise the variables:
groupfile_name <<- "groupinfo.txt"
workspace_filename <<- "task1.RData"
answerfiles_ext <<- ".RData"
answerspec_fileprefix <<- "answerspec"
answerspec_filename <<- paste(answerspec_fileprefix,answerfiles_ext,sep="")
everywhere_includefiles <<- c("cases.csv","casesperday.RData","task1.R","groupinfo.txt","libsubmission.R","casesperson.csv","casesmedrec.csv","casestravel.csv","geomapping.csv")
submission_includefiles <<- c("flattable.RData","flattable.csv","casesperson.RData","casesmedrec.RData","casestravel.RData","geomapping.RData",workspace_filename)
description_files <<- c(answerspec_filename,everywhere_includefiles,"cases_create.SQL","task1_readme_description.txt")
answerlist <<- list()
answerlist_fileprefix <<- "answerlist"
answer_fileprefix <<- "answer_"
answerlist_filename <<- paste(answerlist_fileprefix,answerfiles_ext,sep="")


check_answer <- function(quid, answer, is_file, answerspecs, ignore_format = FALSE){
  success_msg = TRUE # TRUE/FALSE (as in see_if), with attr(success_msg, "msg") containing an error message, if any
  format_msg = TRUE # as above, but for "ignorable" format problems
  # check the type of answer is as expected
  if (answerspecs[[quid]]$type=="file") {
    # A file is required as answer:
    if ((is_file==FALSE)&(ignore_format==TRUE)) warning("File expected as answer. Can not ignore this requirement.") # And will throw an error anyway in the next line...
    success_msg = see_if(is_file==TRUE,msg = "This question requires a file as answer. Set the argument is_file=TRUE and the argument answer= to the name of the file.")
    if (success_msg) {
      # Verify that the file is accessible:
      msg_filepermission = paste("Answer file <",answer,"> does not exist in the current directory.",sep="")
      success_msg = see_if(file.exists(answer),msg=msg_filepermission)
      # Verify the file extension (ignorable):
      format_msg = see_if(identical(tolower(file_ext(answerspecs[[quid]]$filename)),tolower(file_ext(answer))), msg = paste("File extension of answer (<",tolower(file_ext(answer)),">)  does not match that of specification(<",tolower(file_ext(answerspecs[[quid]]$filename)),">)",sep=""))
    }
  } else {
    # An object (not a file) is required as answer:
    if ((is_file==TRUE)&(ignore_format==TRUE)) warning("Object other than file expected as answer. Can not ignore this requirement.") # And will throw an error anyway in the next line...
    success_msg = see_if(is_file==FALSE,msg="A file is not allowed as answer to this question. Set the argument is_file=FALSE and provide as argument answer the variable with the answer.")
    if (success_msg) {
      # answer is an object, thus we now check its format:  
      if (answerspecs[[quid]]$type=="character") {
        # dataframe expected, check number and names of columns, warn if columntypes are different:
        msg_st = paste("Argument answer must be of type 'character', not '",typeof(answer),"' (use typeof(answer)=='character' to verify this).",sep="")
        format_msg = see_if(identical(typeof(answer),answerspecs[[quid]]$type),msg=msg_st)
      }
      if (answerspecs[[quid]]$isdf) { 
        # dataframe expected, check number and names of columns, warn if columntypes are different:
        msg_df = paste("Argument answer must be a data frame with ",length(answerspecs[[quid]]$names)," columns and column names <",toString(tolower(answerspecs[[quid]]$names)),">. \nThe column specification of the given argument answer are: \n",toString(tolower(names(answer))),"\n(Use names(answer)) to verify and change column names).",sep="")
        format_msg = see_if(is.data.frame(answer)==answerspecs[[quid]]$isdf,msg=msg_df)
        if (format_msg) {
          # check if names are identical (ignoring case)
          format_msg = see_if(all(tolower(names(answer))==tolower(answerspecs[[quid]]$names)),msg=msg_df)
        }
      }
    }
  }
  if (success_msg==TRUE) {
    if (format_msg==TRUE) {
      success = TRUE
    } else {
      if (ignore_format==TRUE) {
        success = TRUE
      } else {
        success = FALSE
      }
    }
  } else { 
    success = FALSE
  }
  return(list(success = success,  success_msg = success_msg, format_msg = format_msg))
}


# quid = question id (string consisting of a number and if needed a letter)
# answer = answer, which is either an object such as string, data frame, list, 
#          or the name of a file to include (in that case is_file must be set to TRUE)
# is_file = whether the argument answer is a file, or another object (default FALSE)
# ignore_format = if TRUE, some of the format requirements are ignored.
#                 Default is FALSE. Please use TRUE only after consultation. 
save_answer <- function(quid,answer,is_file=FALSE,ignore_format=FALSE){
  thisanswer = list()
  thisanswer$answer = answer
  thisanswer$timestamp = Sys.time()
  thisanswer$quidraw = quid
  thisanswer$qunum = parse_number(quid)
  thisanswer$qusub =  str_extract(str_to_lower(quid), pattern="[a-z]+")
  if (is.na(thisanswer$qusub)) thisanswer$qusub=""
  thisanswer$quid = paste(thisanswer$qunum,thisanswer$qusub,sep="")
  # Check that answerspecs exists
  assert_that(exists("answerspecs"),msg = "List of answer specifications (variable 'answerspecs') not found.")
  # check if that question exists
  assert_that(any(names(answerspecs)==thisanswer$quid),msg=paste("No question with identifier <",thisanswer$quid,"> found, check argument quid='",quid,"' to refer to one question in ",toString(names(answerspecs)),".",sep=""))
  # check if that question has already been answered, and give a warning if that is the case
  if (any(names(answerlist)==thisanswer$quid)) {
    warning(paste("Previous answer to question with identifier <",thisanswer$quid,"> found, this old answer will be overwritten. Check that argument quid='",quid,"' refers to the right question.",sep=""),immediate. = TRUE)
  }
  
  check_result <- check_answer(thisanswer$quid, answer = thisanswer$answer, is_file = is_file, answerspecs = answerspecs, ignore_format = ignore_format)
  if (!check_result$format_msg) {
    if (ignore_format) {
      warning(paste("You have requested to ignore the answer format for question <",thisanswer$quid,"> by setting the argument ignore_format=TRUE. Overriding the format requirements might result in an invalid answer being recorded. Use this only with permission.",sep=""),immediate.=TRUE)
    } else {
      validate_that(FALSE,msg=paste("The format of the answer does not match its requirements for question <",thisanswer$quid,">. You should change the format of the answer according to the specifications.  Alternatively, you might override the format requirements by setting the argument ignore_format=TRUE. Overriding the format requirements might result in an invalid answer being recorded. Use this only with permission.",sep=""), immediate.=TRUE)
    }
  }
  
  if (check_result$success) {
    # no critical issue (if ignore_format==TRUE, then there might be formatting issues)
    
    # record some info about the type of the given answer:
    if (answerspecs[[quid]]$type=="file") {
      thisanswer$filename = answer
      thisanswer$type = answerspecs[[quid]]$type
    } else {  
      thisanswer$filename = paste(answer_fileprefix,quid,answerfiles_ext,sep="")
      thisanswer$type = typeof(answer)
      thisanswer$isdf = is.data.frame(answer)
      thisanswer$names = names(answer)
      thisanswer$attribs = attributes(answer)
    }
    
    # update and save the list of answers
    if (!exists("answerlist")) {
      warning("List of answers (variable 'answerlist') not found. (Re)initialising it.")
      answerlist <<- list()
    }
    if (any(names(answerlist)==thisanswer$quid)) {
      answerlist[[which(names(answerlist)==thisanswer$quid)]] <<- thisanswer
    } else {
      answerlist$new <<- thisanswer
      names(answerlist)[length(answerlist)] <<- thisanswer$quid
    }
    msg_filepermission = paste("Can not write to answerlist file <",answerlist_filename,"> in the current directory.",sep="")
    msg_writeloadproblem = paste("Verification of saved answerlist from file  <",answerlist_filename,"> failed.",sep="")
    assert_that(is.null(try(saveRDS(answerlist, file = answerlist_filename))),msg=msg_filepermission)
    local({
      tmp_answerlist = readRDS(file = answerlist_filename)
      assert_that(identical(answerlist,tmp_answerlist,ignore.environment = TRUE),msg=msg_writeloadproblem)
    })
    if (answerspecs[[thisanswer$quid]]$type!="file") {
      # save the answer itself to a separate file
      msg_filepermission = paste("Can not write answer to file <",thisanswer$filename,"> in the current directory.",sep="")
      msg_writeloadproblem = paste("Verification of saved answer from file  <",thisanswer$filename,"> failed.",sep="")
      assert_that(is.null(try(saveRDS(thisanswer$answer, file = thisanswer$filename))),msg=msg_filepermission)
      local({
        tmp_answer = readRDS(file = thisanswer$filename)
        assert_that(identical(thisanswer$answer,tmp_answer,ignore.environment = TRUE),msg=msg_writeloadproblem)
      })
    }
    print(paste("Answer to question ",thisanswer$quid," has been saved in file <",thisanswer$filename,">.",sep=""))
    return(TRUE)
  }
  return(FALSE)
}

submission_initialise <- function(clean_files = FALSE){
  # Read group ID from file groupinfo.txt:
  tmp <- read_lines(file = groupfile_name)
  assert_that(!is.na(as.numeric(tmp)), msg = paste("Could not read group number from file <",groupfile_name,">.",sep=""))
  group_id <<- sprintf("%03d",as.numeric(tmp))
  
  # Load the answerspecs:
  answerspecs <<- readRDS(file = answerspec_filename)
  assert_that(typeof(answerspecs)=="list",msg = paste("Could not read answer specifications from file <",answerspec_filename,">.",sep=""))  
}

submission_check <- function(additional_files_to_include = c(), directory_path = getwd(), skip_variable_inmem_comparison = FALSE){
  # Load answerlist from file, and verify it:
  file_answerlist = file.path(directory_path,answerlist_filename)
  file_answerspecs = file.path(directory_path,answerspec_filename)
  assert_that(file.exists(file_answerlist),msg = paste("submission_check failed: File <",file_answerlist,"> not found.",sep=""))
  assert_that(file.exists(file_answerspecs),msg = paste("submission_check failed: File <",file_answerspecs,"> not found.",sep=""))
  answerlist_ = readRDS(file_answerlist)
  answerspecs_ = readRDS(file_answerspecs)
  if (skip_variable_inmem_comparison==FALSE) {
    # Check that answerspecs exists ans matches that in the file:
    assert_that(exists("answerspecs")==TRUE,msg = "List of answer specifications (variable 'answerspecs') not found.")
    # Check that answerlist exists (in memory) and matches that in the file:
    assert_that(exists("answerlist")==TRUE,msg = "List of answers (variable 'answerlist') not found.")
    msg_writeloadproblem = paste("Verification of saved answerlist from file  <",file.path(directory_path,answerlist_filename),"> failed.",sep="")
    assert_that(identical(answerlist,answerlist_,ignore.environment = TRUE),msg=msg_writeloadproblem)
  }
  answerspecs = answerspecs_
  answerlist = answerlist_
  ## Check that all answers in answerspecs exist in answerlist_
  #assert_that(is_empty(setdiff(x=names(answerspecs),y=names(answerlist_))),msg = paste("Answer to question(s) <",toString(setdiff(x=names(answerspecs),y=names(answerlist))),"> not found (in file <",answerlist_filename,">).",sep = "") )
  all_answers_here = see_if(identical(names(answerspecs),names(answerlist_)),msg = paste("Mismatch between the list of saved answers (in file <",answerlist_filename,">, with questions <",toString(names(answerlist_)),">) and the questions <",toString(names(answerspecs)),"> specified in answerspec.",sep=""))
  if (!all_answers_here) warning(attr(all_answers_here,"msg"))
  # Check all indivdual question files:
  valid_answers = c()
  invalid_answers = c()
  valid_answer_files = c()
  for (quid in names(answerspecs)){
    # Check if question has been answered yet:
    if (is.element(quid,names(answerlist))==FALSE) {
      valid1 = FALSE
      valid2 = FALSE
      warning(paste("No answer for question <",quid,"> yet",sep=""))
    } else {
      # Check again if saved answer is formally valid - we warn but do not stop on error.
      msg_filepermission = paste("Answer file <",file.path(directory_path,answerlist[[quid]]$filename),"> does not exist.",sep="")
      msg_writeloadproblem = paste("Verification of saved answer from file  <",file.path(directory_path,answerlist[[quid]]$filename),"> failed.",sep="")
      valid1=see_if(file.exists(file.path(directory_path,answerlist[[quid]]$filename)),msg=msg_filepermission)
      if (!valid1) warning(attr(valid1,"msg"))
      if (answerlist[[quid]]$type!="file") {
        tmp_answer = readRDS(file = file.path(directory_path,answerlist[[quid]]$filename))
        valid2=see_if(identical(answerlist[[quid]]$answer,tmp_answer,ignore.environment = TRUE),msg=msg_writeloadproblem)
        if (!valid2) warning(attr(valid2,"msg"))
      }
    }
    if (all(valid1,valid2)) {
      valid_answer_files = c(valid_answer_files, answerlist[[quid]]$filename)
      valid_answers = c(valid_answers, quid)
    } else invalid_answers = c(invalid_answers, quid)
  }
  # compile a list of files to include
  submission_files = c(answerlist_filename,submission_includefiles,additional_files_to_include)
  valid_submission_files = valid_answer_files
  for (filename in submission_files) {
    assert_that(file.exists(file.path(directory_path,filename)),msg=paste("Could not access submission-required file <",filename,">.",sep=""))
    valid_submission_files = c(valid_submission_files, filename)
  }
  print(paste("Valid answer files have been found for question(s) <",toString(valid_answers),">.",sep=""))
  if (length(invalid_answers)>0) print(paste("!!! No valid answer (file) has been found for question(s) <",toString(invalid_answers),"> !!!",sep=""))
  if (length(invalid_answers)==0) success=TRUE
  else success=FALSE
  return_list = list(success=success, valid_submission_files=valid_submission_files, valid_answers=valid_answers, invalid_answers=invalid_answers)
  return(return_list)
}

submission_finalise <- function(prefix="submission", additional_files_to_include = c()){
  zip_filename = paste(prefix,"_task1_group",group_id,".zip",sep="")
  zip_fullpath <<- file.path(getwd(),zip_filename) 
  zip_url = file.path("file://",zip_fullpath) 
  save.image(file=workspace_filename)
  
  # Check submission and get files:
  check_result = submission_check(additional_files_to_include)
  if (check_result$success==TRUE) notify="" else notify="!!! Note that there were some invalid answers !!!"
  print(paste("The following files will be included in the submission: <",toString(check_result$valid_submission_files),">.",sep=""))
  
  
  # Pack submission files into a ZIP archive:
  zip(zipfile = zip_fullpath, files=check_result$valid_submission_files) # flags = "-r9X"
  
  # Calculate a hash for the ZIP archive:
  zip_sha256 <<- sha256(url(zip_url))
  
  # Notify user:
  message(paste("Submission packed into file <",zip_fullpath,">. \nSHA256 hash: ",zip_sha256," \nPlease submit this file and the provided hash code via blackboard.",notify,sep=""))
}


