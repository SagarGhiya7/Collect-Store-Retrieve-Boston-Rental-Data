# Loading Necessary Packages
library(readxl)
library(stringr)
# Reading Data collected file
df <-
  read_excel(
    "C:/Users/Sagar Ghiya/Desktop/Study/SEM 2/Collecting Storing and Retrieving Data/Project/scrappedData.xlsx"
  )

# DATA CLEANING


# Removing unnecessary column and storing as data frame
df1 <- as.data.frame(df[,-1])
# Extracting number of bedroom part from data frame
a <- str_split_fixed(df1[, 1], ",", 2)
# Putting back to data frame
df1[, 4] <- a[, 1]
colnames(df1)[4] <- "Number of Bedrooms"

# Strategy
# Area column contains strings that contain area with some additional things such as street name
# Purpose is to extract area from it
# Listed down all the neighbourhoods near Boston
# Using grepl matching all area one by one and assigning area names accordingly
# Extracting Area String to convert into specific area
q1 <- df1[, 2]
# grepl returns true when there is a match
# For example, if the area is "Allston", it returns true in below statement. Thus we assigned Allston as area name there.
# Similar is done for all 30 area or boston neighbourhoods
q1[grepl("Allston", q1)] <- "Allston"
q1[grepl("Back Bay", q1)] <- "Back Bay"
q1[grepl("Bay Village", q1)] <- "Bay Village"
q1[grepl("Beacon Hill", q1)] <- "Beacon Hill"
q1[grepl("Brighton", q1)] <- "Brighton"
q1[grepl("Charlestown", q1)] <- "Charlestown"
q1[grepl("Chinatown", q1)] <- "Chinatown"
q1[grepl("Dorchester", q1)] <- "Dorchester"
q1[grepl("Downtown", q1)] <- "Downtown"
q1[grepl("East Boston", q1)] <- "East Boston"
q1[grepl("Kenmore", q1)] <- "Kenmore"
q1[grepl("Hyde Park", q1)] <- "Hyde Park"
q1[grepl("Jamaica Plain", q1)] <- "Jamaica Plain"
q1[grepl("Mission Hill", q1)] <- "Mission Hill"
q1[grepl("North End", q1)] <- "North End"
q1[grepl("Roslindale", q1)] <- "Roslindale"
q1[grepl("Roxbury", q1)] <- "Roxbury"
q1[grepl("South Boston", q1)] <- "South Boston"
q1[grepl("South End", q1)] <- "South End"
q1[grepl("West End", q1)] <- "West End"
q1[grepl("Cambridge", q1)] <- "Cambridge"
q1[grepl("Somerville", q1)] <- "Somerville"
q1[grepl("Malden", q1)] <- "Malden"
q1[grepl("Brookline", q1)] <- "Brookline"
q1[grepl("Waltham", q1)] <- "Waltham"
q1[grepl("Newton", q1)] <- "Newton"
q1[grepl("Quincy", q1)] <- "Quincy"
q1[grepl("Medford", q1)] <- "Medford"
q1[grepl("Needham", q1)] <- "Needham"
q1[grepl("Arlington", q1)] <- "Arlington"

# If there are other areas we don't need, we replace with NA
# Such areas start with \r
q1[grepl("^[\r]", q1)] <- "NA"
df1[, 2] <- q1
# Subsetting to remove NA
df1 <- subset(df1, df1[, 2] != "NA")

# Rent column contains $ sign which will create problem during analysis.
# Removing not needed things in rent column and only keeping numbers
df1[, 3] <- as.numeric(gsub("\\D", "", df1[, 3]))

# Now our data is cleaned and ready for storage
# Putting into data frame
final_df <- data.frame(df1[, 2], df1[, 3], df1[, 4])
# Giving appropriate column names
colnames(final_df) <- c("Region", "Rent", "Number_of_Bedrooms")

# Loading RSQLITE package for storage
library(RSQLite)
# Connecting and creating new database
db <- dbConnect(SQLite(), dbname = "BostonRentals")

# Goal is to covert data into 3NF form and store in SQL database

#Table1

# Extracting unique area to avoid redundancy
Area <- unique(cbind.data.frame(final_df[, 1]))
# Autoincremental key as Primary Key
Area_id <- seq(1:nrow(Area))
# Combining columns as data frame
t1 <- data.frame(Area_id, Area)
colnames(t1) <- c("Area_id", "Area")
# Writing table into database
dbWriteTable(
  conn = db,
  name = "Region",
  value = t1,
  row.names = FALSE
)

# Table2

# Extracting unique values for number of bedrooms and avoiding redundancy
Num_Bedroom <- unique(cbind.data.frame(final_df[, 3]))
# Autoincremental Primary Key
Num_Bedroom_id <- seq(1:nrow(Num_Bedroom))
# Data frame of 2 columns
t2 <- data.frame(Num_Bedroom_id, Num_Bedroom)
colnames(t2) <- c("Bedroom_id", "Num_of_BR")
# Writing table into database
dbWriteTable(
  conn = db,
  name = "Bedroom",
  value = t2,
  row.names = FALSE
)

# Table 3

# Now redundancy is removed
# Last table that will have rent column needs to be matched with two tables and make a foreign key to access data
# Matching with area
final_df$id1 <- t1[match(final_df[, 1], t1[, 2]), 1]
# Matching with Number of Bedroom
final_df$id2 <- t2[match(final_df[, 3], t2[, 2]), 1]
# Auto incremental primary key
PrimaryKey_id <- seq(1:nrow(final_df))
# Creating data frame
t3 <-
  data.frame(PrimaryKey_id, final_df$Rent, final_df$id1, final_df$id2)
colnames(t3) <- c("Pid", "Rent", "id1", "id2")
# Writing table into database
dbWriteTable(
  conn = db,
  name = "Rent",
  value = t3,
  row.names = FALSE
)
# Testing table 1 to check data is stored properly
test1 <- dbSendQuery(db, "Select * from Region")
dbFetch(test1)

# Testing table 2
test2 <- dbSendQuery(db, "Select * from Bedroom")
dbFetch(test2)

# Testing Table 3
test3 <- dbSendQuery(db, "Select * from Rent")
dbFetch(test3)

# Now data needs to be retrieved and analyzed
# Most common rentals are for 1BR, 2BR and 3BR
# Below area or neighbourhood wise analysis is shown for 1BR, 2BR and 3BR
# It can help to figure out areas with low rent dependng upon number of bedrooms

# Retrieval and Analysis for 1 BR
q1 <-
  dbSendQuery(
    db,
    "Select Region.Area, avg(Rent.Rent) as Average1, Bedroom.Num_of_BR from Region JOIN Rent ON Region.Area_id = Rent.id1 JOIN Bedroom ON Rent.id2 = Bedroom.Bedroom_id where Num_of_BR = '1BR' group by Region.Area  "
  )
# Fetching query
x <- data.frame(dbFetch(q1))
# Colour vector to be used for plotting
col <- c("blue", "green", "yellow", "orange", "red")
col1 <- rep(col, 6)

# Loading package ggplot2
library(ggplot2)

# Plot for 1 Bedroom
ggplot(x, aes(
  x = reorder(Area, -Average1),
  y = Average1,
  width = 0.5
)) + geom_bar(stat = "Identity", fill = col1) + theme(axis.text.x = element_text(angle =
                                                                                   -90)) + xlab("Region") + ylab("Rent") + ggtitle("Region vs Rent for 1BR")

# Retrieval and Analysis for 2 BR
q2 <-
  dbSendQuery(
    db,
    "Select Region.Area, avg(Rent.Rent) as Average2, Bedroom.Num_of_BR from Region JOIN Rent ON Region.Area_id = Rent.id1 JOIN Bedroom ON Rent.id2 = Bedroom.Bedroom_id where Num_of_BR = '2BR' group by Region.Area  "
  )

# Fetching query
y <- data.frame(dbFetch(q2))
# Plot for 2 Bedroom
ggplot(y, aes(
  x = reorder(Area, -Average2),
  y = Average2,
  width = 0.5
)) + geom_bar(stat = "Identity", fill = col1) + theme(axis.text.x = element_text(angle =
                                                                                   -90)) + xlab("Region") + ylab("Rent") + ggtitle("Region vs Rent for 2BR")

# Retrieval and Analysis for 3 BR
q3 <-
  dbSendQuery(
    db,
    "Select Region.Area, avg(Rent.Rent) as Average3, Bedroom.Num_of_BR from Region JOIN Rent ON Region.Area_id = Rent.id1 JOIN Bedroom ON Rent.id2 = Bedroom.Bedroom_id where Num_of_BR = '3BR' group by Region.Area  "
  )

# Fetching query
z <- data.frame(dbFetch(q3))
# Plot for 3 Bedroom
ggplot(z, aes(
  x = reorder(Area, -Average3),
  y = Average3,
  width = 0.5
)) + geom_bar(stat = "Identity", fill = col1) + theme(axis.text.x = element_text(angle =
                                                                                   -90)) + xlab("Region") + ylab("Rent") + ggtitle("Region vs Rent for 3BR")

# Above analyses can help one to narrow down search for rental apartment
# One can figure out number of bedrrom they need
# Hence infer from plots to find out areas where there is low rent 