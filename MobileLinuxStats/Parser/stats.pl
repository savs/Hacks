#!/usr/bin/perl -w
#
# A very rough-and-ready script to parse mbox archives for mailman lists and generate basic statistics
# It will parse a folder of lists containing monthly mailman archives.
# Run it from the top-level directory that contains the projects (each project containing lists)

use strict;
use Mail::Mbox::MessageParser;
use GD::Graph::bars;
use Data::Dumper;

my $verbose = 0;
my $debug = 0;

# Configure your list of projects here
# See also get_archives.sh
my @projects = ("Tizen", "MeeGo", "Maemo");
#my @projects = ("Maemo");

Mail::Mbox::MessageParser::SETUP_CACHE( { 'file_name' => '/tmp/mboxcache'});
my %month; @month{qw/January February March April May June July August September October November December/} = (1 .. 12);
my %list_stats;
my $max_mails = 0;


# GD function
sub save_chart
{
	my $chart = shift or die "Need a chart!";
	my $name = shift or die "Need a name!";
	local(*OUT);

	my $ext = $chart->export_format;

	open(OUT, ">$name.$ext") or 
		die "Cannot open $name.$ext for write: $!";
	binmode OUT;
	print OUT $chart->gd->$ext();
	close OUT;
}

sub process_archives
{
    my $project = shift or die "Need a project name";
    
    # Parse a directory containing one or more folders named after the list name, containing mbox archives by year and month.
    # Mbox archives can optionally be compressed
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

    # Generate individual charts
    for my $list (keys %list_stats) {
        my @years_months;
        my @years_months_mails;

        print "$list\n" if $verbose;
        for my $year (sort keys % {$list_stats{$list}}) {
            print "Year: $year\n" if $verbose;
            for my $month (sort keys %{$list_stats{$list}{$year}}) {
                print "Month: $month\n" if $verbose;
                push @years_months, "$year-$month";
                #print "\t$year $month $list_stats{$list}{$year}{$month}\n" if $verbose;
                push @years_months_mails, $list_stats{$list}{$year}{$month};
            }
        }
        my @data = (\@years_months, \@years_months_mails);
        my $width = scalar @years_months * 50;
        my $graph = GD::Graph::bars->new($width,300);
        $graph->set(
            x_label => 'Month',
            y_label => 'Messages',
            title   => 'Messages per month',
            dclrs   => [ qw(purple)],
        ) or warn $graph->error;

        my $image = $graph->plot(\@data) or die "Unable to plot graph: " . $graph->error;
        save_chart($graph, "$project/$list");


    }

    # Generate aggregate chart, hash of hashes: year, month, mail count.
    # %HoH = (
    #    "2010"   => {
    #                   1 => "20",
    #                   2 => "31",
    #                   ...
    #                   12 => "9",
    #   }
    #    "2011"   => {
    #                   1 => "5",
    #                   2 => "122",
    #                   ...
    #                   12 => "3",
    #   }
    #    );
    my %aggregate;
    open(INDEX, ">$project/index.html") or die "Cannot open $project/index.html for write: $!";
    print INDEX "<html><head><title>Mailing list statistics</title></head<body><h1>Mailing list statistics</h1>";
    print INDEX "<h2>Aggregated results</h2>";
    print INDEX "<img src='aggregate.gif' />";

    for my $list (keys %list_stats) {

        for my $year (sort keys % {$list_stats{$list}}) {
            #if (!$aggregate{$year}) {
            #    $aggregate{$year} = $year;
            #}
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
        print INDEX "<h2>$list</h2>";
        print INDEX "<img src='" . $list . ".gif'/>";

    }
    print INDEX "</body></html>";
    close INDEX;

    print "\n" if $debug;

    my @years_months;
    my @years_months_mails;
    for my $year (sort keys %aggregate) {
        print "Year: $year\n" if $debug;
        for my $month (sort keys %{$aggregate{$year}}) {
            print "  Month: $month " if $debug;
            print "  $aggregate{$year}{$month}\n" if $debug;
            push @years_months, "$year-$month";
            push @years_months_mails, "$aggregate{$year}{$month}";
        }
    }

    my @data = (\@years_months, \@years_months_mails);
    #print Dumper(@data);
    my $width = scalar @years_months * 50;
    my $graph = GD::Graph::bars->new($width,300);
    $graph->set(
        x_label => 'Month',
        y_label => 'Messages',
        title   => 'Messages per month',
        dclrs   => [ qw(purple)],
    ) or warn $graph->error;

    my $image = $graph->plot(\@data) or die "Unable to plot graph: " . $graph->error;
    save_chart($graph, "$project/aggregate");
}




foreach my $project (@projects) {
    process_archives($project);
}


__END__