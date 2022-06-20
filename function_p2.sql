---GPA Counting Function
select * from subject;

create or replace function GPA_count1(studentid char(8),semester1 char(5))
returns table (mark numeric,
			  credit int) as
$$
begin 
return query
with tmp as(
	select student.student_id,enrollment.semester,enrollment.midterm_score,enrollment.final_score,
	((midterm_score * (1- percentage_final_exam/100.0) + final_score
	*percentage_final_exam/100.0)) as subject_score,subject.subject_id,subject.name,subject.credit
	from student,subject,enrollment
	where student.student_id = enrollment.student_id
	and subject.subject_id = enrollment.subject_id)
	select case
			when subject_score > 9.4 and subject_score <= 10 then  4*tmp.credit 
			when subject_score > 8.4 and subject_score <= 9.4 then 4*tmp.credit 
			when subject_score > 7.9 and subject_score <= 8.4 then 3.5*tmp.credit 
			when subject_score > 6.9 and subject_score <= 7.9 then 3*tmp.credit 
			when subject_score > 6.4 and subject_score <= 6.9 then 2.5*tmp.credit 
			when subject_score > 5.4 and subject_score <= 6.4 then 2*tmp.credit 
			when subject_score > 4.9 and subject_score <= 5.4 then 1.5*tmp.credit 
			when subject_score > 3.9 and subject_score <= 4.9 then 1*tmp.credit 
			when subject_score > 0 and subject_score <= 3.9 then 0*tmp.credit 
		end mark , tmp.credit as credit
	from tmp
	where tmp.student_id = studentid and tmp.semester = semester1;
end;
$$
language plpgsql;

select * from GPA_count1('20160002','20172');

---GPA Update Function
create or replace function Update_GPA(sID char(8),ses char(5))
returns void as
$$
begin 
update student_result set gpa = (select sum(mark)/sum(credit) from GPA_count1(sID,ses)) where student_id = sID and semester = ses ;
end;
$$
language plpgsql;

select Update_GPA('20160002','20172');

---GPA All Update Function
create or replace function Update_GPA_all()
returns void as
$$
declare i char(8);
k char(5);
begin 
for k in (select semester from student_result)
	loop
	 	for i in (select student_id from student_result)
			loop
				perform Update_GPA(i,k);
			end loop;
	end loop;
end;
$$
language plpgsql;

select Update_GPA_all();

select * from student_result;
						
	



