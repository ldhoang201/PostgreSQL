-- 1.Tìm sản phẩm dựa vào tên và giá thành trong khoảng(;)

select *
from sanpham
where upper(ten) like '%NIKE%'
  and gia between 30 and 80;

-- 2.Sắp xếp sản phẩm theo số lượng tồn kho

select *
from sanpham sp
order by sp.soluong desc;

-- 3.Tìm đơn hàng theo ngày đặt đơn

select *
from donhang
where ngaydat::date = '2021-11-21';
select *
from donhang
where extract(year from ngaydat) = '2020';
select *
from donhang
where extract(month from ngaydat) = '12';

-- 4.Đưa ra đơn hàng có số lượng đặt nhiều nhất

select *
from donhang dh
         join chitietdon ctd
              on dh.id = ctd.order_id
where soluong = (select max(soluong) from chitietdon);

-- 5.Đưa ra số sản phẩm được mua theo màu sắc,size

select mausac, count(soluong) as duocdatmua
from chitietdon
group by mausac
order by duocdatmua desc;

select kichco, count(soluong) as duocdatmua
from chitietdon
group by kichco
order by duocdatmua desc;

-- 6.Đưa ra các sản phẩm không được đặt mua

select sp.id, sp.ten
from sanpham sp
         join chitietdon ctd on sp.id = ctd.product_id
where sp.id not in (select product_id from chitietdon);

-- 7.Đưa ra những khách hàng mua 1 loại sản phẩm nào đó

select distinct tk.id, tk.ten, tk.sdt, tk.diachi
from taikhoan tk
         join donhang dh on tk.id = dh.user_id
         join chitietdon ctd on dh.id = ctd.order_id
         join sanpham sp on ctd.product_id = sp.id
where upper(sp.ten) like '%NEW%';

-- 8.Cho biết có bao nhiêu khách đến từ 1 tỉnh nào đó

select count(id)
from taikhoan
where upper(diachi) like '%BẮC NINH%';

-- 9.Thống kê số đơn hàng theo tỉnh thành

select dh.user_id, tk.diachi, count(dh.id)
from donhang dh
         join taikhoan tk
              on dh.user_id = tk.id
group by dh.user_id, tk.diachi;

-- 10.Cho biết sản được bán chạy nhất trong 1 tháng bất kì

with tmp_table as
         (
             select sp.id, sp.ten, sum(ctd.soluong) as tong_so_luong
             from sanpham sp
                      join chitietdon ctd
                           on sp.id = ctd.product_id
                      join donhang dh
                           on ctd.order_id = dh.id
             where extract(month from dh.ngaydat) = '11'
             group by sp.id
         )

select *
from tmp_table
where tong_so_luong = (select max(tong_so_luong) from tmp_table);

-- 11.Tạo view xem chi tiết đơn hàng theo mã đơn hàng

create or replace view view_chitetdon1
as
(
select dh.id,
       tk.ten,
       tk.diachi,
       dh.trangthaidon,
       dh.ngaydat,
       dh.ngayhengiao,
       sp.ten,
       ctd.soluong,
       ctd.mausac,
       ctd.kichco
from donhang dh
         join chitietdon ctd
              on dh.id = ctd.order_id
         join sanpham sp
              on ctd.product_id = sp.id
         join taikhoan tk
              on dh.user_id = tk.id
where dh.id = 52
    );


-- 12.Hàm update ngày hẹn giao (ngày dự kiến giao)

CREATE FUNCTION updadelivery()
    RETURNS void
    LANGUAGE PLPGSQL
AS
$$
DECLARE
    i int;
BEGIN
    for i in (select id from donhang)
        loop
            update donhang set ngayhengiao = ngaydat + interval '5 day' where id = i;
        end loop;
END;
$$;


-- 13.Xem nhận xét

select sp.ten, tk.ten, nx.noidung, nx.sao
from nhanxet nx
         join taikhoan tk
              on nx.user_id = tk.id
         join sanpham sp
              on sp.id = nx.product_id;

-- 14. Nhập thêm sản phẩm mới

insert into sanpham (gia, soluong, ten, mota)
values (100, 4, 'Thuong Dinh', 'Giầy rất bền');

insert into sanpham (gia, soluong, ten, mota)
values (111, 4, 'Bitis Hunter', 'Giầy siêu bền, đẹp, giá đắt');


-- 15. Kiểm tra xem sản phẩm nào có số lượng tồn kho ít hơn 5 thì nhập thêm 100 sản phẩm đó.

select soluong, ten
from sanpham;
update sanpham
set soluong = soluong + 100
where soluong < 5;

-- 16. Đưa ra sản phẩm có đánh giá tệ nhất (dựa trên số trung bình *)

with tmp_min as (
    select n.product_id, sp.ten, avg(sao)::real as danhgia
    from nhanxet n
             join sanpham sp on sp.id = n.product_id
         --where n.product_id = 2
    group by n.product_id, sp.ten
)

select *
from tmp_min
where danhgia = (select min(danhgia) from tmp_min);

-- 17. cập nhật trạng thái đơn hàng và số lượng sản phẩm khi trả hàng
create or replace function update_trang_thai(in orderid integer)
    returns void as
$$
declare
    chitietdonid integer;
begin
    update donhang
    set trangthaidon = 'Trả hàng.'
    where id = orderid;
    for chitietdonid in (select chitietdon.id
                         from chitietdon
                                  join donhang d on chitietdon.order_id = d.id
                         where d.id = orderid)
        loop
            update sanpham
            set soluong = soluong + (select soluong from chitietdon where id = chitietdonid)
            where id = (select product_id from chitietdon where id = chitietdonid);
        end loop;
end;
$$
    language plpgsql;
-- 18. Đưa ra doanh thu trong tháng hiện tại.

select sum(ctd.soluong * s.gia) as doanh_thu
from chitietdon ctd
         join sanpham s on ctd.product_id = s.id
         join donhang d on d.id = ctd.order_id
where extract(month from d.ngaydat) = extract(month from current_date);

-- 19. Sắp xếp số tiền mà khách hàng đã thanh toán theo chiều giảm dần

create or replace view thanhtoan
as
(
select tk.id, tk.user, tk.ten, tk.sdt, tk.diachi, sum(ctd.soluong * s.gia) as thanh_toan
from taikhoan tk
         join donhang dh on dh.user_id = tk.id
         join chitietdon ctd on dh.id = ctd.order_id
         join sanpham s on ctd.product_id = s.id
group by tk.id, tk.user, tk.ten, tk.sdt, tk.diachi
order by thanh_toan desc
    );

-- 20. Đưa ra sản phẩm có đánh giá tốt nhất (dựa trên số trung bình *)

with tmp as (
    select n.product_id, sp.ten, avg(sao)::real as danhgia
    from nhanxet n
             join sanpham sp on sp.id = n.product_id
         --where n.product_id = 2
    group by n.product_id, sp.ten
)

select *
from tmp
where danhgia = (select max(danhgia) from tmp);

-- 21. Những đơn hàng đã giao xong

select *
from donhang
where ngayhengiao <= current_date;
-- 22. đơn hàng chưa giao xong
select *
from donhang
where ngayhengiao > current_date;

-- 23. Thống kê theo số lượng đơn khách hàng đã đặt

select tk.id, tk.user, tk.ten, tk.sdt, tk.diachi, count(dh.id)
from taikhoan tk
         join donhang dh on dh.user_id = tk.id
group by tk.id, tk.user, tk.ten, tk.sdt, tk.diachi
order by count(dh.id) desc;


-- 24. Thống kê những sản phẩm và số lượng bị trả lại hàng

select tk.id,
       tk.user,
       th.order_id,
       ctd.product_id,
       sp.ten     as tensp,
       ctd.mausac,
       ctd.kichco,
       th.ngaytao as ngay_huy_don
from trahang th
         join chitietdon ctd on th.order_id = ctd.order_id
         join donhang dh on dh.id = ctd.order_id
         join sanpham sp on sp.id = ctd.id
         join taikhoan tk on tk.id = dh.user_id
group by tk.id, tk.user, th.order_id, ctd.product_id, tensp, ctd.mausac, ctd.kichco, ngay_huy_don;

-- 25. Danh sách người mua đến từ Thanh Hóa
select *
from taikhoan
where diachi like '%Thanh Hóa%';
-- 26. Top 10 đơn hàng đặt mua gần nhất
select *
from donhang
order by id desc
limit 10;
-- 27. Đưa ra danh sách sản phẩm có giá trên 80$
select *
from sanpham
where gia > 80;
-- 28. Đưa ra danh sách sản phẩm sắp hết hàng (số lượng < 10)
select *
from sanpham
where soluong < 10;
-- 29. Đưa ra danh sách 5 khách hàng đặt đơn nhiều nhất trong tháng
select taikhoan.*
from taikhoan
         join donhang d on taikhoan.id = d.user_id
where trangthaidon = 'Giao hàng thành công.'
  and current_date - d.ngaydat <= 30
group by taikhoan.id
order by count(d.id) desc
limit 5;
-- 30. Đưa ra danh sách 5 khách hàng chi tiêu nhiều nhất trong tháng
select taikhoan.*
from taikhoan
         join donhang d on taikhoan.id = d.user_id
         join chitietdon c on d.id = c.order_id
         join sanpham s on s.id = c.product_id
where trangthaidon = 'Giao hàng thành công.'
  and current_date - d.ngaydat <= 30
group by taikhoan.id
order by sum(s.gia * c.soluong) desc
limit 5;
-- 31. Đưa ra danh sách 5 khách hàng phản hồi tích cực nhất
select taikhoan.*
from taikhoan
         join nhanxet n on taikhoan.id = n.user_id
group by taikhoan.id
order by count(n.id) desc
limit 5;
-- 32. Đưa ra danh sách 5 sản phẩm được nhiều khách hàng mua nhất trong tháng
select sanpham.*
from sanpham
         join chitietdon c on sanpham.id = c.product_id
         join donhang d on d.id = c.order_id
where trangthaidon = 'Giao hàng thành công.'
  and current_date - d.ngaydat <= 30
group by sanpham.id
order by count(distinct d.user_id) desc;
-- 33. Đưa ra danh sách 5 khách hàng trả hàng nhiều nhất
select taikhoan.*
from taikhoan
         join donhang d on taikhoan.id = d.user_id
where trangthaidon = 'Trả hàng.'
group by taikhoan.id
order by count(d.id) desc;
-- 34. Đưa ra danh sách 5 khách hàng hủy nhiều nhất
select taikhoan.*
from taikhoan
         join donhang d on taikhoan.id = d.user_id
where trangthaidon = 'Đơn đã hủy.'
group by taikhoan.id
order by count(d.id) desc;