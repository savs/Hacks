#!/usr/bin/perl -w
#
# A very rough-and-ready script to parse mbox archives for mailman lists and generate basic statistics
# It will parse a folder of lists containing monthly mailman archives.
# Run it from the top-level archive directory that contains the projects (each project containing lists)

# TODO add person recognition
# TODO add breakdown by day
# TODO add breakdown by list

use strict;
use Mail::Mbox::MessageParser;
use GD::Graph::bars;
use Data::Dumper;

my $verbose = 0;
my $debug = 1;

# Configure your list of projects here
# See also get_archives.sh
# For example:
# my @projects = ("Tizen", "MeeGo", "Maemo");
# TODO make this a split ' ' (find -d in archives) or specify projects on command line?
my @projects = ("Tizen", "MeeGo", "Maemo", "Ubuntu");

# TODO: replace MessageParser with something more sophisticated to get more detail
Mail::Mbox::MessageParser::SETUP_CACHE( { 'file_name' => '/tmp/mboxcache'});
my %month; @month{qw/January February March April May June July August September October November December/} = (1 .. 12);
my %list_stats;
my $max_mails = 0;


# Go through each mailing list archive and gather statistics
sub process_archives
{
    my $project = shift or die "Need a project name";
    
    # Parse a directory containing one or more folders named after the list name, containing mbox archives by year and month.
    # Mbox archives can optionally be compressed (feature of MessageParser)
    print "Project: $project\n";
    my @lists = `find $project/* -prune -type d`;

    # Process the archives
    foreach my $list (@lists) {

        chomp $list;
        my $list_name = substr $list, length "$project/";
        print "Parsing list: $list_name\n" if $debug;
        my @files = `find $project/$list_name/* -prune -name *.txt*`;
        my $month_count = scalar @files; # FIXME do something with this to calculate width
        print "Got $month_count files to process\n" if $debug;

        foreach my $file_name (@files) {
            chomp $file_name;
            # Remove the path
            my $local_file_name = substr $file_name, length "$project/$list_name/";
            # Remove the .txt.gz and divide into year and integer month
            my ($yyyy_month, @ignore) = split /\./, $local_file_name;
            my ($yyyy,$month) = split /-/, $yyyy_month;
            # zero pad the month to ensure it sorts correctly
            $month = sprintf("%02s",$month{$month});
            print "$yyyy $month\n" if $debug;

            # Parse the list
            my $file_handle = new FileHandle($file_name);
            my $folder_reader = new Mail::Mbox::MessageParser( {
                    'file_name' => $file_name,
                    'file_handle' => $file_handle,
                    'enable_cache' => 1,
                    'enable_grep' => 1,
                });

            die $folder_reader unless ref $folder_reader;
            my $mail_count = 0;
            while (!$folder_reader->end_of_file()) {
                my $email = $folder_reader->read_next_email();
                $mail_count++;
            }

            print "\t$month $yyyy: $mail_count\n" if $verbose;
            $list_stats{$list_name}{$yyyy}{$month} = $mail_count;
            if ($mail_count > $max_mails) {
                $max_mails = $mail_count;
            }
        }
    }
    print "Most traffic: $max_mails\n" if $verbose;

    my %aggregate;
    
    for my $list (keys %list_stats) {

        for my $year (sort keys % {$list_stats{$list}}) {
            for my $month (sort keys %{$list_stats{$list}{$year}}) {
                if (!$aggregate{$year}{$month}) {
                    print "$year $month set to $list_stats{$list}{$year}{$month}: " if $debug;
                    $aggregate{$year}{$month} = $list_stats{$list}{$year}{$month};
                    print "$aggregate{$year}{$month}\n" if $debug;
                } else {
                    print "$year $month adding $list_stats{$list}{$year}{$month} to $aggregate{$year}{$month}: " if $debug;
                    $aggregate{$year}{$month} += $list_stats{$list}{$year}{$month};
                    print "$aggregate{$year}{$month}\n" if $debug;
                }
            }
        }

    }
    print "\n" if $debug;

    my $fname = $project . "_stats.txt";
    open(DATA, ">../$fname") || die "Unable to open DATA: $!\n";

    my @years_months;
    my @years_months_mails;
    for my $year (sort keys %aggregate) {
        print "Year: $year\n" if $debug;
        for my $month (sort keys %{$aggregate{$year}}) {
            print "  Month: $month " if $debug;
            print "  $aggregate{$year}{$month}\n" if $debug;
            push @years_months, "$year-$month";
            push @years_months_mails, "$aggregate{$year}{$month}";
            print DATA "$year-$month,$aggregate{$year}{$month}\n";
            
        }
    }
    
    close(DATA);

}



foreach my $project (@projects) {
    process_archives($project);
}


__END__