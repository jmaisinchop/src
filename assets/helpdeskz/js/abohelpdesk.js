/*
* Funcion para deshabilitar botones al enviar datos al servidor SUBMIT
**/
window.onload = function () {
    if(document.forms['myForm'])
    document.forms['myForm'].addEventListener('submit', avisarUsuario);
    console.log('hello javascript ABO helpdesk');
}

function avisarUsuario(evObject) {
    evObject.preventDefault();
    var botones = document.querySelectorAll('button');
    let buttonBack = document.getElementById('btnBack');

    //Deshabilito funciones de 'a'
    if(buttonBack){
        buttonBack.style.cursor = 'default';
        buttonBack.style.textDecoration = 'none';
        buttonBack.style.pointerEvents = 'none';
    }
    
    for (var i=0; i<botones.length; i++) {botones[i].disabled = true; }
    var retrasar = setTimeout(procesaDentroDe1Segundo, 500);
}

function procesaDentroDe1Segundo() {
    document.forms['myForm'].submit();
}
