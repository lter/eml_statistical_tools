<?php 
# This program applies a stylesheet to create a statistical program from a metadata document.
# John Porter 2014
# Either knb_package or emlurl must be specified as arguements

$DEBUG=0;
if ($DEBUG){print 'Debugging output is ON<br>';}
#$EMLPackageSource='http://knb.ecoinformatics.org/knb/metacat?action=read&qformat=xml&docid='; 
#$EMLPackageSource='https://xxx.lternet.edu/package/metadata/eml'; 
$EMLPackageSource='https://pasta.lternet.edu/package/metadata/eml'; 
#$EMLPackageSource='http://pasta.lternet.edu/package/metadata/eml'; 
#$EMLPackageSource='http://pasta.edirepository.org/package/metadata/eml'; 
$Rstylesheet = '/var/www/html/data/eml2/EMLdataset2RPasta.xsl';
$RTidystylesheet = '/var/www/html/data/eml2/EMLdataset2RTidyversePasta.xsl';
$SASstylesheet = '/var/www/html/data/eml2/EMLdataset2SASPasta_1_1.xsl';
$SPSSstylesheet = '/var/www/html/data/eml2/EMLdataset2SPSS_1_2.xsl';
#$Matlabstylesheet = '/var/www/html/data/eml2/EMLdataset2mfile.xsl';
$Matlabstylesheet = 'http://gce-lter.marsci.uga.edu/public/xsl/toolbox/EMLdataset2mfile.xsl';
$Pythonstylesheet = "/var/www/html/data/eml2/EMLdataset2Python.xsl";

# initialize any missing parameters
if (empty($_REQUEST['verbose'])) {$_REQUEST['verbose']='';}
if (empty($_REQUEST['emlURL'])) {$_REQUEST['emlURL']='';}
if (empty($_REQUEST['knb_package'])) {$_REQUEST['knb_package']='';}
if (empty($_REQUEST['statPackage'])) {$_REQUEST['statPackage']='';}

#parse arguements 
if ($_REQUEST['knb_package'] . $_REQUEST['emlURL'] == ''){
  print "Error, either a URL pointing to an EML document or a KNB package ID must be provided";
}else {
if ($_REQUEST['knb_package'] == ''){
  $source= $_REQUEST['emlURL'] . '' ;
}else{
  if ($DEBUG){print($_REQUEST['knb_package']);}
  $inPackage =preg_split('/\./', $_REQUEST['knb_package']);
  if($DEBUG){print_r($inPackage);}
    $pkgScope=$inPackage[0];
    $pkgId=$inPackage[1];
    $pkgRevision=$inPackage[2];
    if ($DEBUG){  print("Scope ".$pkgScope.", ID ".$pkgId.", rev. ".$pkgRevision."\n");}

# if revision is unknown, select the most recent
    if ($pkgRevision == ''){
      $pkgRevision = 'newest';
#      $source= 'http://pasta.lternet.edu/package/eml/'. $pkgScope . '/' . $pkgId ;
#      $revStr= file_get_contents($source);
#      $revList=preg_split('/\s/',$revStr);
#      $pkgRevision=intval($revList[sizeof($revList)-1]);
      if ($DEBUG){      print $pkgRevision;}
    }     
    $source= $EMLPackageSource . '/'.$pkgScope.'/'.$pkgId.'/'.$pkgRevision ;
    if ($DEBUG){   print $source;}
  } # end else
$statProgStyleSheet=$SASstylesheet; 
switch (strtoupper($_REQUEST['statPackage'])){
   case "SAS": $statProgStyleSheet=$SASstylesheet; break;
   case "SPSS": $statProgStyleSheet=$SPSSstylesheet; break;
   case "R": $statProgStyleSheet=$Rstylesheet; break;
   case "RTIDY":$statProgStyleSheet=$RTidystylesheet; break;
   case "TIDYR":$statProgStyleSheet=$RTidystylesheet; break;
   case "M": $statProgStyleSheet=$Matlabstylesheet; break;
   case "PY": $statProgStyleSheet=$Pythonstylesheet; break;
   default: $statProgStyleSheet=$SASstylesheet; break;
}
if ($DEBUG){print "Stylesheet is " . $statProgStyleSheet;}
$do_verbose=0;
if ($_REQUEST['verbose'] != '' || $_REQUEST['verbose'] == 'TRUE'){
 $do_verbose=1;
 }
if($do_verbose){ 
#print "Source document is:\n $source"; 
print "To use this program, follow these steps:";
print "<ol><li>Open a text editor </li>";
print "<li>COPY the program below and PASTE it into the editor window</li>";
print "<li>Edit the program so that the \"PUT--PATH-TO-DATA#-FILE-HERE\" specification points to where the data file is stored on your system (where # is the sequential data table number).</li>";
print "<li>SELECT ALL and COPY the program then PASTE it into your statistical programs editor or console</li></ol>";
print "The program is below this line. If no program is listed, the URL to the EML document may be in error. If the EML file does not include all the information needed, the statistical program will have errors or be incomplete. <br><hr>";

print "<pre>";
}

# process the input document and stylesheet

# set CURL options
$ch= curl_init($source);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HEADER, false);
# php curl lacks default agent, so make one up - php/curl
curl_setopt($ch,CURLOPT_USERAGENT,'php/curl');
# execute CURL and get the results
$result1=curl_exec($ch);
if ($DEBUG) {
    print("Result is: ".$result1);
        print("\n");
	}

$xml = new DOMDocument;
try{  if (!($xml->loadXML($result1))){;
      throw new Exception('Error: Source metadata not returned from URL: '.$source. "\n package requested was: ".$_REQUEST['knb_package'] );
    }
}catch(Exception $e){
      print($e->getMessage());
}

$xsl = new DOMDocument;
try{  if (!($xsl->load($statProgStyleSheet))){;
      throw new Exception('Error: Could not find Stylesheet at: '.$statProgStyleSheet );
    }
}catch(Exception $e){
      print($e->getMessage());
}


# Configure the transformer
$proc = new XSLTProcessor;
$proc->importStyleSheet($xsl); // attach the xsl rules

echo $proc->transformToXML($xml);

print "";
if ($do_verbose){
#if ($_REQUEST['verbose'] != '' || $_REQUEST['verbose'] == 'TRUE'){
print "</pre>";
}
#print "<br>Done"; 
} # end else
?>




