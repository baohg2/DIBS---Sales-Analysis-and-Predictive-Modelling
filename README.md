# 📦 DIBS Retail Company — Sales Analysis and Predictive Modelling

> A data-driven analysis of DIBS Retail Company's sales performance, uncovering trends in customer behaviour and developing a predictive model to forecast sales quantities and support strategic decision-making.

---

## Project Overview

Dibs, a rapidly growing online retail company, seeks to overcome challenges in increasing sales and fostering customer loyalty. This project analyses historical sales data to uncover patterns in customer behaviour, identify top and underperforming products, and develop a machine learning model capable of forecasting sales quantities. Findings are translated into actionable recommendations across inventory management, sales strategy, marketing, and market expansion.

---

## Dataset

The dataset comprises monthly sales records from **January to December**, sourced from 12 separate CSV files and combined into a single data frame for analysis.

| Field | Description |
|---|---|
| `Order_ID` | Unique identifier for each order |
| `Product` | Item sold to the customer |
| `Quantity_Ordered` | Total quantity of items ordered |
| `Price_Each` | Unit price of each product |
| `Order_Date` | Date the customer requested shipment |
| `Purchase_Address` | Full delivery address from the purchase order |

---

## Methodology

This project adopted a structured analytical approach across six stages:

### 1. Data Collection

Monthly sales CSV files (January–December) were loaded individually, verified for consistent column structure across all files, and merged into a unified data frame named `combined_data` for end-to-end analysis.

### 2. Data Preparation and Cleaning

A comprehensive cleaning process was applied to ensure data integrity across four steps:

#### 🔄 Type Conversion
- `Order_ID`, `Quantity_Ordered`, and `Price_Each` were converted from character to **numeric** format.
- `Order_Date` was parsed into proper **date-time** format using `lubridate`.

#### 🔧 Data Transformation
- `Order_Date` was decomposed into separate fields: **date**, **month**, **year**, **hour**, and binary indicators for **weekends** and **holidays**.
- `Purchase_Address` was split into **City**, **State**, and **Post Code** using the `separate` function.
- Column names were standardised for readability (e.g. `Order.ID` → `Order_ID`).

#### 🚨 Outlier Handling
- Records with erroneous order years (**2001** and **2028**) were removed as temporal outliers.
- Product name spelling errors were corrected using `gsub` and `mutate` (e.g. `Goo0gle Phone` → `Google Phone`, `USBC Charging Cable` → `USB-C Charging Cable`).
- Rows containing system error flags (`##system error##`, `Fault error`) and empty product values were removed.

#### 🧮 Sales Calculation
- A derived **Total Sales** column was computed by multiplying `Quantity_Ordered` by `Price_Each` for each order, forming the primary revenue metric throughout the analysis.

### 3. Exploratory Data Analysis (EDA)

EDA was conducted to understand the shape, distribution, and quality of the consolidated dataset. Summary statistics and frequency distributions were examined across products, cities, and time periods to surface early patterns — including the top and bottom performing products by quantity and revenue, and frequently co-purchased product pairs.

### 4. Deep Analysis and Visualization

Deep analysis was performed across three dimensions using `ggplot2` visualisations:

- **Time** — Monthly and daily trends revealed strong Q4 seasonality, with December peaking at 28,137 orders and $4.6M in sales. Hourly analysis identified two peak ordering windows: **11AM–1PM** and **6PM–8PM**.
- **Geography** — California drove **39.8%** of total sales, with San Francisco as the top city. Texas and New York followed at ~13.5% each.
- **Product** — Accessories dominated order volume (low price, high quantity), while the MacBook Pro Laptop led revenue at **$8M (22% of total sales)**. The most common co-purchase pair was iPhone and Lightning Charging Cable (1,002 orders).

### 5. Predictive Modelling

Predictive modelling was implemented in two stages:

**K-Means Clustering** — Products were segmented by `Price_Each` and `Quantity_Ordered` into two clusters:
- **Cluster 1**: High quantity, low price (accessories)
- **Cluster 2**: Low quantity, high price (premium electronics)

Cluster labels were added as a feature to enhance model performance.

**Model Training** — Two models were trained on a 70/30 train-test split using `Price_Each` and `Cluster` as predictors for `Quantity_Ordered`:

| Metric | Linear Regression | Decision Tree |
|---|---|---|
| MAE | 0.0477 | **0.0461** |
| MSE | 0.04619 | **0.0437** |
| R² | 0.7635 | **0.7760** |

The **Decision Tree** outperformed Linear Regression across all metrics and was selected as the preferred forecasting model. Forecasted sales figures are derived by combining predicted quantity with unit price.

### 6. Insights and Recommendations

Recommendations were developed across four strategic areas:

- **Inventory Management** — Use the Decision Tree model to forecast demand for peak seasons (Q4). Prioritise stock for high-turnover, low-price items (e.g. AAA Batteries). Review and reduce or discontinue low-performing SKUs such as LG Dryers.
- **Sales Strategy** — Run targeted seasonal promotions in Q4 and time-limited flash sales during peak hours (11AM–1PM, 6PM–8PM). Bundle frequently co-purchased products (e.g. iPhone + Lightning Charging Cable).
- **Marketing** — Focus campaigns on high-value regions (San Francisco, California) and peak ad windows. Use K-means cluster insights to personalise messaging for each product segment and implement cross-selling strategies.
- **Market Expansion** — Enter densely populated states proximate to existing markets — **Florida**, **Pennsylvania**, and **Illinois** — leveraging existing warehouse and logistics infrastructure.

---

## Model Results

The **Decision Tree** model was selected as the final forecasting model based on superior performance across MAE, MSE, and R² compared to Linear Regression. Predicted quantities combined with product price provide actionable sales forecasts for inventory and planning purposes.

---

## Technologies Used

- **Language**: R
- **Libraries**: `tidyverse`, `dplyr`, `tidyr`, `ggplot2`, `lubridate`, `rpart`, `caret`, `rpart.plot`, `corrplot`, `scales`, `maps`, `viridis`
- **Excel**: Used for additional visual summaries

---

## Author

**Gia Bao Hoang**
