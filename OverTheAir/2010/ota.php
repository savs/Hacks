<?php
print "<html><head><title>OTA</title></head><body><pre>";

$dbh = pg_connect("host=localhost dbname=YOUR_DB user=YOUR_DB_USER");
if (!$dbh) {
	die ("Error in connection: " . pg_last_error());
}

// execute query
$sql = "SELECT * FROM friends";
$result = pg_query($dbh, $sql);
if (!$result) {
	die("Error in SQL query: " . pg_last_error());
}
while ($row = pg_fetch_array($result)) {
	print "Record: "  . $row[0] . "<br />";
}

$username_password = 'dick@hashblue.com:d204423a28681c3b012868f6db715a59';
$uri = "https://api.hashblue.com/subscribers/d204423a28681c3b012868f6db715a59/messages.json";
$getBlueJSON = curl_init() or die(curl_error());
curl_setopt($getBlueJSON, CURLOPT_URL, $uri);
curl_setopt($getBlueJSON, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($getBlueJSON, CURLOPT_USERPWD, $username_password);
$blue_json = curl_exec($getBlueJSON);
curl_close($getBlueJSON);
$blue = json_decode($blue_json, true);
print "<table border=1>";
for ($i=0; $i<count($blue); $i++) {
	print "<tr>";
	print "<td>" . $blue[$i]["timestamp"] . "</td>";
	print "<td>" . $blue[$i]["sent"] . "</td>";
	$sql = "SELECT * FROM friends WHERE phone_number='" . $blue[$i]["contact_msisdn"] . "'";
	$result = pg_query($dbh, $sql);
	if (!$result) {
		die("Error in SQL query: " . pg_last_error());
	}
	$row = pg_fetch_array($result);
	if ($row[0] == $blue[$i]["contact_msisdn"]) {
		print "<td><a href='http://twitter.com/" . $row[3] . "'><img src='" . $row[2]. "' /></a></td>";
		print "<td>" . $row[1]. "</td>";
	} else {
		print "<td>" . $blue[$i]["contact_msisdn"] . "</td>";
	}
	
	print "<td>" . $blue[$i]["subscriber_msisdn"] . "</td>";
	print "<td>" . $blue[$i]["content"] . "</td>";
	print "<td>" . $blue[$i]["favourite"] . "</td>";
	//print var_dump($blue[0]);
	print "</tr>";
	
}
print "</table>";

print "<br /><br />";
var_dump($blue);
//print $bluedata[0];
//var_dump(json_decode($blue, true));

print "</pre></body></html>";

//$html = file_get_contents("http://www.tfl.gov.uk/tfl/livetravelnews/realtime/dlr/default.html");
//$regex = '/DLR network/';
//preg_match($regex, $html, $match);
//print "<html><body><pre>";
//var_dump($match);
//print "[". $match[0] . "]";
//print "</pre></body></html>";
//curl -u anne@hashblue.com:d204423a28681c3b012868f6db715a59 https://api.hashblue.com/subscribers/d204423a28681c3b012868f6db715a59/messages.json

?>


