<?php
include_once('config/config.php');
include_once('include/functions.php');
include_once('config/db_config.php');

$json_string = file_get_contents('php://input');

//Log data
$sql = "INSERT INTO Log (LogDateTime, IPAddress, JSON) VALUES (NOW(), '".$_SERVER['REMOTE_ADDR']."', '".mysql_escape_string($json_string)."')";
$res = mysql_query($sql, $db_storypack);


$json_data = json_decode($json_string);

if (!isset($json_data->st_request)) {
    $error_txt = "no st_request";
    include('include/error_reply.php');
}


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
        $story_id = numbers_only($json_data->st_story_id);
        $apple_receipt = $json_data->apple_receipt;
        if ($story_id == "") {
            $error_txt = "missing valid st_story_id";
            include('include/error_reply.php');            
        }
        include('request/purchase.php');
        break;
    default:
        $error_txt = "st_request not recognized";
        include('include/error_reply.php');
}

?>