<?xml version="1.0"?>
<!-- 
    This stylesheet takes an EML document that includes attribute & physical modules and creates an
    R program that can read data stored in either delimited or fixed
    text files.  The R program includes treatment of missing values, labeling and does rudimentary analyses of the
    data, including range checking. 
    
    Users of the R program need to substitute the path to their data file in the GET DATA statement.
    
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
        <xsl:for-each select="../@packageId"># Package ID: <xsl:value-of
            select="../@packageId"/> Cataloging System:<xsl:value-of select="../@system"/>  <xsl:text>.</xsl:text>  
        </xsl:for-each>
# Data set title: <xsl:value-of select="title"/> <xsl:text>.</xsl:text>
        <xsl:for-each select="creator">
# Data set creator: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/>
        </xsl:for-each>
        <xsl:for-each select="metadataProvider">
#  Metadata Provider: <xsl:text></xsl:text>            
            <xsl:call-template name="partyName"/>
        </xsl:for-each>
        <xsl:for-each select="contact">
#  Contact: <xsl:text></xsl:text>            
            <xsl:call-template name="partyNameEmail"/>
        </xsl:for-each>
        <xsl:if test="dataTable[. !='']">
            <xsl:for-each select="dataTable">
                <!-- List attributes --><xsl:text/> 
# You should replace 'PUT-LOCAL-PATH-TO-DATA-FILE-HERE'  (below) with the appropriate path. <xsl:text/>  
#   to your data file (e.g., c:\mydata\datafile.txt). <xsl:text/>                        
infile<xsl:value-of select="position()"/>  &lt;- file("PUT-LOCAL-PATH-TO-DATA-FILE-HERE", open="r") <xsl:text></xsl:text> 
                <xsl:choose>
                    <xsl:when test="physical/dataFormat/textFormat/complex/textFixed[. !='']">
                        <xsl:call-template name="readFixed"></xsl:call-template>
                    </xsl:when>
                    <xsl:when test="physical/dataFormat/textFormat/simpleDelimited[. !=''] ">
                        <xsl:call-template name="readCSV"></xsl:call-template>
                    </xsl:when>
                    </xsl:choose>
               

 <!-- Now lets list out the variable labels to a different data table -->
tmp_var &lt;- character()<xsl:text></xsl:text>
tmp_label &lt;- character()<xsl:text></xsl:text>
<xsl:for-each select="attributeList">                  
                <xsl:for-each select="attribute">  
                   <xsl:if test="attributeLabel[. != '']">
                       tmp_var &lt;- c(tmp_var , "<xsl:value-of select="attributeName"/>") <xsl:text></xsl:text>
                       tmp_label &lt;- c(tmp_label , "<xsl:value-of select="attributeLabel"/>- <xsl:value-of select="measurementScale/*/unit/*"/>")<xsl:text></xsl:text>
                    </xsl:if>  
                </xsl:for-each> 
</xsl:for-each>
labelFrame<xsl:value-of select="position()"/>&lt;-data.frame(variable=tmp_var, label=tmp_label)<xsl:text></xsl:text>
rm(tmp_var, tmp_label)<xsl:text></xsl:text>        
 
<!-- List out the Value Labels (if data uses codes) -->
tmp_var &lt;- character()<xsl:text></xsl:text>
tmp_code &lt;- character() <xsl:text></xsl:text>               
tmp_label &lt;- character() <xsl:text></xsl:text>
        <xsl:for-each select="attributeList">
            <xsl:for-each select="attribute">  
                <xsl:if test="measurementScale/nominal[. != '']">
                    <xsl:if test="measurementScale/nominal/nonNumericDomain/enumeratedDomain[. != '']">  
                          <xsl:for-each select="measurementScale/nominal/nonNumericDomain/enumeratedDomain/codeDefinition">
                              <xsl:if test="code[. !='']">
tmp_var &lt;- c(tmp_var,"<xsl:value-of select="../../../../../attributeName"/>") <xsl:text> </xsl:text> 
tmp_code &lt;- c(tmp_code,"<xsl:value-of select="code"/>") <xsl:text> </xsl:text> 
tmp_label &lt;- c(tmp_label,"<xsl:value-of select="definition"/>") <xsl:text> </xsl:text> 
                              </xsl:if>
                          </xsl:for-each>
                    </xsl:if>
                </xsl:if>            
            </xsl:for-each>
        </xsl:for-each>
codeLabelFrame<xsl:value-of select="position()"/> &lt;- data.frame(variable=tmp_var, code=tmp_code, label=tmp_label) <xsl:text></xsl:text>
rm(tmp_var, tmp_label, tmp_code) <xsl:text></xsl:text>
                
# HERE IS A LIST  OF VARIABLES from  dataTable<xsl:value-of select="position()"/>  AND LABELS FOR THOSE VARIABLES
labelFrame<xsl:value-of select="position()"/>  <xsl:text></xsl:text>   
                
 # HERE IS A LIST OF VARIABLES TO WHICH CODES HAD BEEN ASSIGNED               
codeLabelFrame<xsl:value-of select="position()"/>    <xsl:text></xsl:text>           
                
attach(dataTable<xsl:value-of select="position()"/>)<xsl:text></xsl:text>               
# The analyses below are basic descriptions of the variables. After testing, they should be replaced.                 
 <!--  Generate some default statistical summaries for nominal variables -->       
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <xsl:if test="measurementScale/nominal|measurementScale/ordinal[. != '']"> 
summary(as.factor(<xsl:value-of select="attributeName"/>)) <xsl:text></xsl:text>               
                        </xsl:if> 
                    </xsl:for-each>
                </xsl:for-each>
<!--  Generate some default statistical summaries for continuous variables -->       
                <xsl:for-each select="attributeList">
                    <xsl:for-each select="attribute">  
                        <xsl:if test="measurementScale/interval|measurementScale/ratio|measurementScale/datetime[. != '']"> 
summary(as.numeric(<xsl:value-of select="attributeName"/>)) <xsl:text></xsl:text>               
                        </xsl:if> 
                    </xsl:for-each>
                </xsl:for-each>                
        </xsl:for-each>
     </xsl:if>  
        </xsl:template>

<xsl:template name="readCSV"> 
 dataTable<xsl:value-of select="position()"/> &lt;-read.csv(infile<xsl:value-of select="position()"/>,<xsl:text> </xsl:text>
    <xsl:choose>
        <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x20']">
            ,sep=" " <xsl:text/>
        </xsl:when>
        <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x20']">
            ,sep=" " <xsl:text/>
        </xsl:when>
        <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='0x09']">
            ,sep="\t" <xsl:text/>
        </xsl:when>
        <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter[.='#x09']">
            ,sep="\t" <xsl:text/>
        </xsl:when>
        <xsl:otherwise>
            ,sep="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/fieldDelimiter"/>" <xsl:text> </xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    
    <xsl:if test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.!='']">
        <xsl:choose>
            <xsl:when test='physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.="&apos;"]'>
                ,quot="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>"<xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter[.='&quot;']">
                ,quot='<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>'<xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                ,quot="<xsl:value-of select="physical/dataFormat/textFormat/simpleDelimited/quoteCharacter"/>"<xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>
    <xsl:for-each select="attributeList">
        , col.names=c(<xsl:text></xsl:text>
        <xsl:for-each select="attribute">
            <xsl:choose>
                <xsl:when test="position()!=last()">
                    "<xsl:value-of select="attributeName"/>",    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    "<xsl:value-of select="attributeName"/>"   <xsl:text> </xsl:text>                             
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        </xsl:for-each>
    <xsl:text>)</xsl:text>, check.names=TRUE)
</xsl:template>
    
    <xsl:template name="readFixed">
<!-- Create a FORTRAN-style format - tabs not allowed -->
tmp_format &lt;- character()<xsl:text></xsl:text>
        <xsl:for-each select="attributeList">       
        <xsl:for-each select="attribute">
            <xsl:if test="../../physical/dataFormat/textFormat/complex/textFixed[. !='']">
                <xsl:variable name="nodeNum" select="position()"/>
                <xsl:variable name="prevNode" select="position() - 1"/>
                <xsl:choose>
                <xsl:when test="$nodeNum > 1">
<xsl:if test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn - ../../physical/dataFormat/textFormat/complex/textFixed[$prevNode]/fieldWidth - ../../physical/dataFormat/textFormat/complex/textFixed[$prevNode]/fieldStartColumn &gt; 0">
tmp_format &lt;- c(tmp_format,"<xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn - ../../physical/dataFormat/textFormat/complex/textFixed[$prevNode]/fieldWidth - ../../physical/dataFormat/textFormat/complex/textFixed[$prevNode]/fieldStartColumn"/>X")<xsl:text></xsl:text>
 </xsl:if>
                </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn[. > 1]">
tmp_format &lt;- c(tmp_format,"<xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldStartColumn - 1"/>X")<xsl:text></xsl:text>
                        </xsl:if>  
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <xsl:when test="(storageType = 'varchar') or (storageType = 'string') or (starts-with(storageType,'char'))">
tmp_format &lt;- c(tmp_format,"A<xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth " />")<xsl:text/>
                    </xsl:when>
                    <xsl:when test="(starts-with(storageType,'int')) or (storageType = 'byte')">
                        <xsl:choose>
                            <xsl:when test="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth[. > 0]">
tmp_format &lt;- c(tmp_format,"<xml:text>F</xml:text><xsl:value-of select="../../physical/dataFormat/textFormat/complex/textFixed[$nodeNum]/fieldWidth"></xsl:value-of><xsl:text>")</xsl:text>                                 
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text> F </xsl:text>
                    </xsl:otherwise>                           
                </xsl:choose>
            </xsl:if> 
                <xsl:text> </xsl:text> 
        </xsl:for-each>      
        </xsl:for-each>  
 tmp_format<xsl:text/>

  <xsl:for-each select="attributeList">        
tmp_cols &lt;- c(<xsl:text/>
            <xsl:for-each select="attribute">
                <xsl:choose>
                    <xsl:when test="position()!=last()">
                        "<xsl:value-of select="attributeName"/>",   <xsl:text/> 
                    </xsl:when>
                    <xsl:otherwise>
                        "<xsl:value-of select="attributeName"/>")<xsl:text/>                            
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
  </xsl:for-each>
# This creates a data.frame named:  dataTable<xsl:value-of select="position()"/>     
    dataTable<xsl:value-of select="position()"/> &lt;-read.fortran(infile<xsl:value-of select="position()"/>,tmp_format, col.names=tmp_cols, check.names=TRUE,na.strings=c("NA","."))<xsl:text/>
rm(tmp_format, tmp_cols)
    </xsl:template>
</xsl:stylesheet>