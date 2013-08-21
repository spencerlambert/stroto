<?php

define("CONFIG_LOADED", true);

define("HTTPD_SITE_ROOT", "/var/www/stroto_storypacks/");
define("THUMBNAIL_SUBDIR", "thumbnails/");
define("THUMBNAIL_PATH", HTTPD_SITE_ROOT.THUMBNAIL_SUBDIR);
define("SITE_URL", "http://storypacks.stroto.com/");
define("THUMBNAIL_URL", SITE_URL.THUMBNAIL_SUBDIR);


define("CONVERT_PATH", "/usr/bin/convert");

//Storypack DB
define("STORYPACK_DB_HOST","localhost");
define("STORYPACK_DB_USER","root");
define("STORYPACK_DB_PASS","mysqlpass");
define("STORYPACK_DB_NAME","story_packs");
define("STORYPACK_DB_SSL",false);

?>