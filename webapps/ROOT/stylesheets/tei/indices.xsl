<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xi="http://www.w3.org/2001/XInclude"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- XSLT to convert index metadata and index Solr results into
       HTML. This is the common functionality for both TEI and EpiDoc
       indices. It should be imported by the specific XSLT for the
       document type (eg, indices-epidoc.xsl). -->

  <xsl:import href="to-html.xsl" />

  <xsl:template match="index_metadata" mode="title">
    <xsl:value-of select="tei:div/tei:head" />
  </xsl:template>

  <xsl:template match="index_metadata" mode="head">
    <xsl:apply-templates select="tei:div/tei:head/node()" />
  </xsl:template>

  <xsl:template match="tei:div[@type='headings']/tei:list/tei:item">
    <th scope="col">
      <xsl:apply-templates/>
    </th>
  </xsl:template>

  <xsl:template match="tei:div[@type='headings']">
    <thead>
      <tr>
        <xsl:apply-templates select="tei:list/tei:item"/>
      </tr>
    </thead>
  </xsl:template>
  
  <xsl:template match="result/doc[arr[@name='index_coordinates']]"> <!-- i.e. locations index -->
    <div id="{str[@name='index_id']}" class="monument">
      <h2><xsl:if test="str[@name='index_number']!=''"><xsl:value-of select="str[@name='index_number']"/><xsl:text>. </xsl:text></xsl:if>
        <xsl:apply-templates select="str[@name='index_item_name']"/></h2>
      <h3>(<xsl:value-of select="string-join(str[@name='index_item_alt_name'], '; ')"/>)</h3>
      
      <xsl:if test="arr[@name='index_coordinates']">
        <div class="row map_box">
        <div id="{str[@name='index_id']}-map" class="mini-map"></div>
          <script type="text/javascript">
            <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT/assets/scripts/maps.js'))"/>
            var mymap = L.map('<xsl:value-of select="str[@name='index_id']"/>-map', { center: [35.15, 33.45], zoom: 7.4, fullscreenControl: true, layers: layers });
            L.control.layers(baseMaps, overlayMaps).addTo(mymap);
            L.control.scale().addTo(mymap);
            L.Control.geocoder().addTo(mymap);
            var marker = L.marker([<xsl:value-of select="arr[@name='index_coordinates']/str[1]"/>]).addTo(mymap).bindPopup('<b>Coordinates:</b><br/><xsl:value-of select="arr[@name='index_coordinates']/str[1]"/>');
          </script>
      </div>
      </xsl:if>
      
      <div>
        <xsl:choose>
          <xsl:when test="str[@name='index_item_type'] eq 'Monument'">
        <!--<p><b>Type: </b><xsl:value-of select="str[@name='index_item_type']" /></p>-->
        <p><b>District: </b><xsl:value-of select="string-join(arr[@name='index_district']/str, '; ')"/>
          <b> &#xA0;&#xA0;&#xA0;&#xA0; Diocese: </b><xsl:value-of select="string-join(arr[@name='index_diocese']/str, '; ')"/></p>
        <p><b>Context: </b><xsl:value-of select="string-join(arr[@name='index_context']/str, '; ')"/>
          <b> &#xA0;&#xA0;&#xA0;&#xA0; Function: </b><xsl:value-of select="string-join(arr[@name='index_function']/str, '; ')"/></p>
        <!--<p><b>Coordinates: </b><xsl:value-of select="string-join(arr[@name='index_coordinates']/str, '; ')"/></p>-->
        <p><b>Architectural type: </b><xsl:value-of select="string-join(arr[@name='index_architectural_type']/str, '; ')"/></p>
        <p><b>Date of construction: </b><xsl:value-of select="string-join(arr[@name='index_construction']/str, '; ')"/></p>
        <p><b>Date of painted decoration: </b></p>  
        <ul><xsl:for-each select="arr[@name='index_mural']/str"><li>
          <xsl:call-template name="MedCYToLink">
            <xsl:with-param name="solr-string" select="." />
          </xsl:call-template>
        </li></xsl:for-each></ul>
        <p><b>State of preservation of the murals: </b><xsl:value-of select="string-join(arr[@name='index_conservation']/str, '; ')"/></p>
        <p><b>Donor(s): </b>
          
          <xsl:call-template name="MedCYToLink">
            <xsl:with-param name="solr-string" select="string-join(arr[@name='index_donors']/str, '; ')" />
          </xsl:call-template>
        </p>
        <p><b>Painter(s): </b>
          <xsl:call-template name="MedCYToLink">
            <xsl:with-param name="solr-string" select="string-join(arr[@name='index_painter']/str, '; ')" />
          </xsl:call-template>
        </p>
        
        <p><b>Graffiti: </b><xsl:if test="string-length(normalize-space(arr[@name='index_graffiti_text']/str)) ne  0">
          <xsl:apply-templates select="arr[@name='index_graffiti_text']"/>
        </xsl:if>
          <xsl:if test="arr[@name='index_graffiti_ptr']/str">
            <xsl:apply-templates select="arr[@name='index_graffiti_ptr']"/>
          </xsl:if>
            <xsl:if test="arr[@name='index_graffiti_bibl']/str">
            <xsl:apply-templates select="arr[@name='index_graffiti_bibl']"/>
        </xsl:if>
        </p>
      
        <p><b>External resources: </b></p>
        <ul><xsl:for-each select="arr[@name='index_external_resource']/str"><li><xsl:apply-templates select="."/></li></xsl:for-each></ul>
        <p><b>Edition(s) of inscriptions: </b><xsl:apply-templates select="arr[@name='index_inscriptions_bibl']"/></p>
        <p><b>Monument bibliography: </b><xsl:apply-templates select="arr[@name='index_monument_bibl']"/></p>
          </xsl:when>
          <xsl:when test="str[@name='index_item_type'] eq 'Repository'">  <!-- This is for handling display of repositories -->
            <p><b>Location: </b> <xsl:value-of select="string-join(arr[@name='index_repository_location']/str, '; ')"/></p>
            <p><b>Museum Website: </b><xsl:apply-templates select="arr[@name='index_repository_url']"/></p>
            <p><b>External resources: </b></p>
            <xsl:choose>
              <xsl:when test="arr[@name='index_external_resource']/str">
              <ul><xsl:for-each select="arr[@name='index_external_resource']/str"><li><xsl:apply-templates select="."/></li></xsl:for-each></ul>
              </xsl:when>
              <xsl:otherwise>
               <ul><li> <xsl:text>n/a</xsl:text></li></ul>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <p><b>Inscriptions: </b></p>
        <ul class="index-instances"><xsl:apply-templates select="arr[@name='index_instance_location']/str"/></ul>
        <p class="locations-go-top"><a href="#monuments">[Top]</a></p>
      </div>
    </div>
  </xsl:template>
  
  <!-- Named template to handle adding HTML for links around MedCY references when they come out of solr queries -->
  <xsl:template name="MedCYToLink">
    <xsl:param name="solr-string"/>
    <xsl:choose> 
      <xsl:when test="contains($solr-string,'MedCY')">
        <xsl:for-each select="tokenize(replace($solr-string,'(MedCY\.\d{3}\.\d{3})', '|$1|'),'\|')">
          <xsl:variable name="solr-string-t" select="."/>
          <xsl:choose>
            <xsl:when test="contains(.,'MedCY')"><a href="/en/inscriptions/{$solr-string-t}.html"><xsl:value-of select="."/></a>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select=".  "/></xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$solr-string"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="result/doc[not(arr[@name='index_coordinates'])]"> <!-- i.e. all indices excluded locations -->
    <tr>
      <xsl:apply-templates select="str[@name='index_item_name']" />
      <xsl:apply-templates select="str[@name='index_surname']" />
      <xsl:apply-templates select="str[@name='index_abbreviation_expansion']"/>
      <xsl:apply-templates select="str[@name='index_numeral_value']"/>
      <xsl:apply-templates select="arr[@name='language_code']"/>
      <xsl:if test="arr[@name='index_epithet']"> <!-- i.e. displayed only in sacred index -->
        <td><xsl:value-of select="str[@name='index_item_alt_name']" /></td>
      </xsl:if>
      <xsl:apply-templates select="arr[@name='index_epithet']" />
      <xsl:apply-templates select="str[@name='index_item_type']" />
      <xsl:apply-templates select="str[@name='index_item_role']" />
      <xsl:apply-templates select="str[@name='index_honorific']" />
      <xsl:apply-templates select="str[@name='index_secular_office']" />
      <xsl:apply-templates select="str[@name='index_dignity']" />
      <xsl:apply-templates select="str[@name='index_ecclesiastical_office']" />
      <xsl:apply-templates select="str[@name='index_occupation']" />
      <xsl:apply-templates select="str[@name='index_relation']" />
      <!--<xsl:apply-templates select="str[@name='index_inscription_date']" />-->
      <xsl:apply-templates select="arr[@name='index_instance_location']" />
    </tr>
  </xsl:template>
  
<!-- Locations Index Output  -->
  <xsl:template match="response/result[descendant::doc[arr[@name='index_coordinates']]]"> 
    <div>
      <xsl:if test="doc/str[@name='index_map_labels']">
        <div class="row map_box">
        <div id="mapid" class="map"></div>
        <script type="text/javascript">
          var med_cyprus_locations = <xsl:value-of select="doc/str[@name='index_map_labels']"/>;
          <xsl:value-of select="fn:doc(concat('file:',system-property('user.dir'),'/webapps/ROOT/assets/scripts/maps.js'))"/>
          var mymap = L.map('mapid', { center: [35.15, 33.45], zoom: 8.5, fullscreenControl: true, layers: layers });
          L.control.layers(baseMaps, overlayMaps).addTo(mymap);
          L.control.scale().addTo(mymap);
          L.Control.geocoder().addTo(mymap);
          toggle_places.addTo(mymap); 
        </script>
      </div>
      </xsl:if>
      
      <h2 class="locations-index" id="monuments">MONUMENTS | <a href="#repositories">REPOSITORIES</a></h2>
      
      <div class="locations-menu-list">
        <xsl:apply-templates select="doc[descendant::str[@name='index_item_type'][.='Monument']]" mode="menu-list"><xsl:sort select="str[@name='index_number']" data-type="number"/></xsl:apply-templates>
      </div>
      
      <xsl:apply-templates select="doc[descendant::str[@name='index_item_type'][.='Monument']]"><xsl:sort select="str[@name='index_number']" data-type="number"/></xsl:apply-templates>
      
      <h2 class="locations-index" id="repositories">REPOSITORIES | <a href="#monuments">MONUMENTS</a></h2>
      <div class="locations-menu-list">
        <xsl:apply-templates select="doc[descendant::str[@name='index_item_type'][.='Repository']]" mode="menu-list"><xsl:sort select="str[@name='index_number']"/></xsl:apply-templates>
      </div>
      
      <xsl:apply-templates select="doc[descendant::str[@name='index_item_type'][.='Repository']]"><xsl:sort select="str[@name='index_number']"/></xsl:apply-templates>
    </div>
  </xsl:template>
  <!-- EM: if monuments and Repositories don't sort properly, add sort on index_number or  index_item_name. Might need to add index numbers to repositories. -->
  
  <xsl:template match="response/result[not(descendant::arr[@name='index_coordinates'])]"> <!-- i.e. all indices excluded locations -->
    <table class="index tablesorter">
      <xsl:apply-templates select="/aggregation/index_metadata/tei:div/tei:div[@type='headings']" />
      <tbody>
        <xsl:apply-templates select="doc">
          <xsl:sort>
            <xsl:variable name="sort">
              <xsl:choose>
                <xsl:when test="str[@name='index_item_sort_name']"><xsl:value-of select="str[@name='index_item_sort_name']"/></xsl:when>
                <xsl:when test="str[@name='index_item_name']"><xsl:value-of select="str[@name='index_item_name']"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="translate(normalize-unicode(lower-case($sort),'NFD'), '&#x0300;&#x0301;&#x0308;&#x0303;&#x0304;&#x0313;&#x0314;&#x0345;&#x0342;' ,'')"/>
          </xsl:sort>
        </xsl:apply-templates>
      </tbody>
    </table>
  </xsl:template>

  <xsl:template match="str[@name='index_abbreviation_expansion']">
    <td>
      <xsl:value-of select="." />
    </td>
  </xsl:template>

  <xsl:template match="str[@name='index_item_name']">
    <th scope="row" class="item_name" id="{ancestor::doc/str[@name='index_id']}">
      <xsl:value-of select="."/>
      <!-- if persons index: show popup with info from persons.xml AL -->
      <xsl:if test="ancestor::doc[descendant::str[@name='index_surname']]">
        <xsl:text> </xsl:text>
        <button type="button" class="expander" onclick="$(this).next().toggleClass('shown'); $(this).text($(this).next().hasClass('shown') ? '[-]' : '[+]');">[+]</button>
        <span class="expanded">
          <b>Name: </b><xsl:value-of select="ancestor::doc/str[@name='index_item_name']"/> <xsl:text> </xsl:text> <xsl:value-of select="ancestor::doc/str[@name='index_surname']"/>
          <br/><b>Greek name: </b><xsl:value-of select="ancestor::doc/str[@name='index_item_alt_name']"/>
          
          <xsl:if test="ancestor::doc/str[@name='index_birth']!=''">
          <br/><b>Birth: </b><xsl:value-of select="ancestor::doc/str[@name='index_birth']"/>
          </xsl:if>
          
          <xsl:if test="ancestor::doc/str[@name='index_death']!=''">
          <br/><b>Death: </b><xsl:value-of select="ancestor::doc/str[@name='index_death']"/>
          </xsl:if>
          
          <xsl:if test="ancestor::doc/str[@name='index_floruit']!=''">
          <br/><b>Floruit: </b><xsl:value-of select="ancestor::doc/str[@name='index_floruit']"/>
          </xsl:if>
          
          <xsl:if test="ancestor::doc/str[@name='index_secular_office']!=''">
            <br/><b>Secular office: </b><xsl:value-of select="ancestor::doc/str[@name='index_secular_office']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/str[@name='index_ecclesiastical_office']!=''">
            <br/><b>Ecclesiastical office: </b><xsl:value-of select="ancestor::doc/str[@name='index_ecclesiastical_office']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/str[@name='index_dignity']!=''">
            <br/><b>Dignity: </b><xsl:value-of select="ancestor::doc/str[@name='index_dignity']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/str[@name='index_occupation']!=''">
      <br/><b>Occupation: </b><xsl:value-of select="ancestor::doc/str[@name='index_occupation']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/str[@name='index_relation']!=''">
      <br/><b>Association with monument: </b><xsl:value-of select="ancestor::doc/str[@name='index_relation']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/arr[@name='index_relationship']/str!=''">
            <br/><b>Relationships: </b>
            <xsl:for-each select="ancestor::doc/arr[@name='index_relationship']/str">
              <a target="_blank" href="#{substring-after(., '#')}"><xsl:value-of select="substring-before(., '#')"/></a>
              <xsl:if test="position()!=last()">; </xsl:if>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="ancestor::doc/str[@name='index_note']!=''">
      <br/><b>Notes: </b><xsl:value-of select="ancestor::doc/str[@name='index_note']"/>
          </xsl:if>
          <xsl:if test="ancestor::doc/arr[@name='index_external_resource']/str[.!='']">
      <br/><xsl:for-each select="ancestor::doc/arr[@name='index_external_resource']/str">
        <xsl:apply-templates select="."/><xsl:if test="position()!=last()"><br/></xsl:if>
      </xsl:for-each>
          </xsl:if>
          <br/><b>URI: </b> 
          <a href="https://medcyprus.ucy.ac.cy/en/indices/epidoc/persons.html#{ancestor::doc/str[@name='index_id']}">
            https://medcyprus.ucy.ac.cy/en/indices/epidoc/persons.html#<xsl:value-of select="ancestor::doc/str[@name='index_id']"/>
          </a>
        </span>
      </xsl:if>
    </th>
  </xsl:template>
  
  <xsl:template match="str[@name=('index_surname', 'index_honorific', 'index_secular_office', 'index_dignity', 'index_ecclesiastical_office', 'index_occupation', 'index_relation', 'index_inscription_date', 'index_item_type', 'index_item_role', 'index_numeral_value', 'index_id')]">
    <td>
      <xsl:value-of select="."/>
    </td>
  </xsl:template>
  
  <xsl:template match="arr[@name='index_instance_location']">
    <td>
      <ul class="index-instances inline-list">
        <xsl:apply-templates select="str" />
      </ul>
    </td>
  </xsl:template>

  <xsl:template match="arr[@name='language_code']">
    <td>
      <ul class="inline-list">
        <xsl:apply-templates select="str"/>
      </ul>
    </td>
  </xsl:template>

  <xsl:template match="arr[@name='language_code']/str">
    <li>
      <xsl:value-of select="."/>
    </li>
  </xsl:template>
  
  <xsl:template match="arr[@name='index_epithet']">
    <td>
      <xsl:variable name="epithets">
        <xsl:for-each select="str">
          <xsl:value-of select="."/>
          <xsl:if test="position()!=last()"><xsl:text>, </xsl:text></xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="string-join(distinct-values(tokenize($epithets, ', ')), ', ')"/>
    </td>
  </xsl:template>
  
  <xsl:template match="arr[@name='index_inscriptions_bibl']|arr[@name='index_monument_bibl']">
    <xsl:for-each select="str[.='unpublished']"><xsl:value-of select="."/></xsl:for-each>  
    <xsl:for-each select="str[.!='unpublished']">
        <xsl:variable name="bibl-id">
          <xsl:choose>
            <xsl:when test="contains(., ',')">
              <xsl:value-of select="substring-before(., ',')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="bibliography-al" select="concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml')"/>
        <xsl:variable name="bibl" select="document($bibliography-al)//tei:bibl[@xml:id=$bibl-id][not(@sameAs)]"/>
        <a href="{concat('../../concordance/bibliography/',$bibl-id,'.html')}" target="_blank">
          <xsl:choose>
            <xsl:when test="doc-available($bibliography-al) = fn:true()">
              <xsl:choose>
                <xsl:when test="$bibl">
                  <xsl:choose>
                    <xsl:when test="$bibl//tei:bibl[@type = 'abbrev']">
                      <xsl:apply-templates select="$bibl//tei:bibl[@type = 'abbrev'][1]"/>
                    </xsl:when>
                    <xsl:when test="$bibl//tei:title[@type = 'short']">
                      <xsl:apply-templates select="$bibl//tei:title[@type = 'short'][1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:choose>
                        <xsl:when test="$bibl[ancestor::tei:div[@xml:id = 'authored_editions']]">
                          <xsl:for-each
                            select="$bibl//tei:name[@type = 'surname'][not(parent::*/preceding-sibling::tei:title[not(@type = 'short')])]">
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()"> – </xsl:if>
                          </xsl:for-each>
                          <xsl:if test="$bibl//tei:date/text()">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$bibl//tei:date"/>
                          </xsl:if>
                        </xsl:when>
                        <xsl:when test="$bibl[ancestor::tei:div[@xml:id = 'series_collections']]">
                          <i>
                            <xsl:value-of select="$bibl/@xml:id"/>
                          </i>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:for-each
                            select="$bibl//tei:*[(self::tei:name and @type = 'surname') or self::tei:surname][not(parent::*/preceding-sibling::tei:title[not(@type = 'short')])]">
                            <xsl:value-of select="."/>
                            <xsl:if test="position() != last()"> – </xsl:if>
                          </xsl:for-each>
                          <xsl:if test="$bibl//tei:date/text()">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="$bibl//tei:date"/>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="upper-case(substring($bibl-id, 1, 1))"/>
                  <xsl:value-of select="substring($bibl-id, 2)"/>
                </xsl:otherwise>
              </xsl:choose>  
            </xsl:when>
          </xsl:choose>
        </a>
      <xsl:if test="contains(., ',')">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="substring-after(., ',')"/>
      </xsl:if>
        <xsl:if test="position()!=last()">; </xsl:if>
      </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template match="arr[@name='index_external_resource']/str">
    <b><xsl:value-of select="substring-before(., ': ')"/>: </b>
    <!-- EM added -->
    <xsl:choose>
      <xsl:when test="contains(substring-after(., ': '),'http')">
        <a target="_blank" href="{substring-after(., ': ')}"><xsl:value-of select="substring-after(., ': ')"/></a>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="substring-after(., ': ')"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="arr[@name='index_repository_url']/str">
        <a target="_blank" href="{.}"><xsl:value-of select="."/></a>
  </xsl:template>
  <xsl:template match="arr[@name='index_graffiti_text']/str">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="arr[@name='index_graffiti_ptr']/str">
    <xsl:analyze-string select="." regex="(http:|https:)(\S+?)(\.|\)|\]|;|,|\?|!|:)?(\s|$)"> 
      <xsl:matching-substring> <!-- it's a URL -->
       (<a target="_blank" href="{concat(regex-group(1),regex-group(2))}"><xsl:value-of select="concat(regex-group(1),regex-group(2))"/></a>)
        <xsl:value-of select="concat(regex-group(3),regex-group(4))"/>
      </xsl:matching-substring>
      <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring> <!-- it's text -->
    </xsl:analyze-string>
  </xsl:template>
  
  <xsl:template match="arr[@name='index_graffiti_bibl']">
    (<xsl:for-each select="str">
          <xsl:variable name="bibl-id">
            <xsl:choose>
              <xsl:when test="contains(., ',')">
                <xsl:value-of select="substring-before(., ',')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="bibliography-al" select="concat('file:',system-property('user.dir'),'/webapps/ROOT/content/xml/authority/bibliography.xml')"/>
          <xsl:variable name="bibl" select="document($bibliography-al)//tei:bibl[@xml:id=$bibl-id][not(@sameAs)]"/>
          <a href="{concat('../../concordance/bibliography/',$bibl-id,'.html')}" target="_blank">
            <xsl:choose>
              <xsl:when test="doc-available($bibliography-al) = fn:true()">
                <xsl:choose>
                  <xsl:when test="$bibl">
                    <xsl:choose>
                      <xsl:when test="$bibl//tei:bibl[@type = 'abbrev']">
                        <xsl:apply-templates select="$bibl//tei:bibl[@type = 'abbrev'][1]"/>
                      </xsl:when>
                      <xsl:when test="$bibl//tei:title[@type = 'short']">
                        <xsl:apply-templates select="$bibl//tei:title[@type = 'short'][1]"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:choose>
                          <xsl:when test="$bibl[ancestor::tei:div[@xml:id = 'authored_editions']]">
                            <xsl:for-each
                              select="$bibl//tei:name[@type = 'surname'][not(parent::*/preceding-sibling::tei:title[not(@type = 'short')])]">
                              <xsl:value-of select="."/>
                              <xsl:if test="position() != last()"> – </xsl:if>
                            </xsl:for-each>
                            <xsl:if test="$bibl//tei:date/text()">
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="$bibl//tei:date"/>
                            </xsl:if>
                          </xsl:when>
                          <xsl:when test="$bibl[ancestor::tei:div[@xml:id = 'series_collections']]">
                            <i>
                              <xsl:value-of select="$bibl/@xml:id"/>
                            </i>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:for-each
                              select="$bibl//tei:*[(self::tei:name and @type = 'surname') or self::tei:surname][not(parent::*/preceding-sibling::tei:title[not(@type = 'short')])]">
                              <xsl:value-of select="."/>
                              <xsl:if test="position() != last()"> – </xsl:if>
                            </xsl:for-each>
                            <xsl:if test="$bibl//tei:date/text()">
                              <xsl:text> </xsl:text>
                              <xsl:value-of select="$bibl//tei:date"/>
                            </xsl:if>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="upper-case(substring($bibl-id, 1, 1))"/>
                    <xsl:value-of select="substring($bibl-id, 2)"/>
                  </xsl:otherwise>
                </xsl:choose>  
              </xsl:when>
            </xsl:choose>
          </a>
          <xsl:if test="contains(., ',')">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="substring-after(., ',')"/>
          </xsl:if>
          <xsl:if test="position()!=last()">; </xsl:if>
      
    </xsl:for-each>)
  </xsl:template>
  
  <xsl:template match="result/doc[arr[@name='index_coordinates']]" mode="menu-list">
    <p class="locations-menu-cols"><a href="{concat('#', str[@name='index_id'])}">
      <xsl:value-of select="str[@name='index_number']"/><xsl:text>. </xsl:text><xsl:value-of select="str[@name='index_item_name']"/>
    </a></p> 
  </xsl:template>
  
  
  <xsl:template match="arr[@name='index_instance_location']/str">
    <!-- This template must be defined in the calling XSLT (eg,
         indices-epidoc.xsl) since the format of the location data is
         not universal. -->
    <xsl:call-template name="render-instance-location" />
  </xsl:template>

</xsl:stylesheet>
