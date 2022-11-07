# load required libraries for each chapter
library(tidyverse)
library(lubridate)
library(ggrepel)
library(patchwork)
#-------- supporting packages
library(flextable)
library(zoo)

# set ggplot2 default theme
ggplot2::theme_set(theme_minimal())

#============== flextable stuff ===============================================
# set flextable font to surpress warning about used Latex engine
flextable::set_flextable_defaults(
    fonts_ignore = TRUE    # ignore waring of Latex engine
  , font.size = 10         # set some default size and family
  , font.family = "Helvetica")

# set flextable border properties
ft_border = flextable::fp_border_default(width = 0.5)


# define standard theme aspects for Brazil and Europe
bra_eur_colours <- c("#52854C","#4E84C4")

my_own_theme_minimal <- theme_minimal() + theme(axis.title = element_text(size = 9))
my_own_theme_bw <- theme_bw() + theme(axis.title = element_text(size = 9))

#Read relevant data
bra_count_region <- read_csv("./data/BRA-region-traffic.csv")
eur_count_region <- read_csv("./data/PBWG-EUR-region-traffic.csv")

bra_count_airport <- read_csv("./data/BRA-airport-traffic.csv") %>%
  mutate(APT_ICAO = as.factor(APT_ICAO))

eur_apts <- c("EGLL","EGKK","EHAM","EDDF","EDDM","LFPG","LSZH","LEMD","LEBL","LIRF")
eur_count_airport <- read_csv("./data/PBWG-EUR-airport-traffic.csv") %>%
  mutate(APT_ICAO = as.factor(ICAO), .before = DATE, .keep = "unused") %>%
  filter(APT_ICAO %in% eur_apts) %>%
  drop_na() #

#------------- check how we can kill this
# previous study summary files/data
dev3_summaries <- list.files(path = "./data/", pattern = "*._DEV3.csv", full.names = TRUE) %>%
  purrr::map_dfr(.f = ~ read_csv(.x))


#------------- determine max date in our data sets -------------------
## this allows to calculate the variation year-to-date
max_date_in_data <- function(.ds){
  max_date <- .ds %>% pull(DATE) %>% max()
}
bra_apt_max_date <- bra_count_airport %>% max_date_in_data()
eur_apt_max_date <- eur_count_airport %>% max_date_in_data()

DateLimit <- min(bra_apt_max_date, eur_apt_max_date)
DateLimit <- lubridate::ymd("2022-07-01")

# temporal scope
min_year <- 2016
key_year <- 2021
