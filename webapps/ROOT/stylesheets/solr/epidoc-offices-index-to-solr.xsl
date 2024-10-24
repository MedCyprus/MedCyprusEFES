<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr index document representing 
    an index of offices, dignities, honorifics and occupations in those documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <xsl:for-each-group select="//tei:rs[@type='office' or @type='dignity' or @type='honorific' or @type='occupation'][ancestor::tei:div/@type='edition']" group-by="@ref">
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
        <xsl:variable name="officesAL" select="'../../content/xml/authority/offices.xml'"/>
        <xsl:variable name="idno" select="document($officesAL)//tei:item[@xml:id=$id]"/>
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
              <xsl:when test="doc-available($officesAL) = fn:true() and $idno">
                <xsl:value-of select="$idno//tei:term[1]" />
              </xsl:when>
              <xsl:when test="$id and not($idno)">
                <xsl:value-of select="$id" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="." />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_type">
            <xsl:if test="doc-available($officesAL) = fn:true() and $idno">
              <xsl:choose>
                <xsl:when test="$idno/ancestor::tei:list[@type='ecclesiastical_offices']">
                  <xsl:text>Ecclesiastical Office</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/ancestor::tei:list[@type='secular_offices']">
                  <xsl:text>Secular Office</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/ancestor::tei:list[@type='dignities']">
                  <xsl:text>Dignity</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/ancestor::tei:list[@type='honorifics']">
                  <xsl:text>Honorific</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/ancestor::tei:list[@type='occupations']">
                  <xsl:text>Occupation</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:rs[@type='office' or @type='dignity' or @type='honorific' or @type='occupation']">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>