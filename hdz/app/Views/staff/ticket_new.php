<?php
/**
 * @var $this \CodeIgniter\View\View
 */
$this->extend('staff/template');
$this->section('content');
?>
    <div class="page-header row no-gutters py-4">
        <div class="col-12 col-sm-4 text-center text-sm-left mb-0">
            <span class="text-uppercase page-subtitle">HelpDeskZ</span>
            <h3 class="page-title"><?php echo lang('Admin.tickets.newTicket'); ?></h3>
        </div>
    </div>
    <?php
if (isset($error_msg)) {
    echo '<div class="alert alert-danger">' . $error_msg . '</div>';
}
if (isset($success_msg)) {
    echo '<div class="alert alert-success">' . $success_msg . '</div>';
}
?>

    <div class="card">
        <div class="card-header border-bottom">
            <h6 class="mb-0"><?php echo lang('Admin.tickets.submitNewTicket'); ?></h6>
        </div>
        <div class="card-body">
            <?php echo form_open_multipart('', [], ['do' => 'submit']); ?>

            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label>Usuario</label>
                        <div class="alert alert-info">
                            <strong><?php echo esc($staff_name); ?></strong> (<?php echo esc($staff_email); ?>)
                        </div>
                        <small class="form-text text-muted">El ticket se creará a nombre del agente que ha iniciado sesión.</small>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="form-group">
                        <label><?php echo lang('Admin.form.department'); ?></label>
                        <select name="department" id="mainDepartmentSelect" class="form-control custom-select">
                            <option value="">-- Seleccione un departamento --</option>
                            <?php foreach ($main_departments_list as $item) : ?>
                                <option value="<?php echo $item->id; ?>" <?php echo set_select('department', $item->id); ?>>
                                    <?php echo $item->name; ?>
                                </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="form-group">
                        <label><?php echo lang('Admin.form.priority'); ?></label>
                        <select name="priority" class="form-control custom-select">
                            <?php foreach ($ticket_priorities as $item) : ?>
                                <option value="<?php echo $item->id; ?>" <?php echo set_select('priority', $item->id, TRUE); ?>><?php echo $item->name; ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label><?php echo lang('Admin.form.status'); ?></label>
                        <select name="status" class="form-control custom-select">
                            <?php foreach ($ticket_statuses as $k => $v) : ?>
                                <option value="<?php echo $k; ?>" <?php echo set_select('status', $k); ?>><?php echo lang('Admin.form.' . $v); ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>
            </div>
            
            <div id="childDepartmentContainer" class="form-group" style="display: none; border: 1px solid #ddd; padding: 15px; border-radius: 5px; background-color: #f9f9f9;">
                <label><strong>Seleccione un departamento específico:</strong></label>
                <div class="d-flex flex-wrap">
                    <?php foreach ($child_departments_list as $item) : ?>
                        <div class="custom-control custom-radio mr-3">
                            <input type="radio" id="sub_dept_<?php echo $item->id; ?>" name="sub_department_radio" value="<?php echo $item->id; ?>" class="custom-control-input" <?php echo set_radio('sub_department_radio', $item->id); ?>>
                            <label class="custom-control-label" for="sub_dept_<?php echo $item->id; ?>"><?php echo $item->name; ?></label>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>


            <div class="form-group">
                <label><?php echo lang('Admin.form.subject'); ?></label>
                <input type="text" name="subject" class="form-control" value="<?php echo set_value('subject'); ?>" required>
            </div>

            <div class="form-group">
                <label><?php echo lang('Admin.form.quickInsert'); ?></label>
                <div class="row">
                    <div class="col-sm-6 mb-3">
                        <select name="canned" id="cannedList" onchange="addCannedResponse(this.value);" class="custom-select">
                            <option value=""><?php echo lang('Admin.cannedResponses.menu'); ?></option>
                            <?php foreach ($canned_response as $item) { echo '<option value="' . $item->id . '">' . $item->title . '</option>'; } ?>
                        </select>
                    </div>
                    <div class="col-sm-6">
                        <select name="knowledgebase" id="knowledgebaseList" onchange="addKnowledgebase(this.value);" class="custom-select">
                            <option value=""><?php echo lang('Admin.kb.menu'); ?></option>
                            <?php echo $kb_selector; ?>
                        </select>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <textarea class="form-control" name="message" id="messageBox" rows="20"><?php echo set_value('message'); ?></textarea>
            </div>
            
            <?php if (site_config('ticket_attachment')) : ?>
                <div class="form-group">
                    <label><?php echo lang('Admin.form.attachments'); ?></label>
                    <div class="row">
                        <div class="col-lg-4 mb-2">
                            <div class="custom-file">
                                <input type="file" class="custom-file-input" name="attachment" id="customFile1">
                                <label class="custom-file-label" for="customFile1" data-browse="<?php echo lang('Admin.form.browse'); ?>"><?php echo lang('Admin.form.chooseFile'); ?></label>
                            </div>
                        </div>
                    </div>
                    <?php for ($i = 2; $i <= site_config('ticket_attachment_number'); $i++) : ?>
                        <div class="row">
                            <div class="col-lg-4 mb-2">
                                <div class="custom-file">
                                    <input type="file" class="custom-file-input" name="attachment[]" id="customFile<?php echo $i; ?>">
                                    <label class="custom-file-label" for="customFile<?php echo $i; ?>" data-browse="<?php echo lang('Admin.form.browse'); ?>"><?php echo lang('Admin.form.chooseFile'); ?></label>
                                </div>
                            </div>
                        </div>
                    <?php endfor; ?>
                    <small class="text-muted"><?php echo lang('Admin.form.allowedFiles') . ' *.' . implode(', *.', unserialize(site_config('ticket_file_type'))); ?></small>
                </div>
            <?php endif; ?>

            <div class="form-group">
                <button class="btn btn-primary"><i class="fa fa-paper-plane"></i> <?php echo lang('Admin.form.submit'); ?></button>
            </div>
            <?php echo form_close(); ?>
        </div>
    </div>

<?php
$this->endSection();
$this->section('script_block');
include __DIR__ . '/tinymce.php';
?>
    <script>
        $(document).ready(function () {
            bsCustomFileInput.init();
        });
        <?php if (isset($canned_response)) { echo 'var canned_response = ' . json_encode($canned_response) . ';'; } ?>
        var KBUrl = '<?php echo site_url(route_to('staff_ajax_kb'));?>';
    </script>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // --- LÓGICA PARA RADIOS DEPENDIENTES ---
        const parentDeptId = "<?= esc($parent_department_id ?? '', 'js') ?>";
        const mainSelect = document.getElementById('mainDepartmentSelect');
        const childContainer = document.getElementById('childDepartmentContainer');
        const childRadios = document.querySelectorAll('input[name="sub_department_radio"]');

        function toggleChildDepartmentVisibility() {
            if (mainSelect.value === parentDeptId) {
                childContainer.style.display = 'block';
            } else {
                childContainer.style.display = 'none';
                // Deseleccionar cualquier radio si se oculta el contenedor
                childRadios.forEach(radio => radio.checked = false);
            }
        }

        mainSelect.addEventListener('change', toggleChildDepartmentVisibility);
        // Ejecutar al cargar la página para restaurar el estado si hubo un error de validación
        toggleChildDepartmentVisibility();

        // --- LÓGICA PARA ADJUNTOS OBLIGATORIOS (MEJORADA) ---
        const requireAttachmentForDepts = "<?= esc($requireAttachmentForDepts ?? '', 'js') ?>";
        if (requireAttachmentForDepts) {
            const requiredDeptsArray = requireAttachmentForDepts.split(',').map(dept => dept.trim().toLowerCase());
            const attachmentWarning = document.createElement('div');
            attachmentWarning.className = 'alert alert-warning mt-2';
            attachmentWarning.style.display = 'none';
            // Insertar el aviso después del contenedor de los radio buttons
            childContainer.parentNode.insertBefore(attachmentWarning, childContainer.nextSibling);

            function checkAttachment() {
                let selectedDeptName = '';
                let finalSelectedDeptText = '';

                if (mainSelect.value === parentDeptId) {
                    const checkedRadio = document.querySelector('input[name="sub_department_radio"]:checked');
                    if (checkedRadio) {
                        // El nombre lo tomamos del label asociado al radio
                        finalSelectedDeptText = document.querySelector(`label[for="${checkedRadio.id}"]`).textContent;
                        selectedDeptName = finalSelectedDeptText.trim().toLowerCase();
                    }
                } else {
                    finalSelectedDeptText = mainSelect.options[mainSelect.selectedIndex].text;
                    selectedDeptName = finalSelectedDeptText.trim().toLowerCase();
                }

                const isRequired = requiredDeptsArray.includes(selectedDeptName);
                if (isRequired) {
                    attachmentWarning.innerHTML = `<b>Atención:</b> Para el departamento <b>${finalSelectedDeptText}</b> es obligatorio adjuntar un archivo.`;
                    attachmentWarning.style.display = 'block';
                } else {
                    attachmentWarning.style.display = 'none';
                }
            }
            
            mainSelect.addEventListener('change', checkAttachment);
            childRadios.forEach(radio => radio.addEventListener('change', checkAttachment));
            checkAttachment(); // Ejecutar al cargar
        }
    });
    </script>
    <?php
$this->endSection();
?>