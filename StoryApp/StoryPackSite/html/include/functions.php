<?php
function returnJSON($JSON) {
    header('Content-type: application/json');
    echo(json_encode($JSON));
}

function numbers_only($str) {
  $pattern = '/[^0-9]/';
  return preg_replace($pattern, '', $str);
}

?>