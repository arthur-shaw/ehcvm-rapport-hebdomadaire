# =============================================================================
# !!! FOR TESTING - DELETE AFTERWARD !!!
# =============================================================================

hholdDta 	<- "QM_UEMOA_GuineeBissauTerE1Vag1.dta"

# =============================================================================
# set project parameters
# =============================================================================

# specify root folders for reject and report projects

rejectProjDir <- "C:/Users/wb393438/UEMOA/vague2/auto-sort/"
reportProjDir <- "C:/Users/wb393438/UEMOA/vague2/hq-report/"

# specify report parameters

reportTitle 	<- "YOUR TITLE HERE"
reportSubTitle 	<- "YOUR SUBTITLE HERE"
reportWeek 		<- NA 					# report date: ymd("YYYY-MM-DD")
numWeeks 		<- 12 					# number of weeks to cover

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
# check setup
# =============================================================================

# TODO: confirm that folders exist
# rejectProjDir
# reportProjDir
# rawDir

# TODO: confirm that files exist
# paste0(constructedDir, "attributes.dta")
# paste0(rawDir, "interview__actions.dta")
# paste0(rawDir, hholdDta)
# paste0(constructedDir, "totCalories.dta")
# paste0(rawDir, "interview__comments.dta")

# =============================================================================
# Generate report
# =============================================================================

# load folder definitions from auto-sort program
source(paste0(rejectProjDir, "/programmes/filePaths.R"))

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
