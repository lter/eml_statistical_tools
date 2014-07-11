<?xml version="1.0"?>
<!-- 
    This stylesheet takes an EML document that includes attribute & physical modules and creates an
    SAS (Statistical Analysis System) program that can read data stored in either delimited or fixed
    text files.  The SAS program includes treatment of missing values, labeling and does rudimentary analyses of the
    data, including range checking. 
    
    Users of the SAS program need to substitute the path to their data file in the INFILE statement.
    
    Things that still need work: 
           Multi-line data records
    
    Modified by John Porter, University of Virginia, 2005. 
    Modified version   Copyright 2005 University of Virginia
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
        <xsl:value-of select="individualName/salutation"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="individualName/givenName"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="individualName/surName"/>
        <xsl:text> - </xsl:text>
        <xsl:value-of select="organizationName"/>
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template name="partyNameEmail">
        <xsl:value-of select="individualName/salutation"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="individualName/givenName"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="individualName/surName"/>
        <xsl:text> - </xsl:text>
        <xsl:value-of select="positionName"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="organizationName"/>
        <xsl:text> </xsl:text>
        <xsl:text> - </xsl:text>
        <xsl:value-of select="electronicMailAddress"/>
    </xsl:template>
    <xsl:template name="infile_stmt"> 
infile 'PUT-LOCAL-PATH-TO-DATA-FILE-HERE' <xsl:text/>
        <xsl:choose>
            <xsl:when test="physical/dataFormat/textFormat/complex/textFixed[. !='']">
                TRUNCOVER<xsl:text/>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x20']"
                > delimiter=" " TRUNCOVER DSD lrecl=32767<xsl:text/>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x20']"
                > delimiter=" " TRUNCOVER DSD lrecl=32767<xsl:text/>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x09']"
                > delimiter='09'x TRUNCOVER DSD lrecl=32767<xsl:text/>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x09']"
                > delimiter='09'x TRUNCOVER DSD lrecl=32767<xsl:text/>
            </xsl:when>
            <xsl:otherwise> delimiter="<xsl:value-of
                    select="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter"/>"
                TRUNCOVER DSD lrecl=32767<xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="physical/dataFormat/textFormat/numHeaderLines[.>0]">
                    firstobs=<xsl:value-of select="physical/dataFormat/textFormat/numHeaderLines + 1"/><xsl:text/>
            </xsl:when>
        </xsl:choose>
        <xsl:text>;</xsl:text>
    </xsl:template>
    <xsl:template name="dataset">
        <xsl:for-each select="../@packageId">* Package ID: <xsl:value-of select="../@packageId"/> <xsl:text>;</xsl:text>
* Cataloging System:<xsl:value-of select="../@system"/>
            <xsl:text>;</xsl:text>
        </xsl:for-each> 
* Data set title: <xsl:value-of select="title"/>
        <xsl:text>;</xsl:text>
        <xsl:for-each select="creator"> 
* Data set creator: <xsl:text/>
            <xsl:call-template name="partyName"/><xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="metadataProvider"> 
* Metadata Provider: <xsl:text/>
            <xsl:call-template name="partyName"/><xsl:text>;</xsl:text>
        </xsl:for-each>
        <xsl:for-each select="contact"> 
* Contact: <xsl:text/>
            <xsl:call-template name="partyNameEmail"/><xsl:text>;</xsl:text>
        </xsl:for-each> 
        
Title1 ' <xsl:value-of select="title"/>' <xsl:text>;</xsl:text>
        
        <xsl:if test="dataTable[. !='']">
            <xsl:for-each select="dataTable">
                <!-- List attributes --><xsl:text/> 
/* You should replace  'PUT-LOCAL-PATH-TO-DATA-FILE-HERE' (below) with the appropriate path; <xsl:text/> 
    to your data file (e.g., c:\mydata\datafile.txt). If you want to create a permanent SAS dataset, replace the WORK. specification <xsl:text/> 
    in the DATA statement (and SET statement in section for range checking) with a valid SAS Library reference. */<xsl:text/> 
DATA WORK.data<xsl:value-of select="position()"/><xsl:text>;</xsl:text> 
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */<xsl:text/>
                <xsl:call-template name="infile_stmt"/> 
input                        <xsl:text> </xsl:text>      
                <xsl:for-each select="attributeList">

                    <xsl:for-each select="attribute">
                        <xsl:choose>
                            <xsl:when test="../../physical/dataFormat/textFormat/complex/textFixed[.!='']">
                                <xsl:variable name="nodeNum" select="position()"/>
                                <xsl:if  test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth[.> 0]"> 
                                    @<xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn" /><xsl:text> </xsl:text>
                                </xsl:if>
                                <xsl:value-of select="attributeName"/>
                                <xsl:text> </xsl:text>
                                <xsl:if test="(storageType = 'varchar') or (storageType = 'string')  or (starts-with(storageType,'char'))">
                                    <xsl:text> $ </xsl:text>
                                    <xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth"/>. <xsl:text/>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="attributeName"/><xsl:text> 
                                </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="(starts-with(storageType,'int')) or (storageType = 'byte')">
                                <xsl:variable name="nodeNum" select="position()"/>
                                <xsl:choose>
                                    <xsl:when test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth[.> 0]">
                                        <xml:text> </xml:text>
                                        <xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth"/><xsl:text>.</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text> </xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>  </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text>;</xsl:text> 
if _ERROR_ then call symputx('_EFIERR_',1); /* set ERROR detection macro variable */ <xsl:text/> 
 <xsl:text/>
                <!-- Set missing value codes -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:for-each select="missingValueCode">
                            <xsl:if test="code[. !=' ']"> 
IF (<xsl:value-of select="../attributeName"/> EQ <xsl:value-of select="code"/>) THEN <xsl:value-of select="../attributeName"/>= . ; <xsl:text/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text/>
                <!-- Now lets list out the variable labels -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:if test="attributeLabel[. != '']"> 
LABEL <xsl:value-of select="attributeName"/> ='<xsl:value-of select="attributeLabel"/>-<xsl:value-of select="measurementScale/*/unit/*"/>' <xsl:text>;</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text/>
                
                
                <!-- List out the Value Labels (if data uses codes) -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:if test="measurementScale/nominal[. != '']">
                            <xsl:if  test="measurementScale/nominal/nonNumericDomain/enumeratedDomain[.!= '']"> 
/* Codes for <xsl:value-of select="attributeName"/> <xsl:text> are: </xsl:text>
                                <xsl:for-each select="measurementScale/nominal/nonNumericDomain/enumeratedDomain/codeDefinition">
                                    <xsl:if test="code[. !='']"> 
                                        '<xsl:value-of select="code"/>'   '<xsl:value-of select="definition"/>' <xsl:text> </xsl:text>
                                    </xsl:if>
                                </xsl:for-each>
                                <xsl:text>.</xsl:text> 
*/ 
                            </xsl:if>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:text>
run;
                </xsl:text>
                
                
/* The analyses below are basic descriptions of the variables.
   After testing, they should be replaced. */
                <!--  Generate some default statistical summaries for nominal variables -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:if test="measurementScale/nominal|measurementScale/ordinal[. != '']">
PROC FREQ; <xsl:text></xsl:text>
      TABLES  <xsl:value-of select="attributeName"/><xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <!--  Generate some default statistical summaries for continuous variables -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">
                        <xsl:if
                            test="measurementScale/interval|measurementScale/ratio|measurementScale/datetime[.!= '']"> 
PROC MEANS; <xsl:text></xsl:text>
        VAR <xsl:value-of select="attributeName"/><xsl:text> ; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
RUN;
                <!-- Generate range checks and list bad cases --> 
TITLE2 'Observations with one or more out of range values'; <xsl:text/>
DATA bad<xsl:value-of select="position()"/><xsl:text>;</xsl:text>
SET WORK.data<xsl:value-of select="position()"/><xsl:text>;</xsl:text> 
* List cases where data is out of range<xsl:text>;</xsl:text>
* Note: if no out of range cases are detected, the variable names will be listed, but no actual cases<xsl:text>;</xsl:text> 
LENGTH BADVARS $ 255<xsl:text>;</xsl:text>
<xsl:call-template name="rangecheck"/> 
IF (BADVARS NE '')<xsl:text>;</xsl:text> 
PROC PRINT data=bad<xsl:value-of select="position()"/>; <xsl:text/>
RUN; <xsl:text/>
</xsl:for-each>
        </xsl:if>
    </xsl:template>
    <xsl:template name="rangecheck">
        <xsl:for-each select="attributeList">
            <xsl:for-each select="attribute">
                <xsl:if test="measurementScale/*/numericDomain/bounds/minimum[.!='']"> 
IF ((<xsl:value-of select="attributeName"/> NE .) AND (<xsl:value-of select="attributeName"/> LT <xsl:value-of select="measurementScale/*/numericDomain/bounds/minimum"/>)) THEN BADVARS=CAT(TRIM(BADVARS),' <xsl:value-of select="attributeName"  />-min')<xsl:text>;</xsl:text>
                </xsl:if>
                <xsl:if test="measurementScale/*/numericDomain/bounds/maximum[.!='']"> 
IF ((<xsl:value-of select="attributeName"/> NE .) AND (<xsl:value-of select="attributeName"/> GT <xsl:value-of  select="measurementScale/*/numericDomain/bounds/maximum"/>)) THEN BADVARS=CAT(TRIM(BADVARS),' <xsl:value-of select="attributeName"  />-max')<xsl:text>;</xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
