library(tidyverse)

nba <- read_csv("../Data/NBA_player_of_the_week.csv")

# nba <- nba %>%
#     mutate(heightIn = 0)
# 
# nba$heightIn[grepl("cm", nba$Height)] <- nba %>%
#     filter(grepl("cm", Height)) %>%
#     select(Height) %>%
#     pull() %>%
#     str_replace("cm", "") %>%
#     as.numeric()
# 
# nba$heightIn <- nba$heightIn/2.54
# 
# nba <- nba %>%
#     mutate(feet = as.numeric(str_sub(nba$Height, 1, 1)),
#            inches = as.numeric(str_sub(nba$Height, 3, -1)))
# 
# # Part 5
# nba$heightIn[!grepl("cm", nba$Height)] <- nba$feet[!grepl("cm", nba$Height)]*12 + nba$inches[!grepl("cm", nba$Height)]


nba <- nba %>%    
  separate(Height, c("Feet", "Inches"), sep = "-") %>%
  mutate(
    Height.In = case_when(
      grepl("cm", Feet) ~ as.numeric(gsub("cm", "", Feet))/2.54,
      TRUE ~ 12*as.numeric(Feet) + as.numeric(Inches)
    )
  )


# nba <- nba %>%
#     mutate(weightlb = 0)
# 

# nba$weightlb[grepl("kg", nba$Weight)] <- nba %>%
#     filter(grepl("kg", Weight)) %>%
#     select(Weight) %>%
#     pull() %>%
#     str_replace("kg", "") %>%
#     as.numeric()
# 
# nba$weightlb <- nba$weightlb*2.20462
# 
# nba$weightlb[!grepl("kg", nba$Weight)] <- nba %>%
#     filter(!grepl("kg", nba$Weight)) %>%
#     select(Weight) %>%
#     pull() %>%
#     as.numeric()

nba <- nba %>%    
  mutate(
    Weight = case_when(
      grepl("kg", Weight) ~ as.numeric(gsub("kg", "", Weight))*2.20462,
      TRUE ~ as.numeric(Weight)
    )
  )

nba <- nba %>%
  group_by(Player) %>%
  count() %>%
  rename(timesWon = n) %>%
  full_join(nba, by = "Player")

nba <- nba %>%
  group_by(Player) %>%
  arrange(desc(Season.short)) %>%
  distinct(Player, .keep_all = T) %>%
  select(Player, Season.short) %>%
  rename(recentSeason = Season.short) %>%
  full_join(nba, by = "Player")