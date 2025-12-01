<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of persons in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl"/>

  <xsl:param name="index_type"/>
  <xsl:param name="subdirectory"/>

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:persName[@type!='divine'][@type!='sacred'][@type!='other'][not(@sameAs)][ancestor::tei:div/@type = 'edition']" group-by="concat(@ref,'-',@role)">
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
        <xsl:variable name="personsAL" select="'../../content/xml/authority/persons.xml'"/>
        <xsl:variable name="idno" select="document($personsAL)//tei:person[@xml:id = $id]"/>
        <xsl:variable name="xmlid" select="@xml:id"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory"/>
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type"/>
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path"/>
          
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="$idno//tei:persName[@xml:lang='en']/tei:forename">
                <xsl:value-of select="$idno//tei:persName[@xml:lang='en'][1]/tei:forename"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($id, ' !!!!')"/>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          
          <field name="index_surname">
            <xsl:value-of select="$idno//tei:persName[@xml:lang='en'][1]/tei:surname"/>
          </field>
          
          <field name="index_item_alt_name">
            <xsl:value-of select="$idno//tei:persName[@xml:lang='grc'][1]"/>
          </field>
          
          <field name="index_note">
            <xsl:value-of select="$idno//tei:note[1]"/>
          </field>
            
          <field name="index_floruit">
            <xsl:for-each select="$idno//tei:floruit">
            <xsl:value-of select="."/>
            <xsl:if test="@ana"><xsl:text> (</xsl:text><xsl:value-of select="translate(@ana, '#', '')"/><xsl:text>)</xsl:text></xsl:if>
              <xsl:if test="position()!=last()">; </xsl:if>
            </xsl:for-each>
          </field>
          
            <field name="index_birth">
              <xsl:value-of select="$idno//tei:birth[1]"/>
            </field> 
         
            <field name="index_death">
              <xsl:value-of select="$idno//tei:death[1]"/>
            </field>
            
          <xsl:for-each select="$idno//tei:idno[@type]">
            <field name="index_external_resource">
              <xsl:choose>
                <xsl:when test="lower-case(@type) = 'pbw'"><xsl:text>PBW</xsl:text></xsl:when>
                <xsl:when test="lower-case(@type) = 'wikidata'"><xsl:text>WikiData</xsl:text></xsl:when>
                <xsl:otherwise><xsl:value-of select="@type"/></xsl:otherwise>
              </xsl:choose>: <xsl:value-of select="."/>
            </field>
          </xsl:for-each>
            
              <field name="index_honorific">
                <xsl:for-each select="$idno//tei:occupation[@type = 'honorific']">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">; </xsl:if>
                </xsl:for-each>
          </field>
            
              <field name="index_secular_office">
                  <xsl:for-each select="$idno//tei:occupation[@type = 'office-secular']">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
          </field>
              
                <field name="index_dignity">
                  <xsl:for-each select="$idno//tei:occupation[@type = 'dignity']">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
          </field>
              
                <field name="index_ecclesiastical_office">
                  <xsl:for-each select="$idno//tei:occupation[@type = 'office-ecclesiastical']">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
          </field>
              
                <field name="index_occupation">
                  <xsl:for-each select="$idno//tei:occupation[@type = 'occupation']">
                    <xsl:value-of select="."/>
                    <xsl:if test="position() != last()">; </xsl:if>
                  </xsl:for-each>
          </field>
          
          <field name="index_relation">
                  <xsl:value-of select="@role"/>
          </field>
          
          <xsl:if test="document($personsAL)//tei:relation[replace(@active, '#','') = $id]">
            <xsl:for-each select="document($personsAL)//tei:relation[replace(@active, '#','') = $id]">
              <field name="index_relationship">
                <xsl:value-of select="tei:desc[1]"/>
                <xsl:text>#</xsl:text>
                <xsl:value-of select="replace(@passive, '#','')"/>
              </field>
            </xsl:for-each>
          </xsl:if>
          
          <field name="index_id">
            <xsl:choose>
              <xsl:when test="$idno/@xml:id">
                <xsl:value-of select="$idno/@xml:id"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id"/>
              </xsl:otherwise>
            </xsl:choose>
          </field>

          <!--<field name="index_inscription_date">
            <xsl:value-of select="ancestor::tei:TEI/tei:teiHeader//tei:origDate"/>
          </field>-->

          <xsl:apply-templates select="current-group()"/>
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:call-template name="field_index_instance_location"/>
  </xsl:template>

</xsl:stylesheet>
