insert into lecturer values('02002','Tuyet Trinh','Vu','10/1/1975','F','','trinhvt@soict.hust.edu.vn');
insert into lecturer values('02003','Linh','Truong','9/8/1976','F','Ha Noi','');
insert into lecturer values('02004','Quang Khoat','Than','10/8/1982','M','Ha Noi','khoattq@soict.hust.edu.vn');
insert into lecturer values('02005','Oanh','Nguyen','2/18/1978','F','HBT,Hn','oanhnt@soict.hust.edu.vn');
insert into lecturer values('02006','Nhat Quang','Nguyen','4/16/1976','M','HBT,HN','quangnn@soict.hust.edu.vn');
insert into lecturer values('02007','Hong Phuong','Nguyen','3/12/1984','M','17A Ta Quang Buu,HBT,HN','phuongnh@soict.hust.edu.vn');

insert into clazz values('20162101','CNTT1.01-K61','02001',null);
insert into clazz values('20162102','CNTT1.02-K61',null,null);
insert into clazz values('20172201','CNTT1.01-K62','02002',null);
insert into clazz values('20162202','CNTT1.02-K62',null,null);

insert into student values('20160001','Ngoc An','Bui','3/18/1987','15 Luong Dinh Cua,D.Da,Hn',null,null);
insert into student values('20160002','Anh','Hoang','5/20/1987','513 B8 KTX BKHN',null,'20162101');
insert into student values('20160003','Thu Hong','Tran','6/6/1987','15 Tran Dai Nghia,HBT,Ha Noi','','20162101');
insert into student values('20160004','Minh Anh','Nguyen','5/20/1987','513 TT Phuong Mai,D.Da,HN','','20162101');
insert into student values('20170001','Nhat Anh','Nguyen','5/15/1988','214 B6 KTX BKHN','','20172201');

update clazz set monitor_id = '20160003' where clazz_id = '20162101';
update clazz set monitor_id = '20170001' where clazz_id = '20172201';

select * from subject where credit >= 5;
select student.* from student, clazz where clazz.name = 'CNTT1.01-K61' and clazz.clazz_id = student.clazz_id;


