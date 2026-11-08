<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
  version="2.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of epithets in those
       documents. -->
  
  <xsl:import href="epidoc-index-utils.xsl" />
  
  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />
  
  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:addName" group-by="concat(@ref, '-', @key, '-', @nymRef)">
        <!-- MedCyprus only uses @key -->
        <xsl:variable name="self" select="."/>
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="contains(@ref, '#')">
              <xsl:value-of select="substring-after(@ref, '#')"/>
            </xsl:when>
            <xsl:when test="@ref">
              <xsl:value-of select="@ref"/>
            </xsl:when>
            <xsl:when test="@key">
              <xsl:value-of select="@key"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@nymRef"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="divineAL" select="'../../content/xml/authority/sacred.xml'"/>
        <xsl:variable name="idno" select="document($divineAL)//tei:person[child::tei:persName[@key=$id]]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          
          <field name="index_item_name"> <!-- epithet in English -->
            <xsl:choose>
              <xsl:when test="$idno">
                <xsl:value-of select="distinct-values($idno/tei:persName[@type='epithet'][@key=$id][@xml:lang='en'])" /> 
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          
          <field name="index_item_namegrc"> <!-- epithet in Greek -->
            <xsl:choose>
              <xsl:when test="$idno">
                <xsl:value-of select="distinct-values($idno/tei:persName[@type='epithet'][@key=$id][@xml:lang='grc'])" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          
          <field name="index_item_namewd"> <!-- epithet in Greek -->
            <xsl:choose>
              <xsl:when test="$idno/tei:idno">
                <xsl:value-of select="$idno/tei:idno" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>n/a</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>
  
  <xsl:template match="tei:addName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>
  
</xsl:stylesheet>