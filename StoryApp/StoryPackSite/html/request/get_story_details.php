<?php
if (CONFIG_LOADED !== true) {
    $error_txt = "no access";
    include('include/error_reply.php');
}

$sql = "SELECT StoryPackID, Name, Description, ThumbnailURL, Price, AppleStoreKey, Type
        FROM
            StoryPack
        WHERE
            StoryPackID='".$story_id."'";
$row = mysql_fetch_assoc(mysql_query($sql, $db_storypack));
if ($story_id != $row['StoryPackID']) {
    $error_txt = "did not find st_story_id: ".$story_id;
    include('include/error_reply.php');                
}

$json = array();
$json['st_details'] = $row;
$json['st_error'] = "";
$json['st_result'] = "OK";

$json['st_bg_list'] = array();  
$sql = "SELECT ThumbnailURL
        FROM
            Images
        WHERE
            StoryPackID='".$story_id."' AND
            ImageType='Background'";
$res = mysql_query($sql, $db_storypack);
while ($row = mysql_fetch_assoc($res)) {
    $json['st_bg_list'][] = $row;    
}


$json['st_fg_list'] = array();  
$sql = "SELECT ThumbnailURL
        FROM
            Images
        WHERE
            StoryPackID='".$story_id."' AND
            ImageType='Foreground'";
$res = mysql_query($sql, $db_storypack);
while ($row = mysql_fetch_assoc($res)) {
    $json['st_fg_list'][] = $row;    
}

returnJSON($json);

?>