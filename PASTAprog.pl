#! /usr/bin/perl
# put the address of your perl compiler on the line above
use WWW::Curl::Easy;

# set the URL that actually is to be queried to generate the EML
$PROGURL="http://www.vcrlter.virginia.edu/data/eml2/getStatProgPASTA.php";
@valid_outtypes=("r","sas","spss","sps","m","tidyr","rtidy","py");


my $curl = WWW::Curl::Easy->new;
        
# output HTML code
#print("Content-type: text/plain\n\n");
#print("valid output types are: ", "@valid_outtypes");

# put the lines of variables and values from URL separated by = in
# associative array named fields
@inblock=$ENV{"QUERY_STRING"};
foreach $inline (split(/\&/,join("",@inblock))) {
        	$inline =~ s/\"//g ;
	        @instuff = split(/\=/, $inline);
        	$fields{$instuff[0]}=&unescapeurl($instuff[1]);
}

$emlurl=$fields{emlurl};
#print("emlurl=",$emlurl);

# ingest and parse input path
@inpath=split(/\//,$ENV{PATH_INFO});
#print("inpath 0:",$inpath[0],"1:",$inpath[1]," 2:",$inpath[2]," 3:",$inpath[3]);
@packageinfo=split(/_|\./,$inpath[1]);
#print("<br>packageinfo 0:",$packageinfo[0]," 1:",$packageinfo[1]," 2:",$packageinfo[2]);
$outtype=$packageinfo[(@packageinfo - 1)]; # get the last element
$outtype=~ tr/[A-Z]/[a-z]/; # set to lower case
if($outtype eq 'sps'){$outtype="spss"} #allow SPSS as well as sps files

$validout=0;
foreach $validouttype (@valid_outtypes){
    if($outtype eq $validouttype){
	$validout=1;
    }
}
#print("validout=",$validout);
if ($validout == 0 ) {
    barf(400,'Error: Invalid statistical file type "'.$outtype.'" chosen. Valid types are: '."@valid_outtypes",'Syntax for this web service:  
http://www.vcrlter.virginia.edu/webservice/PASTAprog/knb-lter-vcr.26.20.r
where knb-lter-vcr.26.20 is replaced by the package ID if the dataset
you are interested in and the suffix (e.g., .r) indicates the desired
type of program.  Package identifiers can be looked up at
https://portal.edirepository.org.


For Matlab programs substitute _ for the periods in the package name
to avoid problems with Matlab\'s file naming conventions.  Thus:
knb-lter-vcr.26.20.m should become knb-lter-vcr_26_20.m

A suffix of .tidyr or .rtidy returns R code using the Tidyverse R package. 
A suffix of .r uses base-R only. 

If metadata is not yet available in the LTER PASTA server, the URL:
http://www.vcrlter.virginia.edu/webservice/PASTAprog/myprogram.r?emlurl=http://myserver.edu/myEMLDoc.xml
can be used, where emlurl is set to the location of an EML document on
the web.


');
    exit();
}

$packagename=$packageinfo[0];
for ($i=1;$i < (@packageinfo - 1);$i++) {
    $packagename=$packagename . "." . $packageinfo[$i];
}
#print("<br>packagename: ",$packagename," outtype: ",$outtype);

if ($emlurl eq ""){
    $runURL=$PROGURL . "?knb_package=" . $packagename . "&statPackage=". $outtype;
}else{
    $runURL=$PROGURL . "?emlURL=" . $emlurl . "&statPackage=". $outtype;
}
#print("runURL: ",$runURL);

# now use CURL module to run the URL. 

#    $curl->setopt(CURLOPT_HEADER,1);
    $curl->setopt(CURLOPT_URL, $runURL);

        # A filehandle, reference to a scalar or reference to a typeglob can be used here.
    my $response_body;
    $curl->setopt(CURLOPT_WRITEDATA,\$response_body);

        # Starts the actual request
    my $retcode = $curl->perform;

        # Looking at the results...
    if ($retcode == 0) {
#	print("Transfer went ok\n");
	barf(200,"Ok");
	my $response_code = $curl->getinfo(CURLINFO_HTTP_CODE);
        # judge result and next action based on $response_code
	print($response_body,"\n");
    } else {
                # Error code, type of error, error message
	barf(404,"An error happened when fetching the EML document: $retcode ".$curl->strerror($retcode)." ".$curl->errbuf."\n");
    }


sub barf {
#arguments are error number, short error string, optional long description string
    local ($errnum,$string,$longMsg)=@_;
    print("Status: $errnum $string\n");
    print("Content-type: text/plain\n\n");
    if ($errnum != 200){
      print("$errnum - $string\n\n") ;
      print($longMsg);
    }
}

sub unescapeurl {
	local $string=$_[0];
	local $hexval;
	local $decval;
	local $charval;
	$string =~ s/\+/ /g; 
	while ($string =~ /(%)([A-Fa-f0-9][A-Fa-f0-9])/){
		$hexval=$2;
  		$decval=hex($hexval);
                $charval=sprintf("%c",$decval);
		$string =~ s/\%$hexval/$charval/gi ;
	}
	return($string);
}
