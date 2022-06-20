1--
1.1--
create view student_shortinfos as
	select student_id, first_name, last_name, gender, dob, clazz_id 
	from student; 

select * from student_shortinfos;

1.2--
insert into student_shortinfos 
values ('20160005','Văn A','Nguyễn','M','1988-05-20','20162101');

update student_shortinfos set last_name = 'Đinh' 
where student_id = '20160005';

delete from student_shortinfos 
where student_id = '20160005';

1.3--
select student_id ,last_name ||' '|| first_name as full_name ,gender ,name as class_name 
from student_shortinfos s
join clazz c on (s.clazz_id = c.clazz_id); 

select s.clazz_id , c.name as class_name , count(s.student_id) as number_of_student
from student_shortinfos s
join clazz c using(clazz_id)
group by s.clazz_id , c.name
order by number_of_student;

1.4-- 
--insert không thành công vì address(student) là NOTNULL mà khi insert vào view không insert cột address.
insert into student_shortinfos 
values ('20160008','Khánh A','Nguyễn','F','1989-07-20','20162101');

--fix
alter table student alter column address set default '';
insert into student_shortinfos 
values ('20160008','Khánh A','Nguyễn','F','1989-07-20','20162101');

1.5--
update student 
set dob = '1988-11-25' where student_id = '20170003';

select * from student_shortinfos;

1.6--
insert into student values('20160006','Hải Đường','Đỗ','1989-02-20','M','Phố Vọng,HBT,HN','','20162101');

select * from student_shortinfos;

3--
3.1--
create or replace view class_infos as
	select s.clazz_id , c.name as class_name , count(s.student_id) as number_of_student
	from student_shortinfos s
	join clazz c using(clazz_id)
	group by s.clazz_id , c.name
	order by number_of_student;
	
select * from class_infos;

3.2-- Try to insert/update/delete into/from view class_infos
--ERROR:Bảng tạo bởi view chứa các lệnh như group by,count,... không thể insert/update/delete  
insert into class_infos 
values ('20162103','CNTT3.02-K62',5);

update class_infos set class_name = 'VN02' 
where clazz_id = '20162102';

delete 
from class_infos 
where class_name = 'CNTT1.01-K61';


