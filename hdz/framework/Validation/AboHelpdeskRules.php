<?php

/**
 * @author: Adrian Carchipulla
 * Clase para validaciones propias de ABO HELPDESK
 *
 */

namespace CodeIgniter\Validation;

use CodeIgniter\HTTP\RequestInterface;
use Config\Mimes;
use Config\Services;

/**
 * File validation rules
 */
class AboHelpdeskRules
{

    /**
     * Se valida que la identificación sea alfanumérico incluyendo el guion medio. 
     */
    public function identification(?string $value = null): bool {
        if($value === null){
            return true;
        }

        // @see https://regex101.com/r/LhqHPO/1
        return (bool) preg_match('/\A[A-Z0-9-]+\z/i', $value);
    }

    /**
     * Se valida que el nombre del cliente sea alfabetico mas 
     * caracteres especiales de (- . &). 
     */
    public function name_client(?string $value = null): bool {
        if($value === null){
            return true;
        }

        // @see https://regex101.com/r/LhqHPO/1
        return (bool) preg_match('/\A[A-Z-.& ]+\z/i', $value);
    }
    
}

