/***********************************************************************************
                PROCESO INFORMACION A COMERCIALES DESDE DPT CRÉDITOS
***********************************************************************************/
/*SE AGREGA NUEVA COLUMNA EN TICKETS*/
ALTER TABLE hdz_tickets ADD advisor_id INT NOT NULL AFTER user_id;
ALTER TABLE hdz_tickets ADD director_commercial_id INT NOT NULL AFTER advisor_id;

/* CONSTRAINT PARA QUE EL NOMBRE DEL PARAMETRO SEA UNICO */
ALTER TABLE bd_helpdesk.hdz_system_params ADD CONSTRAINT UQ_PARAMETER UNIQUE (cparam);

/*SE INSERTA NUEVO DEPARTAMENTO PADRE - PROCESO DE ENVIO DE TICKETS SIN RESPUESTA*/
INSERT INTO hdz_departments (dep_order, name, id_padre, private) VALUES (20, 'Crédito-Desembolso',0,0);

/* PARAMETRIZACION DE ARCHIVOS ADJUNTOS PARA EL NUEVO PROCESO */
INSERT INTO hdz_config_department (ticket_attachment, source_parameter, department_id, ticket_attachment_number, ticket_file_size, ticket_file_type) VALUES
(1,'executive', 15, 5, 10, 'a:1:{i:0;s:3:"pdf";}'),
(1,'advisor', 15, 2, 10, 'a:1:{i:0;s:4:"xlsx";}')
;

/* Nuevo parametro para validar proceso de Envio de tickets de una sola via */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('ONE_WAY_TICKET','T','Crédito-Desembolso',null,'Parametro para validar el envío de tickets sin respuesta. Proceso Crédito-Desembolso');

/* Nuevo parametro para filtrar las personas de los comerciales */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('FILTER_COMMERCIAL','T','3,5,6',null,'Parametro para filtrar los asesores comerciales de Cuenca, Guayaquil y Quito.');

/* Parametro para notificar al Jefe del Departamento Comercial cuando se crea un ticket en el Proceso Crédito-Desembolso  */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('CHIEF_DEPARTMENT_COMMERCIAL','N',null,12,'Parametro para no mostrar en el listado de los asesores comerciales al Jefe del departamento Comercial.');

/* Nuevo parametro para habilitar acceso al proceso Crédito-Desembolso */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('CREDIT_DISBURSEMENT_ENABLED','N',null,2,'Código del departamento que tendrá acceso al proceso de Crédito-Desembolso.');

/* Parametros para validar el acceso a los Procesos  */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('ATTENTION_CLIENT','N',null,14,'Código del proceso Atención al Cliente para validar el acceso a los usuarios.');

INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('CREDIT_DISBURSEMENT','N',null,15,'Código del proceso Crédito-Desembolso para validar el acceso a los usuarios.');

/*Parametro para validar el acceso al menu emails enviados*/
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('MENU_SEND_EMAILS','T','1,33,26',null,'Parametro para validar que ejecutivos, pueden acceder a la opción de Emails enviados.');


/*Se actualiza el parametro que filtra los ids de los comerciales que no se quiere mostrar en el combo. Proceso Crédito-Desembolso */
update hdz_system_params set type_param='N', param_text=null, param_number=12,
param_description='Parametro para notificar al Jefe del departamento Comercial cuando se crea un ticket en Crédito-Desembolso.' where id=11;

/*Parametro para no mostrar a ciertos Asesores en el combo de Asesor Comercial en el proceso Crédito-Desembolso */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('NOTIN_COMMERCIAL','T','12,29',null,'Parametro para no mostrar en el listado de los asesores comerciales al Jefe del departamento Comercial y otras personas.');

/*Parametro para notificar a los departamentos de Cumplimiento, Legal y Operaciones de un nuevo ticket en Credito-Desembolso  */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('NOTIFY_DEPARTMENT_CREDIT_DISBURSEMENT','T','1,8,11',null,'Parametro para notificar un nuevo ticket de Crédito-Desembolso a los departamentos de Cumplimiento, Legal y Operaciones.');