<?php

class StoryPackDB {
    
    protected $db;
    protected $db_version;
    protected $echo_sql;
    protected $last_res;
    
    function __construct($db_file, $story_name, $echo_sql = false) {
        $this->db = new SQLite3($db_file);
        $this->echo_sql = $echo_sql;
        
/*
        $row = $this->fetch_array_single_row("SELECT Version FROM Version");
        if ($row['Version'] != "") {
            $this->db_version = $row['Version'];
            if ($this->db_version != tables::$cur_version) {
                $this->upgradeDB($this->db_version);
            }
            $row = $this->fetch_array_single_row("SELECT Version FROM Version");
            $this->db_version = $row['Version'];
        } else {
            $this->initDB();
        }
*/

        //Assuming this is a new DB every time.  Have not worked out how to check version on empty DB.
        $this->initDB();

        if ($this->echo_sql) echo "DB Version: ".$this->db_version."\n";   
        
        $this->exec("INSERT INTO StoryPackInfo (Name) VALUES('".sqlite_escape_string($story_name)."'");
        
    }
    
    protected function initDB() {
        foreach (tables::asArray() as $sql) {
            $this->exec($sql);
        }
    }
    
    protected function upgradeDB() {
        $this->exec(tables::upgradeFrom($this->db_version));
    }
    
    public function query($sql) {
        if ($this->echo_sql) echo $sql."\n";
        $this->last_res = $this->db->query($sql);
        return $this->last_res;
    }
    
    public function num_rows($sql_res = false) {
        if ($sql_res === false) $sql_res = $this->last_res;
        return $sql_res->numColumns();
    }
    
    protected function exec($sql) {
        if ($this->echo_sql) echo $sql."\n";
        return $this->db->exec($sql);
    }
    
    public function fetch_array($sql_res = false) {
        if ($sql_res === false) $sql_res = $this->last_res;
        return $sql_res->fetchArray();
    }
    
    public function fetch_array_single_row($sql) {
        return $this->fetch_array($this->query($sql));
    }
    
    protected function format_sort_by($sort_by) {
        $sort_text = "";
        if (trim($sort_by) != "") {
            $sort_text = " ORDER BY $sort_by";
        }
        return $sort_text;
    }
    
    protected function format_extra_where($extra_match) {
        $where = "";
        foreach ($extra_match as $name=>$val) {
            $where .= " AND $name='$val'";
        }
        return $where;
    }
    
    protected function format_extra_insert_names($extra_match) {
        $insert = "";
        foreach ($extra_match as $name=>$val) {
            $insert .= ", $name";
        }
        return $insert;
    }

    protected function format_extra_insert_values($extra_match) {
        $insert = "";
        foreach ($extra_match as $name=>$val) {
            $val = sqlite_escape_string($val);
            $insert .= ", '$val'";
        }
        return $insert;
    }
    
    public function insert_image($type, $png_data, $scale) {
        $sql = "INSERT INTO Images (DefaultScale, ImageType, ImageDataPNG) VALUES ('".$scale."', '".$type."','".sqlite_escape_string($png_data)."')";
        return $this->exec($sql);
    }
    
    protected function check_table($table, $account_id, $extra_match) {
        $row = $this->fetch_array_single_row("SELECT AccountID FROM $table WHERE AccountID='$account_id'".$this->format_extra_where($extra_match));
        if ($row['AccountID'] == "") {
            $this->exec("INSERT INTO $table (AccountID".$this->format_extra_insert_names($extra_match).") VALUES ('$account_id'".$this->format_extra_insert_values($extra_match).")");
        }
    }
    
    public function set_values($table, $account_id, $val_array, $extra_match = array()) {
        $account_id = sqlite_escape_string($account_id);
        $this->check_table($table, $account_id, $extra_match);
        
        foreach ($val_array as $name=>$val) {
            $val = sqlite_escape_string(trim($val));
            $this->exec("UPDATE $table SET $name='$val' WHERE AccountID='$account_id'".$this->format_extra_where($extra_match));
        }
    }
            
    public function get_table($table, $cols) {
        $rows = array();
        $items = implode(',', $cols);
        $res = $this->query("SELECT ".$items." FROM ".$table);
        while ($row = $this->fetch_array($res)) {
            array_push($rows, $row);
        }        
        return $rows;
    }
        
}




?>