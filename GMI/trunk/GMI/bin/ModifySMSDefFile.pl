#!/usr/local/bin/perl

# name of SMS file to modify
my $smsFile=$ARGV[0];
my $uniqueId=$ARGV[1];

open (inputFile, "<$smsFile");
my $returnCode = $?;
if ($returnCode != 0) {
   print "Could not open file $smsFile\n";
   return $returnCode;
}

# read file into an array
@fileLines = <inputFile>;
$numLines = @fileLines;

for ($loopCounter = 0; $loopCounter < $numLines; $loopCounter +=1) {
    $fileLines[$loopCounter] =~ s/GMI/$uniqueId/;
   print $fileLines[$loopCounter];
}
