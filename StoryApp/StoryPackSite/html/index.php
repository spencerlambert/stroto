<?php
include_once('config/config.php');
include_once('include/functions.php');

$json_string = file_get_contents('php://input');
$json_data = json_decode($json_string);

if (!isset($json_data->st_request)) {
    $error_txt = "no st_request";
    include('include/error_reply.php');
}

include_once('config/db_config.php');

switch ($json_data->st_request) {
    case "get_free_list":
        $type = 'Free';
        $category = 'Featured';
        include('request/get_list.php');
        break;
    case "get_paid_list":
        $type = 'Paid';
        $category = 'Featured';
        include('request/get_list.php');
        break;
    case "get_story_details":
        $story_id = numbers_only($json_data->st_story_id);
        if ($story_id == "") {
            $error_txt = "missing valid st_story_id";
            include('include/error_reply.php');            
        }
        include('request/get_story_details.php');
        break;
    case "purchase":
        include('request/purchase.php');
        break;
    default:
        $error_txt = "st_request not recognized";
        include('include/error_reply.php');
}

?>