# Data Warehouse OLAP Analysis

Complete data warehouse implementation with OLAP analysis for e-commerce sales. Covers data modeling, ETL processes, and interactive analytics on e-commerce transactions.

## Overview

This project demonstrates the design and implementation of a dimensional data warehouse for e-commerce, including:
- Data preprocessing and cleaning
- Star schema modeling (dimensions + facts)
- ETL pipeline (Extract, Transform, Load)
- Data Marts for targeted analysis
- OLAP operations via Power BI dashboard

## Dataset

E-commerce transaction data:
- 250,000+ transactions
- Customer, product, and temporal dimensions
- Real-world metrics: sales, returns, payment methods, churn rate

## Architecture

**Dimensional Model (Star Schema):**
- **dim_client**: Customer information (age, gender, payment method)
- **dim_produit**: Product catalog (category, price)
- **dim_temps**: Time dimension (date, year, month, day of week)
- **faits_achats**: Fact table with transactional metrics

**Data Marts:**
1. Sales by product (category, period, quantity)
2. Customer behavior (purchases, returns, churn)
3. Temporal trends (daily, monthly, yearly)
4. Payment method analysis
5. Product returns analysis

## Repository Content

- **Report.pdf**: Complete analysis with methodology, schema design, and results
- **Code/**: Database scripts
  - `database_schema.sql`: Full ETL, star schema, data marts creation

## Key Features

- Data quality: cleaning, deduplication, null value handling
- Materialized views for optimized query performance
- Multi-dimensional analysis (drill-down, roll-up, slice, dice)
- Interactive Power BI dashboard with KPIs and filters

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Sales | 551.58M |
| Total Returns | 40K |
| Unique Customers | 39.55K |
| Total Quantity Sold | 607K |
| Average Return Rate | 0.50 |
| Average Churn Rate | 0.20 |

## OLAP Operations Implemented

- **Roll-up**: Aggregate sales from month → year
- **Drill-down**: Explore sales by customer, product, period
- **Slice**: Filter by gender or payment method
- **Dice**: Cross dimensions (e.g., sales by gender AND product in a given period)

## Technology Stack

- **Database**: PostgreSQL
- **ETL**: SQL (CREATE, INSERT, JOIN, aggregations)
- **Analytics**: Power BI
- **Data Modeling**: Star schema (dimensional modeling)


## Project Highlights

- Complete ETL pipeline from raw data to analytical tables
- Proper dimensional modeling for efficient querying
- Multiple data marts for different analytical needs
- Integration with Power BI for interactive dashboards
- OLAP-ready structure enabling flexible analysis

## Authors

**Mesrour Lounis, Rabia Nassim, Mokhtari Anis Badredine, Dahmani Mahdi, Chamen Rayane**

Master 2 Applied Mathematics (Data Science & Decision Support)  
Université Abderrahmane Mira, Béjaïa, Algeria
