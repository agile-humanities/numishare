xquery version "3.1";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace nuds = "http://nomisma.org/nuds";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace hc = "http://expath.org/ns/http-client";

let $recordId := request:get-parameter("recordId", ())

let $collection := replace(request:get-effective-uri(), "^/.*/db/(.*)/.*$", "/db/$1")
let $objects :=
    if ($recordId) then
       collection($collection)/nuds:nuds[nuds:control/nuds:recordId = $recordId]
    else
       collection($collection)/nuds:nuds[nuds:control/nuds:publicationStatus = 'approved']

(: The Graph Store Protocol posts to '/data', not '/query' :)
let $sparql_endpoint := concat(replace(collection($collection)/config/sparql_endpoint, "/query$", ""),"/data")
(: only http requests can be made :)
let $sparql_endpoint := replace($sparql_endpoint,"https","http")
let $uri_space := collection($collection)/config/uri_space

let $posts :=
 for $object in $objects
  let $response := hc:send-request(<hc:request method="post" href="{$sparql_endpoint}">
                                      <hc:header name="Cache-Control" value="no-cache"/>
                                      <hc:body media-type="application/rdf+xml">
				        { doc($uri_space || $object/nuds:control/nuds:recordId || ".rdf") }
				      </hc:body>
				   </hc:request>)
  return $response[1]

return
 <result>{$posts}</result>

