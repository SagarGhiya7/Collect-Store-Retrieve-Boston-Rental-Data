# Collect-Store-Retrieve-Boston-Rental-Data

This project was a part of the curriculum of the course Collect/Store/Retrieve. The challenge was to scrape data from any website, clean data, manipulate data, store it in a relational database, retrieve it and then visualize it. 

I decided to analyze boston rental data from RentHop.com. Used Rvest pckage to scrape data from RentHop regarding apartment specifications such as number of bedrooms, number of bathrooms, living area and so on. Cleaned data to get it in proper shape. For eg: I was able to scrape the entire address for all the apartments. However I just needed to analyze rent by area. So one of the cleaning tasks was to extract the area from each address and put it in a seperate column. 


After getting data in the desired shape, next task was to store it in a relational database to avoid redundancy and decrease storage space. So I connected R with SQL using package RSQLite and created 3 different tables connected by primary key. Used queries to extract the required data. Created visualizations using ggplot2 to analyze boston apartments rent by area. Visualized rent from high to low by region and number of bedrooms. 


One can use such kind of analysis to figure out areas to search apartments depending on their budget.
