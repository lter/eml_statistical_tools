<?xml version="1.0"?>
<!-- 
    This stylesheet takes an EML document that includes attribute & physical modules and creates an
    SPSS (Statistical Package for the Social Sciences) program that can read data stored in either delimited or fixed
    text files.  The SPSS program includes treatment of missing values, labeling and does rudimentary analyses of the
    data, including range checking. 
    
    Users of the SPSS program need to substitute the path to their data file in the GET DATA statement.
    
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
        <xsl:for-each select="../@packageId">Comment Package ID: <xsl:value-of
            select="../@packageId"/> Cataloging System:<xsl:value-of select="../@system"/>  <xsl:text>.</xsl:text>  
        </xsl:for-each>
Comment Data set title: <xsl:value-of select="title"/> <xsl:text>.</xsl:text>
        <xsl:for-each select="creator">
Comment  Data set creator: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/> .
        </xsl:for-each>
        <xsl:for-each select="metadataProvider">
Comment  Metadata Provider: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/> .
        </xsl:for-each>
        <xsl:for-each select="contact">
Comment  Contact: <xsl:text></xsl:text>            
            <xsl:call-template name="partyNameEmail"/> .
        </xsl:for-each>
        
        
Title ' <xsl:value-of select="title"/>' <xsl:text>.</xsl:text>
        <xsl:if test="dataTable[. !='']">
            <xsl:for-each select="dataTable">
                <!-- List attributes --><xsl:text/> 

Comment You should replace 'PUT-PATH-TO-DATA-FILE<xsl:value-of select="position()"/>-HERE'  (below) with the appropriate path. <xsl:text/>  
Comment    to your data file (e.g., c:\mydata\datafile.txt). <xsl:text/>  
                <xsl:if test="physical/distribution/online/url[. !='']"> .
Comment Data can be found online at: <xsl:value-of select="physical/distribution/online/url"/> <xsl:text>       . </xsl:text>
                    <xsl:text> </xsl:text>   
                </xsl:if>                    
GET DATA  /TYPE=TXT/
/ FILE="PUT-PATH-TO-DATA-FILE<xsl:value-of select="position()"/>-HERE" <xsl:text></xsl:text>
                <xsl:choose>
                    <xsl:when test="physical/dataFormat/textFormat/numHeaderLines[.>0]">
                        /FIRSTCASE=<xsl:value-of select="physical/dataFormat/textFormat/numHeaderLines + 1"/><xsl:text></xsl:text>
                    </xsl:when>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="physical/dataFormat/textFormat/complex/textFixed[. !='']">
                        /ARRANGEMENT=Fixed<xsl:text> </xsl:text> 
                    </xsl:when>
                    <xsl:when test="physical/dataFormat/textFormat/simpleDelimited[. !=''] ">
                        /ARRANGEMENT=Delimited<xsl:text> </xsl:text>
                        <xsl:choose>
                            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x20']">
                                /DELIMITERS=" " <xsl:text/>
                            </xsl:when>
                            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x20']">
                                /DELIMITERS=" " <xsl:text/>
                            </xsl:when>
                            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x09']">
                                /DELIMITERS="\t" <xsl:text/>
                            </xsl:when>
                            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x09']">
                                /DELIMITERS="\t" <xsl:text/>
                            </xsl:when>
                            <xsl:otherwise>
                              /DELIMITERS="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter"/>" <xsl:text> </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
			
                        <xsl:if test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.!='']">
                            <xsl:choose>
                                <xsl:when test='physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.="&apos;"]'>
                                    /QUALIFIER="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>"<xsl:text> </xsl:text>
                                </xsl:when>
                                <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.='&quot;']">
                                    /QUALIFIER='<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>'<xsl:text> </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    /QUALIFIER="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>"<xsl:text> </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                <xsl:for-each select="attributeList">
                    /VARIABLES= 
                    <xsl:for-each select="attribute">
                        <xsl:value-of select="attributeName"/>   <xsl:text> </xsl:text>
                        <xsl:if test="../../physical/dataFormat/textFormat/complex/textFixed[. !='']">
                            <xsl:variable name="nodeNum" select="position()"/>
                            <xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn - 1"/><xsl:text>-</xsl:text>
                            <xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth + ../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn - 2" /> 
                        </xsl:if>
                        <xsl:choose>
                            <xsl:when test="(starts-with(storageType, 'varchar')) or (starts-with(storageType,'string')) or (starts-with(storageType,'char'))">
                                <xsl:text> A </xsl:text>
                             </xsl:when>
                            <xsl:when test="(starts-with(storageType,'int')) or (storageType = 'byte')">
                                <xsl:variable name="nodeNum" select="position()"/>
                                <xsl:choose>
                                    <xsl:when test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth[. > 0]">
                                       <xml:text> F</xml:text><xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth"></xsl:value-of><xsl:text>.0</xsl:text>                                 
                                    </xsl:when>
                                    <xsl:otherwise>
                                       <xsl:text> F10.2</xsl:text>
                                    </xsl:otherwise>
                                 </xsl:choose>
                             </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> F </xsl:text>
                            </xsl:otherwise>                           
                        </xsl:choose>
                        <xsl:text> </xsl:text> 
                    </xsl:for-each> 
                </xsl:for-each>
                <xsl:text>.</xsl:text>
execute.                
                
<!-- Set missing value codes -->
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <xsl:if test="missingValueCode[. != '']">
MISSING VALUES  <xsl:value-of select="attributeName"/> <xsl:for-each select="missingValueCode/code">
    <xsl:if test="position()= 1">(</xsl:if>
    <xsl:text>'</xsl:text><xsl:value-of select="."/><xsl:text>'</xsl:text>
    <xsl:if test="position()!=last()">,</xsl:if>
    <xsl:if test="position()=last()">)</xsl:if>
    </xsl:for-each><xsl:text>.</xsl:text> 
                        </xsl:if>  
                    </xsl:for-each> 
                </xsl:for-each> 
               

 <!-- Now lets list out the variable labels -->
<xsl:for-each select="attributeList">
                <xsl:for-each select="attribute">  
                   <xsl:if test="attributeLabel[. != '']">
VAR LABELS   <xsl:value-of select="attributeName"/> '<xsl:value-of select="attributeLabel"/>- <xsl:value-of select="measurementScale/*/unit/*"/>' <xsl:text>.</xsl:text> 
                    </xsl:if>  
                </xsl:for-each> 
</xsl:for-each>
 
<!-- List out the Value Labels (if data uses codes) -->                
        <xsl:for-each select="attributeList">
            <xsl:for-each select="attribute">  
                <xsl:if test="measurementScale/nominal[. != '']">
                    <xsl:if test="measurementScale/nominal/nonNumericDomain/enumeratedDomain[. != '']">
VALUE LABELS   <xsl:value-of select="attributeName"/> <xsl:text> </xsl:text>   
                          <xsl:for-each select="measurementScale/nominal/nonNumericDomain/enumeratedDomain/codeDefinition">
                              <xsl:if test="code[. !='']">
                                  '<xsl:value-of select="code"/>'  '<xsl:value-of select="definition"/>' <xsl:text> </xsl:text>
                              </xsl:if>
                          </xsl:for-each>
                     <xsl:text>.</xsl:text>
                    </xsl:if>
                  </xsl:if>  
            </xsl:for-each>
        </xsl:for-each>
                
                
Comment The analyses below are basic descriptions of the variables. After testing, they should be replaced.                 
 <!--  Generate some default statistical summaries for nominal variables -->       
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <xsl:if test="measurementScale/nominal|measurementScale/ordinal[. != '']"> 
Frequencies   variables=<xsl:value-of select="attributeName"/> <xsl:text> /order=analysis. </xsl:text>               
                        </xsl:if> 
                    </xsl:for-each>
                </xsl:for-each>
<!--  Generate some default statistical summaries for continuous variables -->       
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <xsl:if test="measurementScale/interval|measurementScale/ratio|measurementScale/datetime[. != '']"> 
Descriptives   variables=<xsl:value-of select="attributeName"/> <xsl:text> . </xsl:text>               
                        </xsl:if> 
                    </xsl:for-each>
                </xsl:for-each>
Execute. 
                
                <!-- Generate range checks and list bad cases -->  
Comment List cases where data is out of range<xsl:text>.</xsl:text>  
Comment Note: if no out of range cases are detected, the variable names will be listed, but no actual cases<xsl:text>.</xsl:text>  
TEMPORARY <xsl:text>.</xsl:text>               
STRING BADVARS (A255)<xsl:text>.</xsl:text>
                <xsl:call-template name="rangecheck"/>
SELECT IF (BADVARS NE "")<xsl:text>.</xsl:text> 
LIST VARIABLES=ALL.
Execute.                 
        </xsl:for-each>
     </xsl:if>  
        </xsl:template>

    <xsl:template name="rangecheck">
          <xsl:for-each select="attributeList">
              <xsl:for-each select="attribute">
                  <xsl:if  test="measurementScale/*/numericDomain/bounds/minimum[.!='']">
IF ((NOT MISSING(<xsl:value-of select="attributeName"/>)) AND (<xsl:value-of select="attributeName"/> LT <xsl:value-of select="measurementScale/*/numericDomain/bounds/minimum"/>)) BADVARS=CONCAT(RTRIM(BADVARS)," ", "<xsl:value-of select="attributeName"/>","-min")<xsl:text>.</xsl:text>
                  </xsl:if>           
                  <xsl:if  test="measurementScale/*/numericDomain/bounds/maximum[.!='']">
IF ((NOT MISSING(<xsl:value-of select="attributeName"/>)) AND (<xsl:value-of select="attributeName"/> GT <xsl:value-of select="measurementScale/*/numericDomain/bounds/maximum"/>)) BADVARS=CONCAT(RTRIM(BADVARS)," ", "<xsl:value-of select="attributeName"/>","-max")<xsl:text>.</xsl:text>
                  </xsl:if>          
              </xsl:for-each>
          </xsl:for-each>
    </xsl:template>     
</xsl:stylesheet>
