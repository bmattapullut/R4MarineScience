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

## arrange() - alters the sorting configuration of rows within data frame without changing individial cell values
## essential for inspecting size hierarchies or chronologically ordering long-term environmental observation lines:

# Sort penguins by ascending body mass (Default setting: Smallest mass first)
lightest_first <- arrange(penguins, body_mass_g)

# Sort penguins in descending sequence using the desc() layout wrapper
heaviest_first <- arrange(penguins, desc(body_mass_g))

# Execute nested sorting criteria: Group by species, then sort by descending bill length
stratified_morphology <- arrange(penguins, species, desc(bill_length_mm))

### 1.7.4 Introducing the Pipe (|>)

# we have been performing data operations one step at a time
# this creates "intermediate" variables to hold the result of each stage
# this is good for clarity but it can quickly clutter your environment with objects like data_v1, data_v2

# pipe : a cleaner way to chain the operations together
# pipe acts a recipe for your data

#Without pipe
## You have to read the code "inside-out." You start in the middle, perform the mutate(), then wrap that in a filter(), and finally wrap that all in a select().

#With pipe
## You read from left to right, or top to bottom. You take your data, then you filter it, then you mutate it to create a new column, then you select the columns you need.
## easier to read, debug efficient

## syntax for pipe: |>
## pipe operator built in tidyverse package magrittr - %>%

# instead of 
penguins_subset <- mutate(penguins, bill_ratio = bill_length_mm / bill_depth_mm)
penguins_final <- filter(penguins_subset, species == "Adelie")

# you can use pipe 
penguins_final <- penguins |>
  mutate(bill_ratio = bill_length_mm / bill_depth_mm) |>
  filter(species == "Adelie")


### 1.7.5 Computing new attributes with mutate() ####

## calculate new variables based on ones that exist in our raw data
## this might be to scale observations, apply standard geometric conversions, or compute morphological ratios.
## In data wrangling we call this “mutating” a new variable
## mutate() - to modify existing attributes or append entirely new vectors to the data frame

# Calculate a new morphological ratio in our environment
penguin_ratios <- penguins  |> 
  mutate(body_mass_kg = body_mass_g / 1000,   # Convert grams to kilograms
         bill_ratio = bill_length_mm / bill_depth_mm  # Bill ratio
  )

# View your newly engineered variables appended to the far-right columns
glimpse(penguin_ratios)


## 1.8 Data aggregation and ecological summarisation ####

# To extract ecological stories (e.g., morphological traits by species/island), 
# we compress individual observations into population summary metrics:

# 1. group_by()  -> Creates hidden, virtual data buckets based on categories 
#                   without changing the physical appearance of the table.
# 2. summarise() -> Calculates statistical reductions for each virtual bucket 
#                   and collapses them into a brand-new summary tibble, if it is immediately used after group_by()

# Grouping our active memory penguins by species
grouped_penguins <- group_by(penguins, species)

# Notice that the table looks identical, but metadata notes 'Groups: species [3]'
print(grouped_penguins)

# Collapsing the buckets into explicit summary metrics
species_mass_summary <- summarise(grouped_penguins,
                                  mean_mass_g = mean(body_mass_g)
)

print(species_mass_summary)

# In console summary operation failed and returned entire column of NA values for certain groups
# WHY???
# Problem: Summary functions return NA for entire groups if a single row has an NA.
# Reason:  R's "Missing Value Trap" protects you from miscalculating incomplete data.
# Fix:     Use the magrittr pipe (%>%) and explicitly declare 'na.rm = TRUE' 
#          inside aggregation functions to safely drop missing cells.

# Overcoming the missing value trap using na.rm = TRUE
biological_signal <- penguins %>%
  group_by(species, sex) %>%
  summarise(
    sample_size = n(),                                     # Count total individuals per category
    mean_mass_g = mean(body_mass_g, na.rm = TRUE),         # Calculate mean ignoring missing cells
    sd_mass_g   = sd(body_mass_g, na.rm = TRUE)            # Standard deviation calculation
  )

print(biological_signal)

## Combining the verbs successfully compressed a long observational log into a tight, clean overview of sexual dimorphism and species variation across the study area

## 1.9 Integrating data grammar with visual diagnostics in qmd ####

###1.9.1 Wrangling and plotting in parallel ####

## this method is best used when You need to save the summary table (as a .csv or .rds file) for inclusion in your final report or to share with team members

#create a code chunk that follows the two tasks side by side: 1. 
#pipe the penguin data to group_by() and summarise() to calculate the mean body mass for each species and island. 
#pipe the penguin dataset into ggplot() to create boxplot of body_mass_g by species, with island variable mapped to facet_wrap()
  
  
  
### 1.9.2 Piping Directly to visualisation ####

## this method is best used when You are in the exploration phase, iterating through visualisations rapidly to find the most effective way to communicate your findings.


# Pipe directly from aggregation to plotting with error bars

mass_compare_plot <- penguins |>
  group_by(species, island) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    sd_mass = sd(body_mass_g, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) |>
  ggplot(aes(x = species, y = mean_mass, colour = island)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_mass - sd_mass, 
                    ymax = mean_mass + sd_mass), 
                width = 0.2) +
  labs(title = "Mean Body Mass by Species and Island",
       subtitle = "Error bars represent standard deviation",
       y = "Mean Body Mass (g)",
       x = "Species") +
  theme_minimal()

mass_compare_plot

# CHallenge
#  Experiment with swapping sd_mass (standard deviation) for standard error—you will need to divide your sd by the square root of n (sd / sqrt(n)).

#swap sd_mass (standard deviation) for standard error—you will need to divide your sd by the square root of n (sd / sqrt(n)).
  
mass_compare_plot <- penguins |>
  group_by(species, island) |>
  summarise(
    mean_mass = mean(body_mass_g, na.rm = TRUE),
    se_mass = sd(body_mass_g, na.rm = TRUE) / sqrt(n()),
    n = n(),
    .groups = "drop"
  ) |>
  ggplot(aes(x = species, y = mean_mass, colour = island)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_mass - se_mass, 
                    ymax = mean_mass + se_mass), 
                width = 0.2) +
  labs(title = "Mean Body Mass by Species and Island",
       subtitle = "Error bars represent standard error",
       y = "Mean Body Mass (g)",
       x = "Species") +
  theme_minimal()

mass_compare_plot
 
## 1.10 Saving, exporting and version milestones


# Create output directories if they do not exist:
if (!dir.exists("outputs/figures")) dir.create("outputs/figures") # folder for figs
if (!dir.exists("outputs/tables")) dir.create("outputs/tables") # folder for tables
if (!dir.exists("Rdata")) dir.create("Rdata") # folder for Rdata objects

# 1. Exporting our collapsed summary table as a universal flat text file
write_csv(biological_signal, "outputs/penguin_species_mass_summary.csv")

# 2. Saving our cleaned morphological cohort table as a native R binary file
saveRDS(clean_scientific_fields, "outputs/clean_penguin_morphology_cohort.rds")

ggsave("outputs/mass_compare_plot.png", 
       plot = mass_compare_plot, 
       width = 120, height = 120, 
       units = "mm", dpi = 300)
