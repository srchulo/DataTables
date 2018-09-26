#!perl

use strict;
use warnings;
use v5.20;
use FindBin qw/$Bin/;
use lib $Bin . '/../lib';
use DataTables;
use CGI::Simple;
use DBI;
use Data::Compare qw/Compare/;
use FindBin qw/$Bin/;
use Data::Dumper qw/Dumper/;

my @tests = (
    {
        expected => {
          'aaData' => [
                        [
                          'Gecko',
                          'Camino 1.5',
                          'OSX.3+',
                          '1.8',
                          'A'
                        ],
                        [
                          'Gecko',
                          'Netscape 7.2',
                          'Win 95+ / Mac OS 8.6-9.2',
                          '1.7',
                          'A'
                        ],
                        [
                          'Gecko',
                          'Netscape Browser 8',
                          'Win 98SE+',
                          '1.7',
                          'A'
                        ]
                      ],
          'iTotalDisplayRecords' => 50,
          'iTotalRecords' => 50,
          'sEcho' => '7'
        },
        params => {
            iDisplayStart => 5,
            iDisplayLength => 3,
            bSearchable_0 => 'true',
            bSearchable_1 => 'true',
            bSearchable_2 => 'true',
            sEcho => 7,
             sSearch => "Camino", # TODO
        },
    }
);


my $params = $tests[0]->{params};
my $expected = $tests[0]->{expected};
my $q = CGI::Simple->new($params);

my $dbname = $Bin . '/../t/db/datatables_demo_data.sqlite';
my $dbh = DBI->connect("dbi:SQLite:$dbname","","",{sqlite_unicode => 1}) or die "Couldn't connect to database: " . DBI->errstr;

my $dt = DataTables->new(
    dbh => $dbh,
    query => $q,
    #where_clause => { -or => [{grade => "X"},{grade => 'X'}] },
    #where_clause => { grade => "U" },
);

#set table to select from
$dt->tables(["demo"]);

#set columns to select in same order as order of columns on page
$dt->columns([qw/engine browser platform version grade/]);

my $where_old = $dt->_generate_where_clause_old($q);
#print Dumper $where_old;

my %params = $q->Vars;
my $dtr = $dt->_create_datatables_request(\%params);

my $where_new = $dt->_generate_where_clause($q, $dtr);
#print Dumper $where_new;

#if you wish to do something with the json yourself
my $data = $dt->table_data;    

if( Compare($data, $expected) ) {
    say 'data fetched via DataTables looks like expected';
}else{
    say "data does not look like expected. Returned data:";
    print Dumper $data;
    
    print '-' x 60; print "\n";
    say "Expected data:";
    print Dumper $expected;
    
}




__END__
foreach my $test_href ( @tests ) {
    run_test($test_href->{params}, $test_href->{expected});
}


sub run_test {
    my $params = shift;
    my $expected = shift;

    my $q = CGI::Simple->new($params);
    
    my $dbname = $Bin . '/../t/db/datatables_demo_data.sqlite';
    my $dbh = DBI->connect("dbi:SQLite:$dbname","","",{sqlite_unicode => 1}) or die "Couldn't connect to database: " . DBI->errstr;
    
    my $dt = DataTables->new(
        dbh => $dbh,
        query => $q,
        #where_clause => { -or => [{grade => "X"},{grade => 'X'}] },
        #where_clause => { grade => "U" },
    );
    
    #set table to select from
    $dt->tables(["demo"]);
    
    #set columns to select in same order as order of columns on page
    $dt->columns([qw/engine browser platform version grade/]);
    
    #if you wish to do something with the json yourself
    my $data = $dt->table_data;    
    
    if( Compare($data, $expected) ) {
        say 'data fetched via DataTables looks like expected';
    }else{
        say "data does not look like expected. Data:";
        print Dumper $data;
        
        print '-' x 60; print "\n";      
    }
    
} # /run_test