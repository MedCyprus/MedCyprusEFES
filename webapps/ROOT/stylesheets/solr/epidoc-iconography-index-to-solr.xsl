<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all"
                version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of iconographies of those
       documents. -->

  <xsl:import href="epidoc-index-utils.xsl" />

  <xsl:param name="index_type" />
  <xsl:param name="subdirectory" />

  <xsl:template match="/">
    <add>
      <!-- EM idea of column with co-occuring keywords. put all rs/@ref in an array
             process them so that each item is a keyword, and there is another set of the remaining items. 
             put the latter in a column. Make them links to other items in the index. The-->
      <xsl:for-each-group select="//tei:rs[@type='iconography']" group-by="@ref">
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
        <xsl:variable name="iconographyAL" select="'../../content/xml/authority/iconography.xml'"/>
        <xsl:variable name="idno" select="document($iconographyAL)//tei:item[@xml:id=$id]"/>
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
              <xsl:when test="doc-available($iconographyAL) = fn:true() and $idno">
                <xsl:value-of select="$idno//tei:term[1]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$id" />
              </xsl:otherwise>
            </xsl:choose>
          </field>
          <field name="index_item_type">
            <xsl:if test="doc-available($iconographyAL) = fn:true() and $idno">
              <xsl:choose>
                <xsl:when test="$idno/parent::tei:list[@type='christological_narrative']">
                  <xsl:text>Christological narrative scenes</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='mariological_narrative']">
                  <xsl:text>Mariological narrative scenes</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='other_compositions']">
                  <xsl:text>Other compositions</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='sacred_objects']">
                  <xsl:text>Sacred objects</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='individual_saintly_figures']">
                  <xsl:text>Individual saintly figures</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='supplicants']">
                  <xsl:text>Supplicants</xsl:text>
                </xsl:when>
                <!-- EM adding from iconography.xml -->
                
                <xsl:when test="$idno/parent::tei:list[@type='individual_figure_iconography']">
                  <xsl:text>Individual Figures</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='scenecategories']">
                  <xsl:text>Narrative Scene Categories</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='scene']">
                  <xsl:text>Narrative Scenes</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='individual_figures']">
                  <xsl:text>Individual Figures</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='individual_figure_categories']">
                  <xsl:text>Individual Figure (Categories)</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='gender']">
                  <xsl:text>Gender</xsl:text>
                </xsl:when>
                <xsl:when test="$idno/parent::tei:list[@type='structures_objects_symbols']">
                  <xsl:text>Structures - Objects - Symbols</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </field>
          <xsl:apply-templates select="current-group()" />
        </doc>
      </xsl:for-each-group>
    </add>
  </xsl:template>

  <xsl:template match="tei:rs[@type='iconography']">
    <xsl:call-template name="field_index_instance_location" />
  </xsl:template>

</xsl:stylesheet>
