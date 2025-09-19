/***********************************************************************************
                PROCESO DE ATENCION AL CLIENTE
***********************************************************************************/
/*SE INSERTA NUEVO DEPARTAMENTO PADRE - PROCESO DE ATENCION AL CLIENTE*/
INSERT INTO hdz_departments (dep_order, name, id_padre, private) VALUES (17, 'Atención al cliente',0,0);

/* Nuevo parametro para validar el proceso de Atención al Cliente */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('DEPARTMENT_ATTENTION_CLIENT','T','Atención al cliente',null,'Validaciones para el proceso de atención al cliente.');

/* SE ACTUALIZA EL PARAMETRO DE PROCESO CREDITOS */
/*update hdz_system_params set param_text = '' where cparam = 'NOTIFY_REPLY_ALL_DEPARTMENTS';
update hdz_system_params set param_text = '' where cparam = 'NO_REPLY';*/

/* TABLA PARA GUARDAR LOS TIPOS DE SOLICITUD */
CREATE TABLE hdz_type_solicitude(
id INT NOT NULL AUTO_INCREMENT,
description VARCHAR(200) NOT NULL,
solicitude_order INT NOT NULL,
type VARCHAR (30),
color VARCHAR (10),
value TEXT,
multiple_select INT,
enabled INT NOT NULL,
PRIMARY KEY (id)
);

/* TABLA PARA GUARDAR LA SOLICITUD DEL CLIENTE */
CREATE TABLE hdz_client_solicitude(
	id INT NOT NULL AUTO_INCREMENT,
    identification VARCHAR(20) NOT NULL,
    type_person VARCHAR(6) NOT NULL,
    client_name VARCHAR (100) NOT NULL,
    name_destino1 VARCHAR (100) NOT NULL,
    email VARCHAR(60) NOT NULL,
    name_destino2 VARCHAR (100),
    email2 VARCHAR(60),
    ticket INT NOT NULL,
    solicitude MEDIUMTEXT NOT NULL,
    PRIMARY KEY (id)
);

/* TABLA PARA CONFIGURAR TIPOS DE ARCHIVOS POR DEPARTAMENTOS */
CREATE TABLE hdz_config_department (
	id INT NOT NULL AUTO_INCREMENT,
    ticket_attachment TINYINT (1) NOT NULL COMMENT "Para indicar si se activa adjuntar archivos en los formularios. 1:SI, 0:NO",
	source_parameter VARCHAR (15) NOT NULL COMMENT "Para identificar el destino de la parametrización. executive: Ejecutivo, advisor: Asesor.",
    department_id INT NOT NULL,
    ticket_attachment_number SMALLINT NOT NULL,
    ticket_file_size SMALLINT NOT NULL,
    ticket_file_type MEDIUMTEXT NOT NULL,
    PRIMARY KEY (id)
);

/* CONSTRAINT UNICO PARA EL TIPO DE PARAMETRIZACION POR DEPARTAMENTO */
ALTER TABLE bd_helpdesk.hdz_config_department ADD CONSTRAINT UQ_PARAMETER UNIQUE (source_parameter, department_id);

/* PARA ATENCION AL CLIENTE */
INSERT INTO hdz_config_department (ticket_attachment, source_parameter, department_id, ticket_attachment_number, ticket_file_size, ticket_file_type) VALUES
(1,'advisor', 14, 5, 10, 'a:1:{i:0;s:3:"pdf";}'),
(1,'executive', 14, 2, 10, 'a:1:{i:0;s:4:"xlsx";}')
;

/* PARA VALIJAS */
INSERT INTO hdz_config_department (ticket_attachment, source_parameter, department_id, ticket_attachment_number, ticket_file_size, ticket_file_type) VALUES
(1,'advisor', 4, 5, 10, 'a:7:{i:0;s:3:"jpg";i:1;s:3:"png";i:2;s:3:"gif";i:3;s:3:"pdf";i:4;s:4:"docx";i:5;s:4:"xlsx";i:6;s:3:"zip";}'),
(1,'executive', 4, 3, 10, 'a:1:{i:0;s:4:"xlsx";}')
;

/* PARA CREDITOS */
INSERT INTO hdz_config_department (ticket_attachment, source_parameter, department_id, ticket_attachment_number, ticket_file_size, ticket_file_type) VALUES
(1,'advisor', 10, 5, 10, 'a:7:{i:0;s:3:"jpg";i:1;s:3:"png";i:2;s:3:"gif";i:3;s:3:"pdf";i:4;s:4:"docx";i:5;s:4:"xlsx";i:6;s:3:"zip";}'),
(1,'executive', 10, 3, 10, 'a:1:{i:0;s:4:"xlsx";}')
;

/* CONSTRAINT UNICO PARA LA CEDULA DE LA PERSONA */
ALTER TABLE bd_helpdesk.hdz_client_solicitude ADD CONSTRAINT UQ_CEDULA UNIQUE (identification);
ALTER TABLE bd_helpdesk.hdz_client_solicitude MODIFY identification VARCHAR(20) NOT NULL ;

/* INSERT DE LOS TIPOS DE SOLICITUD */
INSERT INTO hdz_type_solicitude (description, solicitude_order,type,color,value,multiple_select,enabled) VALUES
('INFORMACIÓN CUENTAS',1,'label','#FFFFFF',null,null,1),
('NUMERO DE CUENTA',2, 'text','#007B9D',null,null,1),
	('PERFIL TRANSACCIONAL',3,'checkbox','#868E96',null,null,1),
    ('CORTE DE CUENTA',4,'checkbox','#868E96',null,null,1),
    ('ESTADO DE CUENTA MENSUAL',5,'select','#868E96','Enero, Febrero, Marzo, Abril, Mayo, Junio, Julio, Agosto, Septiembre, Octubre, Noviembre, Diciembre',1,1),
	('SOLICITUD DE CHEQUERA',6,'checkbox','#868E96',null,null,1),
	('REFERENCIAS BANCARIAS',7,'checkbox','#868E96',null,null,1),
('DEPÓSITO A PLAZO FIJO',8,'label','#FFFFFF',null,null,1),
('NUMERO DE DPF',9,'text','#007B9D',null,null,1),
	('TABLA DE PAGO DPF',10,'checkbox','#868E96',null,null,1),
    ('VENCIMIENTOS Y RENOVACIONES',11,'checkbox','#868E96',null,null,1),
    ('REIMPRESION DEL CERTIFICADO',12,'checkbox','#868E96',null,null,1),
    ('CONSOLIDADO DPF',13,'checkbox','#868E96',null,null,1),
('INFORMACIÓN DE CRÉDITO',14,'label','#FFFFFF',null,null,1),
('NÚMERO DE OPERACIÓN DE CRÉDITO',15,'text','#007B9D',null,null,1),
	('TABLA DE AMORTIZACIONES CRÉDITO',16,'checkbox','#868E96',null,null,1),
    ('LIQUIDACIONES DE PRÉSTAMO',17,'checkbox','#868E96',null,null,1),
    ('CONSULTA DE POSICIÓN CONSOLIDADA',18,'checkbox','#868E96',null,null,1),
    ('CERTIFICACIÓN DE CRÉDITO PARA BANCO CENTRAL DEL ECUADOR',19,'checkbox','#868E96',null,null,1),
('INFORMACIÓN TARJETAS DE CRÉDITO',20,'label','#FFFFFF',null,null,1),
('NÚMERO DE TARJETA DE CRÉDITO',21,'text','#007B9D',null,null,1),
	('CUPO DE TARJETAS DE CRÉDITO',22,'checkbox','#868E96',null,null,1),
    ('ESTADOS DE CUENTA DE TC',23,'checkbox','#868E96',null,null,1),
    ('BLOQUEO DE TARJETA DE CREDITO',24,'checkbox','#868E96',null,null,1),
    ('BLOQUEO DE TARJETA DE DÉBITO',25,'checkbox','#868E96',null,null,1),
('POSICIÓN CONSOLIDADA',26,'label','#FFFFFF',null,null,1),
	('RESUMEN CONSOLIDADO DE TODOS LOS PRODUCTOS QUE EL CLIENTE MANTIENE EN EL BANCO',27,'checkbox','#868E96',null,null,1)
;

/* PRUEBAS */
/*INSERT INTO hdz_type_solicitude (description, solicitude_order,type,color,value,multiple_select,enabled) VALUES
('PRUEBA NO MULTIPLE SELECT',28,'select','#868E96','Cuenca, Quito, Guayaquil',0,1);*/

/*SE AGREGA NUEVA COLUMNA EN CUSTOM_FIELDS*/
ALTER TABLE hdz_custom_fields ADD columns INT NOT NULL AFTER display;

/* Plantilla de email para notificar al Cliente el/los documento(s) solicitado(s) */
INSERT INTO hdz_emails_tpl (id, position, name, subject, message, last_update, status)
VALUES('client_notification', 
7,
'New notification to client', 
'Re: [#%ticket_id%] %ticket_subject%',
'<!DOCTYPE html>
<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <title>Document</title>

    <style type="text/css">
        @media screen {
            @font-face {
                font-family: `Lato`;
                font-style: normal;
                font-weight: 400;
                src: local(`Lato Regular`), local(`Lato-Regular`), url(https://fonts.gstatic.com/s/lato/v11/qIIYRU-oROkIk8vfvxw6QvesZW2xOQ-xsNqO47m55DA.woff) format(`woff`);
            }
            @font-face {
                font-family: `Lato`;
                font-style: normal;
                font-weight: 700;
                src: local(`Lato Bold`), local(`Lato-Bold`), url(https://fonts.gstatic.com/s/lato/v11/qdgUG4U09HnJwhYI-uK18wLUuEpTyoUstqEm5AMlJo4.woff) format(`woff`);
            }
            @font-face {
                font-family: `Lato`;
                font-style: italic;
                font-weight: 400;
                src: local(`Lato Italic`), local(`Lato-Italic`), url(https://fonts.gstatic.com/s/lato/v11/RYyZNoeFgb0l7W3Vu1aSWOvvDin1pK8aKteLpeZ5c0A.woff) format(`woff`);
            }
            @font-face {
                font-family: `Lato`;
                font-style: italic;
                font-weight: 700;
                src: local(`Lato Bold Italic`), local(`Lato-BoldItalic`), url(https://fonts.gstatic.com/s/lato/v11/HkF_qI1x_noxlxhrhMQYELO3LdcAZYWl9Si6vvxL-qU.woff) format(`woff`);
            }
        }
        /* CLIENT-SPECIFIC STYLES */
        
        body,
        table,
        td,
        a {
            -webkit-text-size-adjust: 100%;
            -ms-text-size-adjust: 100%;
        }
        
        table,
        td {
            mso-table-lspace: 0pt;
            mso-table-rspace: 0pt;
        }
        
        img {
            -ms-interpolation-mode: bicubic;
        }
        /* RESET STYLES */
        
        img {
            border: 0;
            height: auto;
            line-height: 100%;
            outline: none;
            text-decoration: none;
        }
        
        table {
            border-collapse: collapse !important;
        }
        
        body {
            /*height: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            width: 100% !important;*/
        }
        /* iOS BLUE LINKS */
        
        a[x-apple-data-detectors] {
            color: inherit !important;
            text-decoration: none !important;
            font-size: inherit !important;
            font-family: inherit !important;
            font-weight: inherit !important;
            line-height: inherit !important;
        }
        /* MOBILE STYLES */
        
        @media screen and (max-width:600px) {
            h1 {
                font-size: 32px !important;
                line-height: 32px !important;
            }
        }
        /* ANDROID CENTER FIX */
        
        div[style*="margin: 16px 0;"] {
            margin: 0 !important;
        }
    </style>
</head>

<body style="background-color: #f4f4f4; margin: 0 !important; padding: 0 !important;">
    <!-- Plantilla Notificación Cliente -->
    <table border="0" cellspacing="0" cellpadding="0" width="100%">
        <tbody>
            <tr>
                <!-- LOGO -->
                <td align="center" bgcolor="#f7f9fa">
                    <table style="max-width: 600px;" border="0" width="100%" cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td style="padding: 40px 10px 40px 10px;" align="center" valign="top">&nbsp;
                                    <!--<img style="display: block; border: 0px;" src="https://austrobank.com/wp-content/uploads/2021/12/logoNegro.png" width="250" height="50" />-->
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <!-- TITUTLO -->
            <tr>
                <td align="center" bgcolor="#f7f9fa">
                    <table style="max-width: 850px;" border="0" cellspacing="0" cellpadding="0" width="100%">
                        <tr>
                            <td style="padding: 40px 80px 20px 10px;" align="right" valign="top" bgcolor="#FFFFFF">
                                <img style="display: block; border: 0px;" src="https://austrobank.com/wp-content/uploads/2020/10/AUSTROBANK-lgtp.png" loading="lazy" width="250" height="50" style="display: block; border: 0px;" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!-- CUERPO MENSAJE -->
            <tr>
                <td style="padding: 0px 10px 0px 10px;" align="center" bgcolor="#f7f9fa">
                    <table style="max-width: 850px;" border="0" width="100%" cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td style="padding: 20px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 400; line-height: 25px;" align="right" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: right; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Panam&aacute;, %date%.
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 20px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 25px;" align="left" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: justify; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Estimado(a) %client_name%.
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 20px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 25px;" align="left" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: justify; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Reciba un cordial saludo del Centro de Atenci&oacute;n al Cliente de AUSTROBANK OVERSEAS (PANAM&Aacute;) S.A..
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 20px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 25px;" align="left" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: justify; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Adjunto encontrar&aacute; la informaci&oacute;n solicitada por Usted.
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 20px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 14px; font-weight: 400; line-height: 25px;" align="left" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: justify; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Gracias por ser parte de nuestro selecto grupo de Clientes.
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 20px 30px 50px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 16px; font-weight: 400; line-height: 25px;" align="left" bgcolor="#ffffff">
                                    <p style="margin: 0; text-align: justify; margin-left: 50px; margin-right: 50px; font-style: italic;">
                                        Atentamente,<br> AUSTROBANK OVERSEAS (PANAM&Aacute;) S.A..
                                    </p>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 0px 10px 15px 10px; border-radius: 0px 0px 4px 4px;" align="center" bgcolor="#f7f9fa">
                    <table style="max-width: 850px; " border="0" width="100%" cellspacing="0" cellpadding="0">
                        <tbody>
                            <tr>
                                <td style="padding: 5px 30px 10px 30px; color: #666666; font-family: `Lato`, Helvetica, Arial, sans-serif; font-size: 12px; font-weight: 300; line-height: 20px;" align="left" bgcolor="#DBDBDB">
                                    <p style="text-align: left;"><img src="https://img.icons8.com/stickers/100/000000/password.png" width="30" height="30" /><span style="font-style: italic;">SEGURIDAD</span></p>
                                    <p style="margin: 0; font-style: italic; color: #666666;">
                                        Te recordamos que AUSTROBANK OVERSEAS (PANAM&Aacute;) S.A. no solicita informaci&oacute;n confidencial por ning&uacute;n medio electr&oacute;nico. Este correo fue enviado de forma autom&aacute;tica y no requiere respuesta
                                    </p>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 2px 30px 5px 30px;" align="center" bgcolor="#DBDBDB">
                                    <table style="max-width: 850px;" border="0" width="100%" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td style="text-align: center;">
                                                    <span style="font-size: 12px;">
                                                   <img src="https://img.icons8.com/material-rounded/50/000000/marker.png" width="15" height="15"/>
                                                <b><span style="color: #007b9d;">Calle 53 Este, Marbella. Edificio Humboldt Tower, Planta Baja / Panamá</span></b>
                                                    </span>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td style="padding: 2px 30px 30px 30px;" bgcolor="#DBDBDB" align="center">
                                    <table style="max-width: 850px;" border="0" width="100%" cellspacing="0" cellpadding="0">
                                        <tbody>
                                            <tr>
                                                <td style="text-align: center;">
                                                    <span style="font-size: 12px;">
                                                   <img src="https://img.icons8.com/ios-glyphs/30/000000/new-post.png" width="15" height="15"/>
                                                   <b><span style="color: #007b9d;">contactanos@austrobank.com</span></b>
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <span style="font-size: 12px;">
                                                   <img src="https://img.icons8.com/external-prettycons-solid-prettycons/60/000000/external-telephone-communications-prettycons-solid-prettycons.png" width="15" height="15"/>
                                                <b><span style="color: #007b9d;">+507 223-4455</span></b>
                                                    </span>
                                                </td>
                                                <td style="text-align: center;">
                                                    <span style="font-size: 12px;">
                                                   <img src="https://img.icons8.com/external-flatart-icons-outline-flatarticons/64/000000/external-world-user-experience-flatart-icons-outline-flatarticons.png" width="15" height="15"/>
                                                <b><span style="color: #007b9d;">www.austrobank.com</span></b>
                                                    </span>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
            </tr>
        </tbody>
    </table>
</body>

</html>',
0,1);



/***********************************************************************************
                MEJORAS PROCESO DE ATENCION AL CLIENTE
***********************************************************************************/
/*SE AGREGA NUEVA COLUMNA EN HDZ_CLIENT_SOLICITUDE*/
ALTER TABLE hdz_client_solicitude ADD send_email tinyint(1) NOT NULL AFTER ticket;

ALTER TABLE hdz_client_solicitude ADD date INT NOT NULL AFTER type_person;
ALTER TABLE hdz_client_solicitude ADD last_date INT NOT NULL AFTER date;
ALTER TABLE hdz_client_solicitude ADD msg_id INT NOT NULL AFTER ticket;


/* SE AGREGA NUEVOS TIPO DE SOLICITUD */
INSERT INTO hdz_type_solicitude (description, solicitude_order,type,color,value,multiple_select,enabled) VALUES
('COPIA DE CHEQUES PROPIOS',8,'checkbox','#868E96',null,null,1),
('COPIA DE CHEQUES DEPOSITADOS',9, 'checkbox','#868E96',null,null,1);

/* SE AGREGA NUEVA COLUMNA EN LA TABLA TYPE_SOLICITUDE */
ALTER TABLE hdz_type_solicitude ADD id_padre INT NOT NULL AFTER solicitude_order;

/* TABLA PARA ALMACENAR LOS EMAILS ENVIADOS A LOS CLIENTES */
CREATE TABLE hdz_client_email (
	id INT NOT NULL AUTO_INCREMENT,
    solicitude_id INT NOT NULL,
    name VARCHAR (50) NOT NULL,
    email VARCHAR(50) NOT NULL,
    date INT NOT NULL,
    PRIMARY KEY (id)
)

/*INSERT INTO SELECT MYSQL 
	https://www.w3schools.com/sql/sql_insert_into_select.asp
*/
/*insert into hdz_client_email (solicitude_id, name, email, date)*/
select id, name_destino2, email2, last_date from hdz_client_solicitude
where send_email=1 and type_person='jur' and id <> 12;


/***********************************************************************************
                MEJORAS PROCESO DE CRÉDITOS 20-01-2022
***********************************************************************************/
/* Nuevo parametro para validar el check del radio button TIPO DE CLIENTE  - PROCESO DE CREDITOS */
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('CREDIT_PROCESS','T','Créditos - Originación Comercial',null,'Para validar radio button, TIPO CLIENTE, en el proceso de Créditos.');

INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('ACTIVATE_ACCOUNT','N',null,30,'Para validar que al solicitar una Activación de cuenta debe adjuntar un documento.');


/***********************************************************************************
                MEJORAS HELPDESK 24-01-2022
***********************************************************************************/
ALTER TABLE hdz_config ADD client_emails_page INT NOT NULL AFTER kb_latest;
ALTER TABLE hdz_config ADD client_email_order VARCHAR(5) NOT NULL AFTER client_emails_page;


/***********************************************************************************
                MEJORAS HELPDESK 27-01-2022
***********************************************************************************/
INSERT INTO hdz_system_params (cparam, type_param, param_text, param_number, param_description) values 
('ACTIVATE_ACCOUNT','N',null,30,'Para validar que al solicitar una Activación de cuenta debe adjuntar un documento.');