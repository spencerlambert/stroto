<?php date_default_timezone_set('America/Denver'); ?>
<?php

$MYSQL_ERRNO 		= '';
$MYSQL_ERROR 		= '';


function db_connect($dbname, $dbhost, $dbusername, $dbuserpassword, $ssl = false) {
   global $MYSQL_ERRNO, $MYSQL_ERROR;

   if ($ssl) {
      $link_id = mysql_pconnect($dbhost, $dbusername, $dbuserpassword, MYSQL_CLIENT_SSL);
   } else {
      $link_id = mysql_pconnect($dbhost, $dbusername, $dbuserpassword);      
   }
   if(!$link_id) {
      $MYSQL_ERRNO = 0;
      $MYSQL_ERROR = "Connection failed to the host $dbhost.";
      return 0;
   }
   else if(!mysql_select_db($dbname, $link_id)) {
      $MYSQL_ERRNO = mysql_errno();
      $MYSQL_ERROR = mysql_error();
      return 0;
   }
   else {
      mysql_query("SET wait_timeout=600", $link_id);
      return $link_id;
   }
}

function sql_error() {
   global $MYSQL_ERRNO, $MYSQL_ERROR;

   if(empty($MYSQL_ERROR)) {
      $MYSQL_ERRNO = mysql_errno();
      $MYSQL_ERROR = mysql_error();
   }
   return "$MYSQL_ERRNO: $MYSQL_ERROR";
}

global $db_storypack;
$db['storypack'] = db_connect(STORYPACK_DB_NAME, STORYPACK_DB_HOST, STORYPACK_DB_USER, STORYPACK_DB_PASS, STORYPACK_DB_SSL);
$db_storypack = $db['storypack'];

?>