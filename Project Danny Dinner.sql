-- Danny Dinner Project SQL
CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

select * from menu
select * from sales
select * from members
/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
    -- how many points do customer A and B have at the end of January?

--Bài làm

-- Question 1
Select customer_id, Sum(price) as total_amout
from sales s left join menu m on s.product_id = m.product_id
group by customer_id

--Question 2
select customer_id, count(distinct(order_date)) day_count
from sales
group by customer_id


--Question 3
Select DISTINCT customer_id, product_name, order_date
From sales s LEFT join menu m on s.product_id = m.product_id
where order_date = (
    select Min(order_date) first_date 
    from sales s LEFT join menu m on s.product_id = m.product_id
    )

-- Question 4
with max_sales as (select product_name, count(product_name) total_sales_product
from sales s left join menu m on s.product_id = m.product_id
group by product_name)

select customer_id, product_name ,count(product_name) Max_bought_item_per_cus
from sales s left join menu m on s.product_id = m.product_id
where product_name = (
    select product_name
    from max_sales 
    where total_sales_product = (
        select Max(total_sales_product) 
        from max_sales))
group by customer_id, product_name;

--Question 5
With buy_per_cus as (Select customer_id, product_name, 
count(product_name) Over (Partition by customer_id, product_name order by customer_id) as total_purchased
From sales s left join menu m on s.product_id = m.product_id)

select customer_id, product_name,
Max(total_purchased) as Max_bougth_item
from buy_per_cus
group by customer_id, product_name
order by customer_id

-- Question 6 
with ddif as (
select s.customer_id, s.order_date, 
        m.join_date, me.product_name, 
        DATEDIFF(Day,join_date, order_date) as date_diff
from sales s INNER join members m on s.customer_id = m.customer_id 
              inner join menu me on s.product_id = me.product_id
where order_date > join_date)

select *
from ddif
where date_diff In (select Min(date_diff) from ddif group by customer_id)

--Question 7
with ddif as (
select s.customer_id, s.order_date, 
        m.join_date, me.product_name, 
        DATEDIFF(Day,join_date, order_date) as date_diff
from sales s INNER join members m on s.customer_id = m.customer_id 
              inner join menu me on s.product_id = me.product_id
where order_date < join_date)

select *
from ddif
where date_diff In (select Max(date_diff) from ddif group by customer_id)

--Question 8
select s.customer_id, order_date, product_name, price,
Sum(m.price) Over (Partition by s.customer_id, s.order_date ) as amount_spend, 
count(m.product_name) Over (Partition by s.customer_id, s. order_date) as total_items
from sales s inner join menu m on s.product_id = m.product_id 
              inner join members me on me.customer_id = s.customer_id 
where order_date < join_date
group by s.customer_id, order_date, product_name, price
order by customer_id

--Question 9
with cal_point as (select s.customer_id, order_date, s.product_id, price, product_name,
Case 
    when product_name = 'sushi' then price*20
Else price*10
End as point
from sales s LEFT join menu m on s.product_id = m.product_id 
              LEFT join members me on me.customer_id = s.customer_id)
select Customer_id, sum(point) as total_point_per_cus
from cal_point
group by customer_id;

--Question 10
with cal_point_AB as (select s.customer_id, price, product_name, order_date, join_date,
Case 
     when order_date < join_date and product_name = 'sushi' then price*20
     when order_date < join_date then price*10
     when DateDiff(day, order_date, join_date) <= 7 then price*20
Else price*10
End as cal_point
from sales s inner join members me on s.customer_id = me.customer_id
             inner join menu m on m.product_id = s.product_id)
select customer_id, sum(cal_point) as total_point_in_January
from cal_point_AB
where Datepart(month, order_date) = 1
group by customer_id