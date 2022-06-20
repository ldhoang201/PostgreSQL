select * from sanpham;
select * from chitietdon;
select * from trahang;
select * from donhang;
select * from taikhoan;
select * from nhanxet;

--Tìm sản phẩm dựa vào tên và giá thành trong khoảng(;)

select * 
from sanpham 
where upper(ten) like '%NIKE%'
and gia between 30 and 80;

--Sắp xếp sản phẩm theo số lượng tồn kho

select * 
from sanpham sp
order by sp.soluong desc;

--Tìm đơn hàng theo ngày đặt đơn

select * from donhang where ngaydat::date = '2021-11-21';
select * from donhang where extract(year from ngaydat) = '2020';
select * from donhang where extract(month from ngaydat) = '12';

--Đưa ra đơn hàng có số lượng đặt nhiều nhất

select * from donhang dh 
join chitietdon ctd 
on dh.id = ctd.order_id 
where soluong = (select max(soluong) from chitietdon);

--Đưa ra số sản phẩm được mua theo màu sắc,size

select mausac,count(soluong) as duocdatmua 
from chitietdon
group by mausac
order by duocdatmua desc;

select kichco,count(soluong) as duocdatmua 
from chitietdon
group by kichco
order by duocdatmua desc;

--Đưa ra các sản phẩm không được đặt mua

select sp.id,sp.ten 
from sanpham sp 
join chitietdon ctd on sp.id = ctd.product_id
where sp.id not in (select product_id from chitietdon);

--Cho biết có bao nhiêu khách đến từ 1 tỉnh nào đó

select count(id) from taikhoan 
where upper(diachi) like '%BẮC NINH%';

--Thống kê số đơn hàng theo tỉnh thành

select dh.user_id,tk.diachi,count(dh.id)
from donhang dh
join taikhoan tk
on dh.user_id = tk.id
group by dh.user_id,tk.diachi;

--Cho biết sản được bán chạy nhất trong 1 tháng bất kì

with tmp_table as
(
	select sp.id,sp.ten,sum(ctd.soluong) as tong_so_luong
	from sanpham sp 
	join chitietdon ctd
	on sp.id = ctd.product_id
	join donhang dh 
	on ctd.order_id = dh.id
	where extract(month from dh.ngaydat) = '2'
	group by sp.id
)

select * 
from tmp_table
where tong_so_luong = (select max(tong_so_luong) from tmp_table);

--Tạo view xem chi tiết đơn hàng theo mã đơn hàng

create or replace view view_chitetdon1
as (
	select dh.id,tk.ten,tk.diachi,dh.trangthaidon,dh.ngaydat,
	dh.ngayhengiao,sp.ten,ctd.soluong,ctd.mausac,ctd.kichco
	from donhang dh join chitietdon ctd
	on dh.id = ctd.order_id
	join sanpham sp 
	on ctd.product_id = sp.id
	join taikhoan tk
	on dh.user_id = tk.id
	where dh.id = 52
)
select * from view_chitetdon1;


---Hàm update ngày hẹn giao (ngày dự kiến giao)

CREATE FUNCTION updadelivery() 
   RETURNS void 
   LANGUAGE PLPGSQL
AS $$
DECLARE i int;
BEGIN
	for i in (select id from donhang)
		loop
		  update donhang set ngayhengiao = ngaydat + interval '5 day' where id = i;
		end loop;
END;
$$

select updadelivery();
   
--Xem nhận xét

select sp.ten,tk.ten,nx.noidung,nx.sao 
from nhanxet nx
join taikhoan tk
on nx.user_id = tk.id
join sanpham sp
on sp.id = nx.product_id


--Đưa ra những khách hàng mua 1 sản phẩm nào đó

select distinct tk.id,tk.ten,tk.sdt,tk.diachi 
from taikhoan tk join donhang dh on tk.id = dh.user_id
join chitietdon ctd on dh.id = ctd.order_id
join sanpham sp on ctd.product_id = sp.id
where upper(sp.ten) like '%THUONG DINH%';

--Đưa ra 
with tmp_table as
(
	select sp.id,sp.ten,sum(ctd.soluong) as tong_so_luong
	from sanpham sp 
	join chitietdon ctd
	on sp.id = ctd.product_id
	join donhang dh 
	on ctd.order_id = dh.id
	where extract(month from dh.ngaydat) = '2'
	group by sp.id
)

select * 
from tmp_table
where tong_so_luong = (select max(tong_so_luong) from tmp_table);

--Đưa ra danh sách 5 khách hàng chi tiêu nhiều nhất trong tháng hiện tại
select tk.id,tk.ten,tk.sdt,tk.diachi
from taikhoan tk
         join donhang d on tk.id = d.user_id
         join chitietdon c on d.id = c.order_id
         join sanpham s on s.id = c.product_id
where trangthaidon = 'Giao hàng thành công.'
  and extract(month from d.ngaydat) = extract(month from current_date)
group by tk.id
order by sum(s.gia * c.soluong) desc
limit 5;



  









