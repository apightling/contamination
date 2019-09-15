#!/usr/bin/perl
use strict;
use warnings;

my $usage="\nUSAGE: select_reads.pl file_1.fq file_2.fq percent_contamination contam_file_1.fq contam_file_2.fq output_prefix\n\n";

my $forward=$ARGV[0] or die $usage;
my $reverse=$ARGV[1] or die $usage;
my $percent_contamination=$ARGV[2] or die $usage;
my $forward_contam=$ARGV[3] or die $usage;
my $reverse_contam=$ARGV[4] or die $usage;
my $prefix=$ARGV[5] or die $usage;

my $percent_noncontam=(100-$percent_contamination)/100;
my (%forward, %reverse, %forward_contam, %reverse_contam);

#put forward reads into array, randomly select reads from array and put them into a %forward with $id as key and fastq entry as value

open(FH,"<$forward");
my @forward=<FH>;
close FH;
my $precursor=$forward[0];
chomp $precursor;
$precursor=~s/\_.*//;
$precursor=$precursor.'_';

$forward=join('', @forward);
@forward=split($precursor,$forward);
shift @forward;

my $num_reads=int($percent_noncontam*scalar @forward);
my $num_reads_contam=scalar @forward - $num_reads;

my $count=0;

while ($count < $num_reads)
	{
		my $scalar=scalar @forward;
		my $random=int(rand($scalar));
		my $read= $precursor.$forward[$random];
		my @read=split("\n",$read);
		my $id= $read[0];
		$id=~s/\/.*/\//;
		$forward{$id}=$read;
		splice @forward, $random, 1;
		++$count;
	}

#put reverse reads into %reverse with $id as key and fastq entry as value

open(FH, "<$reverse");

my @reverse=<FH>;
close FH;
$reverse=join('', @reverse);
@reverse=split($precursor,$reverse);
shift @reverse;

foreach my $read (@reverse)
	{
		$read=$precursor.$read;
		my @read=split("\n",$read);
		my $id= $read[0];
		$id=~s/\/.*/\//;
		$reverse{$id}=$read;
	}

#store all forward and reverse reads in %final_forward and %final_reverse

my (%final_forward,%final_reverse);

foreach (keys %forward)
	{
		$final_forward{$_}=$forward{$_};
		$final_reverse{$_}=$reverse{$_};
	}

#put forward_contam reads into array, randomly select reads from array and put them into a %forward_contam with $id as key and fastq entry as value

open(FH,"<$forward_contam");
my @forward_contam=<FH>;
close FH;
$precursor=$forward_contam[0];
chomp $precursor;
$precursor=~s/\_.*//;
$precursor=$precursor.'_';
$forward_contam=join('', @forward_contam);
@forward_contam=split($precursor,$forward_contam);
shift @forward_contam;

$count=0;

while ($count < $num_reads_contam)
        {
                my $scalar=scalar @forward_contam;
                my $random=int(rand($scalar));
                my $read=$precursor.$forward_contam[$random];
                my @read=split("\n",$read);
                my $id= $read[0];
                $id=~s/\/.*/\//;
                $forward_contam{$id}=$read;
                splice @forward_contam, $random, 1;
                ++$count;
        }

#put reverse_contam reads into %reverse_contam with $id as key and fastq entry as value

open(FH, "<$reverse_contam");

my @reverse_contam=<FH>;
close FH;
$reverse_contam=join('', @reverse_contam);
@reverse_contam=split($precursor,$reverse_contam);
shift @reverse_contam;

foreach my $read (@reverse_contam)
        {
                $read=$precursor.$read;
                my @read=split("\n",$read);
                my $id= $read[0];
                $id=~s/\/.*/\//;
                $reverse_contam{$id}=$read;
        }

#store all forward_contam and reverse_contam reads in %final_forward and %final_reverse

foreach (keys %forward_contam)
        {
                $final_forward{$_}=$forward_contam{$_};
                $final_reverse{$_}=$reverse_contam{$_};
        }

#print all reads to files

my $label1=$prefix.'_1.fq';
my $label2=$prefix.'_2.fq';

open(FH,">>$label1");
open(FH1,">>$label2");

foreach (keys %final_forward)
	{
		print FH $final_forward{$_};
		print FH1 $final_reverse{$_};
	}
close FH;
close FH1;

