module namespace fadict = "http://acdh.oeaw.ac.at/pes_eng_dict";
declare namespace tei = 'http://www.tei-c.org/ns/1.0';

declare function fadict:expandExamplePointers($in as item(), $dict as document-node()*) {
    typeswitch ($in)
        case text() return $in
        case attribute() return $in
        case document-node() return document {
            fadict:expandExamplePointers($in/*, $dict)
        }
        case element(tei:ref) return $dict//node()[@xml:id = substring-after($in/@target, '#')]
        case element() return 
            (: element { QName( namespace-uri($in), local-name($in) ) } { for $node in $in/node() return wde:expandExamplePointers($node, $dict) } :)
            element { QName( namespace-uri($in), local-name($in) ) } { 
              for $i in ($in/@*, $in/node()) 
              return fadict:expandExamplePointers($i, $dict) 
            }
        default return $in
};
      
declare function fadict:distinct-nodes( $nodes as node()* )  as node()* {
    for $seq in (1 to count($nodes))
    return $nodes[$seq][not(fadict:is-node-in-sequence(.,$nodes[position() < $seq]))]
};
  
declare function fadict:is-node-in-sequence
 ( $node as node()? ,
    $seq as node()* )  as xs:boolean {

   some $nodeInSeq in $seq satisfies $nodeInSeq is $node
};
 
declare 
    %rest:path("fadict/dict_index")
    %rest:query-param("dict", "{$dict}")    
    %rest:query-param("ind", "{$ind}")    
    %rest:query-param("str", "{$str}")    
    %rest:GET 
    %output:method("html")
    
function fadict:query-index___($dict as xs:string, $ind as xs:string, $str as xs:string) {  
let $rs := 
 switch($ind)
   case "any" return collection($dict)//index/w[starts-with(.,$str)]
   default return 
            if ($str='*')
               then collection($dict)//index[@id=$ind]/w
               else collection($dict)//index[@id=$ind]/w[starts-with(.,$str)]

let $rs2 := <res>{
    for $r in $rs
      return
        if ($r/@lemma)
          then <w lemma="{$r/@lemma}" index="{$r/@index}">{$r/text()}</w>
          else <w index="{$r/@index}">{$r/text()}</w>
    (: return <w index="{$r/../@id}" lemma="{$r/@lemma}">{$r/text()}</w> :)
    (: return <w index="{$r/../@id}" lemma="{$r/text()}">{$r/text()}</w> :)
  }</res>

  let $style := doc('index_2_html.xslt')
  let $ress := <results>{$rs2}</results>
  let $sReturn := xslt:transform($ress, $style)
  return
    $sReturn
};

declare function fadict:createMatchString($in as xs:string) {
  let $s := replace($in, '"', '')
  let $s1 := 
    if (contains($s, '*') or contains($s, '.') or contains($s, '^') or contains($s, '$') or contains($s, '+')  )
    then 'matches(., "' || $s ||'")'
    else '.="' || $s || '"'    
    
  return $s1
};

declare 
    %rest:path("fadict/dict_api")
    %rest:query-param("query", "{$query}")    
    %rest:query-param("dict", "{$dict}")    
    %rest:query-param("xslt", "{$xsltfn}")    
    %rest:GET 

function fadict:dict_query($dict as xs:string, $query as xs:string*, $xsltfn as xs:string) {    
  let $nsTei := "declare namespace tei = 'http://www.tei-c.org/ns/1.0';"
  let $queries := tokenize($query, '999')
  let $coll :='collection("' || $dict || '")'
  let $entry := $coll||'//tei:entry' 
  let $example := $coll||'//tei:div/tei:cit[@type="example"]'
  let $qs := 
     for $query in $queries
        let $terms := tokenize(normalize-space($query), '=')
        return
          switch(normalize-space($terms[1]))
          case 'any' return      $entry||'[.//node()[' || fadict:createMatchString($terms[2]) || ']] | ' || 
                                 $example||'/tei:quote[' || fadict:createMatchString($terms[2] || '.*') || ']|' ||
                                 $example||'/tei:cit/tei:quote[' || fadict:createMatchString($terms[2] || '.*') || ']'          
          case 'lem' return      $entry||'[tei:form[@type="lemma"]/tei:orth[' || fadict:createMatchString($terms[2]) || ']] | ' ||
                                 $entry||'[tei:form[@type="multiWordUnit"]/tei:orth[' || fadict:createMatchString($terms[2]) || ']]'
          
          case 'infl' return     $entry||'[tei:form[@type="inflected"]/tei:orth[' || fadict:createMatchString($terms[2]) || ']]'
          case 'en' return       $entry||'[tei:sense/tei:cit[@type="translationEquivalent"][@xml:lang="en"]/tei:form/tei:orth[' || fadict:createMatchString($terms[2]) || ']]'
          case 'de' return       $entry||'[tei:sense/tei:cit[@type="translationEquivalent"][@xml:lang="de"]/tei:form/tei:orth[' || fadict:createMatchString($terms[2]) || ']]'
          case 'dom' return      $entry||'[tei:sense/tei:usg[@type="domain"][' || fadict:createMatchString($terms[2]) || ']]'
          case 'etymLang' return $entry||'[tei:etym/tei:cit/@xml:lang[' || fadict:createMatchString($terms[2]) || ']]'
          case 'etymSrc' return  $entry||'[tei:etym/tei:cit/tei:form/tei:orth['|| fadict:createMatchString($terms[2]) || ']]'
          case 'pos' return      $entry||'[tei:gramGrp/tei:gram[@type="pos"][' || fadict:createMatchString($terms[2]) || ']]'          
          case 'examples' return $example||'/tei:quote[' || fadict:createMatchString($terms[2] || '.*') || ']|' ||
                                 $example||'/tei:cit/tei:quote[' || fadict:createMatchString($terms[2] || '.*') || ']'          
          default return      $entry||'[.//node()[' || fadict:createMatchString($terms[2]) || ']'
    
  (: let $qq := string-join($qs,'|') :)
  let $qq := string-join($qs)
  
  let $results := xquery:eval($nsTei||$qq)    
  (: return <answer>{count($res)}||{$res}</answer> :)
  
  (: let $results := xquery:eval($query) :)
  (: let $eds := distinct-values($results//tei:fs/tei:f[@name='who']/tei:symbol/@value) 
  let $editors := 
    for $ed in $eds
      return <ed>{$ed}</ed> :)
    
  (: let $exptrs := $results//tei:ref[@type = 'example']
  let $entries := 
    for $r in $results
      return ($r/ancestor::tei:entry, $r/ancestor::tei:cit[@type='example'], $r)[1] :) 

  let $res := fadict:distinct-nodes($results)    
  (: let $res2 :=
    if (count($exptrs)=0)
      then $res
      else for $e in $res return fadict:expandExamplePointers($e, collection($dict)) :)
   
  let $style := doc($xsltfn)
  let $ress := <div type="results" xmlns="http://www.tei-c.org/ns/1.0">{$res}</div> 
  
  let $sReturn := xslt:transform-text($ress, $style)       
  
  (: return <err>{$qq}</err> :)
  return $sReturn
     

    (: if (wde:check-user_($dict, $user, $pw)) :)
      (: then $sReturn :)
      (: else <error type="user authentication" name="{$user}" pw="{$pw}"/> :)       
};
