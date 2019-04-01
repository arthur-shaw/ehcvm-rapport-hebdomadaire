
# =============================================================================
# Load necessary libraries
# =============================================================================

library(haven)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(viridis)
library(rlang)

# =============================================================================
# Prepare data
# =============================================================================

dataDir <- "C:/Users/wb393438/UEMOA/vague2/auto-sort/donnees/"

# -----------------------------------------------------------------------------
# Transform attributes from long to wide
# -----------------------------------------------------------------------------

attributesList <- read_stata(file = paste0(dataDir, "derivees/", "attributes.dta"))

attributesData <- 
	attributesList %>% select(interview__id, interview__key, attribName, attribVal) %>%
	spread(key = attribName, value = attribVal)

# -----------------------------------------------------------------------------
# Get interview metadata: date, interviewer, and supervisor
# -----------------------------------------------------------------------------

actions <- read_stata(file = paste0(dataDir, "fusionnees/", "interview__actions.dta"))

interviewInfo <- actions %>%			
	filter(action == 3) %>%			# filter to completed
	group_by(interview__id) %>% 	# group by interview
	slice(n()) %>% 					# take last action
	ungroup() %>%
	rename(interviewer = originator, supervisor = responsible__name) %>%
	mutate(
		date = as.Date(date),
		week = floor_date(ymd(date), unit = "week", week_start = getOption("lubridate.week.start", 1))
		) %>%
	select(interview__id, interviewer, supervisor, date, week)

# -----------------------------------------------------------------------------
# Join interview attributes and metadata
# -----------------------------------------------------------------------------

 reportData <- inner_join(x = attributesData, y = interviewInfo, by = "interview__id")

# -----------------------------------------------------------------------------
# Create variables that involve mutliple attributes
# -----------------------------------------------------------------------------

reportData <- reportData %>%
	mutate(
		# total non-food items
		numProdNonAlim = 
			numProdNonAlim_fetes	+
			numProdNonAlim_7j		+
			numProdNonAlim_30j		+
			numProdNonAlim_3m		+
			numProdNonAlim_6m		+
			numProdNonAlim_12m)

# -----------------------------------------------------------------------------
# Calories
# -----------------------------------------------------------------------------

caloriesByDate <- 
	read_stata(paste0(dataDir, "derivees/", "totCalories.dta"), encoding = "UTF-8") %>%
	inner_join(interviewInfo, by = "interview__id") %>%
	mutate(plotCalories = if_else(totCalories > 6000, 6000, totCalories)) %>%
	mutate(group = cut(totCalories, 
		breaks = c(-1, 800, 1500, 3000, 4000, Inf),
		labels = c("too low", "low", "OK", "high", "too high" ))) %>%
	select(interview__id, interview__key, supervisor, interviewer, date, week, 
		totCalories, plotCalories, group)

# =============================================================================
# Define reporting period
# =============================================================================

defineReportPeriod <- function(data, numWeeksBefore = 0, endDate = NA) {

	# dateVar <- enquo(dateVar)
	# dates <- enexpr(`$`(data, !!dateVar))

	# compute the first and last weeks of data present in the data set
	firstWeek = min(data$date) %>% 
		floor_date( unit = "week", week_start = getOption("lubridate.week.start", 1))
	lastWeek = max(data$date) %>% 
		floor_date( unit = "week", week_start = getOption("lubridate.week.start", 1))

	# determine the start and end weeks for the report

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
		
		# start of report: either N weeks prior to end, or first week--which if closer
		calcStart = reportWeekEnd - weeks(numWeeksBefore)
		if (calcStart > firstWeek) {
			reportWeekStart = calcStart 					
		} else if (calcStart <= firstWeek) {
			reportWeekStart = firstWeek
		}

	}

	reportWeekStart <<- reportWeekStart
	reportWeekEnd <<- reportWeekEnd
	reportPeriod <<- interval(reportWeekStart, reportWeekEnd)

}

# =============================================================================
# Graph time series of display variable for all teams
# =============================================================================

plotOverTimeTeam <- function(data, displayVar, reportStart, reportEnd, titleText, xText, yText) {

	library(rlang)
	library(lubridate)
	library(ggplot2)
	library(viridis)
	library(hrbrthemes)

	displayVar = rlang::enquo(displayVar)

	dataToGraph <- 
		data %>%
		filter(week %within% interval(reportStart, reportEnd)) %>% 
		group_by(supervisor, week) %>%
		summarise(avgVal = mean(!!displayVar)) %>%
		mutate(supervisor2 = supervisor) %>%
		ungroup()

	dataToGraph <<- dataToGraph

	# View(dataToGraph)

	ggplot(data = dataToGraph, aes(x=week, y=avgVal)) +
		geom_line( data= dataToGraph %>% select(-supervisor), aes(group=supervisor2), color="grey", size=0.5, alpha=0.5) +
		geom_line( aes(color=supervisor), color="#69b3a2", size=1.2 ) +
		scale_color_viridis(discrete = TRUE) +
		theme_ipsum() +
		theme(
			legend.position="none",
			plot.title = element_text(size=14),
			panel.grid = element_blank(),
			axis.text.x = element_text(angle = 90),
			strip.text.x = element_text(size = 10)
		) +
		ggtitle(titleText) +
		xlab(xText) +
		ylab(yText) +
		facet_wrap(~supervisor)	

}


# a few problems to detect and react to:
# Each group consists of only one observation. Do you need to adjust the group aesthetic?
	# filter out groups with no obs (at all--for example, plots in Dakar)
# define the period of the report
	# run date, looking back 4-6 weeks
# handle size of facet names, which I believe are called strip.text.x

# function should take a data set
	# there are some standard manipulations (e.g., group_by, summarise, mutate supervisor, etc.)
	# there are also some non-standard manipulations (e.g., sum up non-food items across categories)

# parameters
	# data set name
	# variable to averaged and displayed
	# graph title
	# graph period: either start/end or report date minus N number of weeks (where N might be user-specified)
	# some settings for WAEMU:
		# French date culture

# =============================================================================
# Create table of interviewers/teams with top/bottom values during reporting period
# =============================================================================

showTopOrBottom <- function(data, levelVar, performVar, reportStart, reportEnd, topOrBottom = "bottom", wiggleRoom = 1) {

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

	tableToShow <<-

		# restrict to reporting period
		filter(data, week %within% rankPeriod) %>% 	
		
		# compute avg val per interviewer per week
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

	# compute average calories during reporting period--both overall and by level
	avgVal <- data %>%
		filter(week %within% rankPeriod) %>% 
		mutate(avgValOverall = mean(!!performVar)) %>%
		group_by(!!levelVar) %>%
		summarise(
			avgValByInt = mean(!!performVar),
			avgValOverall = mean(avgValOverall)) %>%
		ungroup() %>%
		select(!!levelVar, avgValOverall, avgValByInt)		

	# add to the report table average calories overall and by interviewer for the reporting period
	tableToShow <<- tableToShow %>%
		left_join(avgVal)
		# TODO: Figure out how to specify quoted levelVar in by argument of left_join

}


# =============================================================================
# Set report dates
# =============================================================================

defineReportPeriod(data = reportData, numWeeksBefore = 3, endDate = ymd("2018-12-15"))

# =============================================================================
# Progrès de la collecte
# =============================================================================

# TODO: Fill in with Lena's programs


# =============================================================================
# Consommation
# =============================================================================

# -----------------------------------------------------------------------------
# Nombre d'items de consommation alimentaire
# -----------------------------------------------------------------------------

# graph
plotOverTimeTeam(data = reportData, displayVar = numProdAlim, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Nombre de produits alimentaires déclarés", xText = "Semaine de collecte", yText = "Nombre")

# worst enumerators
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = numProdAlim, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
print("Worst interviewers")
tableToShow

# -----------------------------------------------------------------------------
# Calories par personne par jour
# -----------------------------------------------------------------------------

# TODO: Consider making into function with the following parameters:
# Report period: start, end
# Labels: title, x label, y label
# Statistic to compute and show as line (e.g., median, mean)

caloriesForReport <- caloriesByDate %>%
	filter(week %within% interval(reportWeekStart, reportWeekEnd))

calSummary_Week <-
	caloriesForReport %>% 
	group_by(week) %>% 
	summarise(calStat_Week = median(totCalories)) %>% 
	ungroup()

caloriesOverTime < -
	ggplot(data = caloriesForReport, aes(x = week)) +
		geom_jitter(aes(x = week, y = plotCalories, color = group), 
			width = 0.5, height = 0.1, alpha = 0.4) + 
		scale_color_manual(values = c("red", "orange", "grey1", "orange", "red")) +
		geom_violin(width = 3.5, aes(x = week, y = plotCalories, group = factor(week)), 
			fill = "grey70", color = "grey50", alpha = 0.2) +
	geom_point(data = calSummary_Week, aes(x = week, y = calStat_Week), 
		size = 3, color = "red") + 
    geom_line(data = calSummary_Week, aes(x = week, y = calStat_Week), 
    	color = "red", size = 1.5) +    			
    theme(
        panel.background = element_rect(fill = "white"), 
        panel.grid.major = element_line(color = "grey"), 
        strip.background = element_rect(fill = "white"), 
        legend.position = "none") + 
    coord_cartesian(ylim = c(0, 6000)) +
    ylab("Calories per capita")

# trop de calories
showTopOrBottom(data = caloriesForReport, levelVar = interviewer, performVar = totCalories, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "top", wiggleRoom = 1)
print("Enquêteurs avec trop de calories le plus souvent")
tableToShow

# trop peu de calories
showTopOrBottom(data = caloriesForReport, levelVar = interviewer, performVar = totCalories, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
print("Enquêteurs avec trop peu de calories excessives le plus souvent")
tableToShow

# -----------------------------------------------------------------------------
# Number of non-food items
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = numProdNonAlim, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Nombre de produits non-alimentaires déclarés", xText = "Semaine de collecte", yText = "Nombre")

# worst enumerators
showTopOrBottom(data = caloriesByDate, levelVar = interviewer, performVar = numProdNonAlim, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow


# =============================================================================
# Composition du ménage
# =============================================================================

# -----------------------------------------------------------------------------
# Taille du ménage
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = numMembres, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Taille du ménage", xText = "Semaine de collecte", yText = "Nombre")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = numMembres, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# -----------------------------------------------------------------------------
# Pourcentage de membres sous l'âge de 5
# -----------------------------------------------------------------------------

percSous5 <- reportData %>%
	mutate(percSous5 = 100 * (numMemSous5 / numMembres))

# graphique
plotOverTimeTeam(data = percSous5, displayVar = percSous5, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Pourcentage du ménage sous l'âge de 5", xText = "Semaine de collecte", yText = "Pourcentage")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = percSous5, levelVar = interviewer, performVar = percSous5, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# =============================================================================
# Sources de revenu
# =============================================================================

# -----------------------------------------------------------------------------
# Pourcentage avec un salaire
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = revenuEmploi, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Pourcentage avec au moins un salairé", xText = "Semaine de collecte", yText = "Pourcentage")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = revenuEmploi, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# -----------------------------------------------------------------------------
# Nombre d'entreprises non-agricoles
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = numEntreprises, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Nombre d'entreprises non-agricoles", xText = "Semaine de collecte", yText = "Nombre")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = numEntreprises, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# -----------------------------------------------------------------------------
# Pratique l'agriculture
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = pratiqueAgriculture, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Pratique l'agriculture", xText = "Semaine de collecte", yText = "Pourcentage")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = pratiqueAgriculture, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# -----------------------------------------------------------------------------
# Pratique l'élevage
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = pratiqueElevage, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Pratique l'élevage", xText = "Semaine de collecte", yText = "Pourcentage")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = pratiqueElevage, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow

# -----------------------------------------------------------------------------
# Pratique la pêche
# -----------------------------------------------------------------------------

# graphique
plotOverTimeTeam(data = reportData, displayVar = pratiquePeche, reportStart = reportWeekStart, reportEnd = reportWeekEnd,
	titleText = "Pratique la pêche", xText = "Semaine de collecte", yText = "Pourcentage")

# enquêteurs avec la plus petite taille
showTopOrBottom(data = reportData, levelVar = interviewer, performVar = pratiquePeche, reportStart = reportWeekStart, reportEnd = reportWeekEnd, topOrBottom = "bottom", wiggleRoom = 1)
tableToShow
