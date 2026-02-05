<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of mentioned places in those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:placeName[@ref][ancestor::tei:div/@type='edition']" group-by="concat(@ref,'-',@type)">
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
        <xsl:variable name="mentionedplacesAL" select="'../../content/xml/authority/mentioned_places.xml'"/>
        <xsl:variable name="idno" select="document($mentionedplacesAL)//tei:place[@xml:id=$id]"/>
        <doc>
          <field name="document_type">
            <xsl:value-of select="$subdirectory" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$index_type" />
            <xsl:text>_index</xsl:text>
          </field>
          <xsl:call-template name="field_file_path" />
          <field name="index_item_name">
            <xsl:choose>
              <xsl:when test="doc-available($mentionedplacesAL) = fn:true() and $idno">
                <xsl:value-of select="$idno/tei:placeName[@xml:lang='grc'][1]" />
                <xsl:if test="$idno/tei:placeName[@xml:lang='grc'][2]">
                  <xsl:text> / </xsl:text>
                  <xsl:value-of select="$idno/tei:placeName[@xml:lang='grc'][2]" />
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_type">
            <xsl:choose>
            <xsl:when test="$idno/tei:placeName[@xml:lang='en'][1]">
              <xsl:value-of select="$idno/tei:placeName[@xml:lang='en'][1]" />
              <xsl:if test="$idno/tei:placeName[@xml:lang='en'][2]">
                  <xsl:text> / </xsl:text>
                <xsl:value-of select="$idno/tei:placeName[@xml:lang='en'][2]" />
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$id" />
            </xsl:otherwise>
              <!--<xsl:when test="@type='ethnic'"><xsl:text>Ethnic</xsl:text></xsl:when>
              <xsl:otherwise><xsl:text>Toponym</xsl:text></xsl:otherwise>-->
            </xsl:choose>
          </field>
          <field name="index_placenames_gazetteer">
            <xsl:choose>
              <xsl:when test="$idno/tei:idno">
                 <xsl:value-of select="$idno/tei:idno" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="NO_GAZETTEER"/>
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:placeName">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
