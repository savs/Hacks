#!/usr/bin/perl -w
#
# Create rules to map legacy MovableType blog URLs to WordPress URLs.
# 
# Output is a series of Apache httpd mod_rewrite rules.
#
# My MovableType URLs are in the following formats:
# http://www.andrewsavory.com/blog/archives/001580.html -- individual posts where 001580 is the entry_id from mt_entry table)
# http://www.andrewsavory.com/blog/archives/2010_10.html -- monthly archives, appends YYYY_MM.html
#
#
# Default WordPress URLs are in the following formats:
# http://www.andrewsavory.co.uk/blog/?p=1555 -- individual posts where 1555 is the ID from the wp_posts table
# http://www.andrewsavory.co.uk/blog/?m=201110 -- monthly archives, appends YYYYMM
#
# Sane WordPress URLs (WP calls them 'Permalinks') can be in any format, but I configured as:
# http://www.andrewsavory.co.uk/blog/YYYY/1234/ -- where 1234 is post ID.
# Monthly then becomes:
# http://www.andrewsavory.co.uk/blog/date/YYYY/MM
#
# The following WordPress have no corresponding MT URLs and so can be ignored:
# http://www.andrewsavory.co.uk/blog/?cat=9 -- category archives, appends category number
# http://www.andrewsavory.co.uk/blog/?tag=conferences -- tag archives, appends tag name
# All of the above can have ?paged=N appended to list the next page in the sequence.

# BEFORE USE REMEMBER TO CONFIGURE DB CONNECTIONS

use DBI;
use strict;
use warnings;

my $debug = 0;
my %months;

# Get all the MovableType entries
my $mt_dbh = DBI->connect("dbi:Pg:dbname=FIXME;host=127.0.0.1", 'FIXME', 'FIXME') or die "Unable to connect: " . DBI->errstr . "\n";
my $mt_entries = $mt_dbh->selectall_hashref("select entry_id, entry_title, to_char(entry_created_on, 'yyyymm') as date, entry_blog_id from mt_entry order by entry_id", 'entry_id') or die "Unable to execute statement: " . $mt_dbh->errstr . "\n";

# Get all the WordPress entries
my $wp_dbh = DBI->connect("dbi:mysql:database=FIXME;host=localhost", 'FIXME', 'FIXME') or die "Unable to connect: " . DBI->errstr . "\n";
my $wp_posts = $wp_dbh->selectall_hashref('select ID, post_title from wp_posts order by ID', 'ID') or die "Unable to execute statement: " . $wp_dbh->errstr . "\n";

# Print out individual entry remap
print "        # Fix entry archives\n" if !$debug;
foreach my $mt_id (sort keys %$mt_entries) {
    print "$mt_id : $mt_entries->{$mt_id}->{entry_title}\n" if $debug;
    $months{$mt_entries->{$mt_id}->{date}} = 1;
    my $year = substr $mt_entries->{$mt_id}->{date}, 0, 4;
    my $month = substr $mt_entries->{$mt_id}->{date}, 4, 2;
    foreach my $wp_id (keys %$wp_posts) {
        if ($mt_entries->{$mt_id}->{entry_title} eq $wp_posts->{$wp_id}->{post_title}) {
            print "\t= $wp_id ($wp_posts->{$wp_id}->{post_title})\n" if $debug;
            $mt_entries->{$mt_id}->{ID} = $wp_id;
            $mt_entries->{$mt_id}->{UrlID} = sprintf("%06d", $mt_id);
            # There were two blogs: the main (1) and the mobile (2); they are now integrated in WordPress.
            if ($mt_entries->{$mt_id}->{entry_blog_id} == 1) {
                print '        RewriteRule ^/blog/archives/' . $mt_entries->{$mt_id}->{UrlID} . '.html$ /blog/' . $year . '/' . $wp_id . ' [R=301,L]' . "\n" if !$debug;
            } elsif ($mt_entries->{$mt_id}->{entry_blog_id} == 2) {
                print '        RewriteRule ^/moblog/archives/' . $mt_entries->{$mt_id}->{UrlID} . '.html$ /blog/' . $year . '/' . $wp_id . ' [R=301,L]' . "\n" if !$debug;
            }
        }
    }
}

# Print out monthly entry remap
print "\n" if $debug;
print "        # Fix monthly archives\n" if !$debug;
foreach my $yearmonth (sort keys %months) {
    print "orig: [$yearmonth] " if $debug;
    
    # MovableType did monthly as YYYY_MM
    my $mt_format_month = substr $yearmonth, 0, 4;
    $mt_format_month .= "_" . substr $yearmonth, 4, 2;

    # WordPress does YYYY/MM
    my $wp_format_month = substr $yearmonth, 0, 4;
    $wp_format_month .= "/" . substr $yearmonth, 4, 2;

    print "M: [$mt_format_month]\n" if $debug;
    print '        RewriteRule ^/blog/archives/' . $mt_format_month . '.html$ /blog/date/' . $wp_format_month . ' [R=301,L]' . "\n" if !$debug;
    print '        RewriteRule ^/moblog/archives/' . $mt_format_month . '.html$ /blog/date/' . $wp_format_month . ' [R=301,L]' . "\n" if !$debug;
}


__END__