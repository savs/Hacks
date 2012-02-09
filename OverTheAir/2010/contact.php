<html>
    <head>
        <title>#blue contact</title>
        <link rel="stylesheet" href="bubbles.css" >
    </head>
    <body>
    <div id="container">
        <p><small><a href="/~savs/">home</a> | <a href="/~savs/contacts.php">contacts</a></small></p>
        <div class="content">
<?php


$dbh = pg_connect("host=localhost dbname=YOUR_DB user=YOUR_DB_USER");
if (!$dbh) {
	die ("Error in connection: " . pg_last_error());
}


$username_password = 'dick@hashblue.com:d204423a28681c3b012868f6db715a59';
$uri = "https://api.hashblue.apigee.com/subscribers/d204423a28681c3b012868f6db715a59/contacts/" . $_GET["id"] . "/messages.json";

$getBlueJSON = curl_init() or die(curl_error());
curl_setopt($getBlueJSON, CURLOPT_URL, $uri);
curl_setopt($getBlueJSON, CURLOPT_RETURNTRANSFER, TRUE);
curl_setopt($getBlueJSON, CURLOPT_USERPWD, $username_password);
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
//var_dump($plaxo["entry"][441]);
//print "<br /><br />";
//print "<b>** " . $plaxo["entry"][440]["phoneNumbers"][0]["value"] . " **</b>";
//print "<b>** " . $plaxo["entry"][440]["photos"][0]["value"] . " **</b>";
//print "<img src='" . $plaxo["entry"][440]["photos"][0]["value"] . "'/ >";
//print "<b>** " . $plaxo["entry"][441]["emails"][0]["value"] . " **</b>";

// PLAXO DETAILS
// we can just look at the first message from this contact to get their msisdn for plaxo lookup
$plaxo_contact = 0;
for ($x=0; $x<count($plaxo["entry"]); $x++) {
    // iterate through every number for every contact
    for ($y=0; $y<count($plaxo["entry"][$x]["phoneNumbers"]); $y++) {
        if ($plaxo["entry"][$x]["phoneNumbers"][$y]["value"] == $blue[0]["contact_msisdn"]) {
            $plaxo_contact = 1;
            $plaxo_id = $x;
        }
    }
}
$contact_email = $plaxo["entry"][$plaxo_id]["emails"][0]["value"];

// DB DETAILS
// get the user's name from the db if we have it
$sql = "SELECT * FROM friends WHERE phone_number='" . $blue[0]["contact_msisdn"] . "'";
$result = pg_query($dbh, $sql);
if (!$result) {
	die("Error in SQL query: " . pg_last_error());
}
$rows = pg_num_rows($result);
if ($rows >= 1) {
    $row = pg_fetch_array($result);
    $contact_name = $row[1];
} elseif ($plaxo_contact == 1) {
    $contact_name = $plaxo["entry"][$plaxo_id]["displayName"];
} else {
    $contact_name = $blue[0]["contact_msisdn"];
}
if (!empty($row[3])) {
    $twitter_id = $row[3];
}
//print "<h1>" .  $_GET["id"] . "</h1>";
// TABLE
// time  sender pic    content    
// time                content    receiver pic

print "<h1>" . $contact_name . "</h1>";
if (!empty($contact_email)) {
    print "<p>Reply by email to <a href='mailto:" . $contact_email . "'>" . $contact_email . "</a></p>";
}
if (!empty($twitter_id)) {
    print "<p><a href='http://twitter.com/home?status=@" . $twitter_id . " '>" . "Reply on twitter" . "</a></p>";
}

print "<table border=0 cellpadding=2 cellspacing=2>";
for ($i=0; $i<count($blue); $i++) {
    
	// iterate through ALL plaxo contacts

//    print "<b>***[" . $plaxo_id . "]***</b>";
    
    $avatar = "blank_avatar.png";
    $realname = $blue[$i]["msisdn"];

	$sql = "SELECT * FROM friends WHERE phone_number='" . $blue[$i]["contact_msisdn"] . "'";
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



    
    
	print "<tr>";
    $unixtime = strtotime($blue[$i]["timestamp"]);
	$format = '%d/%m/%Y %H:%M:%S';
	$strf = strftime($format,$unixtime);

	$sql = "SELECT * FROM friends WHERE phone_number='" . $blue[$i]["contact_msisdn"] . "'";
	$result = pg_query($dbh, $sql);
	if (!$result) {
		die("Error in SQL query: " . pg_last_error());
	}
	$row = pg_fetch_array($result);

    if ($blue[$i]["sent"]=="true") {
    	print "<td><small>" . $strf . "</small></td>";
        print "<td><img src='" . $avatar . "' /></td>";
    	print "<td align=left><p class='triangle-border left'>" . $blue[$i]["content"] . "</p></td>";
    	print "<td />";
//		print "<td><img src='" . $avatar . "' /></td>";
    } else {
    	print "<td><small>" . $strf . "</small></td>";	
        if (!empty($twitter_id)) {
		    print "<td><a href='http://twitter.com/home?status=RT SMS from %40" . $twitter_id . " " . urlencode($blue[$i]["content"]) . "'><img src='twitter.png'/></a></td>";
	    } else {
	        print "<td />";
	    }
    	print "<td align=right><p class='triangle-right'>" . $blue[$i]["content"] . "</p></td>";
		print "<td><img src='blank_avatar.png' /></td>";
    	
    }

	print "</tr>";
	
}
print "</table>";

print "<br /><br />";
//var_dump($blue);
//print $bluedata[0];
//var_dump(json_decode($blue, true));


//$html = file_get_contents("http://www.tfl.gov.uk/tfl/livetravelnews/realtime/dlr/default.html");
//$regex = '/DLR network/';
//preg_match($regex, $html, $match);
//print "<html><body><pre>";
//var_dump($match);
//print "[". $match[0] . "]";
//print "</pre></body></html>";
//curl -u anne@hashblue.com:d204423a28681c3b012868f6db715a59 https://api.hashblue.com/subscribers/d204423a28681c3b012868f6db715a59/messages.json

?>
</div>
</div>
</body></html>


