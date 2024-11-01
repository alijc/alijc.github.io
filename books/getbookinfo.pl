#!/usr/bin/perl -w
# getbookinfo
# Gets info for a book title and author from local libraries:
#  A) Oregon Library for the Blind (AKA TBABS)
#  B) Multnomah County Library
# Info returned is availability, description and length.

use strict;
#use LWP::Debug qw(+);
use WWW::Mechanize;

my $infile = "./fodder";
my $if;
my $outfile = "./output";

my $tbabsurl = "https://talkingbooks.osl.state.or.us/";

my $mech = WWW::Mechanize->new( autocheck => 1 );
$mech->ssl_opts(  # Don't know why I need this, but I can't connect otherwise
    'SSL_version' => 'TLSv1_2',
    'SSL_cipher_list' => 'ECDHE-RSA-AES256-GCM-SHA384',
    );

open($if, $infile) or die "Couldn't open $infile\n";
while (<$if>) {
    print "\n\n";
    print $_;

    tbabs( $_ );

    multcolib( $_ );
}
close($if);


# getting the info from tbabs (Talking Books and Braille Service)
sub tbabs {
    my ( $bookinfo ) = @_;
    
    my $tbabsurl = "https://talkingbooks.osl.state.or.us/index.jsf";
#https://talkingbooks.osl.state.or.us/search/search.jsf?f=-Braille*medium_ss%3ABraille&p=0&q=The+Orphan+Master%E2%80%99s+Son+by+Adam+Johnson&i=_text_&s=score&l=false&mc=0
    print "\nTBABS:\n";
    $mech->get( $tbabsurl );
    $mech->form_number(1);
    $mech->field( "f", "Digital Book" );  # Exclude braille format
#    $mech->field( "f", "-Braille" );  # Exclude braille format
    $mech->field( "q", $bookinfo );       # Search on title and author
    $mech->click();
    #print $mech->content;

    if (index( $mech->content, "/title/summary.jsf" ) == -1 ) {
	print "not found\n";
	return;
    }

    # Find first link to title
    $mech->follow_link( url_regex => qr|/title/summary.jsf|i );

    # Extract title
    $mech->content =~ /<td class="Value Field-Title">(.*)</; 
    print "$1\n";

    # author
    $mech->content =~ /<td class="Value Field-Names"><a.*>(.*)</; 
    print "$1\n";

    # description (AKA Annotation)
    $mech->content =~ /<td class="Value Field-Annotation">(.*)</; 
    print "$1\n";

    # length
    $mech->content =~ /<td class="Value Field-Length">(.*)</;
    print "$1\n";
}

# getting info from Multnomah County Library
#https://multcolib.bibliocommons.com/v2/search?query=my%20family%20and%20other%20animals%20by%20gerald%20durrell&searchType=keyword&f_STATUS=DGT
sub multcolib {
    my ( $bookinfo ) = @_;
    my $multcoliburl = "https://multcolib.bibliocommons.com/v2/search?query=";
    my $overdriveurl = "https://multcolib.overdrive.com/search?query=";
    
    my $url = $multcoliburl . $bookinfo;
    
    print "\nMultcolib:\n";
    $mech->get( $url );
    if ( $mech->content =~ /Click here to access title/ ) {
	print "available at proquest\n";
    }
    
    #https://multcolib.overdrive.com/search?query=...&sortBy=relevance
    $mech->get( $overdriveurl . $bookinfo . "&sortBy=relevance" );
    if ( $mech->content =~ /window.OverDrive.mediaItems = \{(.*)\};/ ) { 
	my $items = $1;
	#print $items;
	while ( $items =~ /"type":\{"name":"(.*?)".*?availableCopies":(.*?),"ownedCopies":(.*?),.*?"firstCreatorName":"(.*?)","title":"(.*?)"/g ) {
	    print "$5 by $4, $1: $2 out of $3 available\n";
	}
    }

}
