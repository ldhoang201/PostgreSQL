
create or replace function  number_of_students(in id char(8),out result integer)  
language plpgsql  
as  
$$  
declare  
student_numbers integer;  
begin  
	select count(s.student_id) into student_numbers
	from student s where s.clazz_id = id;
	result := student_numbers;
end;  
$$
IMMUTABLE
RETURNS NULL ON NULL INPUT
SECURITY DEFINER;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO fred;

select * from student;
select number_of_students('20162101');

2--

select * from clazz;

create or replace function update_number_students() returns void as
$$
declare
    i char(8);
begin
    for i in (select clazz_id from clazz)
        loop
            update clazz set number_students = number_of_students(i) where clazz_id = i;
        end loop;
end;
$$
    language plpgsql;

select update_number_students(); 


