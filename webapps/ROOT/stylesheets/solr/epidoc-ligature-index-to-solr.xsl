<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- This XSLT transforms a set of EpiDoc documents into a Solr
       index document representing an index of abbreviations in those
       documents. -->

    <xsl:import href="epidoc-index-utils.xsl" />

    <xsl:param name="index_type" />
    <xsl:param name="subdirectory" />

    <xsl:template match="/">
        <add>
            <xsl:for-each-group select="//tei:hi[@rend='ligature'][ancestor::tei:div/@type='edition']" 
                group-by="lower-case(translate(normalize-unicode(normalize-space(string-join(.//text()[not(parent::tei:reg)],'')),'NFD'),'&#x0300;&#x0301;&#x0308;&#x0313;&#x0314;&#x0342;&#x0345; ',''))">
                <doc>
                    <field name="document_type">
                        <xsl:value-of select="$subdirectory" />
                        <xsl:text>_</xsl:text>
                        <xsl:value-of select="$index_type" />
                        <xsl:text>_index</xsl:text>
                    </field>
                    <xsl:call-template name="field_file_path" />
                    <field name="index_item_name">
                        <xsl:value-of select="current-grouping-key()"/>
                    </field>
                    <!--<field name="index_ligature">
                        <xsl:value-of select=".//text()[not(ancestor::tei:am)]"/>
                    </field>-->
                    <xsl:apply-templates select="current-group()" />
                </doc>
            </xsl:for-each-group>
        </add>
    </xsl:template>

    <xsl:template match="tei:hi">
        <xsl:call-template name="field_index_instance_location" />
    </xsl:template>

</xsl:stylesheet>
