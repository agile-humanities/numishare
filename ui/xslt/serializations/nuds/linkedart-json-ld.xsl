<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mets="http://www.loc.gov/METS/"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:nuds="http://nomisma.org/nuds" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/"
	xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
	xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
	xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#" xmlns:numishare="https://github.com/ewg118/numishare"
	exclude-result-prefixes="#all" version="2.0">
	<xsl:include href="../json/json-metamodel.xsl"/>
	<xsl:include href="../../functions.xsl"/>

	<xsl:output name="default" indent="no" omit-xml-declaration="yes"/>

	<!-- config variables -->
	<xsl:variable name="url" select="/content/config/url"/>
	<xsl:variable name="id" select="normalize-space(//*[local-name() = 'recordId'])"/>
	<xsl:variable name="objectUri"
		select="
			if (/content/config/uri_space) then
				concat(/content/config/uri_space, $id)
			else
				concat($url, 'id/', $id)"/>

	<xsl:variable name="fileSec" as="element()*">
		<xsl:copy-of select="//nuds:nuds/nuds:digRep/mets:fileSec"/>
	</xsl:variable>

	<xsl:variable name="nudsGroup" as="element()*">
		<nudsGroup>
			<xsl:choose>
				<xsl:when test="descendant::nuds:typeDesc[string(@xlink:href)]">
					<xsl:variable name="uri" select="descendant::nuds:typeDesc/@xlink:href"/>

					<object xlink:href="{$uri}">
						<xsl:if test="doc-available(concat($uri, '.xml'))">
							<xsl:copy-of select="document(concat($uri, '.xml'))/nuds:nuds"/>
						</xsl:if>
					</object>
				</xsl:when>
				<xsl:otherwise>
					<object>
						<xsl:copy-of select="descendant::nuds:typeDesc"/>
					</object>
				</xsl:otherwise>
			</xsl:choose>
		</nudsGroup>
	</xsl:variable>

	<xsl:variable name="coinType_uris" as="node()*">
		<uris>
			<xsl:for-each
				select="descendant::nuds:typeDesc[string(@xlink:href)] | descendant::nuds:reference[@xlink:arcrole = 'nmo:hasTypeSeriesItem'][string(@xlink:href)]">
				<uri>
					<xsl:value-of select="@xlink:href"/>
				</uri>
			</xsl:for-each>
		</uris>

	</xsl:variable>

	<!-- get non-coin-type RDF in the document -->
	<xsl:variable name="rdf" as="element()*">
		<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/" xmlns:nm="http://nomisma.org/id/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:org="http://www.w3.org/ns/org#"
			xmlns:nomisma="http://nomisma.org/" xmlns:nmo="http://nomisma.org/ontology#">
			<xsl:variable name="id-param">
				<xsl:for-each
					select="
						distinct-values(descendant::*[not(local-name() = 'typeDesc') and not(local-name() = 'reference')][contains(@xlink:href,
						'nomisma.org')]/@xlink:href | $nudsGroup/descendant::*[not(local-name() = 'object') and not(local-name() = 'typeDesc')][contains(@xlink:href, 'nomisma.org')]/@xlink:href)">
					<xsl:value-of select="substring-after(., 'id/')"/>
					<xsl:if test="not(position() = last())">
						<xsl:text>|</xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:variable name="rdf_url" select="concat('http://nomisma.org/apis/getRdf?identifiers=', encode-for-uri($id-param))"/>
			<xsl:copy-of select="document($rdf_url)/rdf:RDF/*"/>
		</rdf:RDF>
	</xsl:variable>

	<xsl:template match="/">
		<xsl:variable name="model" as="element()*">
			<_object>
				<xsl:apply-templates select="//nuds:nuds"/>
			</_object>
		</xsl:variable>

		<xsl:apply-templates select="$model"/>
	</xsl:template>

	<xsl:template match="nuds:nuds">
		<__context>https://linked.art/ns/v1/linked-art.json</__context>
		<id>
			<xsl:value-of select="$objectUri"/>
		</id>
		<type>ManMadeObject</type>
		<label>
			<xsl:value-of select="//nuds:descMeta/nuds:title[@xml:lang = 'en']"/>
		</label>

		<xsl:apply-templates select="nuds:descMeta"/>

		<!-- IIIF manifest, if relevant -->
		<xsl:if test="descendant::mets:file[@USE = 'iiif']">
			<subject_of>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="concat($url, 'manifest/', $id)"/>
						</id>
						<type>InformationObject</type>
						<conforms_to>http://iiif.io/api/presentation</conforms_to>
						<format>application/ld+json;profile="http://iiif.io/api/presentation/2/context.json"</format>
					</_object>
				</_array>
			</subject_of>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:descMeta">
		<!-- identified_by -->
		<identified_by>
			<_array>
				<xsl:apply-templates select="nuds:title[@xml:lang = 'en']"/>
				<xsl:apply-templates select="nuds:adminDesc/nuds:identifier"/>
			</_array>
		</identified_by>

		<xsl:apply-templates select="nuds:physDesc"/>
		<xsl:apply-templates select="$nudsGroup//nuds:typeDesc"/>
	</xsl:template>

	<xsl:template match="nuds:title">
		<_object>
			<type>Name</type>
			<value>
				<xsl:value-of select="."/>
			</value>
			<classified_as>
				<_array>
					<_object>
						<id>aat:300404670</id>
						<label>preferred forms</label>
						<type>Type</type>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<!-- ***** typeDesc templates ***** -->
	<xsl:template match="nuds:typeDesc">
		<classified_as>
			<_array>
				<_object>
					<id>aat:300133025</id>
					<type>Type</type>
					<label>works of art</label>
				</_object>

				<xsl:apply-templates select="nuds:objectType[@xlink:href] | nuds:denomination[@xlink:href]"/>

				<xsl:for-each select="distinct-values($coinType_uris/uri)">
					<_object>
						<id>
							<xsl:value-of select="."/>
						</id>
						<type>Type</type>
						<label>coin type</label>
					</_object>
				</xsl:for-each>
			</_array>
		</classified_as>

		<!-- production -->
		<produced_by>
			<_object>
				<type>Production</type>
				<xsl:if test="nuds:manufacture[@xlink:href]">
					<technique>
						<_array>
							<xsl:apply-templates select="nuds:manufacture[@xlink:href]"/>
						</_array>
					</technique>
				</xsl:if>
				<xsl:if test="nuds:date or nuds:dateRange">
					<xsl:variable name="fromDate"
						select="
							if (nuds:dateRange/nuds:fromDate/@standardDate) then
								nuds:dateRange/nuds:fromDate/@standardDate
							else
								nuds:date/@standardDate"/>
					<xsl:variable name="toDate"
						select="
							if (nuds:dateRange/nuds:toDate/@standardDate) then
								nuds:dateRange/nuds:toDate/@standardDate
							else
								nuds:date/@standardDate"/>

					<timespan>
						<_object>
							<type>TimeSpan</type>
							<begin_of_the_begin>
								<xsl:value-of select="numishare:expandDatetoDateTime($fromDate)"/>
							</begin_of_the_begin>
							<end_of_the_end>
								<xsl:value-of select="numishare:expandDatetoDateTime($toDate)"/>
							</end_of_the_end>
						</_object>
					</timespan>
				</xsl:if>
				<xsl:apply-templates select="nuds:authority[child::*[@xlink:href]]"/>
				<xsl:apply-templates select="nuds:geographic[child::*[@xlink:href]]"/>
			</_object>
		</produced_by>

		<!-- material -->
		<xsl:if test="nuds:material[@xlink:href]">
			<made_of>
				<_array>
					<xsl:apply-templates select="nuds:material[@xlink:href]"/>
				</_array>
			</made_of>
		</xsl:if>

		<!-- parts -->
		<xsl:if test="nuds:obverse or nuds:reverse">
			<part>
				<_array>
					<xsl:apply-templates select="nuds:obverse | nuds:reverse"/>
				</_array>
			</part>
		</xsl:if>
	</xsl:template>

	<xsl:template match="nuds:authority">
		<carried_out_by>
			<_array>
				<xsl:apply-templates select="*[@xlink:role = 'authority' or @xlink:role = 'issuer' or @xlink:role = 'dynasty'][@xlink:href]"/>
			</_array>
		</carried_out_by>
	</xsl:template>

	<xsl:template match="nuds:geographic">
		<took_place_at>
			<_array>
				<xsl:choose>
					<xsl:when test="nuds:geogname[@xlink:role = 'mint'][@xlink:href]">
						<xsl:apply-templates select="nuds:geogname[@xlink:role = 'mint'][@xlink:href]"/>
					</xsl:when>
					<xsl:when test="nuds:geogname[@xlink:role = 'region'][@xlink:href]">
						<xsl:apply-templates select="nuds:geogname[@xlink:role = 'region'][@xlink:href]"/>
					</xsl:when>
				</xsl:choose>
			</_array>
		</took_place_at>
	</xsl:template>

	<xsl:template match="nuds:material | nuds:objectType | nuds:denomination | nuds:manufacture | nuds:persname | nuds:famname | nuds:corpname | nuds:geogname">
		<xsl:variable name="uri" select="@xlink:href"/>

		<_object>
			<id>
				<xsl:value-of select="numishare:resolveUriToCurie($uri, $rdf//*[@rdf:about = $uri])"/>
			</id>
			<type>
				<xsl:choose>
					<xsl:when test="self::nuds:material">Material</xsl:when>
					<xsl:when test="self::nuds:geogname">Place</xsl:when>
					<xsl:when test="self::nuds:persname">Person</xsl:when>
					<xsl:when test="self::nuds:corpname or self::nuds:famname">Group</xsl:when>
					<xsl:otherwise>Type</xsl:otherwise>
				</xsl:choose>
			</type>
			<label>
				<xsl:value-of select="."/>
			</label>
			<xsl:if test="@xlink:role[not(. = 'region') and not(. = 'statedAuthority')]">
				<classified_as>
					<_array>
						<_object>
							<type>Type</type>
							<xsl:choose>
								<xsl:when test="@xlink:role = 'authority'">
									<xsl:choose>
										<xsl:when test="self::nuds:persname">
											<id>aat:300025475</id>
											<label>rulers (people)</label>
										</xsl:when>
										<xsl:when test="self::nuds:corpname">
											<id>aat:300232420</id>
											<label>sovereign states</label>
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								<xsl:when test="@xlink:role = 'dynasty'">
									<id>aat:300386176</id>
									<label>dynasties</label>
								</xsl:when>
								<xsl:when test="@xlink:role = 'issuer'">
									<id>aat:300025467</id>
									<label>magistrates</label>
								</xsl:when>
								<xsl:when test="@xlink:role = 'mint'">
									<id>aat:300006031</id>
									<label>mints (buildings)</label>
								</xsl:when>
							</xsl:choose>

						</_object>
					</_array>
				</classified_as>
			</xsl:if>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:obverse | nuds:reverse">
		<xsl:variable name="side" select="local-name()"/>

		<_object>
			<id>
				<xsl:value-of select="concat($objectUri, '#', $side)"/>
			</id>
			<type>ManMadeObject</type>
			<label>
				<xsl:value-of select="concat(upper-case(substring($side, 1, 1)), substring($side, 2))"/>
			</label>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="numishare:normalizeClassification($side)"/>
						</id>
						<type>Type</type>
						<label>
							<xsl:value-of select="concat(local-name(), 's')"/>
						</label>
					</_object>
				</_array>
			</classified_as>

			<!-- visual items and descriptions -->
			<xsl:apply-templates select="nuds:type"/>
			<xsl:apply-templates select="nuds:legend"/>
			<xsl:if test="nuds:persname[@xlink:href]">
				<shows>
					<_array>
						<_object>
							<type>VisualItem</type>
							<represents>
								<_array>
									<xsl:apply-templates select="nuds:persname[@xlink:href]" mode="portrait"/>
								</_array>
							</represents>
						</_object>
					</_array>
				</shows>
			</xsl:if>

			<!-- digital objects -->
			<xsl:apply-templates select="$fileSec/mets:fileGrp[@USE = $side]"/>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:legend">
		<carries>
			<_array>
				<_object>
					<type>LinguisticObject</type>
					<value>
						<xsl:value-of select="."/>
					</value>
				</_object>
			</_array>
		</carries>
	</xsl:template>

	<xsl:template match="nuds:type">
		<referred_to_by>
			<_array>
				<xsl:apply-templates select="nuds:description[@xml:lang = 'en']"/>
			</_array>
		</referred_to_by>

	</xsl:template>

	<xsl:template match="nuds:description">
		<_object>
			<type>LinguisticObject</type>
			<value>
				<xsl:value-of select="."/>
			</value>
			<classified_as>
				<_array>
					<_object>
						<id>aat:300080091</id>
						<type>Type</type>
						<label>description (activity)</label>
					</_object>

				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<xsl:template match="nuds:persname" mode="portrait">
		<xsl:variable name="uri" select="@xlink:href"/>

		<_object>
			<id>
				<xsl:value-of select="numishare:resolveUriToCurie($uri, $rdf//*[@rdf:about = $uri])"/>
			</id>
			<type>
				<xsl:choose>
					<xsl:when test="@xlink:role = 'deity'">Actor</xsl:when>
					<xsl:otherwise>Person</xsl:otherwise>
				</xsl:choose>
			</type>
			<label>
				<xsl:value-of select="."/>
			</label>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:choose>
								<xsl:when test="@xlink:role = 'deity'">aat:300189808</xsl:when>
								<xsl:otherwise>aat:300015637</xsl:otherwise>
							</xsl:choose>
						</id>
						<type>Type</type>
						<label>
							<xsl:choose>
								<xsl:when test="@xlink:role = 'deity'">figures (representations)</xsl:when>
								<xsl:otherwise>portraits</xsl:otherwise>
							</xsl:choose>
						</label>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<!-- ***** physDesc templates ***** -->
	<xsl:template match="nuds:physDesc">
		<xsl:apply-templates select="nuds:measurementsSet"/>
	</xsl:template>

	<xsl:template match="nuds:measurementsSet">
		<dimension>
			<_array>
				<xsl:apply-templates select="../nuds:axis"/>
				<xsl:apply-templates select="nuds:diameter | nuds:weight"/>
			</_array>
		</dimension>
	</xsl:template>

	<xsl:template match="nuds:diameter | nuds:weight | nuds:axis | nuds:height | nuds:width | nuds:thickness | nuds:axis">
		<_object>
			<type>Dimension</type>
			<value>
				<xsl:choose>
					<xsl:when test=". castable as xs:integer">
						<xsl:value-of select="."/>
					</xsl:when>
					<xsl:when test=". castable as xs:decimal">
						<xsl:value-of select='format-number(., "0.00")' />
					</xsl:when>
				</xsl:choose>
			</value>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="numishare:normalizeClassification(local-name())"/>
						</id>
						<type>Type</type>
						<label>
							<xsl:choose>
								<xsl:when test="self::nuds:axis">die axis</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="local-name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</label>
					</_object>
				</_array>
			</classified_as>
			<xsl:choose>
				<xsl:when test="self::nuds:diameter or self::nuds:height or self::nuds:width or self::nuds:thickness">
					<unit>aat:300379097</unit>
				</xsl:when>

				<xsl:when test="self::nuds:weight">
					<unit>aat:300379225</unit>
				</xsl:when>
			</xsl:choose>
		</_object>
	</xsl:template>

	<!-- ***** adminDesc templates ***** -->
	<xsl:template match="nuds:identifier">
		<_object>
			<type>Identifier</type>
			<value>
				<xsl:value-of select="."/>
			</value>
			<classified_as>
				<_array>
					<_object>
						<id>
							<xsl:value-of select="numishare:normalizeClassification(local-name())"/>
						</id>
						<type>Type</type>
						<label>accession numbers</label>
					</_object>
				</_array>
			</classified_as>
		</_object>
	</xsl:template>

	<!-- ***** Digitial representations ***** -->
	<xsl:template match="mets:fileGrp">
		<representation>
			<_array>
				<xsl:apply-templates select="mets:file[@USE = 'iiif'] | mets:file[@USE = 'reference']"/>
			</_array>
		</representation>
	</xsl:template>

	<xsl:template match="mets:file">
		<_object>
			<id>
				<xsl:value-of select="mets:FLocat/@xlink:href"/>
			</id>
			<type>VisualItem</type>
			<xsl:choose>
				<xsl:when test="@USE = 'iiif'">
					<label>IIIF Image API</label>
					<conforms_to>http://iiif.io/api/image</conforms_to>
				</xsl:when>
				<xsl:otherwise>
					<label>Digital Image</label>
					<xsl:if test="@MIMETYPE">
						<format>
							<xsl:value-of select="@MIMETYPE"/>
						</format>
					</xsl:if>
					<classified_as>
						<_array>
							<_object>
								<id>aat:300215302</id>
								<type>Type</type>
								<label>digital images</label>
							</_object>
						</_array>
					</classified_as>
				</xsl:otherwise>
			</xsl:choose>
		</_object>
	</xsl:template>
</xsl:stylesheet>
