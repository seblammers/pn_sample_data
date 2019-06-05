
# load packages -----------------------------------------------------------

library(here)
library(tidyverse)
library(janitor)


# define functions --------------------------------------------------------

numbers_to_strings <- function (dat){
  # replace the numbers in variable-names with their respective string,
  # according to the axis neuron manual (p. 80)
  
  # structure based on janitor::clean_names()
  
  old_names <- names(dat)
  new_names <- old_names %>%
    gsub("01", "hips", .) %>%
    gsub("02", "right_upleg", .) %>%
    gsub("03", "right_leg", .) %>%
    gsub("04", "right_foot", .) %>%
    gsub("05", "left_upleg", .) %>%
    gsub("06", "left_leg", .) %>%
    gsub("07", "left_foot", .) %>%
    gsub("08", "right_shoulder", .) %>%
    gsub("09", "right_arm", .) %>%
    gsub("10", "right_forearm", .) %>%
    gsub("11", "right_hand", .) %>%
    gsub("12", "left_shoulder", .) %>%
    gsub("13", "left_arm", .) %>%
    gsub("14", "left_forearm", .) %>%
    gsub("15", "left_hand", .) %>%
    gsub("16", "head", .) %>%
    gsub("17", "neck", .) %>%
    gsub("18", "spine_3", .) %>%
    gsub("19", "spine_2", .) %>%
    gsub("20", "spine_1", .) %>%
    gsub("21", "spine", .) %>%
    make.names(.)
  
  dupe_count <- vapply(seq_along(new_names), function(i) {
    sum(new_names[i] == new_names[1:i])
  }, integer(1))
  new_names[dupe_count > 1] <- paste(new_names[dupe_count >
                                                 1], dupe_count[dupe_count > 1], sep = "_")
  stats::setNames(dat, new_names)
}

read_calc <- function(path_to_file) {
  # this function takes a calc-file as input and returns a clean tibble
  # empty columns are removed and variable names are cleaned
  # a new column for the frame-number is added
  
  readr::read_delim(path_to_file,
                    "\t",
                    escape_double = FALSE, trim_ws = TRUE,
                    skip = 5
  ) %>%
    
    # delete entries for bones >= 22; these correspond to the fingers which were not
    # measured in our project; see also Axis Neuron Reference Manual, p. 80;
    dplyr::select(1:336) %>%
    
    # remove values for Quanternions
    dplyr::select(-dplyr::contains("Q")) %>%
    janitor::remove_empty("cols") %>%
    
    # convert given variable-names to human-/machine-friendly names
    numbers_to_strings() %>%
    janitor::clean_names() %>%
    
    # create new column with frame-number
    dplyr::mutate(frame = seq(from = 1, to = nrow(.))) %>%
    
    # put it in the front
    dplyr::select(frame, dplyr::everything())
}


# import sample data ------------------------------------------------------

gait_01 <- here("data", "gait_01.calc") %>% read_calc()

gait_02 <- here("data", "gait_02.calc") %>% read_calc()


