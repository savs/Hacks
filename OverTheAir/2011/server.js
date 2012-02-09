//
// The MIT license
//
// Copyright (C) 2011 by Bernhard Walter ( @bernhard42 )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

//
// Version 27.09.2011
//

express		= require('express'),
OAuth		= require('./oauth').OAuth,
ejs			= require('ejs');
https       = require('https');
fs          = require('fs');

// CONFIG

var consumerKey	   = "FIXME";
var consumerSecret = "FIXME";
var callbackUrl = "http://localhost:3000/accesstoken";
var sandbox = "_Sandbox";
var ericsson_maps_api_key = 'FIXME';

// SETUP SERVER

var app = express.createServer();
app.use(express.logger());
app.use(express.bodyParser());
app.use(express.cookieParser());
app.use(express.session({ secret: "bluevia_node.js_test_8943569166" }));

app.set('view engine', 'ejs');
app.set('view options', { layout: false });

// HELPERS

function getOauth(req) {
	return new OAuth(req.session.oa._requestUrl, req.session.oa._accessUrl,
					 req.session.oa._consumerKey, req.session.oa._consumerSecret,
					 req.session.oa._version, req.session.oa._authorize_callback,
					 req.session.oa._signatureMethod);
}

// ROUTING

app.get('/',
	function(req, res) {
	    res.redirect("/pearson");
	    /*
		if (!req.session.oauth_access_token) {
			res.redirect("/authorise");
		} else {
			res.redirect("/smsform");
		}*/
});

app.get('/authorise',
	function(req, res) {
		var getRequestTokenUrl	 = "https://api.bluevia.com/services/REST/Oauth/getRequestToken";
		var getAccessTokenUrl	 = "https://api.bluevia.com/services/REST/Oauth/getAccessToken";
		var userAuthorizationUrl = "https://connect.bluevia.com/en/authorise?oauth_token=";

		var oa = new OAuth(getRequestTokenUrl, getAccessTokenUrl, consumerKey, consumerSecret,
						   "1.0", callbackUrl, "HMAC-SHA1");

		oa.getOAuthRequestToken(
			function(error, oauth_token, oauth_token_secret, results) {
				if (error) {
					console.log(JSON.stringify(error));
				} else {
					// store the tokens in the session
					req.session.oa = oa;
					req.session.oauth_token = oauth_token;
					req.session.oauth_token_secret = oauth_token_secret;

					// redirect the user to authorize the token
					res.redirect(userAuthorizationUrl + oauth_token);
				}
			}
		)
	}
);

app.get('/accesstoken',
	function(req, res) {
		var oa = getOauth(req);

		oa.getOAuthAccessToken( req.session.oauth_token, req.session.oauth_token_secret, req.param('oauth_verifier'),
			function(error, oauth_access_token, oauth_access_token_secret, results2) {
				if (error) {
					console.log(JSON.stringify(error));
				} else {
					// store the access token in the session
					req.session.oauth_access_token = oauth_access_token;
					req.session.oauth_access_token_secret = oauth_access_token_secret;

					res.redirect("/location");
				}
			}
		);
	}
);

app.get('/location',
	function(req, res) {

	    if (!req.session.oauth_access_token) {
	        console.log("redirect to authorise");
    	    res.redirect("/authorise");
    	} else {
            
    	    var oa = getOauth(req);
    		var access_token		= req.session.oauth_access_token;
    		var access_token_secret = req.session.oauth_access_token_secret;

    		console.log("access_token: " + access_token);
    		console.log("access_token_secret: " + access_token_secret);
    		var terminalLocationUrl = "https://api.bluevia.com/services/REST/Location/TerminalLocation?version=v1&alt=json&locatedParty=alias%3A" + access_token;
    	    console.log("doing location request: " + terminalLocationUrl);
    		
    		// oauth_token, oauth_token_secret, method, url, extra_params, post_body, post_content_type,  callback ) {
    		oa._performSecureRequest(access_token, access_token_secret, 
    		    "GET", terminalLocationUrl, null, "", "",
    		    function(error, data, response) {
    		        if (error) {
    		            console.log("terminalLocationUrl: " + terminalLocationUrl);
    		            console.log(JSON.stringify(error));
    		            res.render('location', { title : 'Error ' + JSON.stringify(error) + " (b0rk b0rk b0rk)" });
    		        } else {
    		            var p = JSON.parse(data);
    		            var locationLatitude = p.terminalLocation.currentLocation.coordinates.latitude;
    		            var locationLongitude = p.terminalLocation.currentLocation.coordinates.longitude;
    		            
    		            var options = {
    		                host: 'api.pearson.com',
    		                path: '/eyewitness/london/block.json?lon=' + locationLongitude + '&lat=' + locationLatitude + '&apikey=FIXME'
    		                // https://api.pearson.com/eyewitness/london/block.[format]?lon=[longitude]&lat=[latitude]&apikey=[apikey]&jsonp=[callback name]
    		            }
    		            
    		            https.get(options, function(res) {
    		                console.log("Got response: " + res.statusCode);
    		                
    		                res.on('data', function(d) {
    		                    var p = JSON.parse(d);
    		                    //console.log(JSON.stringify(d));
    		                    console.log("attempted: " + p.list.link['@title']);
    		                });
    		            }).on('error', function(e) {
    		                console.log("Got error: " + e.message);
    		            });
                		res.render('location', {
                		    title : 'Location ' + locationLatitude + " " + locationLongitude,
                		    location : 'location ' + locationLatitude + "," + locationLongitude,
                		});
    		        }
    		    }
    		)
    	}
    }
)

app.get('/pearson',
	function(req, res) {
	    
	    var locationLatitude = '51.507071';
        var locationLongitude = '-0.036241';
        var poi = [];

        var options = {
            host: 'api.pearson.com',
            path: '/eyewitness/london/block.json?lon=' + locationLongitude + '&lat=' + locationLatitude + '&apikey=FIXME',
            // https://api.pearson.com/eyewitness/london/block.json?lon=-0.036241&lat=51.507071&apikey=FIXME
            // https://api.pearson.com/eyewitness/london/block.[format]?lon=[longitude]&lat=[latitude]&apikey=[apikey]&jsonp=[callback name]
        }
        
        //data = '{"list":{"link":[{"@tag":"tg_info","@id":"EWTG_LONDON093MALL_001","@parent":"EWTG_LONDON093MALL","@latitude":"51.50614","@longitude":"-0.13005","@title":"The Mall"},{"@tag":"tg_info","@id":"EWTG_LONDON092INSCON_001","@parent":"EWTG_LONDON092INSCON","@latitude":"51.50641","@longitude":"-0.13063","@title":"Institute of Contemporary Arts"},{"@tag":"tg_info","@id":"EWTG_LONDON092ROYOPE_001","@parent":"EWTG_LONDON092ROYOPE","@latitude":"51.50806","@longitude":"-0.13237","@title":"Royal Opera Arcade"},{"@tag":"tg_info","@id":"EWTG_LONDON092PALMAL_001","@parent":"EWTG_LONDON092PALMAL","@latitude":"51.50684","@longitude":"-0.13349","@title":"Pall Mall"},{"@tag":"tg_info","@id":"EWTG_LONDON093STJAM_001","@parent":"EWTG_LONDON093STJAM","@latitude":"51.50401","@longitude":"-0.13443","@categories":"Gardens_Parks_And_Squares","@title":"St James’s Park"},{"@tag":"tg_info","@id":"EWTG_LONDON090PICCIR_001","@parent":"EWTG_LONDON090PICCIR","@latitude":"51.50987","@longitude":"-0.1347","@title":"Piccadilly Circus"},{"@tag":"tg_info","@id":"EWTG_LONDON092STJAM_001","@parent":"EWTG_LONDON092STJAM","@latitude":"51.50718","@longitude":"-0.13533","@title":"St James’s Square"},{"@tag":"tg_info","@id":"EWTG_LONDON093MARHOU_001","@parent":"EWTG_LONDON093MARHOU","@latitude":"51.50464","@longitude":"-0.13627","@title":"Marlborough House"},{"@tag":"tg_info","@id":"EWTG_LONDON090STJAM_001","@parent":"EWTG_LONDON090STJAM","@latitude":"51.50894","@longitude":"-0.13685","@categories":"Churches, Childrens_London","@title":"St James’s Church"},{"@tag":"tg_info","@id":"EWTG_LONDON090STJAM_001","@parent":"EWTG_LONDON090STJAM","@latitude":"51.50894","@longitude":"-0.13685","@categories":"Churches, Childrens_London","@title":"St James’s Church"},{"@tag":"tg_info","@id":"EWTG_LONDON093QUECHA_001","@parent":"EWTG_LONDON093QUECHA","@latitude":"51.50497","@longitude":"-0.13708","@categories":"Churches","@title":"Queen’s Chapel"},{"@tag":"tg_info","@id":"EWTG_LONDON091STJAM_001","@parent":"EWTG_LONDON091STJAM","@latitude":"51.50509","@longitude":"-0.13787","@title":"St James’s Palace"},{"@tag":"tg_info","@id":"EWTG_LONDON090ALBANY_001","@parent":"EWTG_LONDON090ALBANY","@latitude":"51.50892","@longitude":"-0.13842","@title":"Albany"},{"@tag":"tg_info","@id":"EWTG_LONDON096CLAHOU_001","@parent":"EWTG_LONDON096CLAHOU","@latitude":"51.50431","@longitude":"-0.13843","@title":"Clarence House"},{"@tag":"tg_info","@id":"EWTG_LONDON090ROYACA_001","@parent":"EWTG_LONDON090ROYACA","@latitude":"51.50852","@longitude":"-0.1391","@categories":"Museums","@title":"Royal Academy of Arts"},{"@tag":"tg_info","@id":"EWTG_LONDON096LANHOU_001","@parent":"EWTG_LONDON096LANHOU","@latitude":"51.50395","@longitude":"-0.13937","@title":"Lancaster House"},{"@tag":"tg_info","@id":"EWTG_LONDON091SPEHOU_001","@parent":"EWTG_LONDON091SPEHOU","@latitude":"51.50514","@longitude":"-0.13964","@title":"Spencer House"},{"@tag":"tg_info","@id":"EWTG_LONDON091BURARC_001","@parent":"EWTG_LONDON091BURARC","@latitude":"51.50928","@longitude":"-0.14044","@title":"Burlington Arcade"},{"@tag":"tg_info","@id":"EWTG_LONDON091RITHOT_001","@parent":"EWTG_LONDON091RITHOT","@latitude":"51.50712","@longitude":"-0.14165","@title":"Ritz Hotel"},{"@tag":"tg_info","@id":"EWTG_LONDON094BUCPAL_003","@parent":"EWTG_LONDON094BUCPAL_002","@latitude":"51.50134","@longitude":"-0.1419","@categories":"Ceremonies","@title":"Buckingham Palace"},{"@tag":"tg_info","@id":"EWTG_LONDON097FARMUS_001","@parent":"EWTG_LONDON097FARMUS","@latitude":"51.51008","@longitude":"-0.14254","@categories":"Museums","@title":"Faraday Museum"},{"@tag":"tg_info","@id":"EWTG_LONDON096QUEGAL_001","@parent":"EWTG_LONDON096QUEGAL","@latitude":"51.49998","@longitude":"-0.14251","@title":"The Queen’s Gallery"},{"@tag":"tg_info","@id":"EWTG_LONDON097GREPAR_001","@parent":"EWTG_LONDON097GREPAR","@latitude":"51.5058","@longitude":"-0.1433","@categories":"Gardens_Parks_And_Squares","@title":"Green Park"},{"@tag":"tg_info","@id":"EWTG_LONDON096ROYMEW_001","@parent":"EWTG_LONDON096ROYMEW","@latitude":"51.49857","@longitude":"-0.14392","@title":"Royal Mews"},{"@tag":"tg_info","@id":"EWTG_LONDON097SHEMAR_001","@parent":"EWTG_LONDON097SHEMAR","@latitude":"51.50668","@longitude":"-0.14666","@title":"Shepherd Market"}]}}';
        https.get(options, function(gres) {
            console.log("Got response: " + gres.statusCode);
            var data = '';
            gres.on('data', function(d) {
                data += d;
            });
            gres.on('end', function(d) {
                var p = JSON.parse(data);
                for (var i=0; i<p.list.link.length; i++) {
                    console.log("poi: " + p.list.link[i]['@title']);
                    poi[i] = { name: p.list.link[i]['@title'], latitude: p.list.link[i]['@latitude'] , longitude: p.list.link[i]['@longitude']};
                }
                console.log("pois: " + poi.length);
        		res.render('location', {
        		    title : 'lat' + locationLatitude + " long" + locationLongitude,
        		    location : 'latitude ' + locationLatitude + ", longitude " + locationLongitude,
        		    latitude : locationLatitude,
        		    longitude : locationLongitude,
        		    poi : poi
        		});

            });

        }).on('error', function(e) {
            if (e) throw e;
            //console.log("Got error: " + e.message);
        });


    }
)


app.listen(3000);
console.log("listening on http://localhost:3000");