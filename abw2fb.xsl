<?xml version="1.0" encoding="UTF-8"?>
<!--
 | XSLT converter from AbiWord 2.4.6 (.abw) to FictionBook 2.0 (.fb2)
 | Version 0.22 beta
 | Author: Romanovich Vladimir T. <ibnteo@gmail.com>
 +-->
<xsl:stylesheet
        xmlns="http://www.gribuser.ru/xml/fictionbook/2.0"
        xmlns:xlink="http://www.w3.org/1999/xlink"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:fo="http://www.w3.org/1999/XSL/Format"
        xmlns:abw="http://www.abisource.com/awml.dtd"
        version="1.0">
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>

    <xsl:template match="/abw:abiword">
        <FictionBook>
            <description>
                <title-info>
                    <genre/>
                    <author>
                        <first-name/>
                        <middle-name/>
                        <last-name/>
                        <home-page/>
                        <email/>
                    </author>
                    <book-title/>
                    <annotation/>
                    <date value="{substring-before(abw:metadata/abw:m[@key='dc.date'],'T')}">
                        <xsl:value-of select="substring-before(abw:metadata/abw:m[@key='dc.date'],'-')"/>
                    </date>
                    <lang>
                        <xsl:value-of select="substring-before(abw:metadata/abw:m[@key='dc.language'],'-')"/>
                    </lang>
                </title-info>
                <document-info>
                    <author>
                        <first-name/>
                        <middle-name/>
                        <last-name/>
                        <home-page/>
                        <email/>
                    </author>
                    <program-used>XSLT abw2fb</program-used>
                    <date value="{substring-before(abw:metadata/abw:m[@key='abiword.date_last_changed'],'T')}">
                        <xsl:value-of select="substring-before(abw:metadata/abw:m[@key='abiword.date_last_changed'],'-')"/>
                    </date>
                    <version>
                        <xsl:value-of select="abw:history/@version"/>
                    </version>
                </document-info>
            </description>
            <body>
                <xsl:apply-templates select="abw:section" mode="body"/>
            </body>
            <!--
            <body name="notes">
            </body>
            -->
            <xsl:apply-templates select="abw:data/abw:d" mode="binary"/>
        </FictionBook>
    </xsl:template>


    <xsl:template match="abw:section" mode="body">
        <xsl:apply-templates select="abw:p[contains(@style, 'Heading')][1]" mode="heading"/>
    </xsl:template>


    <xsl:template match="abw:p" mode="heading">
        <section>
            <title>
                <p>
                    <xsl:apply-templates select="*|text()" mode="p"/>
                </p>
            </title>
            <xsl:choose>
            	<xsl:when test="abw:p[following-sibling::abw:p[1][not(contains(@style, 'Heading'))] and following-sibling::abw:p[contains(@style, 'Heading')][1][number(substring-after(@style, ' ')) &gt; number(substring-after(current()/@style, ' '))]]">
			        <section>
			            <xsl:apply-templates select="following-sibling::abw:p[1][not(contains(@style, 'Heading'))]" mode="section"/>
			        </section>
            	</xsl:when>
            	<xsl:otherwise>
			        <xsl:apply-templates select="following-sibling::abw:p[1][not(contains(@style, 'Heading'))]" mode="section"/>
            	</xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="following-sibling::abw:p[contains(@style, 'Heading')][1][number(substring-after(@style, ' ')) &gt; number(substring-after(current()/@style, ' '))]" mode="heading"/>
        </section>
        <xsl:apply-templates select="following-sibling::abw:p[contains(@style, 'Heading')][number(substring-after(@style, ' ')) &lt;= number(substring-after(current()/@style, ' '))][1][number(substring-after(@style, ' ')) = number(substring-after(current()/@style, ' '))]" mode="heading"/>
        <xsl:if test="not(preceding-sibling::abw:p[contains(@style, 'Heading')][number(substring-after(@style, ' ')) &lt; number(substring-after(current()/@style, ' '))])">
            <xsl:apply-templates select="following-sibling::abw:p[contains(@style, 'Heading')][number(substring-after(@style, ' ')) &lt; number(substring-after(current()/@style, ' '))][1]" mode="heading"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="*" mode="section"/>

    <xsl:template match="abw:p" mode="section">
        <p>
            <xsl:apply-templates select="*|text()" mode="paragraph"/>
        </p>
        <xsl:apply-templates select="following-sibling::*[1][not(contains(@style, 'Heading'))]" mode="section"/>
    </xsl:template>

    <xsl:template match="abw:table" mode="section">
        <xsl:apply-templates select="abw:cell/abw:p" mode="section"/>
        <xsl:apply-templates select="following-sibling::*[1][not(contains(@style, 'Heading'))]" mode="section"/>
    </xsl:template>

    <xsl:template match="abw:p[contains(@props, 'font-weight:bold')]" mode="section">
        <p>
            <strong>
                <xsl:apply-templates select="*|text()" mode="paragraph"/>
            </strong>
        </p>
        <xsl:apply-templates select="following-sibling::abw:p[1][not(contains(@style, 'Heading'))]" mode="section"/>
    </xsl:template>


    <xsl:template match="*|text()" mode="paragraph">
        <xsl:apply-templates select="*|text()" mode="paragraph"/>
    </xsl:template>

    <xsl:template match="abw:c[contains(@props, 'font-weight:bold')]" mode="paragraph">
        <strong>
            <xsl:apply-templates select="*|text()" mode="paragraph"/>
        </strong>
    </xsl:template>

    <xsl:template match="abw:c[contains(@props, 'font-style:italic')]" mode="paragraph">
        <emphasis>
            <xsl:apply-templates select="*|text()" mode="paragraph"/>
        </emphasis>
    </xsl:template>
    
    <xsl:template match="abw:c[contains(@props, 'text-position:superscript')]" mode="paragraph">
        <xsl:text>^</xsl:text>
        <xsl:apply-templates select="*|text()" mode="paragraph"/>
    </xsl:template>

    <xsl:template match="abw:c[contains(@props, 'text-position:subscript')]" mode="paragraph">
        <xsl:text>_</xsl:text>
        <xsl:apply-templates select="*|text()" mode="paragraph"/>
    </xsl:template>

    <xsl:template match="text()" mode="paragraph">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="abw:br" mode="paragraph">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="abw:image" mode="paragraph">
        <image xlink:href="#{@dataid}"/>
    </xsl:template>


    <xsl:template match="abw:d" mode="binary">
        <binary id="{@name}" content-type="{@mime-type}">
            <xsl:value-of select="."/>
        </binary>
    </xsl:template>
</xsl:stylesheet>