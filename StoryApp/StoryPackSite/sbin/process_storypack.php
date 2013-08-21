<?php
include_once('config/config.php');
include_once('config/db_config.php');

$vals = array();
$vals['StoryPackID'] = false;
$handle = fopen('info.txt', "r");
if ($handle) {
    while (!feof($handle)) {
        $line = fgets($handle);
        $line_array = explode(":", $line);
        $vals[trim($line_array[0])] = trim($line_array[1]);
    }
    fclose($handle);
} else {
    echo "Can't load info.txt file.\N";
    exit;
}

//Create the StoryPackID if it's new
if ($vals['StoryPackID'] === false) {
    $type = 'Paid';
    if ($vals['price'] == '0.00') $type = 'Free';
    $sql = "INSERT INTO StoryPack
                (`Name`)
            VALUES
                ('".$vals['Name']."')";
    echo($sql."\n\n");
    $res = mysql_query($sql, $db_storypack);
    $vals['StoryPackID'] = mysql_insert_id($db_storypack);
    
}

//Update the StoryPack table with the values from info.txt
foreach ($vals as $name=>$val) {
    if ($name == 'StoryPackID' || trim($name) == '') continue;
    
    $sql = "UPDATE StoryPack SET
                `".$name."`='".$val."'
            WHERE
                StoryPackID='".$vals['StoryPackID']."'";
    echo($sql."\n\n");
    $res = mysql_query($sql, $db_storypack);
}

//Save the values, this is mainly for saving the StoryPackID for next time.
$handle = fopen('info.txt', "w");
if ($handle) {
    foreach ($vals as $name=>$val) {
        if (trim($name) == '') continue;
        fwrite($handle, str_pad($name.": ", 25).$val."\n");
    }
    fclose($handle);
} else {
    "Failed to save info.txt for StoryPackID: ".$vals['StoryPackID'];
}

//Create Thumbnail Directory
if (is_dir(THUMBNAIL_PATH."/".$vals['StoryPackID']) === false) mkdir(THUMBNAIL_PATH."/".$vals['StoryPackID']);
$thumbnail_dir = THUMBNAIL_PATH.$vals['StoryPackID']."/";
$thumbnail_url = THUMBNAIL_URL.$vals['StoryPackID']."/";

exec(CONVERT_PATH." -define png:size=200x200 ".getcwd()."/thumbnail.png -thumbnail '150x150>' ".$thumbnail_dir."main.png");

$sql = "UPDATE StoryPack SET ThumbnailURL='".$thumbnail_url."main.png' WHERE StoryPackID='".$vals['StoryPackID']."'";
echo($sql."\n\n");
$res = mysql_query($sql, $db_storypack);


//Reset on all images related to the StoryPack
$sql = "DELETE FROM Images WHERE StoryPackID='".$vals['StoryPackID']."'";
echo($sql."\n\n");
$res = mysql_query($sql, $db_storypack);

//Process BG images
$bg_dir = dir(getcwd().'/bg/');
while (false !== ($img = $bg_dir->read())) {
   
    if (strpos($img, '.png') === false) continue;
    if (strpos($img, '.') == 0) continue;

    $image_path = getcwd().'/bg/'.$img;
    $image_bin = mysql_real_escape_string(file_get_contents($image_path));
    $sql = "INSERT INTO Images
                (`StoryPackID`,`ImageDataPNG`,`ImageType`)
            VALUES
                ('".$vals['StoryPackID']."','".$image_bin."','Background')";
    $res = mysql_query($sql, $db_storypack);
    $img_id = mysql_insert_id($db_storypack);

    exec(CONVERT_PATH." -define png:size=200x200 ".$image_path." -thumbnail '150x150>' ".$thumbnail_dir.$img_id.".png");
    
    $sql = "UPDATE Images SET ThumbnailURL='".$thumbnail_url.$img_id.".png' WHERE ImageID='".$img_id."'";
    echo($sql."\n\n");
    $res = mysql_query($sql, $db_storypack);

}
$bg_dir->close();


//Process FG images
$bg_dir = dir(getcwd().'/fg/');
while (false !== ($img = $bg_dir->read())) {
   
    if (strpos($img, '.png') === false) continue;
    if (strpos($img, '.') == 0) continue;

    $image_path = getcwd().'/fg/'.$img;
    $image_bin = mysql_real_escape_string(file_get_contents($image_path));
    $sql = "INSERT INTO Images
                (`StoryPackID`,`ImageDataPNG`,`ImageType`)
            VALUES
                ('".$vals['StoryPackID']."','".$image_bin."','Foreground')";
    $res = mysql_query($sql, $db_storypack);
    $img_id = mysql_insert_id($db_storypack);

    exec(CONVERT_PATH." -define png:size=200x200 ".$image_path." -thumbnail '150x150>' ".$thumbnail_dir.$img_id.".png");
    
    $sql = "UPDATE Images SET ThumbnailURL='".$thumbnail_url.$img_id.".png' WHERE ImageID='".$img_id."'";
    echo($sql."\n\n");
    $res = mysql_query($sql, $db_storypack);

}
$bg_dir->close();

echo "Done\n";


?>