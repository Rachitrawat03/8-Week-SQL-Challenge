# Danny's Diner SQL Data Analysis Project

This repository contains the SQL queries and insights generated from the analysis of data provided by Danny's Diner, a restaurant specializing in sushi, curry, and ramen. The project aimed to assist Danny in understanding customer behavior, optimizing operations, and improving customer experience based on the available data.

## Project Overview

Danny's Diner collected transactional data and member information, seeking to answer various questions about customer spending, visit patterns, favorite menu items, and loyalty program effectiveness. The project utilized MySQL Workbench and employed various SQL functions and techniques to derive insights and answer specific questions provided in the problem statement.

## Data Analysis Tasks

The project addressed the following questions using SQL queries:

1. Total amount spent by each customer.
2. Number of days each customer visited the restaurant.
3. First item purchased from the menu by each customer.
4. Most purchased item on the menu and its frequency.
5. Most popular item for each customer.
6. Item purchased first by the customer after joining the loyalty program.
7. Item purchased just before the customer joined the loyalty program.
8. Total items and amount spent for each member before joining.
9. Calculation of loyalty points based on spending.
10. Calculation of loyalty points earned by customers A and B at the end of January.

## Bonus Questions

Additional SQL queries were developed to create basic data tables for quick insights and to rank customer products, fulfilling Danny's requirements.

## Insights

- Customer A spent the most money ($76).
- Customer B was the most frequent visitor (6 times).
- The first order of customer A was sushi, customer B was curry, and customer C was ramen.
- The most purchased item was ramen (8 times).
- Customer A and C prefer ramen, while customer B enjoys curry, sushi, and ramen equally.
- Customer A was the first member, and his first item was curry.
- Before becoming members, customer A and B spent $25 and $40, respectively.
- Customer A, B, and C accumulated 860, 940, and 360 points, respectively, by the end of January.
- Assuming members can earn 2x points weekly from the day they join, customer A has 660 points, and customer B has 340 points by the end of January 2021.

## Tools Used

- MySQL Workbench
- SQL Functions:
  - Aggregate functions (SUM, COUNT)
  - Table Joins
  - Ranking functions (RANK, DENSE_RANK)
  - Date Functions (DATE_ADD, LAST_DAY)
  - Common Table Expressions (CTE)
  - Window function

## Conclusion

By analyzing the provided data, valuable insights were gained into customer behavior and the effectiveness of the loyalty program, allowing Danny to make informed decisions to enhance his restaurant's operations and customer satisfaction.
