<?php
if (CONFIG_LOADED !== true) {
    $error_txt = "no access";
    include('/include/error_reply.php');
}

include_once('../classes/class_tales.php');
include_once('../classes/class_sqlite.php');

//Check Apple Receipt


//Save Purchase


//Build SQLite file

$sql = "SELECT StoryPackID, Name, Description, ThumbnailURL, Price, AppleStoreKey, Type
        FROM
            StoryPack
        WHERE
            StoryPackID='".$story_id."'";
$row = mysql_fetch_assoc(mysql_query($sql, $db_storypack));
if ($story_id != $row['StoryPackID']) {
    $error_txt = "did not find st_story_id: ".$story_id;
    include('/include/error_reply.php');                
}

$sqlite_filename = random_string(25)."db";

$sqlite_db = new StoryPackDB(DOWNLOAD_PATH.$sqlite_filename, $row['Name']);

$sql = "SELECT DefaultScale, ImageDataPNG, ImageType FROM Images WHERE StoryPackID='".$story_id."'";
$res = mysql_query($sql, $db_storypack);
while ($row = mysql_fetch_assoc($res)) {
    $sqlite_db->insert_image($row['ImageType'], $row['ImageDataPNG'], $row['DefaultScale']);
}

$json = array();
$json['st_url'] = DOWNLOAD_URL.$sqlite_filename;
$json['st_error'] = "";
$json['st_result'] = "OK";

returnJSON($json);

?>