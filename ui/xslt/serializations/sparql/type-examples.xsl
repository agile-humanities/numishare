<?xml version="1.0" encoding="UTF-8"?>
<!-- 	Author: Ethan Gruber
	Date: June 2017
	Function: There are two modes of templates to render SPARQL results into HTML:
	   1. type-examples renders examples of physical specimens related to coin types displayed on coin type pages
	   2. examples of coin types associated with a symbol
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:res="http://www.w3.org/2005/sparql-results#"
    xmlns:numishare="https://github.com/ewg118/numishare" exclude-result-prefixes="#all" version="2.0">

    <!-- **************** PHYSICAL EXAMPLES OF COIN TYPES ****************-->
    <xsl:template match="res:sparql" mode="type-examples">
        <xsl:param name="subtype"/>
        <xsl:param name="page"/>
        <xsl:param name="numFound"/>
        <xsl:param name="limit"/>
        <xsl:param name="endpoint"/>
        <xsl:param name="objectUri"/>
        

        <xsl:variable name="query" select="replace(doc('input:query'), 'typeURI', $objectUri)"/>

        <div class="row">
            <xsl:if test="not($subtype = true())">
                <xsl:attribute name="id">examples</xsl:attribute>
            </xsl:if>
            <xsl:if test="count(descendant::res:result) &gt; 0">
                <div class="col-md-12">
                    <xsl:element name="{if($subtype=true()) then 'h4' else 'h3'}">
                        <xsl:value-of select="numishare:normalizeLabel('display_examples', $lang)"/>
                        <!-- insert link to download CSV -->
                        <small style="margin-left:10px">
                            <a href="{$endpoint}?query={encode-for-uri($query)}&amp;output=csv" title="Download CSV">
                                <span class="glyphicon glyphicon-download"/>Download CSV</a>
                        </small>
                    </xsl:element>
                </div>
                <xsl:if test="not($subtype = true())">
                    <!-- display the pagination toolbar only if there are multiple pages -->
                    <xsl:if test="$numFound &gt; $limit">
                        <xsl:call-template name="pagination">
                            <xsl:with-param name="page" select="$page" as="xs:integer"/>
                            <xsl:with-param name="numFound" select="$numFound" as="xs:integer"/>
                            <xsl:with-param name="limit" select="$limit" as="xs:integer"/>
                        </xsl:call-template>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates select="descendant::res:result" mode="type-examples"/>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="res:result" mode="type-examples">
        <xsl:variable name="title"
            select="
            concat(res:binding[@name = 'identifier']/*, ': ', if
            (string(res:binding[@name = 'collection']/res:literal)) then
            res:binding[@name = 'collection']/res:literal
            else
            res:binding[@name = 'datasetTitle']/res:literal)"/>

        <div class="g_doc col-md-4">
            <span class="result_link">
                <a href="{res:binding[@name='object']/res:uri}" target="_blank">
                    <xsl:value-of select="res:binding[@name = 'title']/res:literal"/>
                </a>
            </span>
            <dl class=" {if($lang='ar') then 'dl-horizontal ar' else 'dl-horizontal'}">
                <xsl:choose>
                    <xsl:when test="res:binding[@name = 'collection']/res:literal">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name = 'collection']/res:literal"/>
                            </a>

                        </dd>
                    </xsl:when>
                    <xsl:otherwise>
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('collection', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='dataset']/res:uri}">
                                <xsl:value-of select="res:binding[@name = 'datasetTitle']/res:literal"/>
                            </a>
                        </dd>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:if test="string(res:binding[@name = 'axis']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('axis', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'axis']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name = 'diameter']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('diameter', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'diameter']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:if test="string(res:binding[@name = 'weight']/res:literal)">
                    <dt>
                        <xsl:value-of select="numishare:regularize_node('weight', $lang)"/>
                    </dt>
                    <dd>
                        <xsl:value-of select="string(res:binding[@name = 'weight']/res:literal)"/>
                    </dd>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="res:binding[@name = 'findUri']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('findspot', $lang)"/>
                        </dt>
                        <dd>
                            <a
                                href="{if (ends-with(res:binding[@name='findUri']/res:uri, '#this')) then substring-before(res:binding[@name='findUri']/res:uri, '#this') else res:binding[@name='findUri']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name = 'findspot']/res:literal)"/>
                            </a>
                        </dd>

                    </xsl:when>
                    <xsl:when test="res:binding[@name = 'hoard']/res:uri">
                        <dt>
                            <xsl:value-of select="numishare:regularize_node('hoard', $lang)"/>
                        </dt>
                        <dd>
                            <a href="{res:binding[@name='hoard']/res:uri}">
                                <xsl:value-of select="string(res:binding[@name = 'findspot']/res:literal)"/>
                            </a>
                        </dd>

                    </xsl:when>
                </xsl:choose>
                <xsl:if test="string(res:binding[@name = 'model']/res:uri)">
                    <dt>3D Model</dt>
                    <dd>
                        <a href="#model-window" model-url="{res:binding[@name='model']/res:uri}" class="model-button" title="{$title}"
                            identifier="{res:binding[@name='object']/res:uri}">Click to view</a>
                    </dd>
                </xsl:if>
            </dl>

            <div class="gi_c">
                <xsl:if test="res:binding[contains(@name, 'Manifest')]">
                    <span class="glyphicon glyphicon-zoom-in iiif-zoom-glyph" title="Click image(s) to zoom" style="display:none"/>
                </xsl:if>

                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'obvRef']/res:uri) and string(res:binding[@name = 'obvThumb']/res:uri)">
                        <a title="Obverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'obvManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'obvManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'obvRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>

                            <img class="gi side-thumbnail" src="{res:binding[@name='obvThumb']/res:uri}"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name = 'obvRef']/res:uri)) and string(res:binding[@name = 'obvThumb']/res:uri)">
                        <img class="gi side-thumbnail" src="{res:binding[@name='obvThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'obvRef']/res:uri) and not(string(res:binding[@name = 'obvThumb']/res:uri))">
                        <a title="Obverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'obvManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'obvManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'obvRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='obvRef']/res:uri}"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- reverse-->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'revRef']/res:uri) and string(res:binding[@name = 'revThumb']/res:uri)">
                        <a title="Reverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'revManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'revManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'revRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='revThumb']/res:uri}"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="not(string(res:binding[@name = 'revRef']/res:uri)) and string(res:binding[@name = 'revThumb']/res:uri)">
                        <img class="gi side-thumbnail" src="{res:binding[@name='revThumb']/res:uri}"/>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'revRef']/res:uri) and not(string(res:binding[@name = 'revThumb']/res:uri))">
                        <a title="Reverse of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'revManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'revManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'revRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img class="gi side-thumbnail" src="{res:binding[@name='revRef']/res:uri}"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
                <!-- combined -->
                <xsl:choose>
                    <xsl:when test="string(res:binding[@name = 'comRef']/res:uri) and string(res:binding[@name = 'comThumb']/res:uri)">
                        <a title="Image of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'comManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'comManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'comRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img src="{res:binding[@name='comThumb']/res:uri}" class="gi combined-thumbnail"/>
                        </a>
                    </xsl:when>
                    <xsl:when test="string(res:binding[@name = 'comRef']/res:uri) and not(string(res:binding[@name = 'comThumb']/res:uri))">
                        <a title="Image of {$title}" id="{res:binding[@name='object']/res:uri}">
                            <xsl:choose>
                                <xsl:when test="res:binding[@name = 'comManifest']">
                                    <xsl:attribute name="href">#iiif-window</xsl:attribute>
                                    <xsl:attribute name="class">iiif-image</xsl:attribute>
                                    <xsl:attribute name="manifest" select="res:binding[@name = 'comManifest']/res:uri"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="href" select="res:binding[@name = 'comRef']/res:uri"/>
                                    <xsl:attribute name="class">thumbImage</xsl:attribute>
                                    <xsl:attribute name="rel">gallery</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <img src="{res:binding[@name='comRef']/res:uri}" class="gi combined-thumbnail"/>
                        </a>
                    </xsl:when>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>

    <!-- **************** EXAMPLES OF COIN TYPES ASSOCIATED TO A SYMBOL ****************-->
    <xsl:template match="res:sparql" mode="listTypes">
        <xsl:param name="objectUri"/>
        <xsl:param name="endpoint"/>

        <!-- aggregate ids and get URI space -->
        <xsl:variable name="type_series_items" as="element()*">
            <type_series_items>
                <xsl:for-each select="descendant::res:result/res:binding[@name = 'type']/res:uri">
                    <item>
                        <xsl:value-of select="."/>
                    </item>
                </xsl:for-each>
            </type_series_items>
        </xsl:variable>

        <xsl:variable name="type_series" as="element()*">
            <list>
                <xsl:for-each select="distinct-values(descendant::res:result/res:binding[@name = 'type']/substring-before(res:uri, 'id/'))">
                    <xsl:variable name="uri" select="."/>
                    <type_series uri="{$uri}">
                        <xsl:for-each select="$type_series_items//item[starts-with(., $uri)]">
                            <item>
                                <xsl:value-of select="substring-after(., 'id/')"/>
                            </item>
                        </xsl:for-each>
                    </type_series>
                </xsl:for-each>
            </list>
        </xsl:variable>

        <!-- use the Numishare Results API to display example coins -->
        <xsl:variable name="sparqlResult" as="element()*">
            <response>
                <xsl:for-each select="$type_series//type_series">
                    <xsl:variable name="baseUri" select="concat(@uri, 'id/')"/>
                    <xsl:variable name="ids" select="string-join(item, '|')"/>

                    <xsl:variable name="service"
                        select="concat('http://nomisma.org/apis/numishareResults?identifiers=', encode-for-uri($ids), '&amp;baseUri=',
                        encode-for-uri($baseUri))"/>
                    <xsl:copy-of select="document($service)/response/*"/>
                </xsl:for-each>
            </response>
        </xsl:variable>

        <!-- HTML output -->
        <h3>Associated Types</h3>

        <xsl:variable name="query" select="replace(doc('input:query'), '%URI%', $objectUri)"/>

        <div id="listTypes-container">
            <div style="margin-bottom:10px;" class="control-row">
                <a href="#" class="toggle-button btn btn-primary" id="toggle-listTypesQuery"><span class="glyphicon glyphicon-plus"/> View SPARQL for full query</a>
                <a href="{$endpoint}?query={encode-for-uri($query)}&amp;output=csv" title="Download CSV" class="btn btn-primary" style="margin-left:10px">
                    <span class="glyphicon glyphicon-download"/>Download CSV</a>
            </div>
            <div id="listTypesQuery-container" style="display:none">
                <pre>
				<xsl:value-of select="$query"/>
			</pre>
            </div>

            <table class="table table-striped">
                <thead>
                    <tr>
                        <th>Type</th>
                        <th style="width:280px">Example</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="descendant::res:result">
                        <xsl:variable name="type_id" select="substring-after(res:binding[@name = 'type']/res:uri, 'id/')"/>

                        <tr>
                            <td>
                                <a href="{res:binding[@name='type']/res:uri}">
                                    <xsl:value-of select="res:binding[@name = 'label']/res:literal"/>
                                </a>
                                <dl class="dl-horizontal">
                                    <xsl:if test="res:binding[@name = 'mint']/res:uri">
                                        <dt>Mint</dt>
                                        <dd>
                                            <a href="{res:binding[@name='mint']/res:uri}">
                                                <xsl:value-of select="res:binding[@name = 'mintLabel']/res:literal"/>
                                            </a>
                                        </dd>
                                    </xsl:if>
                                    <xsl:if test="res:binding[@name = 'den']/res:uri">
                                        <dt>Denomination</dt>
                                        <dd>
                                            <a href="{res:binding[@name='den']/res:uri}">
                                                <xsl:value-of select="res:binding[@name = 'denLabel']/res:literal"/>
                                            </a>
                                        </dd>
                                    </xsl:if>
                                    <xsl:if test="res:binding[@name = 'startDate']/res:literal or res:binding[@name = 'endDate']/res:literal">
                                        <dt>Date</dt>
                                        <dd>
                                            <xsl:value-of select="numishare:normalizeDate(res:binding[@name = 'startDate']/res:literal)"/>
                                            <xsl:if test="res:binding[@name = 'startDate']/res:literal and res:binding[@name = 'startDate']/res:literal"> - </xsl:if>
                                            <xsl:value-of select="numishare:normalizeDate(res:binding[@name = 'endDate']/res:literal)"/>
                                        </dd>
                                    </xsl:if>
                                </dl>
                            </td>
                            <td class="text-right">
                                <xsl:apply-templates select="$sparqlResult//group[@id = $type_id]/descendant::object" mode="results"/>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <!-- paginating results -->
    <xsl:template name="pagination">
        <xsl:param name="page" as="xs:integer"/>
        <xsl:param name="numFound" as="xs:integer"/>
        <xsl:param name="limit" as="xs:integer"/>

        <xsl:variable name="offset" select="($page - 1) * $limit" as="xs:integer"/>

        <xsl:variable name="previous" select="$page - 1"/>
        <xsl:variable name="current" select="$page"/>
        <xsl:variable name="next" select="$page + 1"/>
        <xsl:variable name="total" select="ceiling($numFound div $limit)"/>

        <div class="col-md-12">
            <div class="row">
                <div class="col-md-6">
                    <xsl:variable name="startRecord" select="$offset + 1"/>
                    <xsl:variable name="endRecord">
                        <xsl:choose>
                            <xsl:when test="$numFound &gt; ($offset + $limit)">
                                <xsl:value-of select="$offset + $limit"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$numFound"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <p>Records <b><xsl:value-of select="$startRecord"/></b> to <b><xsl:value-of select="$endRecord"/></b> of <b><xsl:value-of select="$numFound"/></b></p>
                </div>
                <!-- paging functionality -->
                <div class="col-md-6">
                    <div class="btn-toolbar" role="toolbar">
                        <div class="btn-group pull-right">
                            <!-- first page -->
                            <xsl:if test="$current &gt; 1">
                                <a class="btn btn-default" role="button" title="First" href="?page=1#examples">
                                    <span class="glyphicon glyphicon-fast-backward"/>
                                    <xsl:text> 1</xsl:text>
                                </a>
                                <a class="btn btn-default" role="button" title="Previous" href="?page={$current - 1}#examples">
                                    <xsl:text>Previous </xsl:text>
                                    <span class="glyphicon glyphicon-backward"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="$current &gt; 5">
                                <button type="button" class="btn btn-default disabled">
                                    <xsl:text>...</xsl:text>
                                </button>
                            </xsl:if>
                            <xsl:if test="$current &gt; 4">
                                <a class="btn btn-default" role="button" href="?page={$current - 3}#examples">
                                    <xsl:value-of select="$current - 3"/>
                                    <xsl:text> </xsl:text>
                                </a>
                            </xsl:if>
                            <xsl:if test="$current &gt; 3">
                                <a class="btn btn-default" role="button" href="?page={$current - 2}#examples">
                                    <xsl:value-of select="$current - 2"/>
                                    <xsl:text> </xsl:text>
                                </a>
                            </xsl:if>
                            <xsl:if test="$current &gt; 2">
                                <a class="btn btn-default" role="button" href="?page={$current - 1}#examples">
                                    <xsl:value-of select="$current - 1"/>
                                    <xsl:text> </xsl:text>
                                </a>
                            </xsl:if>
                            <!-- current page -->
                            <button type="button" class="btn btn-default active">
                                <b>
                                    <xsl:value-of select="$current"/>
                                </b>
                            </button>
                            <xsl:if test="$total &gt; ($current + 1)">
                                <a class="btn btn-default" role="button" title="Next" href="?page={$current + 1}#examples">
                                    <xsl:value-of select="$current + 1"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="$total &gt; ($current + 2)">
                                <a class="btn btn-default" role="button" title="Next" href="?page={$current + 2}#examples">
                                    <xsl:value-of select="$current + 2"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="$total &gt; ($current + 3)">
                                <a class="btn btn-default" role="button" title="Next" href="?page={$current + 3}#examples">
                                    <xsl:value-of select="$current + 3"/>
                                </a>
                            </xsl:if>
                            <xsl:if test="$total &gt; ($current + 4)">
                                <button type="button" class="btn btn-default disabled">
                                    <xsl:text>...</xsl:text>
                                </button>
                            </xsl:if>
                            <!-- last page -->
                            <xsl:if test="$current &lt; $total">
                                <a class="btn btn-default" role="button" title="Next" href="?page={$current + 1}#examples">
                                    <xsl:text>Next </xsl:text>
                                    <span class="glyphicon glyphicon-forward"/>
                                </a>
                                <a class="btn btn-default" role="button" title="Last" href="?page={$total}#examples">
                                    <xsl:value-of select="$total"/>
                                    <xsl:text> </xsl:text>
                                    <span class="glyphicon glyphicon-fast-forward"/>
                                </a>
                            </xsl:if>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </xsl:template>

</xsl:stylesheet>
