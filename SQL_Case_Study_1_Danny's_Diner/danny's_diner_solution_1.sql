-- 1.  What is the total amount each customer spent at the restaurant?

SELECT 
    s.customer_id, SUM(price) AS Total_amount_spent
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;	

-- 2. How many days has each customer visited the restaurant?

SELECT 
    s.customer_id,
    COUNT(DISTINCT order_date) AS num_of_days_visited
FROM
    sales s
GROUP BY customer_id
ORDER BY num_of_days_visited DESC;

-- 3. What was the first item from the menu purchased by each customer?

SELECT 
    s.customer_id,
    m.product_name,
    MIN(s.order_date) AS first_order_date
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT 
    m.product_name,
    COUNT(product_name) AS num_of_times_purchased
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name
ORDER BY num_of_times_purchased DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?

SELECT 
    customer_id,
    m.product_name,
    COUNT(product_name) AS num_of_times_purchased
FROM
    menu m
        JOIN
    sales s ON m.product_id = s.product_id
GROUP BY product_name , customer_id
ORDER BY num_of_times_purchased DESC;
  select customer_id,group_concat(product_name) as most_loved_item from
  (
  select s.customer_id,m.product_name, count(order_date) as total_purchases,
  rank() over (partition by s.customer_id order by count(*) desc ) as rank_item
  from sales s
  join menu m
  on s.product_id=m.product_id
  group by s.customer_id,m.product_name) x
  where rank_item=1
  group by x.customer_id ;
  
-- 6. Which item was purchased first by the customer after they became a member?
  
with member_first_purchase_cte as
(  
select s.customer_id,m.product_name,s.order_date,
dense_rank() over(partition by customer_id order by order_date) as drnk
from sales s
join members ms
on s.customer_id=ms.customer_id
join menu m
on s.product_id=m.product_id
where s.order_date>=ms.join_date)
select customer_id,product_name,order_date
from member_first_purchase_cte as mfp
where drnk = 1;

-- 7. Which item was purchased just before the customer became a member? 

with member_first_purchase_cte as
(  
select s.customer_id,m.product_name,s.order_date,
dense_rank() over(partition by customer_id order by order_date desc) as drnk
from sales s
join members ms
on s.customer_id=ms.customer_id
join menu m
on s.product_id=m.product_id
where s.order_date<ms.join_date)
select customer_id,product_name,order_date
from member_first_purchase_cte as mfp
where drnk = 1;
 
 -- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
    s.customer_id,
    SUM(price) AS total_amt_spend,
    COUNT(DISTINCT s.product_id) AS item_order_count
FROM
    sales s
        JOIN
    members ms ON s.customer_id = ms.customer_id
        JOIN
    menu m ON s.product_id = m.product_id
WHERE
    s.order_date < ms.join_date
GROUP BY s.customer_id;

-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier — how many points would each customer have?

SELECT 
    s.customer_id,
    SUM(CASE
        WHEN m.product_name = 'sushi' THEN m.price * 20
        ELSE m.price * 10
    END) total_points
FROM
    sales s
        JOIN
    menu m ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with dates_cte as (
 select *,
 date_add(join_date, interval 6 day) as first_week_join,
 last_day("2021-01-31") as last_date
 from members ms)
 select dates_cte.*,
 s.order_date,
 m.product_name,
 sum(case 
 when m.product_name = "sushi" then m.price*20
 when s.order_date between dates_cte.join_date and dates_cte.first_week_join then m.price*20
 else m.price*10
 end) as total_points
 from dates_cte 
 join sales s
 on s.customer_id=dates_cte.customer_id
 join menu m
 on m.product_id=s.product_id
 where s.order_date < dates_cte.first_week_join
 group by dates_cte.customer_id
 order by customer_id ;
 
 -- BONUS QUESTION 1
 
SELECT 
    s.customer_id,
    s.order_date,
    ms.join_date,
    m.product_name,
    m.price,
    CASE
        WHEN s.order_date >= '2021-01-07' THEN 'Y'
        WHEN s.order_date >= '2021-01-09' THEN 'Y'
        ELSE 'N'
    END AS member
FROM
    sales s
        JOIN
    menu m ON m.product_id = s.product_id
        JOIN
    members ms ON s.customer_id = ms.customer_id
ORDER BY s.customer_id , s.order_date , m.price DESC;
 
-- BONUS QUESTION 2

with rank_cte as ( select s.customer_id, s.order_date, ms.join_date, m.product_name, m.price,
 case
 WHEN s.order_date >= '2021-01-07' then 'Y' 
  WHEN s.order_date >= '2021-01-09' then 'Y'
else "N"
end as member
from sales s
join menu m
on m.product_id=s.product_id
join members ms
on s.customer_id=ms.customer_id
order by s.customer_id,s.order_date,m.price desc)
select *,case when member = "N" then null
else rank() over(partition by customer_id,member
order by order_date) end as ranking
from rank_cte;