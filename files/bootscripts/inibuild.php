#!/usr/bin/env php

<?php

$jsonstring = $argv[1];

$json = json_decode($jsonstring, true);

if (json_last_error() == JSON_ERROR_NONE) {
    foreach ($json as $key => $value) {
        echo $key . " = " . $value . "\n";
    }
}
else {
    throw new \Exception(json_last_error_msg(), 1);
}

?>
