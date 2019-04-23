xquery version "3.1";

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace nuds = "http://nomisma.org/nuds";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace hc = "http://expath.org/ns/http-client";
declare option exist:serialize "method=xhtml media-type=text/html indent=yes";


let $collection := replace(request:get-effective-uri(), "^/.*/db/(.*)/.*$", "/db/$1")
let $objects := collection($collection)/nuds:nuds[nuds:control/nuds:publicationStatus = 'approved']

(: The Graph Store Protocol posts to '/data', not '/query' :)
let $sparql_endpoint := replace(collection($collection)/config/sparql_endpoint, "query$", "data")
let $uri_space := collection($collection)/config/uri_space

let $posts :=
 for $object in $objects
 let $request := <hc:request method="post" href="{$sparql_endpoint}">
                   <hc:header name="Cache-Control" value="no-cache"/>
                   <hc:body media-type="application/rdf+xml">{ doc($uri_space || $object/nuds:control/nuds:recordId || ".rdf") }</hc:body>
                 </hc:request>
 let $response := hc:send-request(<hc:request method="post" href="{$sparql_endpoint}">
                                    <hc:header name="Cache-Control" value="no-cache"/>
                                    <hc:body media-type="application/rdf+xml">{ doc($uri_space || $object/nuds:control/nuds:recordId || ".rdf") }</hc:body>
                                  </hc:request>) 
 return $response[1]

return
 <html>
  <body>
   <p>
    {count($objects)} objects were posted to {$sparql_endpoint}.
   </p>
   <dl>
   
    <dt>collection</dt>
    <dd>{$collection}</dd>
    
    <dt>object count</dt>
    <dd>{count($objects)}</dd>
    
    <dt>successes</dt>
    <dd>{count($posts[@status='200'])}</dd>
    
    <dt>failures</dt>
    <dd>{count($posts[not(@status = '200')])}</dd>
   </dl>
  </body>
 </html>