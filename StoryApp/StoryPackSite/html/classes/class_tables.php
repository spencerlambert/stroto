<?php

class tables {
    public static $cur_version = '1.00';
    
    public static $version = "
    CREATE TABLE Version (
        Version text
    );
    ";

    public static $images = "
    CREATE TABLE Images (
        ImageDataPNG_Base64 blob,
        ImageType           text,
        DefaultScale        real
    );
    ";

    public static $story = "
    CREATE TABLE StoryPackInfo (
        Name                text,
        ImageDataPNG_Base64 blob
    );
    ";

    public static function asArray() {
        return array('version'=>tables::$version,
                     'version_insert'=>"INSERT INTO Version (Version) VALUES ('".tables::$cur_version."');",
                     'images'=>tables::$images,
                     'story'=>tables::$story,
                     );
    }

    protected static function upgrade_1_1() {
        //return tables::$credit_card.tables::$ach."UPDATE Version SET Version='1.1';";
    }

    public static function upgradeFrom($version) {
        $sql = "";

        if ($version < 1.10) $sql .= tables::upgrade_1_1();            
        
        return $sql;
        
    }

}

?>