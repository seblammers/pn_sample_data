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

gait_01 <- here("data", "gait_01.calc") %>% read_calc() %>% select(contains("_x_"))

gait_02 <- here("data", "gait_02.calc") %>% read_calc()

gait_01_renamed <- gait_01 %>% 
  #Rename variabels
  #Switch Z and Y axis
  transmute(
    "RHX" = right_upleg_x_x,
    "RHZ" = right_upleg_x_y,
    "RHY" = right_upleg_x_z*-1,
    "RKX" = right_leg_x_x,
    "RKZ" = right_leg_x_y,
    "RKY" = right_leg_x_z*-1,
    "RAX" = right_foot_x_x,
    "RAZ" = right_foot_x_y,
    "RAY" = right_foot_x_z*-1,
    "RSX" = right_shoulder_x_x,
    "RSZ" = right_shoulder_x_y,
    "RSY" = right_shoulder_x_z*-1,
    "REX" = (right_forearm_x_x    + right_arm_x_x)/2, #An attempt to create the elbow joint center by averaging the forearm and arm coordinates
    "REZ" = (right_forearm_x_y    + right_arm_x_y)/2,
    "REY" = (right_forearm_x_z*-1 + right_arm_x_z*-1)/2,
    "RWX" = right_hand_x_x,
    "RWZ" = right_hand_x_y,
    "RWY" = right_hand_x_z*-1,
    "LHX" = left_upleg_x_x,
    "LHZ" = left_upleg_x_y,
    "LHY" = left_upleg_x_z*-1,
    "LKX" = left_leg_x_x,
    "LKZ" = left_leg_x_y,
    "LKY" = left_leg_x_z*-1,
    "LAX" = left_foot_x_x,
    "LAZ" = left_foot_x_y,
    "LAY" = left_foot_x_z*-1,
    "LSX" = left_shoulder_x_x, 
    "LSZ" = left_shoulder_x_y,
    "LSY" = left_shoulder_x_z*-1,
    "LEX" = (left_forearm_x_x    + left_arm_x_x)/2, #An attempt to create the elbow joint center by averaging the forearm and arm coordinates
    "LEZ" = (left_forearm_x_y    + left_arm_x_y)/2,
    "LEY" = (left_forearm_x_z*-1 + left_arm_x_z*-1)/2,
    "LWX" = left_hand_x_x,
    "LWZ" = left_hand_x_y,
    "LWY" = left_hand_x_z*-1,
    "HAX" = hips_x_x,
    "HAZ" = hips_x_y,
    "HAY" = hips_x_z*-1) %>% 
  
  #Create coordinates for the toes (just made them equal to ankle coordinates)
  mutate(
    RTX = RAX,
    RTY = RAY,
    RTZ = RAZ,
    LTX = LAX,
    LTY = LAY,
    LTZ = LAZ,
    frame = row_number())

library(mocapr)
gait_01_renamed %>% 
  #Downsample data
  filter(row_number() %% 5 == 0) %>%
  filter(row_number() < 60) %>% 
  animate_global(nframes = nrow(.))


gait_01_renamed %>% 
  #Downsample data
  filter(row_number() %% 5 == 0) %>%
  filter(row_number() < 60) %>% 
  project_full_body_to_MP() %>% 
  animate_movement(nframes = nrow(.))


gait_01_renamed %>% 
  #Downsample data
  filter(row_number() %% 5 == 0) %>%
  filter(row_number() < 60) %>% 
  project_full_body_to_AP() %>% 
  animate_anatomical(nframes = nrow(.))
#This results is rotation too much because the hip joints are really mid-thigh points

