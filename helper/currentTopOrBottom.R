
currentTopOrBottom <- function(
	data, 						# data frame used for the table
	levelVar, 					# variable that defines level of reporting (e.g., interviewer, supervisor)
	performVar, 				# variable whose values will be measured in the table
	reportStart, 				# week when report starts
	reportEnd, 					# week when report ends
	reportScope = NA, 			# logical expression describing observations over which report produced
	topOrBottom = "bottom", 	# whether performers in top or bottom of distribution should be shown
	colNames 					# text for column headers
	) {

# =============================================================================
# load necessary libraries
# =============================================================================

	# packages needed for this program 
	packagesNeeded <- c(
		"dplyr", 	# to do basic data wrangling
		"lubridate" # to parse dates and elapsed time
	)

	# identify and install those packages that are not already installed
	packagesToInstall <- packagesNeeded[!(packagesNeeded %in% installed.packages()[,"Package"])]
	if(length(packagesToInstall)) 
		install.packages(packagesToInstall, quiet = TRUE, 
			repos = 'https://cloud.r-project.org/', dep = TRUE)

	# load all needed packages
	lapply(packagesNeeded, library, character.only = TRUE)

# =============================================================================
# process parameters: variables, top/bottom, rank period, number of elapsed weeks
# =============================================================================

	levelVar <- enquo(levelVar)
	performVar <- enquo(performVar)

	# look at either top or bottom 10%
	if (topOrBottom == "bottom") {
		rank = quo(min(weeklyRank, na.rm = TRUE))
	} else if (topOrBottom == "top") {
		rank = quo(max(weeklyRank, na.rm = TRUE))
	}

	# filter data set to user-defined scope, if scope provided
	scope = enexpr(reportScope)
	if (!is_bare_atomic(scope)) {

		data <- data %>%
			filter(!!scope)

	}

	# determine reporting period
	rankPeriod = interval(reportStart, reportEnd)

# =============================================================================
# create table
# =============================================================================


	# rank interviewers into deciles each week
	rankByWeek <- 
		data %>%
		filter(week %within% rankPeriod) %>%
		group_by(!!levelVar, week) %>% 
			summarise(currentVal = mean(!!performVar, na.rm = TRUE)) %>% ungroup() %>% 
		group_by(week) %>%
		arrange(week, currentVal) %>%
		mutate(
			weeklyRank = ntile(currentVal, 10), 
			topBottomThisWeek = (week == reportEnd & weeklyRank == !!rank),
			extremeRank = !!rank) %>%
		ungroup()

	# take the top/bottom decile for the current week
	currentExtreme <- rankByWeek %>% 
		filter(topBottomThisWeek == 1) %>%
		select(!!levelVar, currentVal)

	# count number of total weeks that the current top/bottom have been top/bottom
	numWeeksOnTopBottom <- currentExtreme %>%
		select(!!levelVar) %>%
		left_join(rankByWeek) %>% 	# TODO: figure out how to merge by quoted variable
		filter(weeklyRank == extremeRank) %>%
		group_by(!!levelVar) %>%
		summarise(numWeeks = n()) %>%
		ungroup() %>%
		select(!!levelVar, numWeeks)

	avgVals <- data %>%
		filter(week %within% rankPeriod) %>% 
		mutate(avgValOverall = mean(!!performVar, na.rm = TRUE)) %>%
		group_by(!!levelVar) %>%
		summarise(
			avgValInt = mean(!!performVar, na.rm = TRUE),
			avgValOverall = mean(avgValOverall, na.rm = TRUE)) %>%
		ungroup() %>%
		select(!!levelVar, avgValInt, avgValOverall)	

	# 
	tableToShow <<- 
		currentExtreme %>%
		left_join(numWeeksOnTopBottom) %>% 	# TODO: figure out how to merge by quoted variable
		left_join(avgVals) %>%
		mutate(diffAvgValOverall = currentVal - avgValOverall) %>%
		select(!!levelVar, currentVal, avgValInt, diffAvgValOverall, numWeeks) %>%
		arrange(currentVal, numWeeks)

	tableToShow %>%
	arrange(desc(currentVal), numWeeks) %>%
	knitr::kable(
		digits = 2, 
		col.names = colNames,
		format.args = list(decimal.mark = '.', big.mark = ',')
		) %>%
	kable_styling(bootstrap_options = c("striped"))	

}
