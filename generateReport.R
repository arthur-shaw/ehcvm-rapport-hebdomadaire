# =============================================================================
# set project parameters
# =============================================================================

# specify root folders for reject and report projects

rejectProjDir 	= ""
reportProjDir 	= ""

# report title and subtitle

reportTitle 	= "YOUR TITLE HERE"
reportSubTitle 	= "YOUR SUBTITLE HERE"

# report period

reportWeek 		= NA 	# end date; follow format ymd("YYYY-MM-DD")
numWeeks 		= 12 	# number of weeks to cover

# sample design

expectedSample 			= NA
numPsuExpected 			= NA
numIntExpectedPerPsu 	= NA

# =============================================================================
# load necessary libraries
# =============================================================================

# packages needed for this program 
packagesNeeded <- c(
	"lubridate",	# to set report date as a function of system date
	"rmarkdown" 	# to generate report
)

# identify and install those packages that are not already installed
packagesToInstall <- packagesNeeded[!(packagesNeeded %in% installed.packages()[,"Package"])]
if(length(packagesToInstall)) 
	install.packages(packagesToInstall, quiet = TRUE, 
		repos = 'https://cloud.r-project.org/', dep = TRUE)

# load all needed packages
lapply(packagesNeeded, library, character.only = TRUE)

# =============================================================================
# load file paths from auto-sort program
# =============================================================================

# confirm that filePaths.R exists
if (!file.exists(paste0(rejectProjDir, "/programmes/filePaths.R"))) {
	stop("File that contains file paths for data, filePaths.R, is missing")
}

# load folder definitions from auto-sort program
source(paste0(rejectProjDir, "/programmes/filePaths.R"))

# =============================================================================
# check setup
# =============================================================================

# parameters provided
for (x in c("expectedSample", "numPsuExpected", "numIntExpectedPerPsu")) {
	if (!exists(x)) {
		stop(paste0("Expected paramter not found: ", x))
	}
}

# folders exist
for (x in c("rejectProjDir", "reportProjDir", "rawDir")) {
	if (!exists(x)) {
		stop(paste0("Expected folder not found: ", x))
	}
}

# raw data files exist
for (x in c("attributes.dta", "totCalories.dta")) {

	# construct full path
	fullPath <- paste0(constructedDir, x)

	# check whether file exists at path
	if (!file.exists(fullPath)) {
		stop(paste0("Expected file not found: ", x))
	}

}

# constructed data files exist
for (x in c("menage.dta", "interview__actions.dta", "interview__comments.dta")) {

	# construct full path
	fullPath <- paste0(rawDir, x)

	# check whether file exists at path
	if (!file.exists(fullPath)) {
		stop(paste0("Expected file not found: ", x))
	}

}

# =============================================================================
# Generate report
# =============================================================================

# define report date as Monday of week containing system date
if (is.na(reportWeek)) {
	reportWeek 	<- floor_date(ymd(Sys.Date()),
		 unit = "week", 
		 week_start = getOption("lubridate.week.start", 1))
}

# generate the report
rmarkdown::render(
	input = 		paste0(reportProjDir, "rapport_hebdomadaire_EHCVM.Rmd"), 
	output_dir = 	paste0(reportProjDir), 
	output_file = 	paste0("rapport-", reportWeek, ".html"), 
	encoding = "UTF-8")
