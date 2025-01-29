<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
  xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />
  
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
        which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  
  <xsl:template match="//tei:term[@type='textType']" mode="facet_inscription_type">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="text_typesAL" select="'../../content/xml/authority/text_types.xml'"/>
    <field name="inscription_type">
      <xsl:choose>
        <xsl:when test="doc-available($text_typesAL) = fn:true() and document($text_typesAL)//tei:item[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($text_typesAL)//tei:item[@xml:id=$id][1]/tei:term[@xml:lang='en'][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origPlace[@ref]" mode="facet_ecclesiastical_diocese">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="locationsAL" select="'../../content/xml/authority/locations.xml'"/>
    <field name="ecclesiastical_diocese">
      <xsl:choose>
        <xsl:when test="doc-available($locationsAL) = fn:true() and document($locationsAL)//tei:place[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($locationsAL)//tei:place[@xml:id=$id][1]/tei:placeName[@type='diocese'][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origPlace[@ref]" mode="facet_administrative_district">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="locationsAL" select="'../../content/xml/authority/locations.xml'"/>
    <field name="administrative_district">
      <xsl:choose>
        <xsl:when test="doc-available($locationsAL) = fn:true() and document($locationsAL)//tei:place[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($locationsAL)//tei:place[@xml:id=$id][1]/tei:placeName[@type='district'][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origPlace[@ref]" mode="facet_monument_context">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="locationsAL" select="'../../content/xml/authority/locations.xml'"/>
    <field name="monument_context">
      <xsl:choose>
        <xsl:when test="doc-available($locationsAL) = fn:true() and document($locationsAL)//tei:place[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($locationsAL)//tei:place[@xml:id=$id][1]/tei:desc[@type='context'][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origPlace[@ref]" mode="facet_monument_function">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="locationsAL" select="'../../content/xml/authority/locations.xml'"/>
    <field name="monument_function">
      <xsl:choose>
        <xsl:when test="doc-available($locationsAL) = fn:true() and document($locationsAL)//tei:place[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($locationsAL)//tei:place[@xml:id=$id][1]/tei:desc[@type='function'][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="//tei:rs[@type='placement-building']" mode="facet_placement">
    <xsl:variable name="id" select="substring-after(@ref, '#')"/>
    <xsl:variable name="placementAL" select="'../../content/xml/authority/placement.xml'"/>
    <field name="placement">
      <xsl:choose>
        <xsl:when test="doc-available($placementAL) = fn:true() and document($placementAL)//tei:item[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($placementAL)//tei:item[@xml:id=$id][1]/tei:term[1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>  
  
  <xsl:template match="tei:rs[@key]" mode="facet_mentioned_institutions">
    <field name="mentioned_institutions">
      <xsl:value-of select="@key"/>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:persName/tei:name[@nymRef]" mode="facet_person_name">
    <field name="person_name">
      <xsl:value-of select="@nymRef"/>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:origDate" mode="facet_textual_origin_date">
    <field name="textual_origin_date">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  
  <!-- Treat both iconographic facet fields the same - they should have the same set of values. -->
  <xsl:template match="tei:rs[@type='iconography']/@ref" mode="facet_iconography">
    <xsl:variable name="id" select="substring-after(., '#')"/>
    <xsl:variable name="iconographyAL" select="'../../content/xml/authority/iconography.xml'"/>
    <field name="iconography">
     <!-- <xsl:value-of select="substring-after(., '#')"/>-->
      <xsl:choose>
      <xsl:when test="doc-available($iconographyAL) = fn:true() and document($iconographyAL)//tei:item[@xml:id=$id]">
        <xsl:value-of select="normalize-space(translate(translate(translate(document($iconographyAL)//tei:item[@xml:id=$id][1], '/', '／'), '_', ' '), '(?)', ''))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>xx </xsl:text>
        <xsl:value-of select="$id" />
      </xsl:otherwise>
      </xsl:choose>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:rs[@type='iconography']/@ref" mode="facet_iconographic_categories">
    
    <xsl:variable name="id" select="substring-after(., '#')"/>
    <xsl:variable name="iconographyAL" select="'../../content/xml/authority/iconography.xml'"/>
    <field name="iconographic_categories">
      <xsl:choose>
        <xsl:when test="doc-available($iconographyAL) = fn:true() and document($iconographyAL)//tei:item[@xml:id=$id]">
          <xsl:value-of select="normalize-space(translate(translate(translate(document($iconographyAL)//tei:item[@xml:id=$id][1], '/', '／'), '_', ' '), '(?)', ''))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>xx </xsl:text>
          <xsl:value-of select="$id" />
        </xsl:otherwise>
      </xsl:choose>
    </field>
    

  </xsl:template>
  
  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  
  <xsl:template name="extra_fields">
    <xsl:call-template name="field_inscription_type"/>
    <xsl:call-template name="field_mentioned_institutions"/>
    <xsl:call-template name="field_ecclesiastical_diocese"/>
    <xsl:call-template name="field_administrative_district"/>
    <xsl:call-template name="field_monument_context"/>
    <xsl:call-template name="field_monument_function"/>
    <xsl:call-template name="field_placement"/>
    <xsl:call-template name="field_person_name"/>
    <xsl:call-template name="field_textual_origin_date"/>
    <xsl:call-template name="field_iconography"/>
    <xsl:call-template name="field_iconographic_categories"/>
  </xsl:template>
  
  <xsl:template name="field_inscription_type">
    <xsl:apply-templates mode="facet_inscription_type" select="/tei:TEI/tei:teiHeader"/>
  </xsl:template>
  
  <xsl:template name="field_mentioned_institutions">
    <xsl:apply-templates mode="facet_mentioned_institutions" select="//tei:text/tei:body/tei:div[@type='edition']"/>
  </xsl:template>
  
  <xsl:template name="field_ecclesiastical_diocese">
    <xsl:apply-templates mode="facet_ecclesiastical_diocese" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>
  
  <xsl:template name="field_administrative_district">
    <xsl:apply-templates mode="facet_administrative_district" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>
  
  <xsl:template name="field_monument_context">
    <xsl:apply-templates mode="facet_monument_context" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>
  
  <xsl:template name="field_monument_function">
    <xsl:apply-templates mode="facet_monument_function" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace" />
  </xsl:template>
  
  <xsl:template name="field_placement">
    <xsl:apply-templates mode="facet_placement" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:supportDesc/tei:support" />
  </xsl:template>
  
  <xsl:template name="field_person_name">
    <xsl:apply-templates mode="facet_person_name" select="//tei:text/tei:body/tei:div[@type='edition']" />
  </xsl:template>
  
  <xsl:template name="field_textual_origin_date">
    <xsl:apply-templates mode="facet_textual_origin_date" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origDate" />
  </xsl:template>
  
  <xsl:template name="field_iconography">
    <xsl:apply-templates mode="facet_iconography" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:decoDesc/tei:p/tei:rs[@type='iconography']/@ref"/>
  </xsl:template>
  
  <xsl:template name="field_iconographic_categories">
    <xsl:apply-templates mode="facet_iconographic_categories" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:decoDesc/tei:p/tei:rs[@type='iconography']/@ref"/>
  </xsl:template>
  
</xsl:stylesheet>
