<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0">

   <xsl:output method="html"/>
   <!--<xsl:variable name="var1" select="concat('#',//@xml:id)"/>-->
   <xsl:template match="/">
      <div>
         <xsl:variable name="entryNum"><xsl:value-of select="count(//tei:div[@type='results']/tei:entry)"/></xsl:variable>
         <div class="dvStats">
            <xsl:value-of select="$entryNum"/><xsl:text> </xsl:text>
            <xsl:choose>
               <xsl:when test="$entryNum=0">records. Try to add .* to your query!</xsl:when>
               <xsl:when test="$entryNum=1">record</xsl:when>
               <xsl:otherwise>records</xsl:otherwise>
            </xsl:choose>
         </div>

         <xsl:if test="$entryNum=0">
            <xsl:for-each select="//tei:cit[@type='example']">
               <div class="dvExamples">
                  <xsl:value-of select="tei:quote"/><br/>

                  <span class="spTransEn"><xsl:text> </xsl:text><xsl:value-of select="tei:cit[@type='translation']/tei:quote"/></span>
               </div>
            </xsl:for-each>
         </xsl:if>

         <!-- ********************************************* -->
         <!-- ***  ENTRY ********************************** -->
         <!-- ********************************************* -->
         <xsl:for-each select="//tei:div[@type='results']/tei:entry">
            <xsl:sort select="./tei:form/tei:orth"/>
            <div class="dvRoundLemmaBox_ltr">
               <xsl:value-of select="tei:form/tei:orth[@xml:lang='fa-x-modDMG']"/> (<xsl:value-of select="tei:form/tei:orth[@xml:lang='fa-Arab']"/>)
               <xsl:if test="tei:gramGrp/tei:gram[@type='pos']">
                  <span class="spGramGrp">
                     <xsl:text> </xsl:text>
                     (<xsl:choose>
                         <xsl:when test="tei:gramGrp/tei:gram[@type='pos']='responseParticle'">response particle</xsl:when>
                         <xsl:otherwise><xsl:value-of select="tei:gramGrp/tei:gram[@type='pos']"/></xsl:otherwise>
                      </xsl:choose>)
                     
                  </span>
               </xsl:if>
            </div>

            <table class="tbEntry">
               <xsl:if test="tei:form[@type='lemma']/tei:form[@type='variant']">
                  <tr>
                     <td class="tdHead">Lemma (var.)</td>
                     <td>
                        <xsl:for-each select="tei:form[@type='lemma']/tei:form[@type='variant'] ">
                           <xsl:if test="position()&gt;1"><xsl:text>, </xsl:text></xsl:if>
                           <xsl:value-of select="tei:orth[@xml:lang='fa-x-modDMG']"/> (<xsl:value-of select="tei:orth[@xml:lang='fa-Arab']"/>)
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:if>
               

               <!-- ********************************************* -->
               <!-- ***  ETYMOLOGY ****************************** -->
               <!-- ********************************************* -->
               <xsl:if test="tei:etym ">
                  <tr>
                     <td class="tdHead">Etymology</td>
                     <td>
                        <xsl:for-each select="tei:etym ">
                           <xsl:if test="position()&gt;1"><br/></xsl:if>
                           ˂ <xsl:value-of select="tei:cit/tei:form/tei:orth"/> (<xsl:value-of select="tei:cit/@xml:lang"/>)
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:if>
                              

               <!-- ********************************************* -->
               <!-- ***  INFLECTED FORMS (Pls, etc.) ************ -->
               <!-- ********************************************* -->
               <xsl:if test="string-length(tei:form[@type='inflected'])&gt;0">
                  <tr>
                     <td class="tdHead">Inflected</td>
                     <td>
                        <xsl:for-each select="tei:form[@type='inflected']">
                           <xsl:if test="string-length(tei:orth)&gt;0">
                              <xsl:if test="position()&gt;1"><br/></xsl:if>
                              <xsl:value-of select="tei:orth[@xml:lang='fa-x-modDMG']"/> (<xsl:value-of select="tei:orth[@xml:lang='fa-Arab']"/>)

                              <xsl:if test="tei:gramGrp[tei:gram]">
                                 <xsl:variable name="out">
                                    <xsl:for-each select="tei:gramGrp/tei:gram">
                                       <xsl:if test="position()&gt;1">, </xsl:if>
                                       <xsl:choose>
                                          <xsl:when test="@type='nomClass'">cl.<xsl:value-of select="."/></xsl:when>
                                          <xsl:when test=".='imperative'">imp.</xsl:when>
                                          <xsl:when test=".='infinitive'">inf.</xsl:when>
                                          <xsl:when test=".='locative'">loc.</xsl:when>
                                          <xsl:when test=".='plural'">pl.</xsl:when>
                                          <xsl:when test=".='singular'">sg.</xsl:when>
                                          <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                                       </xsl:choose>
                                    </xsl:for-each>
                                 </xsl:variable>
                                 <span class="spGramGrp"> (<xsl:value-of select="normalize-space($out)"/>)</span>
                              </xsl:if>

                              <!-- ********************************************* -->
                              <!-- ***  USG of infl.  ************************** -->
                              <!-- ********************************************* -->
                              <xsl:if test="tei:usg"><xsl:text> </xsl:text>(<xsl:value-of select="tei:usg"/>)</xsl:if>
                           </xsl:if>
                           
                           <xsl:if test="tei:form[@type='variant']">
                              <xsl:for-each select="tei:form[@type='variant']">
                                 <div class="dvVariant"><b><xsl:text>Var: </xsl:text></b>
                                    <xsl:value-of select="tei:orth"/>
   
                                    <xsl:if test="tei:gramGrp[tei:gram]">
                                       <xsl:variable name="out">
                                          <xsl:for-each select="tei:gramGrp/tei:gram">
                                             <xsl:if test="position()&gt;1">, </xsl:if>
                                             <xsl:choose>
                                                <xsl:when test="@type='nomClass'">cl.<xsl:value-of select="."/></xsl:when>
                                          <xsl:when test=".='imperative'">imp.</xsl:when>
                                          <xsl:when test=".='infinitive'">inf.</xsl:when>
                                          <xsl:when test=".='locative'">loc.</xsl:when>
                                          <xsl:when test=".='plural'">pl.</xsl:when>
                                          <xsl:when test=".='singular'">sg.</xsl:when>
                                                <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                                             </xsl:choose>
                                          </xsl:for-each>
                                       </xsl:variable>
                                       <span class="spGramGrp"> (<xsl:value-of select="normalize-space($out)"/>)</span>
                                    </xsl:if>
                                 </div>
                              </xsl:for-each>
                           </xsl:if>
                        </xsl:for-each>
                     </td>
                  </tr>
                  
               </xsl:if>

               <!-- ********************************************* -->
               <!-- ***  DERIVED FORMS (Pls, etc.) ************ -->
               <!-- ********************************************* -->
               <xsl:if test="string-length(tei:form[@type='derived'])&gt;0">
                  <tr>
                     <td class="tdHead">Derived</td>
                     <td>
                        <xsl:for-each select="tei:form[@type='derived']">
                           <xsl:if test="string-length(tei:orth)&gt;0">
                              <xsl:if test="position()&gt;1">,<xsl:text>  </xsl:text></xsl:if>
                              <xsl:value-of select="tei:orth"/>

                              <xsl:variable name="out">
                                 <xsl:for-each select="tei:gramGrp/tei:gram">
                                    <xsl:if test="position()&gt;1">, </xsl:if>
                                    <xsl:choose>
                                       <xsl:when test="@type='nomClass'">cl.<xsl:value-of select="."/></xsl:when>
                                       <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                                    </xsl:choose>
                                 </xsl:for-each>
                              </xsl:variable>
                              <span class="spGramGrp"> (<xsl:value-of select="normalize-space($out)"/>)</span>

                              <!-- ********************************************* -->
                              <!-- ***  USG of infl.  ************************** -->
                              <!-- ********************************************* -->
                              <xsl:if test="tei:usg"><xsl:text> </xsl:text>(<xsl:value-of select="tei:usg"/>)</xsl:if>
                           </xsl:if>
                        </xsl:for-each>
                     </td>
                  </tr>
               </xsl:if>

               <!-- ********************************************* -->
               <!-- ** SENSES *********************************** -->
               <!-- ********************************************* -->
               <xsl:for-each select="tei:sense">

                  <tr>
                     <td class="tdSenseHead">Sense
                        <xsl:if test="count(parent::tei:entry/tei:sense)&gt;1"><xsl:text> </xsl:text>
                           <xsl:value-of select="position()"/>
                        </xsl:if>

                        
                        <!-- ********************************************* -->
                        <!-- ** USG ************************************** -->
                        <!-- ********************************************* -->
                        <xsl:if test="tei:usg">
                           <div class="dvDef">
                              <span class="dvArguments"><xsl:value-of select="tei:usg"/></span>
                           </div>
                        </xsl:if>

                        <!-- ********************************************* -->
                        <!-- ** ARGUMENTS ******************************** -->
                        <!-- ********************************************* -->
                        <xsl:if test="tei:gramGrp/tei:gram[@type='arguments']">
                           <div class="dvDef">
                              <span class="dvArguments"><xsl:value-of select="tei:gramGrp/tei:gram[@type='arguments']"/></span>
                           </div>
                        </xsl:if>
                     </td>

                     <td class="tdSense">
                        <!-- ********************************************* -->
                        <!-- ** DEF ************************************** -->
                        <!-- ********************************************* -->
                        <xsl:for-each select="tei:def">
                           <div class="dvDef">
                              <span class="spDef">(<xsl:value-of select="."/>)</span>
                           </div>
                        </xsl:for-each>

                        <div class="dvDef">
                           <xsl:for-each select="tei:cit[@type='translationEquivalent'][@xml:lang='en']">
                              <xsl:if test="string-length(.)&gt;1">
                                 <span class="spTransEn">
                                    <xsl:if test="position()&gt;1">,<xsl:text> </xsl:text></xsl:if>
                                    <xsl:value-of select="tei:form/tei:orth"/>
                                    <xsl:if test="tei:gloss"><xsl:text> </xsl:text>(<xsl:value-of select="tei:gloss"/>)</xsl:if>
                                 </span>
                              </xsl:if>
                           </xsl:for-each>

                           <!-- ********************************************* -->
                           <!-- ** USG ************************************** -->
                           <!-- ********************************************* -->
                           <xsl:if test="tei:usg[@xml:lang='en']">
                              <span class="dvUsg"><xsl:text> </xsl:text>(<xsl:value-of select="tei:usg[@xml:lang='en']"/>)</span>
                           </xsl:if>
                        </div>

                        <xsl:for-each select="tei:cit[@type='example']">
                           <div class="dvExamples">
                              <xsl:apply-templates select="tei:quote[@xml:lang='fa-x-modDMG']"/>
                              <xsl:text> </xsl:text>
                              <xsl:apply-templates select="tei:quote[@xml:lang='fa-Arab']"/>
                              <xsl:if test="@subtype='proverb'"><span class="dvArguments"><i> (prov.)</i></span></xsl:if>

                              <xsl:for-each select="tei:cit[@type='translation'][@xml:lang='en']">
                                 <span class="spTransEn"><xsl:text> </xsl:text><xsl:value-of select="tei:quote"/><xsl:if test="@subtype='literal'"> <span class="dvArguments"> (lit.)</span></xsl:if></span>
                              </xsl:for-each>
                           </div>
                        </xsl:for-each>

                        <xsl:for-each select="tei:cit[@type='multiWordUnit'][@xml:lang='zu']">
                           <div class="dvMWUExamples">
                              <table>
                                 <tr>
                                    <xsl:if test="tei:quote[@xml:lang='zu']">
                                       <td class="tdNoBorder">
                                          <xsl:value-of select="tei:quote[@xml:lang='zu']"/>
                                       </td>
                                    </xsl:if>
                                    <td class="tdNoBorder">
                                       <xsl:for-each select="tei:cit[@type='translation']">
                                          <div class="dvDef">
                                             <span class="spTrans">
                                                <xsl:value-of select="tei:quote[@xml:lang='zu']"/>
                                                <xsl:if test="tei:usg"><xsl:text> </xsl:text>
                                                   (<xsl:value-of select="tei:usg"/>)
                                                </xsl:if>
                                             </span>
                                          </div>
                                       </xsl:for-each>
                                    </td>
                                 </tr>
                              </table>
                           </div>
                        </xsl:for-each>

                        <xsl:for-each select="tei:entry[@type='example']">
                           <div class="dvMWUExamples">
                              <table>
                                 <tr>
                                    <xsl:if test="tei:form/tei:orth[@xml:lang='zu']">
                                       <td class="tdNoBorder">
                                          <xsl:value-of select="tei:form/tei:orth[@xml:lang='zu']"/>
                                       </td>
                                    </xsl:if>

                                    <td class="tdNoBorder">
                                       <xsl:for-each select="tei:sense">
                                          <div class="dvDef">
                                             <span class="spTrans">
                                                <xsl:value-of select="tei:cit/tei:quote[@xml:lang='zu']"/>

                                                <xsl:if test="tei:usg">
                                                   (<xsl:value-of select="tei:usg"/>)
                                                </xsl:if>
                                             </span>
                                          </div>
                                       </xsl:for-each>
                                    </td>
                                 </tr>
                              </table>
                           </div>
                        </xsl:for-each>

                     </td>
                  </tr>

               </xsl:for-each>

               <!--
               <tr>
                  <td class="tdSenseHead">Editors</td>
                  <td>
                     <span class="spEditors" alt="Editors">
                        <xsl:for-each select="//ed">
                           <xsl:sort select="."/>
                           <xsl:if test="position()&gt;1">,<xsl:text>&#x2006;</xsl:text></xsl:if>
                           <xsl:choose>
                              <xsl:when test=".='Anton'">A.&#xA0;Anton</xsl:when>
                              <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
                           </xsl:choose>
                        </xsl:for-each>
                     </span>
                  </td>
               </tr>
               -->
            </table>
         </xsl:for-each>

         <br/><br/>
         <br/><br/>
         <br/><br style="margin-bottom:200px"/>
      </div>

   </xsl:template>

   <xsl:template match="tei:ref">
      <!--
      <xsl:choose>
         <xsl:when test="@target=$var1"><span style="color:red"><xsl:apply-templates/></span></xsl:when>
         <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
      </xsl:choose>
      -->        <xsl:apply-templates/>
   </xsl:template>

</xsl:stylesheet>
