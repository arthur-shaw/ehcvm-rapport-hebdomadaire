currentBiggestChange <- function(
	data, 						# input data
	levelVar, 					# level of reporting (e.g., supervisor, interviewer)
	performVar, 				# indicator of performacnce (e.g., houshold size)
	reportEnd, 					# end date of reporting period
	topOrBottom = "bottom", 	# "bottom" = 1st decile of change, "top" = 10th decile
	colNames 					# text for column headers
	) {

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
		rank = quo(min(changeRank))
	} else if (topOrBottom == "top") {
		rank = quo(max(changeRank))
	}

	# determine reporting period
	rankPeriod = interval(reportEnd, reportEnd)

# =============================================================================
# process parameters: variables, top/bottom, rank period, number of elapsed weeks
# =============================================================================

	tableToShow <<- data %>%

		# compute avg val per level per week
		group_by(!!levelVar, week) %>% 
			summarise(avgVal = mean(!!performVar)) %>% ungroup() %>% 

		# compute change over previous week
		group_by(!!levelVar) %>% 
		arrange(week, .by_group = TRUE) %>%
		mutate(pct_change = (avgVal/lag(avgVal) - 1)*100) %>%
		ungroup() %>%

		# remove any observations where percent change cannot be computed
		filter(
			# any NaN from (0-0)/0
			!is.na(pct_change) & 
			# Inf from (someNum - 0)/0
			is.finite(pct_change)
			) %>%

		# rank changes for current week
		filter(week == reportEnd) %>%
		arrange(pct_change) %>%		
		mutate(changeRank = ntile(pct_change, 10)) %>%
		filter(changeRank == !!rank)

# =============================================================================
# create table
# =============================================================================

	if (nrow(tableToShow) > 0) {

		tableToShow %>% 
		select(!!levelVar, pct_change) %>%
			knitr::kable(
				digits = 2, 
				col.names = colNames,
				format.args = list(decimal.mark = '.', big.mark = ',')
				) %>%
			kable_styling(bootstrap_options = c("striped"))

	}

}
