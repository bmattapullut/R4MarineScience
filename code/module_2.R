install.packages("here")

#-------------------------#
# MB5370: Techniques in Marine Science 1
# R for Marine Science
# Brihatee Mattapullut
# 29 September 2026

#-------------------------#
#Workshop 01. Foundations of Data Science - Wrangling and Plotting ####

# Load the primary data science framework and Excel import library
library(tidyverse)
library(readxl)

# Practice Import A: Loading a standard comma-separated plain text file
benthic_cover <- read_csv(here::here("data/workshop1/reef_cover_log.csv"))

# Practice Import B: Parsing a tab-separated telemetry instrument array string
acoustic_stream <- read_tsv(here::here("data/workshop1/acoustic_telemetry_stream.txt"))

# Practice Import C: Targeting a specific sheet in a multi-tab Excel spreadsheet
fisheries_annual <- read_excel(here::here("data/workshop1/fish_catch_data.xlsx"), sheet = "Commercial_2026")

# Read in mangrove_data
mangrove_data <- read_csv(file = here::here("data/workshop1/mangrove_survey_raw.csv"))

# Use args within read_csv to skip headers and declare missing flags
mangrove_data <- read_csv(
  here::here("data/workshop1/mangrove_survey_raw.csv"),
  skip = 5,   # Skip the first 5 lines of field notes
  na = c(".", "NA", "9999", "ND", "blank"))  # Convert known text alts to true NA
