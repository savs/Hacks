<?php
$html = file_get_contents("http://www.tfl.gov.uk/tfl/livetravelnews/realtime/dlr/default.html");
$regex = '/DLR network/';
preg_match($regex, $html, $match);
print "<html><body><pre>";
var_dump($match);
print "[". $match[0] . "]";
print "</pre></body></html>";

?>