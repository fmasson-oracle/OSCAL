<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math sch doc"
    version="3.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:doc="https://fedramp.gov/oscal/fedramp-automation-documentation"
    xpath-default-namespace="http://purl.oclc.org/dsdl/schematron">
    <xsl:output
        method="text" />
    <xsl:template
        match="/">
        <!-- define a variable for the input (Schematron) document -->
        <!-- because subsequent contexts are strings -->
        <xsl:variable
            name="sch"
            as="document-node()"
            select="current()" />
        <!-- declare the distinct attribute names -->
        <xsl:variable
            name="groups"
            as="xs:string*"
            select="distinct-values(//(assert | report)/@doc:* ! local-name())" />
        <!-- create the proto-JSON XML -->
        <xsl:variable
            name="xml"
            as="node()">
            <!-- the outermost structure is an array -->
            <array
                xmlns="http://www.w3.org/2005/xpath-functions">
                <!-- iterate over the various attribute names -->
                <xsl:for-each
                    select="$groups">
                    <!-- preserve the current context as it will be occluded -->
                    <xsl:variable
                        name="attribute-local-name"
                        as="xs:string"
                        select="current()" />
                    <!-- create a grouping -->
                    <map>
                        <string
                            key="title">
                            <xsl:text expand-text="true">FedRAMP {$attribute-local-name} assertion view</xsl:text>
                        </string>
                        <!-- get the distinct values found in this attribute -->
                        <xsl:variable
                            name="groupitems"
                            as="xs:string*"
                            select="distinct-values($sch//@doc:*[local-name() eq $attribute-local-name])" />
                        <!-- create a list of related assertions for each distinct attribute value-->
                        <array
                            key="groups">
                            <xsl:for-each
                                select="$groupitems">
                                <xsl:variable
                                    name="item"
                                    as="xs:string"
                                    select="current()" />
                                <map>
                                    <string
                                        key="title">
                                        <xsl:value-of
                                            select="current()" />
                                    </string>
                                    <array
                                        key="assertionIds">
                                        <xsl:for-each
                                            select="$sch//(assert | report)">
                                            <xsl:choose>
                                                <xsl:when
                                                    test="@doc:* = $item">
                                                    <string>
                                                        <xsl:value-of
                                                            select="@id" />
                                                    </string>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:for-each>
                                    </array>
                                </map>
                            </xsl:for-each>
                        </array>
                    </map>
                </xsl:for-each>
            </array>
        </xsl:variable>
        <!-- output the equivalent JSON -->
        <xsl:copy-of
            select="xml-to-json($xml)" />
    </xsl:template>
</xsl:stylesheet>