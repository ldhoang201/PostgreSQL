create or replace function tf_before() returns trigger 
as
$$
begin 
raise notice 'Before trigger dc kich hoat';
return new;
end;
$$
language plpgsql;

create or replace trigger tf_before_clazz 
before insert on clazz
for each row 
execute procedure tf_before();

select * from clazz;
insert into clazz(clazz_id,name) values ('20162103','CNTT1.03-k64');

--trigger insert
create or replace function tf_update_nbstu() returns trigger 
as 
$$
begin
	update clazz set number_students = number_students + 1 where clazz_id = NEW.clazz_id;
	return null;
end;
$$
language plpgsql;

create trigger tg_update_nbstu 
after insert on student
for each row 
when (NEW.clazz_id is not null)
execute procedure tf_update_nbstu();

--trigger delete
create or replace function tf_update_nbstu_delete() returns trigger 
as 
$$
begin
	update clazz set number_students = number_students - 1 where clazz_id = OLD.clazz_id;
	return null;
end;
$$
language plpgsql;

create or replace trigger tg_update_nbstu_delete 
after delete on student
for each row 
when (OLD.clazz_id is not null)
execute procedure tf_update_nbstu_delete();

--trigger update
create or replace function tf_update_nbstu_update() returns trigger 
as 
$$
begin
	update clazz set number_students = number_students - 1 where clazz_id = OLD.clazz_id;
	update clazz set number_students = number_students + 1 where clazz_id = NEW.clazz_id;
	return null;
end;
$$
language plpgsql;

create or replace trigger tg_update_nbstu_update 
after update of clazz_id on student
for each row 
when (OLD.clazz_id is not null)
execute procedure tf_update_nbstu_update();


select * from student;
select * from clazz;
insert into student values('20160010','Van C','Nguyen','1989-08-12','M','Ta Quang Buu',null,'20162101');
delete from student where student_id = '20160010';

update student set clazz_id = '20172201' where student_id = '20160009';



