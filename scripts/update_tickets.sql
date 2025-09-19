SELECT * FROM hdz_departments;
select * from hdz_;
select * from hdz_staff order by id;
select * from hdz_tickets_messages where ticket_id=174;

select count(*) from hdz_tickets where department_id=14;
select count(*) from hdz_client_solicitude;

/*Tickets enviados y no tienen respuesta*/
select * from hdz_tickets where id in (182,249,258,259,262,273,274,275,289,373,386);

/*Tickets enviados y no tienen respuesta - Credito Desembolso*/
/*Id Jefe Departamentos Marco Merchan: */
select * from hdz_staff where id = 12;
update hdz_tickets set status = 5, director_commercial_id = 12 where id in (182,289) ;

/*Cerrar tickets sin respuesta*/
update hdz_tickets set status = 5 where id in (249,258,259,262,273,274,275,373,386);

select * from hdz_tickets where id in (249,258,259,262,273,274,275,373,386);


/*Data Por Cerrar*/
select t.*, tm.message,from_unixtime(tm.date ,'%d-%m-%Y %H:%i:%s') f_creacion_ticket 
from hdz_tickets t 
inner join hdz_tickets_messages tm on
tm.ticket_id = t.id
where t.id in (182,249,258,259,262,273,274,275,289,373,386)
order by tm.date;

select * from hdz_tickets_messages;


