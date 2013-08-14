<?php

class tables {
    public static $cur_version = '1.00';
    
    public static $version = "
    CREATE TABLE Version (
        Version varchar(100)
    );
    ";

    public static $images = "
    CREATE TABLE Images (
        ImageDataPNG    blob,
        ImageType       varchar(100)
    );
    ";

    public static $story = "
    CREATE TABLE StoryPackInfo (
        Name            varchar(100)
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