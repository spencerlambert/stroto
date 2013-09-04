<?php
function returnJSON($JSON) {
    header('Content-type: application/json');
    echo(json_encode($JSON));
}

function numbers_only($str) {
  $pattern = '/[^0-9]/';
  return preg_replace($pattern, '', $str);
}

function random_string($length) {
    $characters = '0123456789';
    $characters .= 'abcdefghijklmnopqrstuvwxyz'; 
    $charactersLength = strlen($characters)-1;
    $string = '';

    //select some random characters
    for ($i = 0; $i < $length; $i++) {
        $string .= $characters[mt_rand(0, $charactersLength)];
    }        
    
    return $string;
}

?>