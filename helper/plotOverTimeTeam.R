	
plotOverTimeTeam <- function(
	data, 
	displayVar, 
	outputPath = NA, 
	reportStart, 
	reportEnd, 
	reportScope = NA,
	titleText = waiver(),
	captionText = waiver(),  
	xText = waiver(), 
	yText = waiver()
	) {

# =============================================================================
# load necessary libraries
# =============================================================================

	# packages needed for this program 
	packagesNeeded <- c(
		"rlang", 	# to support tidy eval for functions
		"dplyr",	# to do basic data wrangling
		"lubridate", # to handle reporting dates and intervals
		"ggplot2",	# to graph plots
		"hrbrthemes", # to have a clean graph theme
		"viridis", 	# to have color-blind-friendly colors
		"haven" 	# to save figure data to Stata format
	)

	# identify and install those packages that are not already installed
	packagesToInstall <- packagesNeeded[!(packagesNeeded %in% installed.packages()[,"Package"])]
	if(length(packagesToInstall)) 
		install.packages(packagesToInstall, quiet = TRUE, 
			repos = 'https://cloud.r-project.org/', dep = TRUE)

	# load all needed packages
	lapply(packagesNeeded, library, character.only = TRUE)

# =============================================================================
# Prepare data to graph
# =============================================================================

	# filter data set to user-defined scope, if scope provided
	scope = enexpr(reportScope)
	if (!is_bare_atomic(scope)) {

		data <- data %>%
			filter(!!scope)

	}	

	# compute graph values for variable values to display
	displayVar = rlang::enquo(displayVar)

	dataToGraph <- data %>%
		# filter to report period
		filter(week %within% interval(reportStart, reportEnd)) %>% 
		# compute average over supervisor-week 
		group_by(supervisor, week) %>%
		summarise(avgVal = mean(!!displayVar, na.rm = TRUE)) %>%
		mutate(supervisor2 = supervisor) %>%
		ungroup()

# =============================================================================
# Export graph data
# =============================================================================

	if (!is.na(outputPath)) {

		dataToGraph %>%
		select(supervisor, avgVal, week) %>%
		write_dta(path = outputPath, version = stataVersion)
		
	}

# =============================================================================
# Create plots
# =============================================================================

	# compute how many weeks the data covers
	numWeeksCovered <- dataToGraph %>%
		distinct(week) %>%
		nrow()

	# plot a bar chart for 1 week
	if (numWeeksCovered == 1) {

		# create graph data
		dataToGraph <- dataToGraph %>%
		arrange(avgVal) %>%
	    mutate(
	    	rank = row_number(),
	    	supervisor = factor(rank, labels = supervisor))

	    # compute overall median (from interview-level data)
	    overallAvg <- data %>% summarize(overallMed = mean(!!displayVar, na.rm = TRUE)) %>% as.numeric()

		ggplot(data = dataToGraph, aes(x = supervisor, y = avgVal)) +
			# lollipops for supervisor levels
			geom_segment( aes(x = supervisor, xend = supervisor, y = 0, yend = avgVal)) +
			geom_point(size = 3, color = "#69b3a2") +
			coord_flip() +
			# median of levels
			geom_hline(yintercept = overallAvg, color = "red") +			
			theme_ipsum() +
	    theme(
	      panel.grid.minor.y = element_blank(),
	      panel.grid.major.y = element_blank(),
	      legend.position="none"
	    ) +
	    xlab(xText) +
	    ylab(yText)			

	# plot a line graph for more than 1 week
	} else if (numWeeksCovered > 1) {

		# identify last week of data for each supervisor
		dataToAnnotate = dataToGraph %>%
			group_by(supervisor) %>%
			filter(week == max(week)) %>%
			ungroup()

		ggplot(data = dataToGraph, aes(x=week, y=avgVal)) +
			# sketch lines for all supervisors as background grey
			geom_line( data= dataToGraph %>% select(-supervisor), 
				aes(group=supervisor2), color="grey", size=0.5, alpha=0.5) +
			# sketch line for current supervisor in separate color
			geom_line( aes(color=supervisor), color="#69b3a2", size=1.2 ) +
			# plot points for observations
			geom_point( aes(color=supervisor), color="#69b3a2", size=1.5 ) +
			# show values of last weeks as text 
			geom_text(data = dataToAnnotate, 
				aes(color=supervisor, label = round(avgVal, digits = 1)), 
				color="#183d38", fontface = "bold",
				# put text above points
				nudge_y = (max(dataToGraph$avgVal, na.rm = TRUE) - min(dataToGraph$avgVal, na.rm = TRUE))*0.2, size = 4,
				# move points on vertical and horizontal borders inward
				vjust="inward", hjust="inward"
				) +
			scale_color_viridis(discrete = TRUE) +
			theme(
				legend.position="none",
				plot.title = element_text(size=14),
				panel.background = element_rect(fill = "white"), 
				strip.background = element_rect(fill = "white"), 
				panel.grid = element_blank(),
				axis.text.x = element_text(angle = 90),
				strip.text.x = element_text(size = 10)
			) +
			labs(title = titleText, caption = captionText) +
			xlab(xText) +
			ylab(yText) +
			facet_wrap(~supervisor)	

	}

}
