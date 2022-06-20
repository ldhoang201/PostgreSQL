select * from student;
select * from clazz;
select * from enrollment;
select * from subject;
select * from teaching;
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
select * 
from subject
where subject_id not in(select subject_id from enrollment);
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

--11'

select count(distinct en.subject_id) as numberofsubjects
from enrollment en 
where en.student_id = '20160001';

--12
select *
from student 
where extract('year' from dob) = 1999 
and extract('month' from dob) = 6;

--12'
select * from student where 
extract('month' from dob) = extract('month' from current_date);

--13
select student.clazz_id,clazz.name,count(student.student_id) as numberofstudents
from student 
join clazz on (student.clazz_id = clazz.clazz_id)
group by student.clazz_id,clazz.name
order by numberofstudents;

--14
select min(en.midterm_score) as lowest_score,
       max(en.midterm_score) as highest_score,
       avg(en.midterm_score) as average_score
from enrollment en
        join subject s on s.subject_id = en.subject_id
where s.name = 'Mạng máy tính'
and semester = '20172';
  
--15
select tea.lecturer_id,lec.last_name ||' '|| lec.first_name as lecturer_name,count(tea.subject_id) as numberofsubjects
from teaching tea
join lecturer lec on (lec.lecturer_id = tea.lecturer_id)
group by lecturer_name,tea.lecturer_id;

--16
select tea.subject_id,sub.name,count(tea.lecturer_id) as numberof_lecturers_incharge
from teaching tea
join subject sub on(tea.subject_id = sub.subject_id)
group by tea.subject_id,sub.name
having count(tea.lecturer_id) >= 2;

--17
select sub.subject_id,sub.name,count(tea.lecturer_id) as numberof_lecturers_incharge
from subject sub
left join teaching tea  on(tea.subject_id = sub.subject_id)
group by sub.subject_id,sub.name
having count(tea.lecturer_id) < 2;

--18
with bang_diem as(
select student.student_id,student.last_name ||' '||student.first_name student_name,
((midterm_score * (1- percentage_final_exam/100.0) + final_score
*percentage_final_exam/100.0)) as subject_score
from student
join enrollment on(student.student_id = enrollment.student_id)
join subject on(subject.subject_id = enrollment.subject_id)
where subject.subject_id = 'IT3080' 
and enrollment.semester = '20172')

select student_id,student_name,subject_score 
from bang_diem 
where subject_score = (select max(subject_score) from bang_diem );






  
  

