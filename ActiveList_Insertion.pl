#!/usr/bin/perl
#
# Title:        Threat Feeder Importer
#
# Start:        perl ActiveList_Insertion.pl canvas.xml [ActiveListName entries] > archive.xml
#
#
###############################################################################/

use strict;

# Command line arguments:
my $getTime = time();
$getTime = $getTime."000";
my $activeListRegex='ActiveList.*name\s*=\s*"([^"]*)".*';
my $archiveFile = $ARGV[0];
my @tokens=();

defined $archiveFile or die ("Usage: ActiveList_Insertion.pl canvas.xml [ActiveListName entriesFile] > archive.xml");

open(IN, $archiveFile) || die ("Failed to open file");

#if no activeListName is specified, quit with exception...

my $activeListName = $ARGV[1];

if (!defined $activeListName) { 

    # print out the ActiveLists contained in this archive

    print "Active Lists supported in the archive:\n";

    while (<IN>) {
        chomp;
        if (/$activeListRegex/) {
            print "\t".$1."\n";
        }
    }   
    exit;
}

my $entriesFile = $ARGV[2];

defined $entriesFile or die ("Usage: ActiveList_Insertion.pl canvas.xml [ActiveListName entriesFile] > archive.xml");

# reading the entries really quick...

open (ENTRIES, $entriesFile) || die ("Failed to open entriesFile");

my @entries;

while (<ENTRIES>) {

    chomp;
    $_ =~ s/
//g;

    next if (/^\s*$/);

    push(@entries,$_);   

}

close (ENTRIES);

# print a valid archive header for the output archive

print '<?xml version="1.0" encoding="UTF-8"?>'."\n";
print '<!DOCTYPE archive SYSTEM "../../schema/xml/archive/arcsight-archive.dtd">'."\n";
print '<archive buildVersion="3.5.1.0.0" buildName="SolutionTeam" buildTime="1-11-2006_11:20:18" user="admin" createTime="01-14-2006_09:35:16.402">'."\n";

# going through the archive

my $found=0;

while (<IN>) {

    chomp;
    $_ =~ s/
//g;

    if (/ActiveList.*name="$activeListName"/) {

        print $_."\n";        # just print it out again.
        $found = 1;            # we found the said activeList
        print '     <activeListEntries>'."\n";
        print '     <list>'."\n";

        for my $entry (@entries) {

            if ($activeListName=~/(Allowed Ports)|(Internet Ports)|(Peer to Peer Ports)/) {

                printGeneratedListNumbers($entry);

            } else {

                printGeneratedList($entry);

            }

        }

        print '     </list>'."\n";
        print '     </activeListEntries>'."\n";
        print '   </ActiveList>'."\n";
        print '</archive>'."\n";
        last;
    }   
}

 

if ($found==0) {

    print STDERR "Could not find your ActiveList: $activeListName\n";

}

close (IN);
exit;

sub printGeneratedList (){

    my ($input) = @_;

    my $result = "";
     $result .='           <map>'."\n";
     $result .='             <count>1</count>'."\n";
     $result .="              <creationTime>$getTime</creationTime>\n";
     $result .="              <lastSeenTime>$getTime</lastSeenTime>\n";
     $result .='              <values>'."\n";
     $result .='                 <list>'."\n";
     @tokens = split(/,/, $input);
     foreach my $token (@tokens) {
          $result .= "               <string>$token</string>\n";
     }
     $result .='                 </list>'."\n";
     $result .='              </values>'."\n";
     $result .='           </map>'."\n";

        print $result;  #Write

}

 

sub printGeneratedListNumbers (){

    my ($input) = @_;

    my $result = "";
     $result .='           <map>'."\n";
     $result .='             <count>1</count>'."\n";  
     $result .="              <creationTime>$getTime</creationTime>\n";
     $result .="              <lastSeenTime>$getTime</lastSeenTime>\n";
     $result .='              <values>'."\n";
     $result .='                 <list>'."\n";

    # integers/numbers have to be in HEX

    $result .= sprintf("               <string>%x</string>\n", $input);
     $result .='                 </list>'."\n";
     $result .='              </values>'."\n";
     $result .='           </map>'."\n";
 
        print $result;  #Write

}

