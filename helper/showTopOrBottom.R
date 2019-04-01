
showTopOrBottom <- function(data, levelVar, performVar, reportStart, reportEnd, topOrBottom = "bottom") {

# =============================================================================
# load necessary libraries
# =============================================================================

	# packages needed for this program 
	packagesNeeded <- c(
		"dplyr" 	# to do basic data wrangling
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
		rank = quo(min(weeklyRank))
	} else if (topOrBottom == "top") {
		rank = quo(max(weeklyRank))
	}

	# determine reporting period
	rankPeriod = interval(reportStart, reportEnd)

	# compute number of weeks
	numWeeks <- difftime(reportEnd, reportStart, units = "weeks")

# =============================================================================
# process parameters: variables, top/bottom, rank period, number of elapsed weeks
# =============================================================================

	tableToShow <<-

		# restrict to ranking period
		filter(data, week %within% rankPeriod) %>% 	
		
		# compute avg val per level per week
		group_by(!!levelVar, week) %>% 
			summarise(avgVal = mean(!!performVar)) %>% ungroup() %>% 

		# compute rank decile rank per week, and whether top/bottom this week
		group_by(week) %>% 
			arrange(week, avgVal) %>% 
			mutate(
				weeklyRank = ntile(avgVal, 10), 
				topBottomThisWeek = (week == reportEnd & weeklyRank == !!rank),
				extremeRank = !!rank) %>%
			ungroup() %>%

		# count number of top/bottom decile rankings; determine whether top/bottom this week
		group_by(!!levelVar) %>% 
			filter(weeklyRank == extremeRank) %>% 
			summarise(
				numWeeksTopBottom = n(), 
				topBottomThisWeek = max(topBottomThisWeek)) %>%
			ungroup() %>% 

		# keep those who were top/bottom for all reporting weeks or all reporting weeks minus a few
		filter( 
			(numWeeksTopBottom == numWeeks) | 					# top/bottom for all reporting weeks
			((numWeeksTopBottom == numWeeks - wiggleRoom) & 	# or all but a few and top/bottom this week
				topBottomThisWeek == 1) 	
			) %>%
		arrange(desc(numWeeksTopBottom))

	# compute average during reporting period--both overall and by level
	avgVal <- data %>%
		filter(week %within% rankPeriod) %>% 
		mutate(avgValOverall = mean(!!performVar)) %>%
		group_by(!!levelVar) %>%
		summarise(
			avgValByInt = mean(!!performVar),
			avgValOverall = mean(avgValOverall)) %>%
		ungroup() %>%
		select(!!levelVar, avgValOverall, avgValByInt)		

	# add to the report table average overall and by interviewer for the reporting period
	tableToShow <<- tableToShow %>%
		left_join(avgVal)
		# TODO: Figure out how to specify quoted levelVar in by argument of left_join

}
