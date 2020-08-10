<?xml version="1.0"?>
<!-- 
    This stylesheet takes an EML document that includes attribute & physical modules and creates an
    R program that can read data stored in either delimited or fixed
    text files.  The R program includes treatment of missing values, labeling and does rudimentary analyses of the
    data, including range checking. 
    
    Users of the R program need to substitute the path to their data file in the GET DATA statement.

    CHANGES Corrected header issue and added structure statement
    
    Things that still need work: 
           Multi-line data records
	   Titles and other comments with embedded newlines 
    
    Modified by John Porter, University of Virginia, 2017. 
    Modified version   Copyright 2015 University of Virginia
    original version: Copyright: 2003 Board of Reagents, Arizona State University
    
    This material is based upon work supported by the National Science Foundation 
    under Grant No. 9983132, 0080381, and 0219310. Any opinions, findings and conclusions or recommendation 
    expressed in this material are those of the author(s) and do not necessarily 
    reflect the views of the National Science Foundation (NSF).  
                  
    For Details: http://ces.asu.edu/bdi
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.
 
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
 
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:for-each select="*/dataset">
            <xsl:call-template name="dataset"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="partyName">
        <xsl:value-of select="individualName/salutation"/><xsl:text> </xsl:text> <xsl:value-of select="individualName/givenName"/> <xsl:text> </xsl:text> <xsl:value-of select="individualName/surName"/> <xsl:text> - </xsl:text>
        <xsl:value-of select="organizationName"/><xsl:text> </xsl:text>
    </xsl:template>
    
    <xsl:template name="partyNameEmail">
        <xsl:value-of select="individualName/salutation"/><xsl:text> </xsl:text> <xsl:value-of select="individualName/givenName"/> <xsl:text> </xsl:text> <xsl:value-of select="individualName/surName"/><xsl:text> - </xsl:text>
        <xsl:value-of select="positionName"/><xsl:text> </xsl:text>
        <xsl:value-of select="organizationName"/><xsl:text> </xsl:text>
        <xsl:text> - </xsl:text> <xsl:value-of select="electronicMailAddress"/>
    </xsl:template>

    <xsl:template name="dataset">
        <xsl:for-each select="../@packageId"># Package ID: <xsl:value-of
            select="../@packageId"/> Cataloging System:<xsl:value-of select="../@system"/>  <xsl:text>.</xsl:text>  
        </xsl:for-each>
        <xsl:variable name="oneLineTitle">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="title" />
                <xsl:with-param name="replace" select="'&#xA;'" />
                <xsl:with-param name="by" select="' '" />
            </xsl:call-template>
        </xsl:variable>
# Data set title: <xsl:value-of select="$oneLineTitle"/> <xsl:text>.</xsl:text>
        <xsl:for-each select="creator">
# Data set creator: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/>
        </xsl:for-each>
        <xsl:for-each select="metadataProvider">
# Metadata Provider: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/>
        </xsl:for-each>
        <xsl:for-each select="contact">
# Contact: <xsl:text></xsl:text>            
            <xsl:call-template name="partyNameEmail"/>
        </xsl:for-each>
        <xsl:if test="../access[1]/@system[. = 'https://pasta.lternet.edu']">
# Metadata Link: https://portal.lternet.edu/nis/metadataviewer?packageid=<xsl:value-of select="../@packageId"/>
        </xsl:if>
# Stylesheet for metadata conversion into program: John H. Porter, Univ. Virginia, jporter@Virginia.edu<xsl:text></xsl:text> 
#<xsl:text></xsl:text>
#install package tidyverse if not already installed<xsl:text></xsl:text>
if(!require(tidyverse)){<xsl:text/> install.packages("tidyverse")<xsl:text/> } <xsl:text/> 
library("tidyverse")<xsl:text/>
        <xsl:if test="dataTable[. !='']">
            <xsl:for-each select="dataTable">
                <!-- List attributes --><xsl:text/> 
infile<xsl:value-of select="position()"/> &lt;- trimws("<xsl:value-of select="physical/distribution/online/url"
                />"<xsl:text/>)<xsl:text/> 
infile<xsl:value-of select="position()"/> &lt;-sub("^https","http",infile<xsl:value-of select="position()"/>)<xsl:text/>
# This creates a tibble named: dt<xsl:value-of select="position()"/>
                <xsl:choose>
                    <xsl:when test="physical/dataFormat/textFormat/complex/textFixed[. !='']">
                        <xsl:call-template name="readFixed"/>
                    </xsl:when>
                    <xsl:when test="physical/dataFormat/textFormat/simpleDelimited[. !=''] ">
                        <xsl:call-template name="readCSV"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:variable name="tableNum">
                    <xsl:value-of select="position()"/>
                </xsl:variable> 
               
         <!-- Convert missing values -->
                <xsl:if test="attributeList//missingValueCode[. != '']">
                    <xsl:text>
                        
                    </xsl:text>
# Convert Missing Values to NA for individual vectors <xsl:text></xsl:text>
                </xsl:if>
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <!--change spaces to . in attribute names -->
                        <xsl:variable name="cleanAttribName">
                            <xsl:call-template name="cleanAttribNames">
                                <xsl:with-param name="text" select="attributeName" />
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:for-each select="missingValueCode">
                            <xsl:if test="code[. != '']">
dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/> &lt;- ifelse((trimws(as.character(dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/>))==trimws("<xsl:value-of select="code"/>")),NA,dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/>)<xsl:text></xsl:text>               
suppressWarnings(dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/> &lt;- ifelse(!is.na(as.numeric("<xsl:value-of select="code"/>")) &amp; (trimws(as.character(dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/>))==as.character(as.numeric("<xsl:value-of select="code"/>"))),NA,dt<xsl:value-of select="$tableNum"/>$<xsl:value-of select="$cleanAttribName"/>))<xsl:text></xsl:text>
                            </xsl:if> 
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text>
                    
                </xsl:text>
# Observed issues when reading the data. An empty list is good!
problems(dt<xsl:value-of select="$tableNum"/>)<xsl:text/> 
# Here is the structure of the input data tibble: 
glimpse(dt<xsl:value-of select="$tableNum"/>)<xsl:text/> 
# And some statistical summaries of the data 
summary(dt<xsl:value-of select="$tableNum"/>)<xsl:text/> 
# Get more details on character variables
                    <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:if test="measurementScale/nominal|measurementScale/ordinal[. != '']">
                            <xsl:variable name="cleanAttribName">
                                <xsl:call-template name="cleanAttribNames">
                                    <xsl:with-param name="text" select="attributeName"/>
                                </xsl:call-template>
                            </xsl:variable> 
summary(as.factor(dt<xsl:value-of select="$tableNum" />$<xsl:value-of select="$cleanAttribName"/>))<xsl:text/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <xsl:template name="readCSV"> 
	dt<xsl:value-of select="position()"/> &lt;-read_delim(infile<xsl:value-of select="position()"/><xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x20']"
                > ,delim=" " <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x20']"
                > ,delim=" " <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x09']"
                > ,delim="\t" <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x09']"
                > ,delim="\t" <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when
                test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='space']">
                ,delim=" " <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when
                test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='Space']">
                ,delim=" " <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when
                test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='SPACE']">
                ,delim=" " <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='tab']">
                ,delim="\t" <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='Tab']">
                ,delim="\t" <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='TAB']">
                ,delim="\t" <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x2c']"> 
                ,delim="," <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when
                test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='comma']">
                ,delim="," <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when
                test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='Comma']">
                ,delim="," <xsl:text></xsl:text>
            </xsl:when>
            <xsl:when  test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='COMMA']">
                ,delim="," <xsl:text></xsl:text>
            </xsl:when>
            <xsl:otherwise> 
                ,delim="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter"/>" <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="physical/dataFormat/textFormat/numHeaderLines[.!='']"> 
                ,skip=<xsl:value-of select="physical/dataFormat/textFormat/numHeaderLines"/><xsl:text></xsl:text>
        </xsl:if>
        <xsl:if test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.!='']">
            <xsl:choose>
                <xsl:when
                    test='physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.="&apos;"]'
                    > 
				,quote="<xsl:value-of
                        select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"
                    />"<xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.='&quot;']"
                    > 
                    ,quote='<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>'<xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise> 
                    ,quote="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>"<xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:for-each select="attributeList"> 
                    , col_names=c(<xsl:text></xsl:text>
            <xsl:for-each select="attribute">
                <!--clean bad characters in attribute names -->
                <xsl:variable name="cleanAttribName">
                    <xsl:call-template name="cleanAttribNames">
                        <xsl:with-param name="text" select="attributeName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="position()!=last()"> 
                        "<xsl:value-of select="$cleanAttribName" />", <xsl:text> </xsl:text>
                    </xsl:when>
                    <xsl:otherwise> 
                        "<xsl:value-of select="$cleanAttribName"/>" <xsl:text> </xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each> ),<xsl:text/>
        <xsl:call-template name="col_types">
            <xsl:with-param name="attributeList"/>
        </xsl:call-template>
        <!-- Now deal with missing values - if listed -->
        <xsl:call-template name="addMissingList">
            <xsl:with-param name="attributeList"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="col_types">
        <xsl:for-each select="attributeList"> 
                    col_types=list(<xsl:text/>
            <xsl:for-each select="attribute">
                <!--change spaces to . in attribute names -->
                <xsl:variable name="cleanAttribName">
                    <xsl:call-template name="cleanAttribNames">
                        <xsl:with-param name="text" select="attributeName"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="measurementScale/interval|measurementScale/ratio[. != '']">
                        col_number() <xsl:if test="position()!=last()"
                            >,<xsl:text> </xsl:text></xsl:if>
                    </xsl:when>
                    <xsl:when test="measurementScale/nominal|measurementScale/ordinal[. != '']"> 
                        col_character()<xsl:if test="position()!=last()">,<xsl:text> </xsl:text></xsl:if>
                    </xsl:when>
                    <xsl:when test="measurementScale/dateTime[. != '']">
                        <!-- Don't attempt to convert dates where the format lacks the year month and day -->
                        <xsl:choose>
                            <xsl:when test="(contains(measurementScale/dateTime/formatString,'Y') or contains(measurementScale/dateTime/formatString,'y'))and
                                (contains(measurementScale/dateTime/formatString,'M') and
                                (contains(measurementScale/dateTime/formatString,'D') or contains(measurementScale/dateTime/formatString,'d')))">
                                <xsl:choose>
                                    <xsl:when test="contains(measurementScale/dateTime/formatString,'Z')">
                        col_datetime("<xsl:call-template name="getDateFormat"><xsl:with-param name="text" select="measurementScale/dateTime/formatString"/> </xsl:call-template>",tz='UTC')<xsl:if test="position()!=last()">,</xsl:if><xsl:text>  </xsl:text>
                                    </xsl:when>
                                    <xsl:when test="contains(measurementScale/dateTime/formatString,'H') or contains(measurementScale/dateTime/formatString,'h')"> 
                        col_datetime("<xsl:call-template name="getDateFormat"><xsl:with-param name="text"  select="measurementScale/dateTime/formatString" /></xsl:call-template>")<xsl:if test="position()!=last()">,</xsl:if><xsl:text> </xsl:text>
                                        <xsl:text>
                                    </xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise> 
                        col_date("<xsl:call-template name="getDateFormat"><xsl:with-param name="text" select="measurementScale/dateTime/formatString"/></xsl:call-template>")<xsl:if test="position()!=last()">,</xsl:if><xsl:text>  </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose> 
                            </xsl:when>
                            <xsl:otherwise>
                        col_character()<xsl:if test="position()!=last()">,<xsl:text> </xsl:text></xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>                  
                        </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
        <xsl:text>),</xsl:text><xsl:text></xsl:text>
    </xsl:template>

    <xsl:template name="addMissingList">
        <xsl:for-each select="attributeList"> 
                        na=c(" ",".","NA") </xsl:for-each> )<xsl:text/>
    </xsl:template>

    <xsl:template name="readFixed">
dt<xsl:value-of select="position()"/>&lt;-read_fwf(infile<xsl:value-of select="position()"/>
            <xsl:if test="physical/dataFormat/textFormat/numHeaderLines[.!='']"> 
             ,skip=<xsl:value-of select="physical/dataFormat/textFormat/numHeaderLines"/><xsl:text/>
            </xsl:if> 
                <xsl:for-each select="attributeList">          
             ,fwf_cols(<xsl:text/>
            <xsl:for-each select="attribute">
                <!--clean bad characters in attribute names -->
                <xsl:variable name="cleanAttribName">
      <xsl:call-template name="cleanAttribNames">
              <xsl:with-param name="text" select="attributeName"/>
      </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="position()!=last()">
                        <xsl:variable name="nodeNum" select="position()"/> "<xsl:value-of
                            select="$cleanAttribName"/>" = c(<xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn"/>,<xsl:value-of
                                select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn
                            + ../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth - 1"/>), 
                        <xsl:text/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nodeNum" select="position()"/> "<xsl:value-of
                            select="$cleanAttribName"/>"=c(<xsl:value-of
                            select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn"
                            />,<xsl:value-of
                                select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn
                            + ../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth -1"
                        />)), <xsl:text></xsl:text>
                        <xsl:text/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            </xsl:for-each>
        
<xsl:call-template name="col_types">
            <xsl:with-param name="attributeList"/>
</xsl:call-template>
<xsl:call-template name="addMissingList">
    <xsl:with-param name="attributeList"/>
</xsl:call-template>

    </xsl:template>


    <xsl:template name="cleanAttribNames">
        <xsl:param name="text"/>
        <xsl:variable name="a1">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$text"/>
                <xsl:with-param name="replace" select="' '"/>
                <xsl:with-param name="by" select="'.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a2">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a1"/>
                <xsl:with-param name="replace" select="'('"/>
                <xsl:with-param name="by" select="'.paren.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a3">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a2"/>
                <xsl:with-param name="replace" select="')'"/>
                <xsl:with-param name="by" select="'.paren.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a4">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a3"/>
                <xsl:with-param name="replace" select="'%'"/>
                <xsl:with-param name="by" select="'.percent.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a5">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a4"/>
                <xsl:with-param name="replace" select="'/'"/>
                <xsl:with-param name="by" select="'.per.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a6">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a5"/>
                <xsl:with-param name="replace" select="'+'"/>
                <xsl:with-param name="by" select="'.plus.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a7">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a6"/>
                <xsl:with-param name="replace" select="'-'"/>
                <xsl:with-param name="by" select="'.hyphen.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a8">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a7"/>
                <xsl:with-param name="replace" select="'*'"/>
                <xsl:with-param name="by" select="'.astrix.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a9">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a8"/>
                <xsl:with-param name="replace" select="'^'"/>
                <xsl:with-param name="by" select="'.carat.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a10">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a9"/>
                <xsl:with-param name="replace" select="'_'"/>
                <xsl:with-param name="by" select="'_'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a11">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a10"/>
                <xsl:with-param name="replace" select="'['"/>
                <xsl:with-param name="by" select="'.bracket.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a12">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a11"/>
                <xsl:with-param name="replace" select="']'"/>
                <xsl:with-param name="by" select="'.bracket.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a13">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a12"/>
                <xsl:with-param name="replace" select="':'"/>
                <xsl:with-param name="by" select="'.colon.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a14">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$a13"/>
                <xsl:with-param name="replace" select="';'"/>
                <xsl:with-param name="by" select="'.semicolon.'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="a15">
            <xsl:call-template name="string-add-v-to-leading-numbers">
                <xsl:with-param name="text" select="$a14"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$a15"/>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text,$replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text,$replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="string-add-v-to-leading-numbers">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains('0123456789', substring($text,1,1))">
                  <xsl:value-of select="concat('v_',$text)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getDateFormat">
        <xsl:param name="text"/>
        <xsl:variable name="d1">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$text" />
                <xsl:with-param name="replace" select="'YYYY'" />
                <xsl:with-param name="by" select="'%Y'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d2">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d1" />
                <xsl:with-param name="replace" select="'yyyy'" />
                <xsl:with-param name="by" select="'%Y'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d3">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d2" />
                <xsl:with-param name="replace" select="'yy'" />
                <xsl:with-param name="by" select="'%y'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d4">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d3" />
                <xsl:with-param name="replace" select="'YY'" />
                <xsl:with-param name="by" select="'%y'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d5">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d4" />
                <xsl:with-param name="replace" select="'MM'" />
                <xsl:with-param name="by" select="'%m'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d6">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d5" />
                <xsl:with-param name="replace" select="'dd'" />
                <xsl:with-param name="by" select="'%d'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d7">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d6" />
                <xsl:with-param name="replace" select="'DD'" />
                <xsl:with-param name="by" select="'%d'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d8">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d7" />
                <xsl:with-param name="replace" select="'hh'" />
                <xsl:with-param name="by" select="'%H'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d9">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d8" />
                <xsl:with-param name="replace" select="'HH'" />
                <xsl:with-param name="by" select="'%H'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d10">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d9" />
                <xsl:with-param name="replace" select="'mm.mm'" />
                <xsl:with-param name="by" select="'%M'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d11">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d10" />
                <xsl:with-param name="replace" select="'mm'" />
                <xsl:with-param name="by" select="'%M'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d12">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d11" />
                <xsl:with-param name="replace" select="'ss.sss'" />
                <xsl:with-param name="by" select="'%S'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d13">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d12" />
                <xsl:with-param name="replace" select="'ss'" />
                <xsl:with-param name="by" select="'%S'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d14">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d13" />
                <xsl:with-param name="replace" select="'www'" />
                <xsl:with-param name="by" select="'%b'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d15">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d14" />
                <xsl:with-param name="replace" select="'WWW'" />
                <xsl:with-param name="by" select="'%b'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d16">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d15" />
                <xsl:with-param name="replace" select="'A/P'" />
                <xsl:with-param name="by" select="'%p'" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d17">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d16" />
                <xsl:with-param name="replace" select="'Z'" />
                <xsl:with-param name="by" select="''" />
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d18">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d17"/>
                <xsl:with-param name="replace" select="'MON'"/>
                <xsl:with-param name="by" select="'%b'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="d19">
            <xsl:call-template name="string-replace-all">
                <xsl:with-param name="text" select="$d18"/>
                <xsl:with-param name="replace" select="'mon'"/>
                <xsl:with-param name="by" select="'%b'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$d19"/>
    </xsl:template>
</xsl:stylesheet>
