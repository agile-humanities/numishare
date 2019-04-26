xquery version "3.1";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace httpclient = "http://exist-db.org/xquery/httpclient";
declare namespace nuds = "http://nomisma.org/nuds";

import module namespace request = "http://exist-db.org/xquery/request";
(: import module namespace hc = "http://expath.org/ns/http-client"; :)

let $recordId := request:get-parameter("recordId", ())

let $collection := replace(request:get-effective-uri(), "^/.*/db/(.*)/.*$", "/db/$1")


let $recordIds :=
    if (request:get-parameter("recordId", ())) then
       request:get-parameter("recordId", ())
    else
       for $object in
            collection($collection)/nuds:nuds[nuds:control/nuds:publicationStatus = 'approved']
       return $object/nuds:control/nuds:recordId/text()

(: use update for deleting triples :)
let $sparql_endpoint := concat(replace(collection($collection)/config/sparql_endpoint, "/query$", ""),"/update")
(: only http requests can be made :)
let $sparql_endpoint := xs:anyURI(replace($sparql_endpoint,"https","http"))

let $uri_space := xs:anyURI(collection($collection)/config/uri_space)
let $headers :=
    <httpclient:headers>
      <httpclient:header name="Content-Type" value="application/x-www-form-urlencoded"/>
      <httpclient:header name="media-type" value="application/x-www-form-urlencoded"/>
    </httpclient:headers>

let $responses :=
    for $recordId in $recordIds
            let $update := encode-for-uri("DELETE WHERE {<" || $uri_space || $recordId || "> ?p ?o}")
	    let $response := httpclient:post($sparql_endpoint, "update=" || $update, false(), $headers)
    return $response
return <result>{$responses}</result>
	