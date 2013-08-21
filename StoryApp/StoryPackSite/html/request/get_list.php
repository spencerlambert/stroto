<?php
if (CONFIG_LOADED !== true) {
    $error_txt = "no access";
    include('/include/error_reply.php');
}

$sql = "SELECT StoryPackID, Name, ThumbnailURL, Price, AppleStoreKey, Type
        FROM
            StoryPack
        WHERE
            Type='".$type."' AND
            (CategoryOne='".$category."' OR CategoryTwo='".$category."')
        ORDER BY DisplayOrder";
$res = mysql_query($sql, $db_storypack);

$json = array();
$json['st_list'] = array();
$json['st_error'] = "";
$json['st_result'] = "OK";

while ($row = mysql_fetch_assoc($res)) {
    $json['st_list'][] = $row;    
}


returnJSON($json);

?>