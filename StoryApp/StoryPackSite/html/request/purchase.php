<?php
if (CONFIG_LOADED !== true) {
    $error_txt = "no access";
    include('include/error_reply.php');
}

include_once('classes/class_tables.php');
include_once('classes/class_sqlite.php');

//Check Apple Receipt
if (trim($apple_receipt) == "") {
    $error_txt = "apple_receipt is blank";
    include('include/error_reply.php');                    
}

if (trim($apple_receipt) == "APPLE DOWN") {
    $error_txt = "Apple Server Down";
    include('include/error_reply.php');                    
}

//Save Purchase


//Build SQLite file
$sql = "SELECT StoryPackID, Name
        FROM
            StoryPack
        WHERE
            StoryPackID='".$story_id."'";
$row = mysql_fetch_assoc(mysql_query($sql, $db_storypack));
if ($story_id != $row['StoryPackID']) {
    $error_txt = "did not find st_story_id: ".$story_id;
    include('include/error_reply.php');                
}

$sqlite_filename = random_string(25).".db";

$thumbnail_img = THUMBNAIL_PATH.$story_id."/main.png";
$thumbnail_bin = file_get_contents($thumbnail_img);

$sqlite_db = new StoryPackDB(DOWNLOAD_PATH.$sqlite_filename, $row['Name'], $thumbnail_bin);

$sql = "SELECT DefaultScale, ImageDataPNG, ImageType FROM Images WHERE StoryPackID='".$story_id."'";
$res = mysql_query($sql, $db_storypack);
while ($row = mysql_fetch_assoc($res)) {
    $sqlite_db->insert_image($row['ImageType'], $row['ImageDataPNG'], $row['DefaultScale']);
}

$bytes = filesize(DOWNLOAD_PATH.$sqlite_filename);

$json = array();
$json['st_storypack_url'] = DOWNLOAD_URL.$sqlite_filename;
$json['st_storypack_bytes'] = $bytes;
$json['st_error'] = "";
$json['st_result'] = "OK";

returnJSON($json);

?>