<html>
    <head>
        <title>#blue contacts</title>
        <link rel="stylesheet" href="bubbles.css" >
    </head>
    <body>
    <div id="container">
    <div class="content">
        <p><small><a href="/~savs/">home</a></small></p>
        <h1>Your contacts</h1>
<?php
$dbh = pg_connect("host=localhost dbname=YOUR_DB user=YOUR_DB_USER");
if (!$dbh) {
	die ("Error in connection: " . pg_last_error());
}

// Get all the Blue data
$blue_username_password = 'dick@hashblue.com:d204423a28681c3b012868f6db715a59';
$blue_uri = "https://api.hashblue.com/subscribers/d204423a28681c3b012868f6db715a59/contacts.json";
$getBlueJSON = curl_init() or die(curl_error());
curl_setopt($getBlueJSON, CURLOPT_URL, $blue_uri);
curl_setopt($getBlueJSON, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($getBlueJSON, CURLOPT_USERPWD, $blue_username_password);
$blue_json = curl_exec($getBlueJSON);
curl_close($getBlueJSON);
$blue = json_decode($blue_json, true);

// Get all the Plaxo data
$plaxo_username_password = 'USERNAME:PASSWORD';
$plaxo_uri = "http://www.plaxo.com/pdata/contacts";
$getPlaxoJSON = curl_init() or die(curl_error());
curl_setopt($getPlaxoJSON, CURLOPT_URL, $plaxo_uri);
curl_setopt($getPlaxoJSON, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($getPlaxoJSON, CURLOPT_USERPWD, $plaxo_username_password);
$plaxo_json = curl_exec($getPlaxoJSON);
curl_close($getPlaxoJSON);
$plaxo = json_decode($plaxo_json, true);
//print "<br /><br />";
//var_dump($plaxo["entry"][440]);
//print "<br /><br />";
//print "<b>** " . $plaxo["entry"][440]["phoneNumbers"][0]["value"] . " **</b>";
//print "<b>** " . $plaxo["entry"][440]["photos"][0]["value"] . " **</b>";
//print "<img src='" . $plaxo["entry"][440]["photos"][0]["value"] . "'/ >";

// TABLE
// contact pic | contact name or number | plaxo photo / email / name / |
print "<table border=0>";
for ($i=0; $i<count($blue); $i++) {

	// iterate through ALL plaxo contacts
	$plaxo_contact = 0;
	for ($x=0; $x<count($plaxo["entry"]); $x++) {
	    // iterate through every number for every contact
	    for ($y=0; $y<count($plaxo["entry"][$x]["phoneNumbers"]); $y++) {
	        if ($plaxo["entry"][$x]["phoneNumbers"][$y]["value"] == $blue[$i]["msisdn"]) {
	            $plaxo_contact = 1;
	            $plaxo_id = $x;
	        }
	    }
	}

    $avatar = "blank_avatar.png";
    $realname = $blue[$i]["msisdn"];

	print "<tr>";
	$sql = "SELECT * FROM friends WHERE phone_number='" . $blue[$i]["msisdn"] . "'";
	$result = pg_query($dbh, $sql);
	if (!$result) {
		die("Error in SQL query: " . pg_last_error());
	}
	$row = pg_fetch_array($result);

    // set the avatar
	if ($row[0] == $blue[$i]["msisdn"]) {
	    if (!empty($row[2])) {
	        $avatar = $row[2];
	    }
    }
	if ($plaxo_contact) {
	    $realname = $plaxo["entry"][$plaxo_id]["displayName"];
	    if (!empty($plaxo["entry"][$plaxo_id]["photos"][0]["value"])) {
	        $avatar = $plaxo["entry"][$plaxo_id]["photos"][0]["value"];
        }
	}

	// pic
	print "<td><a href='contact.php?id=" . $blue[$i]["id"] . "'><img width='75' src='" . $avatar. "' /></a></td>";
    // name or number as link to messages page
	print "<td><a href='contact.php?id=" . $blue[$i]["id"] . "'>" . $realname . "</a></td>";
    

	if ($plaxo_contact == 1) {
	    print "<td><img src='plaxo-logo.gif' /></td>";
	}
//	print var_dump($blue[0]);
	print "</tr>";
	
}
print "</table>";

print "<br /><br />";

?>

</div></div>
    </body>
</html>
