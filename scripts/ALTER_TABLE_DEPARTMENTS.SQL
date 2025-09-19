/*SE AGREGA NUEVA COLUMNA DEPARTAMENTS*/
ALTER TABLE hdz_departments ADD id_padre INT NOT NULL AFTER name;

/*SE AGREGA NUEVA COLUMNA EN TICKETS*/
ALTER TABLE hdz_tickets ADD department_id_child MEDIUMTEXT NOT NULL AFTER department_id;

/*SE INSERTA NUEVO DEPARTAMENTO PADRE*/
INSERT INTO hdz_departments (dep_order, name, id_padre, private) VALUES (5, 'Crédito',0,0);

/*CAMBIAR TIPO DE DATO EN LA TABLA TICKETS*/
ALTER TABLE hdz_tickets MODIFY department_id MEDIUMTEXT NOT NULL;

/*CAMBIAR TIPO DE DATO EN LA TABLA DEPARTMENTS*/
ALTER TABLE hdz_departments MODIFY id_padre VARCHAR(10) NOT NULL;

/*UPDATE DEPARTMENTS ID_PADRE PROCESO CREDITOS*/
UPDATE hdz_departments SET id_padre='4,10' WHERE id IN (1,11,8,5,6,3);

/* SE CREA TABLA PARAMETROS DEL SISTEMA - PARA VALIDACIONES */
CREATE TABLE hdz_system_params (
id INT NOT NULL AUTO_INCREMENT,
cparam VARCHAR(50) NOT NULL,
type_param VARCHAR (1) NOT NULL,
param_text VARCHAR (300),
param_number INT (6),
param_description VARCHAR(100) NOT NULL,
PRIMARY KEY (id)
);

/* Para notificar via Email a los deparmentos adjunto, cuando hay respuesta al ticket. Proceso Creditos */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('NOTIFY_REPLY_ALL_DEPARTMENTS', 'T', 'Créditos - Originación Comercial', null,'Para notificar via Email a los deparmentos adjunto, cuando hay respuesta al ticket. Proceso Creditos'),
('NO_REPLY', 'T', 'Créditos - Originación Comercial', null,'Para deshabilitar boton de respuesta en la vista del Ticket.');
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('ATTACHMENTS_FILES','N',null,0,'Para activar, si adjunta archivos a las notificaciones de respuesta. 1: SI, 0: NO.');
/*EJEMPLO DE ALTER TABLE MYSQL
https://www.anerbarrena.com/alter-table-mysql-5050/
*/
ALTER TABLE nombre_tabla ADD nombre_columna VARCHAR(5) AFTER nombre_columna_anterior;
ALTER TABLE nombre_tabla MODIFY nombre_columna DATE NOT NULL;




