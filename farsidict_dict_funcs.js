var sDict = 'dc_pes_eng__publ';
var sDictInd = 'dc_pes_eng__publ__ind';
var sXSLT = 'farsidict.xslt';
var sSubDir = 'fadict';
var inpSel = 0;         
var ramz = "";
var usr = "";
var allowedFields = ["any", "lem", "infl", "en", "pos", "root", "dom", "subc", "etymLang", "etymSrc"];


function xmlToString(xmlData) { 
  var xmlString;
  //IE
  if (window.ActiveXObject){
    xmlString = xmlData.xml;
  }
  // code for Mozilla, Firefox, Opera, etc.
  else{
    xmlString = (new XMLSerializer()).serializeToString(xmlData);
  }
  return xmlString;
}        

function countChar(s_, c_) {
   ilen = s_.length;
   var res = 0;
   for (i=0; i!=ilen; i++) {
      //console.log(s_.charAt(i));
      if (s_.charAt(i) == c_)
        res = res + 1;
   }
   return res;
}

function trim(s_) {
  var res = s_;
  while (res.charAt(0) == ' ') {
     res = res.substring(1, res.length);
  }

  while (res.charAt(res.length-1) == ' ') {
     res = res.substring(0, res.length-1);
  }
  return res;
}

function createMatchString(s_) {
  res = "";
  s_ = trim(s_);
  if ((s_.indexOf('*') > -1) || 
      (s_.indexOf('.') > -1) ||
      (s_.indexOf('^') > -1) ||
      (s_.indexOf('$') > -1) ||
      (s_.indexOf('+') > -1) 
     ) {
    //next line is necessary for IE
    s_ = encodeURIComponent(s_);
    res = 'matches(., "' + s_ + '")';                          
  } else {
    s_ = encodeURIComponent(s_);
    res = '.="' + s_ + '"';
  }
  return res;
}

function prepareDictQuery(sq_) {   
   ok = -1;   
   sq_ = trim(sq_);
   sq_ = sq_.replace(/\] /g, ']');
   sq_ = sq_.replace(/ \[/g, '[');
   sq_ = sq_.replace(/]\+\[/g, ']#[');
   
   var sWrongField = '';
   var field = $("#slFieldSelect").val();
   iBrackets = countChar(sq_, ')');
   //console.log('field: ' + field);
   console.log('query: ' + sq_);

   var sQuery = ''; 
   var ok = true;
   var str_array = sq_.split('#');
   for(var i = 0; i < str_array.length; i++) {
     s = str_array[i];
     s = s.replace(/]/g, '');
     s = s.replace(/\[/g, '');
     s = trim(s);
     n = s.indexOf('=');
     
     if (sQuery.length > 0) { sQuery = sQuery + '999'; }
     
     if (n > -1) {
        field = s.substring(0, n);
        nn = allowedFields.indexOf(field);
        if (nn > -1) {
            sQuery = sQuery + s;
        } else {
            ok = false;
            sWrongField = field;
        }         
     } else {
        if (field.length > 0) {
            sQuery = sQuery + field + '=' + s;
       } else {
            sQuery = sQuery + 'any=' + s;    
       }         
     }
   }
   
   if (ok) {        
      console.log("sQuery: " + sQuery); 
      var res  = './dict_api?query=' + sQuery +  '&dict=' + sDict + '&xslt=' + sXSLT;
      console.log("res: " + res); 
      return res;
   } else {
       alert('There is a wrong field indicator (' + sWrongField + ') in your query.');    
       return '';
   }
}

 function initUser() {
    ramz = $("#pw1").val();
    ramz = $.sha256(ramz).toUpperCase();
    usr = $("#usr1").val();         
 }
         
function execQuery(query_) {
    $("#imgPleaseWait").css('visibility', 'visible');
    //initUser();
    //console.log('usr: ' + usr);
    //console.log('ramz: ' + ramz);
    
    $.ajax({
       url: query_,
       type: 'GET',
       dataType: 'html',
       cache: false,
       crossDomain: true,
       //headers: {'From': usr, 'Pragma': ramz,},
       //headers: {'autho': usr + ':' + ramz},
       contentType: 'application/html; charset=utf-8',
       success: function (result) {
          //console.log('pos56');
          //alert(result);
          
          showKWICsTab();
          if (result.includes('error type="user authentication"')) {
              alert('Error: authentication did not work');                  
          } else {
              $("#dvKWICs").html(result);
              $("#dvWordSelector").hide();
              $("#imgPleaseWait").css('visibility', 'hidden');                     
          }
       },
       error: function (error) {
          alert('Error: ' + error);
       }                           
    });
}

function hideAllTabs() {
  $("#btnQuery").attr('class', 'btnInActive');
  $("#btnProject").attr('class', 'btnInActive');
  $("#btnUser").attr('class', 'btnInActive');
  $("#btnHelp").attr('class', 'btnInActive');
  $("#btnLang").attr('class', 'btnInActive');
  $("#btnImprint").attr('class', 'btnInActive');

  $("#btnQuery1").attr('class', 'btnInActive');
  $("#btnProject1").attr('class', 'btnInActive');
  $("#btnUser1").attr('class', 'btnInActive');
  $("#btnHelp1").attr('class', 'btnInActive');
  $("#btnLang1").attr('class', 'btnInActive');
  $("#btnImprint1").attr('class', 'btnInActive');
             
  $("#dvMobileMenu").hide();
  $("#dvStart").hide();
  $("#dvInpText").hide();
  $("#dvProject").hide();
  $("#dvUser").hide();
  $("#dvHelp").hide();
  $("#dvLang").hide();
  $("#dvImprint").hide();
  $("#dvCharTable").hide();
}

function insert(str, index, value) {
   return str.substr(0, index) + value + str.substr(index);
}
         
/*          function fillWordSelector(q_) {
           $("#imgPleaseWait").css('visibility', 'visible');
           
           if (q_.length == 0) { q_ = '*'; }
           sInd = $("#slFieldSelect").val();
           sUrl1 = '/dict_index/' + sDictInd + '/' + sInd + '/' + q_;
           console.log('sUrl1: ' + sUrl1);
           console.log('sInd: ' + sInd);
           $.ajax({
             url: sUrl1,
                        type: 'GET',
                        dataType: 'html',
                           contentType: 'application/html; charset=utf-8',
                           success: function(result) {
                              if (result.indexOf('option') !== -1) {
                                 $("#dvWordSelector").show();
                                 $("#slWordSelector").html(result);
                              } else {
                                 $("#dvWordSelector").hide();
                              }
                              $("#imgPleaseWait").css('visibility', 'hidden');
                           },
                           error: function (error) {
                              alert('Error: ' + error);
                           }                           
                     });
           
         }
*/

function directDictQuery(query_) {
    //alert(query_);
    $("#txt1").val(query_);
    sQuery = prepareDictQuery(query_);
    execQuery(sQuery);    
}

function fillWordSelector(q_, dictInd_) {
    $("#imgPleaseWait").css('visibility', 'visible');
    $("#slWordSelector").css('visibility', 'visible');
    $("#slWordSelector").html('');
        
    //if (q_.length > 0) { 
        sInd = $("#slFieldSelect").val();
        sUrl1 = './dict_index?dict=' + dictInd_ + '&ind=' + sInd + '&str=' + q_;
        //console.log('fillWordSelector: ' + sUrl1);
        $.ajax({
            url: sUrl1,
            type: 'GET',
            dataType: 'html',
            contentType: 'application/html; charset=utf-8',
            success: function (result) {
                if (result.indexOf('option') !== -1) {
                    $("#dvWordSelector").show();
                    $("#slWordSelector").html(result);
                    $("#slWordSelector").show();
                } else {
                    
                    $("#dvWordSelector").hide();
                }
                $("#imgPleaseWait").css('visibility', 'hidden');
            },
            error: function (error) {
                alert('Error: ' + error);
            }
        });    
    /* 
      
     } else {
        $("#imgPleaseWait").css('visibility', 'hidden');
        $("#slWordSelector").css('visibility', 'hidden');
    }
    */
}

function showKWICsTab() {
    hideAllTabs();
    $("#dvInpText").show();
    $("#btnQuery").attr('class', 'btnActive');
}
          
function tryIt(query_, field_) {
    hideAllTabs();
    $("btnQuery").attr('class', 'btnActive');
    $("#dvInpText").show();
    $("#txt1").val(query_);
    if (field_.length > 0) {
       $('#dvFieldSelect').show();
       $('#slFieldSelect').val(field_).prop('selected', true);
       query_ = "(" + field_ + "=" + query_ + ")";
    } else {
        $('#dvFieldSelect').hide();
    }

    sQuery = prepareDictQuery(query_);
    if (sQuery.length > 0) { 
        execQuery(sQuery);    
    }
}
         
$(document).ready(
    function() {
        var currentURL = decodeURI(window.location.toString());
        console.log('currentUrl: ' + currentURL);
        var args = currentURL.split('?');
        if (args[1]) {
        if (args[1].length > 0) {
           console.log('query: ' + args[1]);
           tryIt(args[1], '');
        }}

        var txtValues = '';
                
        $("#btnX").mousedown (
          function(event) {
             $("#txt1").val('');
             $("#txt1").focus();
          }
        )
               
       $("[id^=btnProject]").mousedown (
          function(event) {
             hideAllTabs();
             $(this).attr('class', 'btnActive');
             $("#dvProject").show();
          }
       )
       
       $("[id^=btnQuery]").mousedown (
          function(event) {
             hideAllTabs();
             $("#imgPleaseWait").css('visibility', 'hidden');
             $(this).attr('class', 'btnActive');
             $("#dvInpText").show();
          }
       )
       
       $("[id^=btnUse]").mousedown (
          function(event) {
             hideAllTabs();
             $(this).attr('class', 'btnActive');
             $("#dvUser").show();
          }
       )
               
       $("[id^=btnHelp]").mousedown (
          function(event) {
             hideAllTabs();
             $(this).attr('class', 'btnActive');
             $("#dvHelp").show();
          }
       )
       
       $("[id^=btnLang]").mousedown (
          function(event) {
             hideAllTabs();
             $(this).attr('class', 'btnActive');
             $("#dvLang").show();
          }
       )
       
       $("[id^=btnImprint]").mousedown (
          function(event) {
             hideAllTabs();
             $(this).attr('class', 'btnActive');
             $("#dvImprint").show();
          }
       )              
       
       $("#usr1,#pw1").keyup (
          function(event) { 
             if ( event.which == 13 ) {
                $("#inpUser").hide();
                $("#dvInpText").css('visibility', 'visible');
                $("#txt1").attr("autofocus","autofocus");
                return false;
             }
          }
       );
       
      $("[id^=ct]").mousedown (
          function(event) {
             var s1 = $("#txt1").val();
             var s2 = $(this).text(); 
             var s = insert(s1, inpSel, s2);
             $("#txt1").val(s);
             
             inpSel += 1;
             document.getElementById('txt1').selectionStart = inpSel + 1;
             fillWordSelector($("#txt1").val(), sDictInd);
          }
       );
               
               $("[id^=ct]").mouseover (
                 function(event) {
                    $(this).css( 'cursor', 'pointer' );
                 }
               );
               
               $("[id^=ct]").mouseout (
                 function(event) {
                    $(this).css( 'cursor', 'auto' );
                 }
               );
               
               $("[id^=id_opt]").mouseenter (
                 function(event) {
                    $(this).toggleClass('liHigh');
                 }
               );
               
               $("[id^=id_opt]").mouseleave (
                 function(event) {
                    $(this).toggleClass('liHigh');
                    //$('#dvDebug').text('not high');
                 }
               );
               
               $("#btnMobileMenu").click (
                 function(event) {
                  hideAllTabs();
                  $("#dvMobileMenu").show();
                 }               
               )
               
               $("[id^=id_opt]").click (
                 function(event) {
                 }
               );
               
               $("#slWordSelector").keyup (
                 function(event) {
                    $('#txt1').val($("#slWordSelector option:selected").text());
                 }
               );
               
               $("#slWordSelector").keydown (
                  function(event) { 
                     if ( event.which == 13 ) {         
                        $('#txt1').val($("#slWordSelector option:selected").text());
                        $('#txt1').focus();
                        $('#dvWordSelector').hide();
                     }  else if ( event.which == 27 ) {  /* Key: ESCAPE */
                        $("#dvWordSelector").hide();
                        $("#txt1").focus();                     
                     } else if ( event.which == 38 ) {  /* Key: Up */                     
                        if (document.getElementById("slWordSelector").selectedIndex == 0) {
                          $("#slWordSelector option:first").removeAttr('selected');
                          $('#txt1').focus();
                        }
                     }
                  }
               );

               
               $("#slWordSelector").click (
                  function() {
                     $('#txt1').val($("#slWordSelector option:selected").text());
                  }
               );
               
               
               $("#txt1").mousedown (
                  function(event) {
                     if ($("#slFieldSelect").val() == 'ar' ) {
                        $("#dvCharTable").show();
                     }
                  }
               );
               
               $('#txt1').on("focus", function(){
                  $("#dvCharTable").show();
               });

               $("#txt1").keyup (
                  function(event) { 
                     inpSel = document.getElementById('txt1').selectionStart;
                     if ( event.which == 13 ) {
                        $("#dvCharTable").hide();
                        $("#imgPleaseWait").css('visibility', 'visible');
                        $("#dvKWICs").html('');
                     
                        var sq = $("#txt1").val();
                        var field = $("#slFieldSelect").val();
                        //console.log("sq: " + sq);
                        //console.log("field: " + field);
                                                
                        sQuery = prepareDictQuery(sq);
                        if (sQuery.length > 0) {
                           //console.log('#' + sQuery);
                           execQuery(sQuery);    
                           //console.log('dvStats: ' + $("#dvStats").text());
                        } else {
                           alert('Could not create query.');
                        }
                                                
                     } else if ( event.which == 40 )
                     /* Arrow Down */
                     { 
                        $("#slWordSelector").focus();
                        $("#slWordSelector option:first").attr('selected','selected');                                                      
                     } else {
                        $("#dvCharTable").show();
                        var sq = $("#txt1").val();
  
                        if (sq.indexOf('=') > -1) {
                           $('#dvFieldSelect').hide();
                        } else {
                           $('#dvFieldSelect').show();
                        }
                        
                        go = -1;
                        if (sq.length > 0) { go = 0; } 
                        sInd = $("#slFieldSelect").val();
                        if ((sInd == "pos") | (sInd == "dom") | (sInd == "etymLang") | (sInd == "subc")) {
                            go = 0; 
                        }
                        console.log(sInd);
                        console.log(go);
                        
                        if (go == 0) {
                           if (sq.indexOf('=') == -1) {
                              fillWordSelector(sq, sDictInd);
                           }
                        } else {
                           $("#dvWordSelector").hide();
                        }
                     
                     }
                  }
               );
            }
          );
          
$( document ).ready(function() {
    hideAllTabs();
    $("#dvCharTable").hide();
    $("#dvWordSelector").hide();            
    $("#dvInpText").hide();
    $("#dvStart").show();
    
    $("#imgPleaseWait").css('visibility', 'hidden');
});
