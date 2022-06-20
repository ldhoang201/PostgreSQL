--1

select * 
from subject where credit >= 2;
--2
select student.* 

from student join clazz on (student.clazz_id = clazz.clazz_id) 
where name ='CNTT1.01-K61';

--3
select student.* 
from student join clazz on (student.clazz_id = clazz.clazz_id) 
where name like '%CNTT%';

--4
    select student.* 
	from student,enrollment,subject 
	where student.student_id = enrollment.student_id and enrollment.subject_id = subject.subject_id
	and subject.name = 'Cơ sở dữ liệu'
intersect 
    select student.* 
	from student,enrollment,subject 
	where student.student_id = enrollment.student_id and enrollment.subject_id = subject.subject_id
	and subject.name = 'Mạng máy tính';
--5
    select distinct student.* 
	from student,enrollment,subject 
	where student.student_id = enrollment.student_id and enrollment.subject_id = subject.subject_id
	and subject.name = 'Cơ sở dữ liệu'
union
    select distinct student.* 
	from student,enrollment,subject 
	where student.student_id = enrollment.student_id and enrollment.subject_id = subject.subject_id
	and subject.name = 'Mạng máy tính';
--6
SELECT * 
FROM subject
WHERE subject_id NOT IN(SELECT subject_id FROM enrollment);
--8
select student.student_id,student.first_name,student.last_name,enrollment.midterm_score,enrollment.final_score,((midterm_score * (1- percentage_final_exam/100.0) + final_score
*percentage_final_exam/100.0)) as subject_score,subject.percentage_final_exam
from student,subject,enrollment
where student.student_id = enrollment.student_id
and subject.subject_id = enrollment.subject_id
and subject.name ='Cơ sở dữ liệu' and enrollment.semester = '20172';
--9
with tmp as (
select student.student_id,student.first_name,student.last_name,enrollment.midterm_score,enrollment.final_score,((midterm_score * (1- percentage_final_exam/100.0) + final_score
*percentage_final_exam/100.0)) as subject_score,subject.percentage_final_exam
from student,subject,enrollment
where student.student_id = enrollment.student_id
and subject.subject_id = enrollment.subject_id)

select * from tmp 
where tmp.midterm_score < 3 or tmp.final_score < 3 or tmp.subject_score < 4;
--10
select distinct student.*,c.monitor
from student
left join
(select clazz.clazz_id,last_name||' '||first_name monitor
from clazz
left join student on monitor_id=student_id) as c
on student.clazz_id=c.clazz_id;
--11
select * 
from student 
where (2021 - extract('year' from dob)) >= 25;
