library(here)
library(tidyverse)
#library(RMoCap) #install from GitHub
library(mocapr)


# Sebastians gait file
bvh_data <- RMoCap::read.bvh(here("data", "gait_01.bvh"))
bvh_data_df <- RMoCap::bvh.to.df(bvh_data, sd = FALSE) 


#Wrangle data into format that mocapr can work with

data_to_animate <- bvh_data_df %>% 
  #Rename variabels
  #Switch Z and Y axis
  rename(
    "time_seconds" = "Time",
    "RHX" = RightUpLeg.Dx,
    "RHZ" = RightUpLeg.Dz,
    "RHY" = RightUpLeg.Dy,
    "RKX" = RightLeg.Dx,
    "RKZ" = RightLeg.Dz,
    "RKY" = RightLeg.Dy,
    "RAX" = RightFoot.Dx,
    "RAZ" = RightFoot.Dz,
    "RAY" = RightFoot.Dy,
    "RTX" = EndSite5.Dx,
    "RTY" = EndSite5.Dy,
    "RTZ" = EndSite5.Dz,
    "RSX" = RightArm.Dx,  
    "RSZ" = RightArm.Dz,  
    "RSY" = RightArm.Dy,  
    "REX" = RightForeArm.Dx,  
    "REZ" = RightForeArm.Dz, 
    "REY" = RightForeArm.Dy, 
    "RWX" = RightHand.Dx,
    "RWZ" = RightHand.Dz,
    "RWY" = RightHand.Dy,
    "LHX" = LeftUpLeg.Dx,
    "LHZ" = LeftUpLeg.Dz,
    "LHY" = LeftUpLeg.Dy,
    "LKX" = LeftLeg.Dx,
    "LKZ" = LeftLeg.Dz,
    "LKY" = LeftLeg.Dy,
    "LAX" = LeftFoot.Dx,
    "LAZ" = LeftFoot.Dz,
    "LAY" = LeftFoot.Dy,
    "LSX" = LeftArm.Dx,    
    "LSZ" = LeftArm.Dz,    
    "LSY" = LeftArm.Dy,    
    "LEX" = LeftForeArm.Dx,
    "LEZ" = LeftForeArm.Dz,
    "LEY" = LeftForeArm.Dy,
    "LWX" = LeftHand.Dx,
    "LWZ" = LeftHand.Dz,
    "LWY" = LeftHand.Dy,
    "LTX" = EndSite9.Dx,
    "LTY" = EndSite9.Dy,
    "LTZ" = EndSite9.Dz,
    "HAX" = Hips.Dx,
    "HAZ" = Hips.Dz,
    "HAY" = Hips.Dy) %>% 
  mutate(
    frame = row_number())


data_to_animate %>% 
  #Downsample data as the data contains more points pr second that what is needed to make an animation
  filter(row_number() %% 10 == 0) %>% 
  #Animate the beginning of the gait
  filter(frame < 300) %>% 
  #mocapr specific code
  project_full_body_to_MP() %>% 
  animate_movement(fps = 50)





