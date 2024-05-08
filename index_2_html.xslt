<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" version="1.0">

    <xsl:output method="xml"/>
    <xsl:template match="/">
        
        <div>            
            <xsl:for-each select="//w">
                <option>
                    <xsl:attribute name="class">opWordList_<xsl:value-of select="@index"/></xsl:attribute>
                    <xsl:choose>
                    	<xsl:when test="@lemma"><xsl:value-of select="@lemma"/></xsl:when>
                    	<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                    </xsl:choose>
                </option>    
            </xsl:for-each>
         </div>
      
    </xsl:template>
</xsl:stylesheet>
