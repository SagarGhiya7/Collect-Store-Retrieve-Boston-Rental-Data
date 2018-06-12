# Loading needed packages
library(rvest)
library(xlsx)
# DATA COLLECTION
# Scrapping data from rent hop regarding rents for Boston Apartments
# Below codes keep on adding 1 and pasting to the end of URL to increment pages
# Data is scrapped through 2000 pages
# Scraping address also containing number of bedrooms
address <-
  unlist(lapply(paste0(
    'https://www.renthop.com/search/boston?location_search=&min_price=0&max_price=8000&q=&neighborhoods_str=&sort=hopscore&page=1',
    1:2000
  ),
  function(url) {
    url %>% read_html() %>%
      html_nodes(".listing-title-link") %>%
      html_text()
  }))


# Scrapping area
area <-
  unlist(lapply(paste0(
    'https://www.renthop.com/search/boston?location_search=&min_price=0&max_price=8000&q=&neighborhoods_str=&sort=hopscore&page=1',
    1:2000
  ),
  function(url) {
    url %>% read_html() %>%
      html_nodes("#search-results-box .font-size-85") %>%
      html_text()
  }))

# Scrapping Rent
rent <-
  unlist(lapply(paste0(
    'https://www.renthop.com/search/boston?location_search=&min_price=0&max_price=8000&q=&neighborhoods_str=&sort=hopscore&page=1',
    1:2000
  ),
  function(url) {
    url %>% read_html() %>%
      html_nodes(".color-fg-green") %>%
      html_text()
  }))

# Removing \n from rent data
rent_final <- subset(rent, rent != "\n")

# Creating data frame for scrapped data
df <- data.frame(address, area, rent_final)

# Page keeps on updating 24*7
# So it would be difficult to show analyses as sometimes analyses would be refuted
# Also it takes half an hour to scrape 1 item of above 3 items, so each time one has to wait while starting to code
# Thus its better to make data constant

# Writing data into excel file and stroring in PC
# This completes data collection process
# This data is then imported into another R script submitted with this and analyzed

write.xlsx(df, file = "df.xlsx")
