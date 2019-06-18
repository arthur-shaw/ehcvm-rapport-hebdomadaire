
defineReportPeriod <- function(data, numWeeksBefore = 0, endDate = NA) {

# =============================================================================
# load necessary libraries
# =============================================================================

	# packages needed for this program 
	packagesNeeded <- c(
		"dplyr",	# to do basic data wrangling
		"lubridate" # to handle reporting dates and intervals
	)

	# identify and install those packages that are not already installed
	packagesToInstall <- packagesNeeded[!(packagesNeeded %in% installed.packages()[,"Package"])]
	if(length(packagesToInstall)) 
		install.packages(packagesToInstall, quiet = TRUE, 
			repos = 'https://cloud.r-project.org/', dep = TRUE)

	# load all needed packages
	lapply(packagesNeeded, library, character.only = TRUE)

# =============================================================================
# Compute first and last weeks in data set
# =============================================================================

	# compute the first and last weeks of data present in the data set
	firstWeek = min(data$date) %>% 
		floor_date( unit = "week", week_start = getOption("lubridate.week.start", 1))
	lastWeek = max(data$date) %>% 
		floor_date( unit = "week", week_start = getOption("lubridate.week.start", 1))

# =============================================================================
# Determine the start and end weeks for the report
# =============================================================================

	# if no end date specified, compute start as N weeks prior to last week in dset
	if (is.na(endDate)) {

		# end of report: last week for which there is data
		reportWeekEnd = lastWeek

		# start of report: N weeks prior to end
		calcStart = reportWeekEnd - weeks(numWeeksBefore)
		if (calcStart > firstWeek) {
			reportWeekStart = calcStart 					
		} else if (calcStart <= firstWeek) {
			reportWeekStart = firstWeek
		}		

	# if end date specified, compute start as N weeks prior to specified date
	} else if (!is.na(endDate)) {
		
		# end of report: week of provided end date
		reportWeekEnd = floor_date(endDate, unit = "week", 
			week_start = getOption("lubridate.week.start", 1))

		# but if specified report week comes later than week of last data point
		# then use the latter
		if (lastWeek < reportWeekEnd) {
			reportWeekEnd = lastWeek
		}
		
		# start of report: either N weeks prior to end, or first week--which if closer
		calcStart = reportWeekEnd - weeks(numWeeksBefore)
		if (calcStart > firstWeek) {
			reportWeekStart = calcStart 					
		} else if (calcStart <= firstWeek) {
			reportWeekStart = firstWeek
		}

	}

# =============================================================================
# Put computed dates into the global environment
# =============================================================================

	reportWeekStart <<- reportWeekStart
	reportWeekEnd <<- reportWeekEnd
	reportPeriod <<- interval(reportWeekStart, reportWeekEnd)

}
