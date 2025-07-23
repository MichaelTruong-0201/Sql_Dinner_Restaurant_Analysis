# 🍽️ Phân Tích Doanh Thu và Hoạt Động Của Nhà Hàng Ăn Tối Danny (SQL + Azure Data Studio)

## 🎓 Tác giả
- Tên: Trương Trấn An
- Email: truongtranan1017@gmail.com

## 📌 Mục tiêu dự án
Dự án nhằm phân tích dữ liệu vận hành của nhà hàng **Danny Dinner** để:
- Hiểu rõ hành vi khách hàng và mức độ chi tiêu
- Phân loại nhóm khách hàng theo doanh thu
- Đánh giá sản phẩm phổ biến
- Mô phỏng tính toán **chương trình khuyến mãi** dựa trên lịch sử hóa đơn theo số điểm

---

## 🛠️ Công cụ và công nghệ
- **Azure Data Studio (Localhost)**
- **SQL Server (Local)**  
- **Ngôn ngữ SQL**: `JOIN`, `ORDER BY`, `GROUP BY`, `CTE`

---

## 🗂️ Cấu trúc dữ liệu mô phỏng
Database: `Danny_Dinner`

### Các bảng chính:
- `sales`: customer_id, order_date, product_id  
- `menu`: product_id, product_name, price
- `member`: customer_id, join_date

---

## 🔍 Phương pháp thực hiện
1. **Khởi tạo database**: `CREATE DATABASE Danny_Dinner`
2. **Tạo bảng và thêm dữ liệu mẫu** (`CREATE TABLE`, `INSERT INTO`)
3. **Phân tích doanh thu theo tháng, món ăn, khách hàng**  
4. **Dùng `CTE` để xác định nhóm khách chi tiêu cao/thấp**
5. **Tính toán khuyến mãi dựa trên mức tiêu dùng**

---

## 🧠 Một số truy vấn tiêu biểu

### 📈 Which Item is the most popular for each customer?
```
With buy_per_cus as (Select customer_id, product_name, 
count(product_name) Over (Partition by customer_id, product_name order by customer_id) as total_purchased
From sales s left join menu m on s.product_id = m.product_id)

select customer_id, product_name,
Max(total_purchased) as Max_bougth_item
from buy_per_cus
group by customer_id, product_name
order by customer_id;
```

### 🍽️ If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
```
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
```
