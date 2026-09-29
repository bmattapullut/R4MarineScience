install.packages("here")

#-------------------------#
# MB5370: Techniques in Marine Science 1
# R for Marine Science
# Brihatee Mattapullut
# 29 September 2026

#-------------------------#
#Workshop 01. Foundations of Data Science - Wrangling and Plotting ####

## 1.4 Ingesting data into R ####

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

## 1.5 Data frame architechtures: Tibbles vs legacy tables ####

# Force a modern tibble to degrade into a legacy base R data frame structure
benthic_cover_df <- as.data.frame(benthic_cover)

##comparing behavioural difference
## presentation of each structure is different

# Print the old-style dataframe structure to view
print(benthic_cover_df)
# And compare with tibble alternative
print(benthic_cover)

## 1.6 Wrangling out ecological signals using Palmer Penguins ####

# Install the data package (execute this command once in your console pane and then delete!)
# install.packages("palmerpenguins")

# Load the package data into active memory
library(palmerpenguins)
data("penguins")

# Examine the structure of the dataset - always do this when loading a new dataset!
glimpse(penguins) # tidyverse version (from dplyr package)
str(penguins) # base R version

## glimpse maps entire architechtural anatomy of dataset
## variable vectors types are listed within arrow markers:
## <fct> - factor - categorical groupings with fixed levels
## <dbl> - double - continuous numeric measurements containing decimals
## <int> - integer - whole number variables tracking counts

## conducting a statistical overview to map out missing observations and parameter boundaries

# Generate an exploratory summary matrix
summary(penguins)

## summary reports presence of explicit missing indicators (NA) within the individual biological metrics

## 1.7 Foundational grammar: Slicing, filtering, sorting and transforming ####

# dplyr package has a highly structured grammar of data manipulation build around intuitive action verbs
# every function has a standard design
# it  accepts an input data frame as its primary argument and outputs a cleanly modified tibble
# this section will have the foundational verbs required to shape tables manually

### 1.7.1 isolating attributes with select() ####

## Ecological data tables frequently collect duplicate logistics records that do not contribute to morphological or physiological questions
## select() allows you to slice your datasets vertically, isolating or dropping columns based on variable names:

# Vertically slice specific morphometric variables by explicit name
morphology_metrics <- select(penguins, species, bill_length_mm, bill_depth_mm, body_mass_g)
glimpse(morphology_metrics)

# Retain a continuous block of attributes using the colon operator
spatial_block <- select(penguins, species:island)

# Discard logistics tracking attributes while preserving everything else using the minus sign
clean_scientific_fields <- select(penguins, -year)

### 1.7.2 Sifting rows with filter() ####

## select() targets variables vertically
## filter() isolates records horizontally based on targetted conditional parameters
## every row is evaluated against your logical expressions
## entries evaluated to TRUE are retained
## entries that return FALSE or NA are dropped

# Isolate observations belonging to a single categorical target group
adelie_cohort <- filter(penguins, species == "Adelie")

# Sift out individuals using continuous numerical boundary thresholds
# Preserves only large penguins whose mass exceeds 4500 grams
heavy_penguins <- filter(penguins, body_mass_g > 4500)

# Combine multiple conditional parameters across separate attributes
# Preserves records matching Gentoo penguins sampled explicitly on Biscoe Island
biscoe_gentoo <- filter(penguins, species == "Gentoo" & island == "Biscoe")

# Sift records matching multiple targeting flags within an explicit set
sub_islands <- filter(penguins, island %in% c("Dream", "Torgersen"))

### 1.7.3 Ordering sequences with arrange() ####


