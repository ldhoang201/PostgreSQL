select * from products;
select * from categories;
select * from orders;
select * from orderlines;
select * from customers;
select * from inventory;
select * from cust_hist;

1--Đưa ra danh sách các sản phẩm (prod_id, title) thuộc loại (category) "Documentary".
select p.prod_id,p.title
from products p
         join categories c on p.category = c.category
where c.categoryname = 'Documentary';

2--Đưa ra thông tin chi tiết về sản phẩm trong hóa đơn có mã số 942. Thông tin chi tiết: orderlineid, prod_id, product title, quantiy, price, amount

create index idx_order_orderid on orders(orderid);

select  ol.orderlineid, ol.prod_id, p.title, ol.quantity, p.price, o.totalamount 
from orderlines ol join orders o on o.orderid = ol.orderid 
join products p on ol.prod_id = p.prod_id 
where o.orderid = '942';

3--Hãy cho biết có bao nhiêu khách hàng khác nhau đã từng mua ít nhất 1 sản phẩm
select count(distinct c.customerid) from orders o,customers c 
where c.customerid = o.customerid; 

4--Đưa ra danh sách tên các nước có khách hàng đã đặt hàng. Sắp xếp theo thứ tự alphabet
select distinct country 
from customers c join orders o on c.customerid = o.customerid
order by country asc;

5--Đưa ra danh sách tên nước, số lượng khách hàng và số lượt khách hàng đã mua hàng đến từ mỗi nước
select c.country,count(distinct o.customerid),count(o.customerid) from 
customers c left join orders o using(customerid)
group by country;

6--Hiển thị ra tổng tiền (totalamount) lớn nhất, nhỏ nhất, và trung bình trên hóa đơn.
select max(totalamount) as max_of_totalamount,
min(totalamount) as min_of_totalamount ,
avg(totalamount) as avg_of_totalamount
from orders ; 

7--Đưa ra thống kê theo giới tính về số lượt khách hàng mua cho mỗi loại sản phẩm (category). Sắp xếp giảm dần  theo số lượt mua của loại sản phẩm


select c.category,c.categoryname,
		 count(case when cus.gender = 'M' then 1 end ) as men,
		 count(case when cus.gender = 'F' then 1 end ) as women
from categories c 
		 join products p on c.category = p.category
         join orderlines ol on p.prod_id = ol.prod_id
         join orders o on o.orderid = ol.orderid
         join customers cus on cus.customerid = o.customerid
group by c.category
order by count(o.orderid) desc;

--cách khác

select c.category, c.categoryname,
count(cus.customerid) filter (where gender = 'M') as number_of_male,
count(cus.customerid) filter (where gender = 'F') as number_of_female
from products p join orderlines ol on p.prod_id = ol.prod_id
join orders o on ol.orderid = o.orderid
join customers cus on o.customerid = cus.customerid
right join categories c on p.category = c.category
group by c.category;


8--Cho biết có bao nhiêu khách hàng từ "Germany"?
select count(customerid) 
from customers where country = 'Germany';

9-- Đưa ra danh sách khách hàng đã có tổng hóa đơn mua hàng vượt quá 2.000
select c.customerid,c.firstname ||' '|| c.lastname as customer_name
from customers c join orders o using(customerid)
where o.totalamount > 2000;

10--Đưa ra danh sách các sản phẩm mà tiêu đề (title) có chứa "Apollo" (không quan trọng chữ hoa, chữ thường) và có giá ít hơn 10$
select * from products 
where title ilike '%Apollo%' 
and price < 10;

11--Đưa ra danh sách loại sản phẩm mà không có mặt hàng nào được đặt mua
select c.* from products p join categories c using(category)
left join orderlines o using(prod_id)
where o.orderlineid is null;

--sửa
Select *
From categories
Where category not in (select distinct p.category from orderlines od join products p on od.prod_id=p.prod_id);

select categories.*
from categories
where categories.category not in(
select distinct products.category 
from orderlines 
join products on orderlines.prod_id = products.prod_id);

12--Đưa ra danh sách các khách hàng (mã khách hàng, họ và tên) đã mua cả hai sản phẩm có title "AIRPORT ROBBERS" và " AGENT ORDER" (không phân biệt chữ hoa, chữ thường).

create index idx_product_title on products(title);
drop index idx_product_title;

select c.customerid,c.firstname ||' '|| c.lastname as customer_name from
(customers c join orders o using(customerid)) join orderlines using(orderid)
join products p using(prod_id)
where p.title ilike 'AIRPORT ROBBERS'
intersect 
select c.customerid,c.firstname ||' '|| c.lastname as customer_name from
(customers c join orders o using(customerid)) join orderlines using(orderid)
join products p using(prod_id)
where p.title ilike '%AGENT ORDER%';

13--Lập danh sách các sản phẩm đã được mua trong ngày (orderdate) (ngày lập danh sách)
select * 
from products p join orderlines o using (prod_id)
where orderdate = (select current_date);

14--Đưa ra danh sách tên các mặt hàng và số lượng tồn của các mặt hàng không có người mua trong tháng 12/2004.

select p.prod_id,p.title,i.quan_in_stock,o.orderdate from products p left join (orderlines o 
join inventory i using(prod_id) ) using(prod_id)
where extract('month' from o.orderdate) != '12' ;

15--Đưa ra danh sách sản phẩm (prod_id, title, sốlượng đã bán)bán chạy nhất(sản phẩm được bán với số lượng lớn nhất)trong tháng 12/2004
with tmp as(
	select p.prod_id,p.title,sum(o.quantity) as sales
	from products p
	join orderlines o using(prod_id) 
	where extract('month' from o.orderdate) = '12' and extract('year' from o.orderdate) = '2004'
	group by prod_id
	order by sales desc
)

select * 
from tmp
where sales = (select max(sales) from tmp);

with bang as(
select p.prod_id,p.title, sum(o.quantity) as tong
from products p join orderlines o
on p.prod_id=o.prod_id
and date_part('year', orderdate) = 2004
and date_part('month', orderdate) =12
group by p.prod_id
)
select * from bang where bang.tong in( select max(bang.tong) from bang)

select products.prod_id,products.title,sum (orderlines.quantity)
from products left join orderlines using (prod_id)
where extract ('year' from orderdate) = 2004
and extract ('month' from orderdate) = 12
group by products.prod_id
having sum (orderlines.quantity) in (select max(slsp) from sum_quantity)
order by sum(orderlines.quantity) DESC;



create or replace view sum_quantity as(
select orderlines.prod_id, sum (orderlines.quantity) as slsp
from orderlines
where extract ('year' from orderdate) = 2004
and extract ('month' from orderdate) = 12
group by orderlines.prod_id
order by sum(orderlines.quantity) DESC)

select * from sum_quantity;

create or replace view suborder as
(select prod_id, sum(quantity) as total from orderlines
where
date_part('month', orderdate) = 12
and date_part('year', orderdate) = 2004
group by (prod_id))

select pro.prod_id, pro.title, i.sales
from products as pro, suborder as sub, inventory as i
where pro.prod_id = sub.prod_id
and i.prod_id = pro.prod_id
and sub.total = (select max(total) from suborder)



select * from suborder
order by total desc








