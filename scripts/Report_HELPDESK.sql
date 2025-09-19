/*FORMAT DATE MYSQL
	https://www.w3schools.com/sql/func_mysql_date_format.asp
*/

select 
t.id ticket_id,
u.fullname usuario_envia_ticket,
dusr.department dpt_usr_envia_ticket,
t.subject nro_guia,
d.name departamento_proceso,
t.department_id_child departmento_adjunto,
from_unixtime(t.date ,'%d-%m-%Y %H:%i:%s') f_creacion_ticket,
tm.id id_message,
from_unixtime(tm.date ,'%d-%m-%Y %H:%i:%s') f_respuesta_ticket,
userresp.fullname nombre_usuario_responde,
stres.fullname nombre_angente_responde, 
stres.department dpt_agente_responde,
from_unixtime(t.last_update ,'%d-%m-%Y %H:%i:%s') f_ultima_respuesta_ticket,
t.replies nro_respuesta,
CASE 
	WHEN t.status = 1 THEN 'Enviado'
    WHEN t.status = 2 THEN 'Atendido'
    WHEN t.status = 3 THEN 'Esperando respuesta'
    WHEN t.status = 4 THEN 'En proceso'
    WHEN t.status = 5 THEN 'Cerrado'
    ELSE ' '
END AS estatus,
t.last_replier,
staff.fullname usuario_ultima_respuesta
from hdz_tickets t
inner join hdz_departments d ON 
d.id= t.department_id
inner join hdz_users u ON
u.id = t.user_id 
left join hdz_staff staff ON
staff.id = t.last_replier
inner join hdz_tickets_messages tm ON
tm.ticket_id = t.id
/*and tm.staff_id <> 0*/
left outer join hdz_staff stres ON
stres.id = tm.staff_id
left outer join hdz_users userresp ON
userresp.id = t.user_id
and tm.customer = 1
left outer join hdz_departments ds ON
ds.id = stres.department

left outer join hdz_staff dusr ON
dusr.email = u.email

/*WHERE t.id =46*/
where t.department_id = 14 /*Para Valijas*/
/*where t.department_id = 10 /*Para Creditos-Originacion Comercial*/
/*where t.department_id = 14 /*Atencion al cliente*/
/*where t.department_id not in (4,10,14) /*Otros*/
and date(from_unixtime(t.date ,'%Y-%m-%d')) between '2023-05-01' and '2023-05-31'
order by t.id, tm.id desc; 

/********************************************************************************* 
/         QUERY PARA GENERAR REPORTE DE ATENCION AL CLIENTE, ESTADO DE CTA       /
*********************************************************************************/
select 
t.id ticket_id,
u.fullname usuario_envia_ticket,
dusr.department dpt_usr_envia_ticket,
t.subject nro_guia,
d.name departamento_proceso,
t.department_id_child departmento_adjunto,
from_unixtime(t.date ,'%d-%m-%Y %H:%i:%s') f_creacion_ticket,
tm.id id_message,
from_unixtime(tm.date ,'%d-%m-%Y %H:%i:%s') f_respuesta_ticket,
userresp.fullname nombre_usuario_responde,
stres.fullname nombre_angente_responde, 
stres.department dpt_agente_responde,
from_unixtime(t.last_update ,'%d-%m-%Y %H:%i:%s') f_ultima_respuesta_ticket,
t.replies nro_respuesta,
CASE 
	WHEN t.status = 1 THEN 'Enviado'
    WHEN t.status = 2 THEN 'Atendido'
    WHEN t.status = 3 THEN 'Esperando respuesta'
    WHEN t.status = 4 THEN 'En proceso'
    WHEN t.status = 5 THEN 'Cerrado'
    ELSE ' '
END AS estatus,
t.last_replier,
staff.fullname usuario_ultima_respuesta,
cs.type_person,
cs.client_name,
cs.email,
cs.email2,
cs.solicitude
from hdz_tickets t
inner join hdz_client_solicitude cs on
cs.ticket = t.id
inner join hdz_departments d ON 
d.id= t.department_id
inner join hdz_users u ON
u.id = t.user_id 
left join hdz_staff staff ON
staff.id = t.last_replier
inner join hdz_tickets_messages tm ON
tm.ticket_id = t.id
/*and tm.staff_id <> 0*/
left outer join hdz_staff stres ON
stres.id = tm.staff_id
left outer join hdz_users userresp ON
userresp.id = t.user_id
and tm.customer = 1
left outer join hdz_departments ds ON
ds.id = stres.department

left outer join hdz_staff dusr ON
dusr.email = u.email

/*WHERE t.id =46*/
where t.department_id = 14 /*Para Atencion al cliente*/
and date(from_unixtime(t.date ,'%Y-%m-%d')) between '2023-05-01' and '2023-05-31'
and cs.solicitude like '%5,%'
order by t.id, tm.id desc; 

/********************************************************************************* 
/      QUERY PARA EXPORTAR A UN TXT REPORTE INCIDENCIAS DESDE TERMINAL LINUX     /
*********************************************************************************/
select  
t.id ticket_id,
u.fullname usuario_envia_ticket,
t.subject nro_guia,
d.name departamento,
t.department_id_child departmento_adjunto,
from_unixtime(t.date ,'%d-%m-%Y %H:%i:%s') f_creacion_ticket,
from_unixtime(t.last_update ,'%d-%m-%Y %H:%i:%s') f_ultima_respuesta_ticket,
t.replies nro_respuesta,
CASE 
	WHEN t.status = 1 THEN 'Enviado'
    WHEN t.status = 2 THEN 'Atendido'
    WHEN t.status = 3 THEN 'Esperando respuesta'
    WHEN t.status = 4 THEN 'En proceso'
    WHEN t.status = 5 THEN 'Cerrado'
    ELSE ' '
END AS estatus,
t.last_replier,
staff.fullname usuario_ultima_respuesta
from hdz_tickets t
inner join hdz_departments d ON 
d.id= t.department_id
inner join hdz_users u ON
u.id = t.user_id 
left join hdz_staff staff ON
staff.id = t.last_replier
order by t.id
INTO OUTFILE '/var/lib/mysql-files/tickets.txt' 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n'; 




/**
EJEMPLO https://stackoverflow.com/questions/32737478/how-should-i-tackle-secure-file-priv-in-mysql
EJEMPLO EXPORT TEXT DESDE TERMINAL (MySQL): https://solutioncenter.apexsql.com/how-to-export-import-mysql-data-to-excel/
https://hevodata.com/learn/mysql-export-to-csv/
**/
/* VEMOS EL DIRECTORIO SEGURO ESPECIFICADO POR MYSQL*/
SHOW VARIABLES LIKE "secure_file_priv";

