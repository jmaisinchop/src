<?php
/**
 * @package EvolutionScript
 * @author: EvolutionScript S.A.C.
 * @Copyright (c) 2010 - 2020, EvolutionScript.com
 * @link http://www.evolutionscript.com
 */

namespace App\Controllers\Staff;


use App\Controllers\BaseController;
use App\Models\CannedModel;
use Config\Services;


class Tickets extends BaseController
{
    public function manage($page)
    {
        $tickets = new \App\Libraries\Tickets();

        if($this->request->getPost('action')){
            if(!is_array($this->request->getPost('ticket_id'))) {
                $error_msg = lang('Admin.error.noItemsSelected');
            }else{
                foreach ($this->request->getPost('ticket_id') as $ticket_id){
                    if(is_numeric($ticket_id)){
                        if($this->request->getPost('action') == 'remove'){
                            $tickets->deleteTicket($ticket_id);
                        }elseif($this->request->getPost('action') == 'update'){
                            $cantReplies = getCountRepliesTicket($ticket_id);
                            if(is_numeric($this->request->getPost('department'))){
                                if((int)$cantReplies->replies === 0){
                                } else {
                                    if(Services::departments()->isValid($this->request->getPost('department'))){
                                        $tickets->updateTicket([
                                            'department_id' => $this->request->getPost('department')
                                        ], $ticket_id);
                                    }
                                }      
                            }
                            if(is_numeric($this->request->getPost('status'))){
                                if((int)$cantReplies->replies === 0){
                                    $error_msg  = "No puede cerrar el ticket sin haber agregado una respuesta";
                                } else {
                                    if(array_key_exists($this->request->getPost('status'), $tickets->statusList())){
                                        $tickets->updateTicket([
                                            'status' => $this->request->getPost('status')
                                        ], $ticket_id);
                                    }
                                }
                            }
                            if(is_numeric($this->request->getPost('priority'))){
                                if($tickets->existPriority($this->request->getPost('priority'))){
                                    $tickets->updateTicket([
                                        'priority_id' => $this->request->getPost('priority')
                                    ], $ticket_id);
                                }
                            }
                        }
                    }
                }
                return redirect()->to(current_url(true));
            }
        }

        if($this->session->has('ticket_error')){
            $error_msg = $this->session->getFlashdata('ticket_error');
        }
        $result = $tickets->staffTickets($page);
        return view('staff/tickets',[
            'departments' => $this->staff->getDepartments(),
            'statuses' => $tickets->statusList(),
            'tickets_result' => $result['result'],
            'priorities' => $tickets->getPriorities(),
            'pager' => $result['pager'],
            'page_type' => $page,
            'error_msg' => isset($error_msg) ? $error_msg : null
        ]);
    }

    public function view($ticket_id)
    {
        $tickets = Services::tickets();
        if(!$ticket = $tickets->getTicket(['id' => $ticket_id])){
            $this->session->setFlashdata('ticket_error', lang('Admin.error.ticketNotFound'));
            return redirect()->route('staff_tickets');
        }
        #Validacion de permisos al abrir ticket
        $key = array_search($ticket->department_id, array_column($this->staff->getDepartments(),'id'));
        /*if(!is_numeric($key)){
            $this->session->setFlashdata('ticket_error', lang('Admin.error.ticketNotPermission'));
            return redirect()->route('staff_tickets');
        }*/
        $attachments = Services::attachments();
        #Download
        if($this->request->getGet('download')){
            if(!$file = $attachments->getRow(['id' => $this->request->getGet('download'),'ticket_id' => $ticket->id])){
                return view('client/error',[
                    'title' => lang('Client.error.fileNotFound'),
                    'body' => lang('Client.error.fileNotFoundMsg'),
                    'footer' => ''
                ]);
            }
            return $attachments->download($file);
        }
        elseif (is_numeric($this->request->getGet('delete_file'))){
            if(!$file = $attachments->getRow([
                'id' => $this->request->getGet('delete_file'),
                'ticket_id' => $ticket->id
            ])){
                return redirect()->to(current_url());
            }else{
                $attachments->deleteFile($file);
                $this->session->setFlashdata('ticket_update',lang('Admin.tickets.attachmentRemoved'));
                return redirect()->to(current_url());
            }
        }
        //Update Information
        if($this->request->getPost('do') == 'update_information') {
            $validation = Services::validation();

            $validation->setRules([
                'department' => 'required|is_natural_no_zero|is_not_unique[departments.id]',
                'status' => 'required|is_natural|in_list[' . implode(',', array_keys($tickets->statusList())) . ']',
                'priority' => 'required|is_natural_no_zero|is_not_unique[priority.id]',
                'replies' => 'is_natural_no_zero'
            ], [
                'department' => [
                    'required' => lang('Admin.error.invalidDepartment'),
                    'is_natural_no_zero' => lang('Admin.error.invalidDepartment'),
                    'is_not_unique' => lang('Admin.error.invalidDepartment'),
                ],
                'status' => [
                    'required' => lang('Admin.error.invalidStatus'),
                    'is_natural' => lang('Admin.error.invalidStatus'),
                    'in_list' => lang('Admin.error.invalidStatus'),
                ],
                'priority' => [
                    'required' => lang('Admin.error.invalidPriority'),
                    'is_natural_no_zero' => lang('Admin.error.invalidPriority'),
                    'is_not_unique' => lang('Admin.error.invalidPriority')
                ],
                'replies' =>[
                    'is_natural_no_zero' => lang('Admin.error.closeTicket')
                ]
                ]);

            
            if($validation->withRequest($this->request)->run() == false){
                $error_msg = $validation->listErrors();
            }else{
                $tickets->updateTicket([
                    'department_id' => $this->request->getPost('department'),
                    'status' => $this->request->getPost('status'),
                    'priority_id' => $this->request->getPost('priority'),
                ], $ticket->id);
                $this->session->setFlashdata('ticket_update', 'Ticket updated.');
                return redirect()->to(current_url());
            }
        }
        //Reply Ticket
        elseif ($this->request->getPost('do') == 'reply')
        {
            //Obtengo el nombre del departamento del ticket.
            $departmentTicket = getNamesDepAdjuntosById($ticket->department_id);

            //Se obtiene parametros del sistema.
            $paramAT = getParam('DEPARTMENT_ATTENTION_CLIENT');
            $paramLoan = getParam('DEPARTMENT_LOAN_PAYMENTS');

            $validation = Services::validation();
            $validation->setRule('message','message','required',[
                'required' => lang('Admin.error.enterMessage')
            ]);

            //Se consulta la parametrizacion del departamento para archivos adjuntos
            $configAttachmentDep = getConfigDepartmentById($ticket->department_id, 'executive');

            //Parametro para enviar o no el email al cliente y cerrar el ticket - Proceso Atencion al Cliente.
            $checkedAttachmentFiles = $this->request->getPost('isAttached') ? true : false;

            // SOLUCIÓN DEFINITIVA: Verificamos si la configuración fue encontrada ANTES de usarla.
            if (!empty($configAttachmentDep)) {
                
                // Si la configuración existe, ahora sí comprobamos si los adjuntos están habilitados.
                if($configAttachmentDep->ticket_attachment){
                    $max_size = $configAttachmentDep->ticket_file_size * 1024;
                    $allowed_extensions = unserialize($configAttachmentDep->ticket_file_type);
                    $allowed_extensions = implode(',', $allowed_extensions);
                    $validation->setRule('attachment', 'attachment', 'ext_in[attachment,' . $allowed_extensions . ']|max_size[attachment,' . $max_size . ']', [
                        'ext_in' => lang('Admin.error.fileNotAllowed'),
                        'max_size' => lang_replace('Admin.error.fileBig', ['%size%' => number_to_size($max_size * 1024, 2)])
                    ]);
                }
            }

            //Se valida campos de email de los clientes - Proceso Atencion al cliente.
            if($checkedAttachmentFiles && trim($paramAT->param_text) === $departmentTicket){
                $validation->setRule('destino1','destino1','required',[
                    'required' => 'No tiene registrado el nombre del cliente.'
                ]);

                $validation->setRule('emailCliente','emailCliente','required|valid_email',[
                    'required' => 'No tiene una dirección de correo electrónico para enviar los documentos al cliente.',
                    'valid_email' => 'Introduce una dirección de correo electrónico válida para el destinatario'
                ]);


                if($this->request->getPost('destino2') !=''){
                   $validation->setRule('emailCliente2','emailCliente2','required|valid_email',[
                        'required' => 'El segundo destinatario, no tiene una dirección de correo electrónico para enviar los documentos al cliente.',
                        'valid_email' => 'Introduce una dirección de correo electrónico válida para el destinatario 2.'
                    ]); 
                }
            }

            /*if($this->settings->config('ticket_attachment')){
                $max_size = $this->settings->config('ticket_file_size')*1024;
                $allowed_extensions = unserialize($this->settings->config('ticket_file_type'));
                $allowed_extensions = implode(',', $allowed_extensions);
                $validation->setRule('attachment', 'attachment', 'ext_in[attachment,'.$allowed_extensions.']|max_size[attachment,'.$max_size.']',[
                    'ext_in' => lang('Client.error.fileNotAllowed'),
                    'max_size' => lang_replace('Client.error.fileBig', ['%size%' => number_to_size($max_size*1024, 2)])
                ]);
            }*/

            if($validation->withRequest($this->request)->run() == false){
                $error_msg = $validation->listErrors();
            }else{
                if ($this->settings->config('ticket_attachment')) {
                    if ($files_uploaded = $attachments->ticketUpload()) {
                        $files = $files_uploaded;
                    }
                }

                $msg_id_solicitude = 0;

                //Message
                $message = $this->request->getPost('message').$this->staff->getData('signature');
                $message_id = $tickets->addMessage($ticket->id, $message, $this->staff->getData('id'));

                //File
                if (isset($files)) {
                    $attachments->addTicketFiles($ticket->id, $message_id, $files);
                }

                $tickets->updateTicketReply($ticket->id, $ticket->status, true);  

                //Cierro el ticket automáticamente al responder (Atencion al Cliente y Préstamos)
                if(trim($paramAT->param_text) === $departmentTicket || trim($paramLoan->param_text) === $departmentTicket){
                    if($checkedAttachmentFiles){
                        $msg_id_solicitude = $message_id;
                        $tickets->updateTicket([
                        'status' => 5,
                        ], $ticket->id); 
                    }
                } 

                //Para actualizar el historial de solicitudes del Cliente.
                if($message != '' && $msg_id_solicitude !='' &&  $this->request->getPost('emailCliente') !=''){
                    $ticket_client = getEmailSolicitude($ticket->id);
                    if($ticket_client != null){
                        $tickets->updateClientSolicitude($ticket_client->id, 
                        $this->request->getPost('emailCliente'), 
                        $this->request->getPost('emailCliente2'),
                        $checkedAttachmentFiles,
                        $msg_id_solicitude
                        );
                    }
                }
               
                if(!defined('HDZDEMO')){
                    $portal_department_name = trim(getParamText('DEPARTAMENTO_CLIENTE_ESPECIAL'));

                    if (!empty($portal_department_name) && $ticket->department_name == $portal_department_name) {
                        $tickets->replyTicketNotificationPortal($ticket, $message, (isset($files) ? $files : null));
                    } else {
                        $tickets->replyTicketNotification($ticket, $message, (isset($files) ? $files : null), $checkedAttachmentFiles);
                    }
                }
                $this->session->setFlashdata('ticket_update', lang('Admin.tickets.messageSent'));
                return redirect()->to(current_url()); 
            }
        }
        elseif ($this->request->getPost('do') == 'delete_note'){
            $validation = Services::validation();
            $validation->setRule('note_id','note_id','required|is_natural_no_zero');
            if($validation->withRequest($this->request)->run() == false) {
                $error_msg = lang('Admin.tickets.invalidRequest');
            }elseif(!$note = $tickets->getNote($this->request->getPost('note_id'))) {
                $error_msg = lang('Admin.tickets.invalidRequest');
            }elseif ($this->staff->getData('admin') == 1 || $this->staff->getData('id') == $note->staff_id){
                $tickets->deleteNote($ticket->id, $this->request->getPost('note_id'));
                $this->session->setFlashdata('ticket_update', lang('Admin.tickets.noteRemoved'));
                return redirect()->to(current_url());
            }else{
                $error_msg = lang('Admin.tickets.invalidRequest');
            }
        }
        elseif ($this->request->getPost('do') == 'edit_note'){
            $validation = Services::validation();
            $validation->setRule('note_id','note_id','required|is_natural_no_zero');
            if($validation->withRequest($this->request)->run() == false) {
                $error_msg = lang('Admin.tickets.invalidRequest');
            }elseif ($this->request->getPost('new_note') == ''){
                $error_msg = lang('Admin.tickets.enterNote');
            }elseif(!$note = $tickets->getNote($this->request->getPost('note_id'))) {
                $error_msg = lang('Admin.tickets.invalidRequest');
            }elseif ($this->staff->getData('admin') == 1 || $this->staff->getData('id') == $note->staff_id){
                $tickets->updateNote($this->request->getPost('new_note'), $note->id);
                $this->session->setFlashdata('ticket_update', lang('Admin.tickets.noteUpdated'));
                return redirect()->to(current_url());
            }else{
                $error_msg = lang('Admin.tickets.invalidRequest');
            }
        }
        elseif ($this->request->getPost('do') == 'save_notes'){
            if($this->request->getPost('noteBook') == ''){
                $error_msg = lang('Admin.tickets.enterNote');
            }else{
                $tickets->addNote($ticket->id, $this->staff->getData('id'), $this->request->getPost('noteBook'));
                $this->session->setFlashdata('ticket_update', lang('Admin.tickets.notesSaved'));
                return redirect()->to(current_url());
            }
        }

        if($this->session->has('ticket_update')){
            $success_msg = $this->session->getFlashdata('ticket_update');
        }

        $messages = $tickets->getMessages($ticket->id);
        if(defined('HDZDEMO')){
            $ticket->email = '[Hidden in demo]';
        }
        return view('staff/ticket_view',[
            'error_msg' => isset($error_msg) ? $error_msg : null,
            'success_msg' => isset($success_msg) ? $success_msg : null,
            'ticket' => $ticket,
            'canned_response' => $tickets->getCannedList(),
            'message_result' => $messages['result'],
            'pager' => $messages['pager'],
            'departments_list' => Services::departments()->getAll(),
            'ticket_statuses' => $tickets->statusList(),
            'ticket_priorities' => $tickets->getPriorities(),
            'kb_selector' => Services::kb()->kb_article_selector(),
            'ticket_solicitude' => $this->settingsAbo->getSolicitude(),
            'notes' => $tickets->getNotes($ticket->id)
        ]);
    }

    public function create()
    {
        $tickets = Services::tickets();

        // --- LÓGICA DE VALIDACIÓN AL ENVIAR EL FORMULARIO ---
        if ($this->request->getPost('do') == 'submit') {
            $validation = Services::validation();
            $departmentsModel = new \App\Models\Departments();

            // 1. OBTENER PARÁMETROS Y DATOS DEL FORMULARIO
            $parentDeptNameParam = trim(getParamText('DEPS_PADRE_CON_HIJOS')); // ej: "Sistemas"
            $mainDeptId = $this->request->getPost('department');
            $childDeptRadioId = $this->request->getPost('sub_department_radio'); // Nuevo campo para los radios
            
            $finalDeptId = $mainDeptId; // Por defecto, el ID del ticket es el del select principal

            // 2. LÓGICA DE VALIDACIÓN PRINCIPAL
            $mainDeptObject = $departmentsModel->find($mainDeptId);
            if ($mainDeptObject && strcasecmp($mainDeptObject->name, $parentDeptNameParam) == 0) {
                // Si se seleccionó el departamento padre, el radio button del hijo es OBLIGATORIO
                if (empty($childDeptRadioId)) {
                    return redirect()->back()->withInput()->with('error_msg', 'Al seleccionar "' . $parentDeptNameParam . '", es obligatorio elegir un departamento específico.');
                }
                // El ID final para el ticket es el del hijo seleccionado en el radio.
                $finalDeptId = $childDeptRadioId;
            }

            // Obtener el nombre del departamento final para la regla del adjunto
            $finalDeptObject = $departmentsModel->find($finalDeptId);
            $finalDeptName = $finalDeptObject ? $finalDeptObject->name : '';

            // 3. REGLAS DE VALIDACIÓN ESTÁNDAR
            $rules = [
                'department' => 'required',
                'priority'   => 'required|is_natural_no_zero|is_not_unique[priority.id]',
                'status'     => 'required|is_natural|in_list[' . implode(',', array_keys($tickets->statusList())) . ']',
                'subject'    => 'required',
                'message'    => 'required'
            ];
            $errors = [
                'department' => [
                    'required' => lang('Admin.error.invalidDepartment'),
                ],
                'priority' => [
                    'required' => lang('Admin.error.invalidPriority'),
                    'is_natural_no_zero' => lang('Admin.error.invalidPriority'),
                    'is_not_unique' => lang('Admin.error.invalidPriority'),
                ],
                'status' => [
                    'required' => lang('Admin.error.invalidStatus'),
                    'is_natural' => lang('Admin.error.invalidStatus'),
                    'in_list' => lang('Admin.error.invalidStatus'),
                ],
                'subject' => [
                    'required' => lang('Admin.error.enterSubject'),
                ],
                'message' => [
                    'required' => lang('Admin.error.enterMessage'),
                ]
            ];

            // 4. CONSTRUIR LAS REGLAS PARA EL ADJUNTO DE FORMA SEGURA
            $attachmentRules = [];
            
            // Regla #1: Adjunto obligatorio por parámetro DEPS_HIJOS_ADJUNTO_OBLIGATORIO
            $requireAttachmentFor_String = trim(getParamText('DEPS_HIJOS_ADJUNTO_OBLIGATORIO'));
            if (!empty($requireAttachmentFor_String)) {
                $requireAttachmentFor_Array = array_map('trim', explode(',', $requireAttachmentFor_String));
                foreach ($requireAttachmentFor_Array as $dept_name) {
                    if (strcasecmp($finalDeptName, $dept_name) == 0) {
                        $attachmentRules[] = 'uploaded[attachment]';
                        $errors['attachment']['uploaded'] = 'Para el departamento de ' . $dept_name . ', es obligatorio adjuntar un archivo.';
                        break;
                    }
                }
            }

            // Regla #2: Reglas generales de tipo y tamaño de archivo
            if ($this->settings->config('ticket_attachment')) {
                $max_size = $this->settings->config('ticket_file_size') * 1024;
                $allowed_extensions = implode(',', unserialize($this->settings->config('ticket_file_type')));
                
                $attachmentRules[] = 'ext_in[attachment,' . $allowed_extensions . ']';
                $attachmentRules[] = 'max_size[attachment,' . $max_size . ']';
                
                $errors['attachment']['ext_in'] = lang('Admin.error.fileNotAllowed');
                $errors['attachment']['max_size'] = lang_replace('Admin.error.fileBig', ['%size%' => number_to_size($max_size * 1024, 2)]);
            }

            // Si se generó alguna regla para 'attachment', se la añade al conjunto de reglas.
            if (!empty($attachmentRules)) {
                $rules['attachment'] = implode('|', $attachmentRules);
            }
            
            $validation->setRules($rules, $errors);

            // --- El resto del código para procesar el ticket permanece igual ---
            if ($validation->withRequest($this->request)->run() == false) {
                $error_msg = $validation->listErrors();
            } elseif (defined('HDZDEMO')) {
                $error_msg = 'This is not possible in demo version.';
            } else {
                $attachments = Services::attachments();
                if ($this->settings->config('ticket_attachment')) {
                    if ($uploaded_files = $attachments->ticketUpload()) {
                        $files = $uploaded_files;
                    }
                }
                $name = $this->staff->getData('fullname');
                $email = $this->staff->getData('email');
                $client_id = $this->client->getClientID($name, $email);
                // ¡Importante! Usamos $finalDeptId aquí
                $ticket_id = $tickets->createTicket($client_id, $this->request->getPost('subject'), $finalDeptId, $this->request->getPost('priority'));
                $message = $this->request->getPost('message') . $this->staff->getData('signature');
                $message_id = $tickets->addMessage($ticket_id, $message, $this->staff->getData('id'));
                $tickets->updateTicket(['last_replier' => $this->staff->getData('id'), 'status' => $this->request->getPost('status')], $ticket_id);
                if (isset($files)) {
                    $attachments->addTicketFiles($ticket_id, $message_id, $files);
                }
                $ticket = $tickets->getTicket(['id' => $ticket_id]);
                $tickets->replyTicketNotification($ticket, $message, (isset($files) ? $files : null));
                $this->session->setFlashdata('form_success', 'Ticket has been created and client was notified.');
                return redirect()->route('staff_ticket_view', [$ticket_id]);
            }
        }
        
        // --- INICIO DE LA SECCIÓN PARA PREPARAR Y MOSTRAR LA VISTA ---
        
        // 1. OBTENER PARÁMETROS Y SEPARAR DEPARTAMENTOS
        $parentDeptNameParam = trim(getParamText('DEPS_PADRE_CON_HIJOS'));
        $allDepartments = Services::departments()->getAll();
        $mainDepartments = [];
        $childDepartments = [];
        $parentDeptIdForView = null;

        if (!empty($parentDeptNameParam)) {
            foreach ($allDepartments as $dept) {
                if (strcasecmp($dept->name, $parentDeptNameParam) == 0) {
                    $parentDeptIdForView = $dept->id;
                    break;
                }
            }
        }

        if ($parentDeptIdForView) {
            foreach ($allDepartments as $dept) {
                if (isset($dept->id_padre) && $dept->id_padre == $parentDeptIdForView) {
                    $childDepartments[] = $dept;
                } else {
                    $mainDepartments[] = $dept;
                }
            }
        } else {
            $mainDepartments = $allDepartments;
        }

        // 2. PASAR TODOS LOS DATOS A LA VISTA
        $this->data['staff_name'] = $this->staff->getData('fullname');
        $this->data['staff_email'] = $this->staff->getData('email');
        $this->data['error_msg'] = isset($error_msg) ? $error_msg : session()->getFlashdata('error_msg');
        $this->data['success_msg'] = $this->session->getFlashdata('form_success');
        $this->data['canned_response'] = $tickets->getCannedList();
        
        $this->data['main_departments_list'] = $mainDepartments;
        $this->data['child_departments_list'] = $childDepartments;
        $this->data['parent_department_id'] = $parentDeptIdForView;

        $this->data['requireAttachmentForDepts'] = getParamText('DEPS_HIJOS_ADJUNTO_OBLIGATORIO');
        $this->data['ticket_statuses'] = $tickets->statusList();
        $this->data['ticket_priorities'] = $tickets->getPriorities();
        $this->data['kb_selector'] = Services::kb()->kb_article_selector();

        return view('staff/ticket_new', $this->data);
    }

    public function cannedResponses()
    {
        $tickets = Services::tickets();
        if($this->request->getPost('do') == 'remove'){
            if(!$canned = $tickets->getCannedResponse($this->request->getPost('msgID'))){
                $error_msg = lang('Admin.error.invalidCannedResponse');
            }elseif(!$this->staff->getData('admin') && $canned->staff_id != $this->staff->getData('id')) {
                $error_msg = lang('Admin.error.invalidCannedResponse');
            }elseif (defined('HDZDEMO')){
                $error_msg = 'This is not possible in demo version.';
            }else{
                $tickets->deleteCanned($canned->id);
                $this->session->setFlashdata('canned_update','Canned response has been removed.');
                return redirect()->route('staff_canned');
            }
        }

        if($this->request->getGet('action') && is_numeric($this->request->getGet('msgID'))){
            if(!$canned = $tickets->getCannedResponse($this->request->getGet('msgID'))){
                $error_msg = lang('Admin.error.invalidCannedResponse');
            }elseif (defined('HDZDEMO')){
                $error_msg = 'This is not possible in demo version.';
            }else{
                $cannedModel = new CannedModel();
                switch ($this->request->getGet('action')){
                    case 'move_up':
                        if($canned->position > 1){
                            $cannedModel->protect(false);
                            $cannedModel->set('position', $canned->position)
                                ->where('position', ($canned->position-1))
                                ->update();
                            $cannedModel->protect(true);
                            $tickets->changeCannedPosition(($canned->position-1), $canned->id);
                        }
                        break;
                    case 'move_down':
                        if($canned->position < $tickets->lastCannedPosition()){
                            $cannedModel->protect(false);
                            $cannedModel->set('position', $canned->position)
                                ->where('position', ($canned->position+1))
                                ->update();
                            $cannedModel->protect(true);
                            $tickets->changeCannedPosition(($canned->position+1), $canned->id);
                        }
                        break;
                }
                return redirect()->route('staff_canned');
            }
        }
        if($this->session->has('canned_update')){
            $success_msg = $this->session->getFlashdata('canned_update');
        }
        return view('staff/canned_manage',[
            'cannedList' => $tickets->getCannedList(),
            'lastCannedPosition' => $tickets->lastCannedPosition(),
            'error_msg' => isset($error_msg) ? $error_msg : null,
            'success_msg' => isset($success_msg) ? $success_msg : null
        ]);
    }

    public function editCannedResponses($canned_id)
    {
        $tickets = Services::tickets();
        if(!$canned = $tickets->getCannedResponse($canned_id)){
            return redirect()->route('staff_canned');
        }
        if($this->request->getPost('do') == 'submit')
        {
            $validation = Services::validation();
            $validation->setRules([
                'title' => 'required',
                'message' => 'required'
            ],[
                'title' => [
                    'required' => lang('Admin.error.enterTitle'),
                ],
                'message' => [
                    'required' => lang('Admin.error.enterMessage')
                ]
            ]);
            if($validation->withRequest($this->request)->run() == false){
                $error_msg = $validation->listErrors();
            }elseif (defined('HDZDEMO')){
                $error_msg = 'This is not possible in demo version.';
            }else{
                $tickets->updateCanned([
                    'title' => esc($this->request->getPost('title')),
                    'message' => $this->request->getPost('message'),
                    'last_update' => time()
                ], $canned_id);
                $this->session->setFlashdata('canned_update','Canned response has been updated.');
                return redirect()->to(current_url());
            }
        }

        if($this->session->has('canned_update')){
            $success_msg = $this->session->getFlashdata('canned_update');
        }
        return view('staff/canned_form',[
            'error_msg' => isset($error_msg) ? $error_msg : null,
            'success_msg' => isset($success_msg) ? $success_msg : null,
            'canned' => $canned,
            'staff_canned' => ($canned->staff_id > 0 ? $this->staff->getRow(['id'=>$canned->staff_id],'fullname') : null)
        ]);
    }

    public function newCannedResponse()
    {
        if($this->request->getPost('do') == 'submit'){
            $validation = Services::validation();
            $validation->setRules([
                'title' => 'required',
                'message' => 'required'
            ],[
                'title' => [
                    'required' => lang('Admin.error.enterTitle'),
                ],
                'message' => [
                    'required' => lang('Admin.error.enterMessage')
                ]
            ]);
            if($validation->withRequest($this->request)->run() == false){
                $error_msg = $validation->listErrors();
            }elseif (defined('HDZDEMO')){
                $error_msg = 'This is not possible in demo version.';
            }else{
                $tickets = Services::tickets();
                $tickets->insertCanned($this->request->getPost('title'), $this->request->getPost('message'));
                $this->session->setFlashdata('canned_update', 'Canned response has been inserted.');
                return redirect()->route('staff_canned');
            }
        }

        return view('staff/canned_form',[
            'error_msg' => isset($error_msg) ? $error_msg : null,
            'success_msg' => $this->session->has('canned_update') ? $this->session->getFlashdata('canned_update') : null,
        ]);
    }
}