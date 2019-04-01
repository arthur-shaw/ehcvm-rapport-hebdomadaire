
library(dplyr)
library(haven)
library(lubridate)

dataDir <- "C:/Users/wb393438/UEMOA/vague2/auto-sort/donnees/fusionnees/"

rejectActions <- c(7, 8)

rejectStats <- 
	read_stata(paste0(dataDir, "interview__actions.dta"), encoding = "UTF-8") %>%
	mutate(
		date = as.Date(date),
		week = floor_date(ymd(date), unit = "week", 
			week_start = getOption("lubridate.week.start", 1)),
		hqRejected = (
			(action %in% rejectActions) & 
			(role %in% c("Administrator", "Headquarter"))),
		hqAutoRejected = (originator == "admin")) %>%
	group_by(supervisor, week) %>%
	summarise(
		numRejected = sum(hqRejected),
		numAutoRejected = sum(hqAutoRejected) 
		) %>%
	ungroup()


 rejectStatsSup <- 
 	actions %>%
 	left_join(
 		interviewInfo %>% select(interview__id, interviewer, supervisor), 
 		by = "interview__id") %>%
 	mutate(
		date = as.Date(date),
		week = floor_date(ymd(date), unit = "week", 
			week_start = getOption("lubridate.week.start", 1)),
		hqRejected = (
			(action %in% rejectAction) & 
			(role %in% c("Administrator", "Headquarter"))),
		hqAutoRejected = (originator == "admin")) %>%
	group_by(supervisor, week) %>%
	summarise(
		numRejected = sum(hqRejected),
		numAutoRejected = sum(hqAutoRejected) 
		) %>%
	ungroup()	

rejectStatsInt <- 
 	actions %>%
 	left_join(
 		interviewInfo %>% select(interview__id, interviewer, supervisor), 
 		by = "interview__id") %>%
 	mutate(
		date = as.Date(date),
		week = floor_date(ymd(date), unit = "week", 
			week_start = getOption("lubridate.week.start", 1)),
		hqRejected = (
			(action %in% rejectAction) & 
			(role %in% c("Administrator", "Headquarter"))),
		hqAutoRejected = (originator == "admin")) %>%
	group_by(interviewer, week) %>%
	summarise(
		numRejected = sum(hqRejected),
		numAutoRejected = sum(hqAutoRejected) 
		) %>%
	ungroup()	

rmarkdown::render(
	input = "C:/Users/wb393438/UEMOA/vague2/hq-report/rapport_hebdomadaire_EHCVM.Rmd", 
	output_file = "test.html", 
	output_dir = "C:/Users/wb393438/UEMOA/vague2/hq-report/", 
	encoding = "UTF-8")

rejects

library(stringr)

rejectMessages <- 
	read_stata(paste0(dataDir, "interview__comments.dta"), encoding = "UTF-8") %>%
	
	# find rejections
	filter((variable %in% c("@@RejectedBySupervisor", "@@RejectedByHeadquarter")) & 
		(role %in% c("Administrator", "Headquarter"))) %>%
	
	# keep those that have components of an auto-reject message
	filter(str_detect(comment, "ERRO[R]*: |\\\\n")) %>%

	# 
    mutate(
        date = as.Date(date, format = "%m/%d/%Y"),
        week = floor_date(ymd(date), unit = "week", 
                          week_start = getOption("lubridate.week.start", 1)))

library(tidyr)

nullComments <- c('', '"', '" ', '[WebInterviewUI:CommentYours]', '[WebInterviewUI:CommentYours', '[WebInterviewUI:CommentYours"')

rejectReasonStats <- 
    rejectMessages %>% 
    
    # remove undesirable content from rejection messages
  	mutate(														
  		comment = str_replace(comment, '^"[ ]*', ""),			# starting quote
  		comment = str_replace(comment, '[ ]*"$', ''),			# ending quote
  		comment = str_replace(comment, 							# ending strange content
  			"\\[WebInterviewUI:CommentYours[\\]]*$", ""),
  		comment = str_replace(comment,
  			"^[\\[]*WebInterviewUI:CommentYours\\] ", ""),		# starting strange content
  		comment = str_replace(comment, "Your comment ", ""),	# more starting strange content
  		comment = str_trim(comment, side = "both"), 			# whitespace padding
  		comment = str_replace(comment, "\\.$", ""), 			# terminal .
  		comment = str_replace(comment, "\\\\n[ \\.]*$", "") 	# terminal \n
  		) %>%

    # expand reject message observations into reject reason observations
    separate_rows(comment, sep = " \\\\n ")	%>% # doesn't work when sep = " \\n "

    # determine week from date
    mutate(
        date = as.Date(date, format = "%m/%d/%Y"),
        week = floor_date(ymd(date), unit = "week", 
                          week_start = getOption("lubridate.week.start", 1))) %>%

    # create counts per week
    group_by(comment, week) %>%
    summarise(numReason = n())

