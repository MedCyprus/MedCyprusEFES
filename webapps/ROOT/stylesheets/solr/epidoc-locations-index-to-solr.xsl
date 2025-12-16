<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of locations of those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <!-- START MAP POINTS -->
  <xsl:variable name="locationsAL" select="'../../content/xml/authority/locations.xml'"/>
  
  <xsl:variable name="med_cyprus_locations">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="document($locationsAL)//tei:place[matches(normalize-space(descendant::tei:geo), '\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:variable name="id" select="@xml:id"/>
      <!--<xsl:variable name="count" select="count(collection('../../content/xml/epidoc/?select=*.xml;recurse=yes')//tei:origPlace[substring-after(@ref, '#')=$id])"/>-->
      <xsl:variable name="count">
        <xsl:choose>
          <xsl:when test="parent::tei:listPlace/@type='repositories'">
          <xsl:value-of select="count(collection('../../content/xml/epidoc/?select=*.xml;recurse=yes')//tei:repository[substring-after(@ref, '#')=$id])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(collection('../../content/xml/epidoc/?select=*.xml;recurse=yes')//tei:origPlace[substring-after(@ref, '#')=$id])"/>
        </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <!-- add if to handle repositories where count should match tei:repository[@ref]-->
      
      <xsl:variable name="label"><xsl:value-of select="concat(@n, '. ', normalize-space(translate(tei:placeName[1], ',', '; ')))"/></xsl:variable>
      <xsl:variable name="coords" select="normalize-space(descendant::tei:geo[1])"/>
      <xsl:variable name="locationType" select="parent::tei:listPlace/@type"/><!-- value will be repositories or monuments -->
      <xsl:text>{</xsl:text>
      <xsl:text>id: "</xsl:text><xsl:value-of select="$id"/><xsl:text>",
      </xsl:text>
      <xsl:text>label: "</xsl:text><xsl:value-of select="$label"/><xsl:text>",
      </xsl:text>
      <xsl:text>count: </xsl:text><xsl:value-of select="$count"/><xsl:text>,
      </xsl:text>
      <xsl:text>locationType: "</xsl:text><xsl:value-of select="$locationType"/><xsl:text>",
      </xsl:text>
      <xsl:text>x: </xsl:text><xsl:value-of select="substring-before($coords, ',')"/><xsl:text>,
      </xsl:text>
      <xsl:text>y: </xsl:text><xsl:value-of select="substring-after($coords, ',')"/><xsl:text>}</xsl:text>

      <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:variable>
  
  <!--<xsl:variable name="map_labels">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="document($locationsAL)//tei:place[matches(normalize-space(descendant::tei:geo), '\d{1,2}(\.\d+){0,1},\s+?\d{1,2}(\.\d+){0,1}')]">
      <xsl:text>"</xsl:text><xsl:value-of select="normalize-space(translate(tei:placeName[1], ',', '; '))"/><xsl:text>"</xsl:text><xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:variable>-->
  <!-- END MAP POINTS -->

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:origPlace[@ref]|//tei:repository[@ref]" group-by="@ref">
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="contains(@ref, '#')">
              <xsl:value-of select="substring-after(@ref, '#')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@ref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="idno" select="document($locationsAL)//tei:place[@xml:id=$id]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          
          <xsl:if test="position()=1"> <!--TO GENERATE MAP, preventing having this indexed for all locations -->
            <field name="index_map_points"></field>
            <field name="index_map_labels"><xsl:value-of select="normalize-space($med_cyprus_locations)"/></field>
          </xsl:if>
          
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="doc-available($locationsAL) = fn:true() and $idno">
                <xsl:value-of select="normalize-space(translate(translate(translate($idno//tei:placeName[@xml:lang='en'][1], '/', '／'), '_', ' '), '(?)', ''))" /> 
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_id">
            <xsl:value-of select="translate(string-join($id, ''), ' ', '_')"/>
          </field>
          <field name="index_number">
            <xsl:value-of select="$idno/@n"/>
          </field>
          <field name="index_item_type">
            <xsl:choose>
              <xsl:when test="self::tei:origPlace"><xsl:text>Monument</xsl:text></xsl:when>
              <xsl:when test="self::tei:repository"><xsl:text>Repository</xsl:text></xsl:when>
            </xsl:choose>
          </field>
          <!--<xsl:if test="doc-available($locationsAL) = fn:true() and $idno">-->
          <field name="index_item_alt_name">
            <xsl:value-of select="$idno//tei:placeName[@xml:lang='el'][1]"/>
          </field>
          <field name="index_district">
            <!--<xsl:choose>
              <xsl:when test="contains($idno//tei:placeName[@type='district'][1]/@ref, '#')">
                <xsl:value-of select="substring-after($idno//tei:placeName[@type='district'][1]/@ref, '#')"/> 
              </xsl:when>
              <xsl:otherwise>-->
                <xsl:value-of select="$idno//tei:placeName[@type='district']"/>
              <!--</xsl:otherwise>
            </xsl:choose>-->
          </field>
          <field name="index_diocese">
            <!--<xsl:choose>
              <xsl:when test="contains($idno//tei:placeName[@type='diocese'][1]/@ref, '#')">
                <xsl:value-of select="substring-after($idno//tei:placeName[@type='diocese'][1]/@ref, '#')"/> 
              </xsl:when>
              <xsl:otherwise>-->
                <xsl:value-of select="$idno//tei:placeName[@type='diocese']"/>
              <!--</xsl:otherwise>
            </xsl:choose>-->
          </field>
          <field name="index_repository_location">
            <xsl:value-of select="$idno//tei:location/tei:placeName"/>
          </field>
          <field name="index_coordinates">
            <xsl:value-of select="$idno//tei:location/tei:geo"/>
          </field>
            <field name="index_construction">
              <xsl:value-of select="$idno//tei:desc[@type='construction']"/>
            </field>
            <field name="index_function">
              <xsl:value-of select="$idno//tei:desc[@type='function']"/>
            </field>
            <field name="index_context">
              <xsl:value-of select="$idno//tei:desc[@type='context']"/>
            </field>
            <field name="index_architectural_type">
              <xsl:apply-templates select="$idno//tei:desc[@type='architectural']" mode="munge-ref"/>
          </field>
              <xsl:for-each select="$idno//tei:desc[@type='mural']//tei:desc[@type='layer']">
                <field name="index_mural">
                  <!--<xsl:value-of select="."/>-->
                  <xsl:value-of>
                    <xsl:apply-templates mode="date-evidence"/>
                  </xsl:value-of>
                </field>
              </xsl:for-each>
          
            <field name="index_conservation"> <!-- if <ref>, then rewrite string and replace <ref> link with start and end symbols -->
             <xsl:apply-templates select="$idno//tei:desc[@type='conservation']" mode="munge-ref"/>
          </field>
          
            <field name="index_donors">
              <xsl:value-of select="$idno//tei:desc[@type='donors']"/>
            </field>
            <field name="index_painter">
              <xsl:value-of select="$idno//tei:desc[@type='painter']"/>
            </field>
         <field name="index_graffiti_text">
           <xsl:value-of select="$idno//tei:desc[@type='graffiti']/text()"/>
         </field>
          <xsl:if test="$idno//tei:desc[@type='graffiti']/tei:ptr">
          <field name="index_graffiti_ptr">
            <xsl:value-of select="$idno//tei:desc[@type='graffiti']/tei:ptr/@target"/>
          </field>
          </xsl:if>
          <xsl:for-each select="$idno//tei:desc[@type='graffiti']/tei:bibl/tei:ptr">
            <field name="index_graffiti_bibl">
            <xsl:value-of select="substring-after(@target, '#')"/> 
            <xsl:if test="following-sibling::tei:citedRange">
              <xsl:text>, </xsl:text>
              <xsl:value-of select="following-sibling::tei:citedRange"/>
            </xsl:if>
            </field>
          </xsl:for-each>
          
            <xsl:for-each select="$idno//tei:idno[@type]">
                <field name="index_external_resource">
                  <xsl:choose>
                    <xsl:when test="@type='geonames'"><xsl:text>GeoNames</xsl:text></xsl:when>
                    <xsl:when test="@type='wikidata'"><xsl:text>WikiData</xsl:text></xsl:when>
                    <xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
                  </xsl:choose>: <xsl:value-of select="."/>
                </field>
              </xsl:for-each>
              <xsl:choose>
                <xsl:when test="$idno//tei:listBibl[@type='inscriptions']/tei:bibl[@ana='unpublished']">
                  <field name="index_inscriptions_bibl">
                    <xsl:text>Unpublished</xsl:text>
                  </field>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:for-each select="$idno//tei:listBibl[@type='inscriptions']/tei:bibl/tei:ptr">
                    <field name="index_inscriptions_bibl">
                    <xsl:value-of select="substring-after(@target, '#')"/>
                    <xsl:if test="following-sibling::tei:citedRange">
                    <xsl:text>, </xsl:text>
                      <xsl:value-of select="following-sibling::tei:citedRange"/>
                    </xsl:if>
                    </field>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            
            <xsl:choose>
              <xsl:when test="$idno//tei:listBibl[@type='monument']/tei:bibl[@ana='unpublished']">
                <field name="index_monument_bibl">
                  <xsl:text>Unpublished</xsl:text>
                </field>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="$idno//tei:listBibl[@type='monument']/tei:bibl/tei:ptr">
                  <field name="index_monument_bibl">
                    <xsl:value-of select="substring-after(@target, '#')"/>
                    <xsl:if test="following-sibling::tei:citedRange">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="following-sibling::tei:citedRange"/>
                    </xsl:if>
                  </field>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
         
          <field name="index_repository_url"> <!-- Assumes only one museum website. Indexes it for each location, including monuments. -->
            <xsl:value-of select="$idno//tei:bibl/tei:ref[@type='website']"/>
          </field>
          <!--</xsl:if>-->
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:date" mode="date-evidence">
    <xsl:value-of select="."/> based on 
    <xsl:value-of select="translate(replace(@evidence,' ',', '),'-',' ')"/>.
  </xsl:template>

  <xsl:template match="tei:origPlace|tei:repository">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>
  
  <xsl:template match="tei:ref" mode="munge-ref">
    ¢<xsl:value-of select="@target"/>£<xsl:value-of select="."/>¢
  </xsl:template>

</xsl:stylesheet>
