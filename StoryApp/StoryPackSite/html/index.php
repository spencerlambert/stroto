<?php
include_once('include/functions.php');

$json_string = file_get_contents('php://input');
$json_data = json_decode($json_string);

if (!isset($json_data->st_request)) {
    $error_txt = "no st_request";
    include('include/error_reply.php');
}

switch ($json_data->st_request) {
    case "get_free_list":
        include('request/get_free_list.php');
        break;
    case "get_paid_list":
        include('request/get_paid_list.php');
        break;
    case "get_story_details":
        include('request/get_story_details.php');
        break;
    case "purchase":
        include('purchase.php');
        break;
    default:
        $error_txt = "st_request not recognized";
        include('include/error_reply.php');
}

?>