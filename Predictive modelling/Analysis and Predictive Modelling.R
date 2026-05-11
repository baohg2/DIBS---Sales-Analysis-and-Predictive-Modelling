# Import libraries 

install.packages("dplyr")
install.packages("viridis")  # For color palettes
install.packages("maps")
library(tidyverse)
library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(rpart)
library(caret)
library(rpart.plot)
library(corrplot)
library(scales)
library(maps)
library(dplyr)
library(viridis)

# 1. Data Preparation

Jan <-read.csv("01_Sales_Jan.csv")
Feb <-read.csv("02_Sales_Feb.csv")
Mar <-read.csv("03_Sales_Mar.csv")
Apr <-read.csv("04_Sales_Apr.csv")
May <-read.csv("05_Sales_May.csv")
Jun <-read.csv("06_Sales_Jun.csv")
Jul <-read.csv("07_Sales_Jul.csv")
Aug <-read.csv("08_Sales_Aug.csv")
Sep <-read.csv("09_Sales_Sep.csv")
Oct <-read.csv("10_Sales_Oct.csv")
Nov <-read.csv("11_Sales_Nov.csv")
Dec <-read.csv("12_Sales_Dec.csv")

# Checking whether columns are the same for all files 
all(sort(colnames(Jan)) == sort(colnames(Feb))) && all(sort(colnames(Feb)) == sort(colnames(Mar)))
all(sort(colnames(Mar)) == sort(colnames(Apr))) && all(sort(colnames(Apr)) == sort(colnames(May)))
all(sort(colnames(May)) == sort(colnames(Jun))) && all(sort(colnames(Jun)) == sort(colnames(Jul)))
all(sort(colnames(Jul)) == sort(colnames(Aug))) && all(sort(colnames(Aug)) == sort(colnames(Sep)))
all(sort(colnames(Sep)) == sort(colnames(Oct))) && all(sort(colnames(Oct)) == sort(colnames(Nov)))
all(sort(colnames(Nov)) == sort(colnames(Dec))) 

# Create new column for each file to identify month
Jan$month <- "Jan"
Feb$month <- "Feb"
Mar$month <- "Mar"
Apr$month <- "Apr"
May$month <- "May"
Jun$month <- "Jun"
Jul$month <- "Jul"
Aug$month <- "Aug"
Sep$month <- "Sep"
Oct$month <- "Oct"
Nov$month <- "Nov"
Dec$month <- "Dec"


#combine all the files
combined_data <- rbind(Jan, Feb, Mar, Apr, May, Jun, Jul, Aug, Sep, Oct, Nov, Dec)

#display the first few rows of the data frame  
head(combined_data)  

#generate a summary of the data frame  
summary(combined_data)  

#display the structure of the "combined_data" data frame 
str(combined_data) 

#Renaming the specified columns 
colnames(combined_data)[colnames(combined_data) == "Order.ID"] <- "Order_ID" 
colnames(combined_data)[colnames(combined_data) == "Quantity.Ordered"] <- "Quantity_Ordered" 
colnames(combined_data)[colnames(combined_data) == "Price.Each"] <- "Price_Each" 
colnames(combined_data)[colnames(combined_data) == "Order.Date"] <- "Order_Date" 
colnames(combined_data)[colnames(combined_data) == "Purchase.Address"] <- "Purchase_Address" 


# Check Order_ID column
# unique(combined_data$Order_ID) 

# Remove rows where Order_ID contains "Order ID" 
 combined_data <- combined_data[combined_data$Order_ID != "Order ID", ]


# Check Product column
unique(combined_data$Product) 
# Count occurrences of each unique value in the "Product" column
product_counts <- table(combined_data$Product)
# Display the counts
print(product_counts)


# Correcting the spelling errors with right spellings 
combined_data$Product <- gsub("Goo0gle Phone", "Google Phone", combined_data$Product) 
combined_data$Product <- gsub("USBC Charging Cable", "USB-C Charging Cable", combined_data$Product) 
combined_data$Product <- gsub("Wired Headphoness", "Wired Headphones", combined_data$Product) 
combined_data$Product <- gsub("LightCharging Cable", "Lightning Charging Cable", combined_data$Product) 
combined_data$Product <- gsub("IPhone", "iPhone", combined_data$Product) 
# Remove rows where Product contains "##system error##" 
combined_data <- combined_data[combined_data$Product != "##system error##", ] 
# Remove rows where Product contains "Fault Error" 
combined_data <- combined_data[combined_data$Product != "Fault error", ] 
# Remove rows where Product contains "### syste error###" 
combined_data <- combined_data[combined_data$Product != "### syste error###", ] 
# Filter rows with empty "Product" values
filtered_data <- subset(combined_data, Product == "")
str(filtered_data) 
#remove rows with empty product values
combined_data <- combined_data[combined_data$Product != "", ]

combined_data$Product <- gsub("AAA Batteries \\(4pack\\)", "AAA Batteries (4-pack)", combined_data$Product)

#verifying results 
distinct(combined_data, Product) 


# Check Quantity_Ordered column
unique(combined_data$ Quantity_Ordered) 

# Filter rows with empty "Quantity_Ordered" values
filtered_data <- subset(combined_data, Quantity_Ordered == "0")
#remove rows with empty product values
combined_data <- combined_data[combined_data$Quantity_Ordered != "0", ]

# Quantity_Ordered is reflected as character instead of numeric so converting Quantity_Ordered to numeric 
combined_data$Quantity_Ordered <- as.numeric(combined_data$Quantity_Ordered) 

# Check Price_Each column
unique(combined_data$Price_Each) 

# Remove the dollar sign ($) from the values in the Price_Each column 
combined_data$Price_Each <- as.numeric(gsub("\\$", "", combined_data$Price_Each)) 

# Price_Each is reflected as character instead of numeric so converting it to numeric 
combined_data$Price_Each <- as.numeric(combined_data$Price_Each) 


# Check Order_Date column
unique(combined_data$ Order_Date) 
combined_data$Date = sapply(strsplit(combined_data$Order_Date, " "), `[`, 1) 
combined_data$Time = sapply(strsplit(combined_data$Order_Date, " "), `[`, 2) 

#Manipulating the date column, changing it into the year and month format 
combined_data$Date = sub("^0(.*)", "\\1", combined_data$Date) 
head(combined_data) 


#Converting it into date format 
combined_data$Date = mdy(combined_data$Date) 


# Extract Additional Information: Extract additional useful information from the Order.Date variable, such as day of the week or hour of the day, which might be helpful for analysis.
# Convert Order_Date to datetime object
combined_data$Order_Date <- parse_date_time(combined_data$Order_Date, orders = c("mdy HM", "m/d/Y HM"))

# Extract Year, Month, Day, and Time
combined_data$Year <- year(combined_data$Order_Date)
combined_data$Month <- month(combined_data$Order_Date)
combined_data$Day <- day(combined_data$Order_Date)
combined_data$Time <- format(combined_data$Order_Date, format = "%H:%M")


# Check unique year
unique(combined_data$Year) 
product_counts <- table(combined_data$Year)
product_counts


# Check information for possible outliers in Year
# Subset data to include only rows with specified years
outlier_year_data <- combined_data[combined_data$Year %in% c(2001, 2020, 2021,2028), ]

# Define the plausible year range
min_year <- 2019
max_year <- 2024

# Identify incorrect years
incorrect_years <- which(format(combined_data$Order_Date, "%Y") < min_year | format(combined_data$Order_Date, "%Y") > max_year)

# Print rows with incorrect years for reference
combined_data[incorrect_years, ]

# Update incorrect years to a plausible year (e.g., replace 2028 with 2021 and 2001 with 2021)
combined_data$Order_Date[incorrect_years] <- as.POSIXct(paste("2021", format(combined_data$Order_Date[incorrect_years], "%m-%d %H:%M:%S")), format="%Y-%m-%d %H:%M:%S")

# Display the data frame with the new columns
print(head(combined_data))

unique(combined_data$Purchase_Address) 
# Separating  Street_Address, State, City and Post_Code 
combined_data = separate(combined_data, Purchase_Address, into = paste0("column", 1:3), sep = ", ") 

#Renaming Columns  
colnames(combined_data)[6] = "Street_Address" 
colnames(combined_data)[7] = "City" 
head(combined_data) 


#Separating state and postcode 
combined_data = separate(combined_data, column3, into = paste0("column", 1:2), sep = " ") 

#Renaming them 
colnames(combined_data)[8] = "State" 
colnames(combined_data)[9] = "Post_Code" 

#Checking for missing values 
anyNA(combined_data) 
colSums(is.na(combined_data)) 

#Dropping NAs  
combined_data = drop_na(combined_data) 
anyNA(combined_data) 
print(combined_data) 

# Reviewing the string lengths of Order IDs to ensure their validity. 
unique(nchar(combined_data$Order_ID)) 

#Reviewing the frequency distribution of order quantities to ensure there are no irregularities. 
table(combined_data$Quantity_Ordered) 

#Checking distinct product names 
table(combined_data$Product) 
#Reviewing the occurrence of prices to detect any unusual patterns or outliers. 
table(combined_data$Price_Each) 

#Examining the frequency of cities, states, and postal codes to identify potential address errors. 

table(combined_data$City) 
# further data cleansing for  Las Angeles and Los Angeles 
# San Francisco and SanFrancisco

table(combined_data$State) 
table(combined_data$Post_Code) 


# Check data after cleansing
head(combined_data)
summary(combined_data)


# 2. EDA 

#Q1: what is the worst year of sales and how much was earned ? 
# Calculating total sales per year
yearly_sales <- combined_data %>%
  group_by(Year) %>%
  summarise(Total_Sales = sum(Price_Each * Quantity_Ordered, na.rm = TRUE))

# Finding the year with the lowest total sales
worst_year <- yearly_sales %>%
  filter(Total_Sales == min(Total_Sales))

# print the worst year and its total sales
print(worst_year)


#Q2: how much was earned in the beat year of sales?
# Find the year with the highest total sales
best_year <- yearly_sales %>%
  filter(Total_Sales == max(Total_Sales))

# Display the best year and its total sales
print(best_year)


#Q3: In the best year of sales which was the best month of sales?
# Filtering out data for the best year
best_year_data <- combined_data %>%
  filter(Year == best_year$Year)

# Calculate total sales per month in the best year
monthly_sales <- best_year_data %>%
  group_by(Month) %>%
  summarise(Total_Sales = sum(Price_Each * Quantity_Ordered, na.rm = TRUE))

# Find the month with the highest total sales in the best year
best_month <- monthly_sales %>%
  filter(Total_Sales == max(Total_Sales))

# Display the best month and its total sales
print(best_month)


#Q4: In the best year year of sales how much was earned in the best month 
# Total earnings in the best month of the best year
total_earnings_best_month <- best_month$Total_Sales

# print the total earnings in the best month
print(total_earnings_best_month)


#Q5: Which City had the most sales in the best year of sales?
# Calculate total sales for each city in the best year
city_sales_best_year <- best_year_data %>%
  group_by(City) %>%
  summarise(Total_Sales = sum(Price_Each * Quantity_Ordered, na.rm = TRUE)) %>%
  arrange(desc(Total_Sales))

# Display the city with the highest total sales
best_selling_city <- city_sales_best_year %>%
  filter(Total_Sales == max(Total_Sales))

print(best_selling_city)


#Q6: To maximise the likelihood of customers buying a product, 
#what time should Dibs business be displaying advertisements in the best year of sales?
# Calculate total sales for each hour in the best year
hourly_sales <- best_year_data %>%
  mutate(Hour = hour(Order_Date)) %>%
  group_by(Hour) %>%
  summarise(Total_Sales = sum(Price_Each * Quantity_Ordered, na.rm = TRUE))

# Finding the hour(s) with the highest total sales
peak_hours <- hourly_sales %>%
  filter(Total_Sales == max(Total_Sales))

# Display the peak hours
print(peak_hours)


#Q7: Which products are most often sold together 
# Sorting information by Order_ID, then extract the products for each order
order_products <- combined_data %>%
  group_by(Order_ID) %>%
  summarise(Products = list(unique(Product)))

# Filter out orders with less than 2 unique products
order_products <- order_products %>%
  filter(lengths(Products) >= 2)

# Create combination
safe_combn <- function(products) {
  if (length(products) < 2) {
    return(character(0))  # Return an empty character vector if less than 2 products
  }
  combn(products, 2, paste, collapse = " & ")
}

#create every possible product combination for every order
order_product_combinations <- order_products %>%
  mutate(Combinations = purrr::map(Products, safe_combn)) %>%
  unnest(Combinations, keep_empty = TRUE)

# Count occurrences and repetitions of each product combination
product_combination_counts <- order_product_combinations %>%
  group_by(Combinations) %>%
  summarise(Count = n()) %>%
  arrange(desc(Count))

# Display the top product combinations
head(product_combination_counts, 10)


#Q8: Overall which product sold the most and why do you think it has sold the most?
# Calculate total quantity ordered for each product
product_sales <- combined_data %>%
  group_by(Product) %>%
  summarise(Total_Quantity = sum(Quantity_Ordered, na.rm = TRUE)) %>%
  arrange(desc(Total_Quantity))

# Display the best selling product
best_selling_product <- product_sales %>%
  filter(Total_Quantity == max(Total_Quantity))

print(best_selling_product)


#Q9: What is the least sold product in the best year of sales?
# Calculating total quantity ordered for each product in the best year
product_sales_best_year <- best_year_data %>%
  group_by(Product) %>%
  summarise(Total_Quantity = sum(Quantity_Ordered, na.rm = TRUE)) %>%
  arrange(Total_Quantity)

# Displaying the least sold product
least_sold_product <- product_sales_best_year %>%
  filter(Total_Quantity == min(Total_Quantity))

print(least_sold_product)



# Deep Analysis and Visualization

# a.Monthly sales trend vs monthly average sales

# Aggregate sales by month in the best year
sales_by_month_best_year <- aggregate(Price_Each * Quantity_Ordered ~ format(Order_Date, "%m"), data = best_year_data, FUN = sum)
monthly_average_sales <- mean(sales_by_month_best_year$`Price_Each * Quantity_Ordered`)
names(sales_by_month_best_year) <- c("Month", "Sales")

# Plot monthly sales trend
ggplot(sales_by_month_best_year, aes(x = Month, y = Sales)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = monthly_average_sales, linetype = "dashed", color = "red") +
  labs(title = "Monthly Sales Trend vs Monthly Average Sales",
       x = "Month",
       y = "Sales",
       caption = "Monthly average sales shown in red dashed line") +
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"), 
        panel.background = element_blank(),
        panel.grid.major = element_line(color = "gray80"),panel.grid.minor = element_blank()) +
  scale_y_continuous(labels = label_dollar(scale = 1e-6, suffix = "M")) 



# b.Sales by state

# Aggregate sales by month in the best year
sales_by_state <- aggregate(Price_Each * Quantity_Ordered ~ format(State), data = best_year_data, FUN = sum)
names(sales_by_state) <- c("State", "Sales")

# Create a data frame with state codes and state names
state_mapping <- data.frame(
  StateCode = c("CA", "GA", "ME", "MA", "NY", "OR", "TX", "WA"),
  StateName = c('California', 'Georgia', 'Maine', 'Massachusetts', 'New York', 'Oregon', 'Texas', 'Washington')
)

# Map state codes to state names
sales_by_state$State_name <- state_mapping$StateName[match(sales_by_state$State, state_mapping$StateCode)]

# Calculate percentage for each state 
sales_by_state <- sales_by_state %>% 
  mutate(Percentage = Sales / sum(Sales) * 100) 

# Calculate the position for the labels
sales_by_state <- sales_by_state %>%
  arrange(desc(Sales)) %>%
  mutate(ypos = cumsum(Percentage) - 0.5 * Percentage)

# Adjust ypos for specific states
sales_by_state <- sales_by_state %>%
  mutate(ypos = ifelse(State_name == "Oregon", ypos - 1.5, ypos))

# Order the data by Sales in descending order
sales_by_state <- sales_by_state %>% 
  arrange(Sales)

# Reorder the State_name factor levels based on Sales
sales_by_state$State_name <- factor(sales_by_state$State_name, levels = sales_by_state$State_name)

# Create pie chart with single color fill
ggplot(sales_by_state, aes(x="", y=Percentage, fill=State_name)) + 
  geom_bar(width=1, stat="identity") + 
  coord_polar(theta="y") + 
  scale_fill_viridis_d(option = "viridis") +
  labs(title="Sales by State", x="", y="") + 
  theme_void() + # Remove background and axis 
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"),
        legend.position = "right") +  # Position legend on the right
  geom_text(aes(label = paste0(round(Percentage, 1), "%"), y = ypos), color = ifelse(sales_by_state$State_name == "California", "black", "white"))  # Add labels

# Get the map data
states_map <- map_data("state")

# Convert state names to lowercase for matching
sales_by_state <- sales_by_state %>%
  mutate(region = tolower(State_name))

# Merge map data with sales data
map_data_with_sales <- states_map %>%
  left_join(sales_by_state, by = "region")

# Create the map plot
ggplot(map_data_with_sales, aes(map_id = region, fill = Sales / 1e6)) +
  geom_map(map = states_map, color = "white") +
  expand_limits(x = states_map$long, y = states_map$lat) +
  scale_fill_viridis_c(option = "viridis", na.value = "gray90",
                       limits = c(0, 15),  # Set the range for the legend
                       labels = scales::label_dollar(scale = 1, suffix = "M")) +
  labs(
    title = "Geographical Sales footprints",
    fill = "Sales"
  ) +
  theme_void() +
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, size = 16, color = "#1C4A83", face = "bold")
  ) 



#c.Top 10 products sold in the best year of sales
# Aggregate sales by state in the best year
top_products <- aggregate(Price_Each * Quantity_Ordered ~ format(Product), data = combined_data, FUN = sum)
names(top_products) <- c("Product", "Sales")
top_products <- top_products %>% arrange(desc(Sales))

top_10_products <- top_products%>%
  slice_head(n = 10)

ggplot(top_10_products, aes(x = reorder(Product, -Sales), y = Sales)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Top 10 Products by Sales",
       x = "Product",
       y = "Total Sales") +
  scale_y_continuous(labels = label_dollar(scale = 1e-6, suffix = "M")) + # Format y-axis labels 
  coord_flip() + 
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"), 
        panel.background = element_blank(),
        panel.grid.major = element_line(color = "gray80"),panel.grid.minor = element_blank())

# d. Monthly order trend vs monthly average order 
monthly_orders <- aggregate(Quantity_Ordered ~ format(Order_Date, "%m"), data = combined_data, FUN = sum)
names(monthly_orders) <- c("Month", "Quantity_ordered")
monthly_average_order <- mean(monthly_orders$Quantity_ordered)

ggplot(monthly_orders, aes(x = Month, y = Quantity_ordered)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = monthly_average_order, linetype = "dashed", color = "red") +
  labs(title = "Monthly Order Trend vs Monthly Average Orders",
       x = "Month",
       y = "Quantity of orders",
       caption = "Monthly average order shown in red dashed line") +
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"), 
        panel.background = element_blank(),
        panel.grid.major = element_line(color = "gray80"),panel.grid.minor = element_blank())

# e.Daily order trend vs daily average
daily_orders <- best_year_data %>%  
  group_by(Date = as.Date(Order_Date)) %>%  
  summarise(Daily_Orders = n()) 

daily_avg_orders <- mean(daily_orders$Daily_Orders) 

ggplot(daily_orders, aes(x=Date, y=Daily_Orders)) + 
  geom_line(color = "steelblue", size = 0.6) + 
  geom_hline(yintercept=daily_avg_orders, linetype="dashed", color="red") +
  scale_y_continuous(expand = c(0, 0), limits = c(0, NA)) +
  labs(title="Daily Order Trend vs Daily Average Orders", x="Date", y="Quantity of orders",
       caption = "Daily average order shown in red dashed line") +
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"), 
        panel.background = element_blank(),
        panel.grid.major = element_line(color = "gray80"),panel.grid.minor = element_blank())

# f.Hourly order trend vs hourly average order 

# Convert the 'Time' column to just the hour
best_year_data <- best_year_data %>%
  mutate(Hour = hour(hm(Time)))  # Extract hour from time

# Group by hour and summarize
hourly_orders <- best_year_data %>%
  group_by(Hour) %>%
  summarise(Hourly_Orders = n())

# Calculate the hourly average orders
hourly_avg_orders <- mean(hourly_orders$Hourly_Orders)

# Create the plot
ggplot(hourly_orders, aes(x = factor(Hour), y = Hourly_Orders, group = 1)) + 
  geom_line(color = "steelblue") + 
  geom_point() + 
  geom_hline(yintercept = hourly_avg_orders, linetype = "dashed", color = "red") + 
  labs(title = "Hourly Order Trend vs Hourly Average Order", x = "Hour", y = "Quantity of orders",
       caption = "Daily average order shown in red dashed line") +
  theme(plot.title = element_text(size = 16, color = "#1C4A83", face = "bold"), 
        panel.background = element_blank(),
        panel.grid.major = element_line(color = "gray80"),panel.grid.minor = element_blank())




# 4. Predictive Modelling 

# KMeans clustering to help improve the accuracy in predicting sales quantity
# Select and scale the features to standardize features
features <- combined_data[, c("Price_Each", "Quantity_Ordered")]
features_scaled <- scale(features)

# Apply K-means clustering
kmeans_model <- kmeans(features_scaled, centers = 2, nstart = 20)
clusters <- kmeans_model$cluster

# Adding cluster labels to the dataset
combined_data$Cluster <- clusters

ggplot(data = combined_data, aes(x = Price_Each, y = Quantity_Ordered, color = factor(Cluster))) +
  geom_point(size = 3) +
  scale_color_manual(values = c("1" = "steelblue", "2" = "red")) +
  labs(title = "K-Means Clustering on Price_Each and Quantity Ordered",
       x = "Price_Each",
       y = "Quantity_Ordered",
       color = "Cluster") +
  theme_minimal() +
  theme(
    plot.title = element_text(color = "steelblue", size = 20, face = "bold")
  )


#check whether the clusters are reflected in column
head(combined_data)
summary(combined_data)

# Ensure no NA values in the relevant columns
anyNA(combined_data$Quantity_Ordered)
anyNA(combined_data$Price_Each)
anyNA(combined_data$Cluster)

# Select relevant columns to check correlation
selected_columns <- combined_data[, c("Quantity_Ordered", "Price_Each", "Cluster","Year", "Month","Day")]

# Checking correlation matrix for linear regression 
# Check column names of selected_columns
head(selected_columns)
# Calculate correlation matrix
correlation_matrix <- cor(selected_columns)
# Print correlation matrix
print(correlation_matrix)


# Choosing features with highest values for decision tree 
# Train the decision tree model
tree_model <- rpart(Quantity_Ordered ~ Price_Each + Cluster+ City+ Month +Year + Day +Time , data = combined_data)
# Get feature importance
feature_importance <- tree_model$variable.importance
# Print feature importance
print(feature_importance)


# Splitting data into training and testing sets
index <- createDataPartition(combined_data$Year, p = 0.70, list = FALSE)
train_data <- combined_data[index, ]
test_data <- combined_data[-index, ]

# Model 1: Linear Regression
model_lm <- lm(Quantity_Ordered ~ Price_Each +  Cluster  , data = train_data)

# Model 2: Decision Tree Regression
model_rpart <- rpart(Quantity_Ordered ~ Price_Each  + Cluster ,  data = train_data)


# Predictions using test data
predict_lm <- predict(model_lm, test_data)
predict_rpart <- predict(model_rpart, test_data)


# Create data frames for evaluation
results_lm <- data.frame(Actual = test_data$Quantity_Ordered, Predicted = predict_lm)
results_rpart <- data.frame(Actual = test_data$Quantity_Ordered, Predicted = predict_rpart)


# Evaluate models using performance metrics
mae_lm <- mean(abs(results_lm$Actual - results_lm$Predicted))
mae_rpart <- mean(abs(results_rpart$Actual - results_rpart$Predicted))


mse_lm <- mean((results_lm$Actual - results_lm$Predicted)^2)
mse_rpart <- mean((results_rpart$Actual - results_rpart$Predicted)^2)


# Print the MAE and MSE for each model
cat("MAE:\n")
cat("Linear Regression: ", mae_lm, "\n")
cat("Decision Tree: ", mae_rpart, "\n")


cat("MSE:\n")
cat("Linear Regression: ", mse_lm, "\n")
cat("Decision Tree: ", mse_rpart, "\n")

calculate_r_squared <- function(actual, predicted) {
  ss_total <- sum((actual - mean(actual))^2)
  ss_residual <- sum((actual - predicted)^2)
  r_squared <- 1 - (ss_residual / ss_total)
  return(r_squared)
}

# Calculate R-squared for linear model
r_squared_lm <- calculate_r_squared(results_lm$Actual, results_lm$Predicted)
print(paste("R-squared for Linear Model:", r_squared_lm))

# Calculate R-squared for decision tree model
r_squared_rpart <- calculate_r_squared(results_rpart$Actual, results_rpart$Predicted)
print(paste("R-squared for Decision Tree Model:", r_squared_rpart))


# Plotting the residuals

par(mfrow = c(1, 2))
plot(results_lm$Actual - results_lm$Predicted, 
     main = "Residuals: Linear Regression", 
     ylab = "Residuals", 
     xlab = "Index",
     col.main = "steelblue",
     font.main = 2,
     cex.main = 1.5)  # Adjust the size as needed
plot(results_rpart$Actual - results_rpart$Predicted, 
     main = "Residuals: Decision Tree", 
     ylab = "Residuals", 
     xlab = "Index",
     col.main = "steelblue",
     font.main = 2,
     cex.main = 1.5)  # Adjust the size as needed



# Model recommendation based on both metrics and residual plots
 if (mae_lm <  mae_rpart  & mse_lm < mse_rpart) {
  cat("Linear Regression is the recommended model due to the lowest MAE and MSE.")
} else   {
  cat("Decision Tree is the recommended model due to the lowest MAE and MSE.")
} 
