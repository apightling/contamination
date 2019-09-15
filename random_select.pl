#!/usr/bin/perl

open(FH,"$ARGV[0]") or die "\nUSAGE: random_select.pl file.txt number_to_select\n\n";
my %numbers=();
my $count=1;while (<FH>)
        {
                $numbers{$count}=$_;
                ++$count;
        }

my $limit=scalar (keys %numbers);

$count=1;

while ($count <= $ARGV[1])
        {
                my $random_number=int(rand($limit));
                print $numbers{$random_number};
                ++$count;
        }

