/* 
Copyright 2017 Injenia Srl

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 
*/

var VERSION = "v1";

var http = require('http');
var fs = require('fs');
var os = require('os');

/**
 * Request handler: it responds with a page if you ask for index.html, with a phrase otherwise
 */
var handleRequest = function(request, response) {
    var hostname = os.hostname();
    console.log(new Date() + " - " + hostname + ": " + request.url);

    switch (request.url) {
        case "/index.html":
            substitutionMap = {
                hostname: hostname,
                version: VERSION
            };
            sendFile(__dirname + "/index.html", response, "text/html", substitutionMap);
            break;

        case "/json":
            var reply = {
                status: "ok",
                hostname: hostname,
                version: VERSION
            };
            response.writeHead(200);
            response.end(JSON.stringify(reply));
            break;

        default:
            response.writeHead(200);
            response.end("Hi there :) my name is " + hostname + " - " + VERSION);

    }
}

/**
 * It serves a local file to the client
 * 
 * @param {string} localPath the absolute local path to serve
 * @param {response} response response object
 * @param {string} mimeType the mime type to serve
 * @param {obj} substitutionMap a JSON map with text to substitute in the file, undefined otherwise
 */
var sendFile = function(localPath, response, mimeType, substitutionMap) {
	fs.readFile(localPath, 'utf-8', function(err, contents) {
		if(!err) {
			response.setHeader("Content-Length", contents.length);
			if (mimeType != undefined) {
				response.setHeader("Content-Type", mimeType);
			}
            response.statusCode = 200;
            
            var renderedText = contents;
            if(substitutionMap) {
                for (var key in substitutionMap) {
                    renderedText = renderedText.replace('{{' + key + '}}', substitutionMap[key]);
                }
            }

			response.end(renderedText);
		} else {
            console.log(err);
			response.writeHead(500);
			response.end();
		}
	});
}

/* I'm listening on localhost:8080 */
console.log("Starting server to port 8080");
var www = http.createServer(handleRequest);
www.listen(8080);
