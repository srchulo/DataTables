use Test::More;
use CGI::Simple;
use DBI;
use Data::Compare qw/Compare/;
use FindBin qw/$Bin/;
use DataTables;

#
# tests for DataTables 1.10 interface
#

eval "use DBD::SQLite";
plan skip_all => "DBD::SQLite required for this test script." if $@;

plan tests => 4;

my @tests = (
    # -----------------------------------------------------------------------------
    # test standard view, no filter, no order, 10 records
    {
        expected => {
            "recordsFiltered" => 50,
            "draw" => 1,
            "recordsTotal" => 50,
            "data" => [
                ["Gecko","Firefox 1.0","Win 98+ / OSX.2+","1.7","A"],
                ["Gecko","Firefox 1.5","Win 98+ / OSX.2+","1.8","A"],
                ["Gecko","Firefox 2.0","Win 98+ / OSX.2+","1.8","A"],
                ["Gecko","Firefox 3.0","Win 2k+ / OSX.3+","1.9","A"],
                ["Gecko","Camino 1.0","OSX.2+","1.8","A"],
                ["Gecko","Camino 1.5","OSX.3+","1.8","A"],
                ["Gecko","Netscape 7.2","Win 95+ / Mac OS 8.6-9.2","1.7","A"],
                ["Gecko","Netscape Browser 8","Win 98SE+","1.7","A"],
                ["Gecko","Netscape Navigator 9","Win 98+ / OSX.2+","1.8","A"],
                ["Gecko","Mozilla 1.0","Win 95+ / OSX.1+","1","A"],
            ]
        },
        params => {
            'draw' => 1,
            'columns[0][data]' => 0,
            'columns[0][name]' => undef,
            'columns[0][searchable]' => 'true',
            'columns[0][orderable]' => 'true',
            'columns[0][search][value]' => undef,
            'columns[0][search][regex]' => 'false',
            'columns[1][data]' => 1,
            'columns[1][name]' => undef,
            'columns[1][searchable]' => 'true',
            'columns[1][orderable]' => 'true',
            'columns[1][search][value]' => undef,
            'columns[1][search][regex]' => 'false',
            'columns[2][data]' => 2,
            'columns[2][name]' => undef,
            'columns[2][searchable]' => 'true',
            'columns[2][orderable]' => 'true',
            'columns[2][search][value]' => undef,
            'columns[2][search][regex]' => 'false',
            'columns[3][data]' => 3,
            'columns[3][name]' => undef,
            'columns[3][searchable]' => 'true',
            'columns[3][orderable]' => 'true',
            'columns[3][search][value]' => undef,
            'columns[3][search][regex]' => 'false',
            'columns[4][data]' => 4,
            'columns[4][name]' => undef,
            'columns[4][searchable]' => 'true',
            'columns[4][orderable]' => 'true',
            'columns[4][search][value]' => undef,
            'columns[4][search][regex]' => 'false',
            'order[0][column]' => 0,
            'order[0][dir]' => 'asc',
            'start' => 0,
            'length' => 10,
            'search[value]' => undef,
            'search[regex]' => 'false',
        },
    },
    # -----------------------------------------------------------------------------
    # test with filter/search, no order
    {
        expected => {
            "recordsFiltered" => 2,
            "draw" => 1,
            "recordsTotal" => 50,
            "data" => [
                ["Gecko","Camino 1.0","OSX.2+","1.8","A"],
                ["Gecko","Camino 1.5","OSX.3+","1.8","A"],
            ]
        },
        params => {
            'draw' => 1,
            'columns[0][data]' => 0,
            'columns[0][name]' => undef,
            'columns[0][searchable]' => 'true',
            'columns[0][orderable]' => 'true',
            'columns[0][search][value]' => undef,
            'columns[0][search][regex]' => 'false',
            'columns[1][data]' => 1,
            'columns[1][name]' => undef,
            'columns[1][searchable]' => 'true',
            'columns[1][orderable]' => 'true',
            'columns[1][search][value]' => undef,
            'columns[1][search][regex]' => 'false',
            'columns[2][data]' => 2,
            'columns[2][name]' => undef,
            'columns[2][searchable]' => 'true',
            'columns[2][orderable]' => 'true',
            'columns[2][search][value]' => undef,
            'columns[2][search][regex]' => 'false',
            'columns[3][data]' => 3,
            'columns[3][name]' => undef,
            'columns[3][searchable]' => 'true',
            'columns[3][orderable]' => 'true',
            'columns[3][search][value]' => undef,
            'columns[3][search][regex]' => 'false',
            'columns[4][data]' => 4,
            'columns[4][name]' => undef,
            'columns[4][searchable]' => 'true',
            'columns[4][orderable]' => 'true',
            'columns[4][search][value]' => undef,
            'columns[4][search][regex]' => 'false',
            'order[0][column]' => 0,
            'order[0][dir]' => 'asc',
            'start' => 0,
            'length' => 10,
            'search[value]' => 'cam',
            'search[regex]' => 'false',
        },
    },
    # -----------------------------------------------------------------------------
    # test with filter/search, order by OS desc
    {
        expected => {
            "recordsFiltered" => 2,
            "draw" => 1,
            "recordsTotal" => 50,
            "data" => [
                ["Gecko","Camino 1.5","OSX.3+","1.8","A"],
                ["Gecko","Camino 1.0","OSX.2+","1.8","A"],
            ]
        },
        params => {
            'draw' => 1,
            'columns[0][data]' => 0,
            'columns[0][name]' => undef,
            'columns[0][searchable]' => 'true',
            'columns[0][orderable]' => 'true',
            'columns[0][search][value]' => undef,
            'columns[0][search][regex]' => 'false',
            'columns[1][data]' => 1,
            'columns[1][name]' => undef,
            'columns[1][searchable]' => 'true',
            'columns[1][orderable]' => 'true',
            'columns[1][search][value]' => undef,
            'columns[1][search][regex]' => 'false',
            'columns[2][data]' => 2,
            'columns[2][name]' => undef,
            'columns[2][searchable]' => 'true',
            'columns[2][orderable]' => 'true',
            'columns[2][search][value]' => undef,
            'columns[2][search][regex]' => 'false',
            'columns[3][data]' => 3,
            'columns[3][name]' => undef,
            'columns[3][searchable]' => 'true',
            'columns[3][orderable]' => 'true',
            'columns[3][search][value]' => undef,
            'columns[3][search][regex]' => 'false',
            'columns[4][data]' => 4,
            'columns[4][name]' => undef,
            'columns[4][searchable]' => 'true',
            'columns[4][orderable]' => 'true',
            'columns[4][search][value]' => undef,
            'columns[4][search][regex]' => 'false',
            'order[0][column]' => 2,
            'order[0][dir]' => 'desc',
            'start' => 0,
            'length' => 10,
            'search[value]' => 'cam',
            'search[regex]' => 'false',
        },
    },
    # -----------------------------------------------------------------------------
    # test with filter/search + multiple order
    {
        expected => {
            "recordsFiltered" => 7,
            "draw" => 1,
            "recordsTotal" => 50,
            "data" => [
                ["Misc","NetFront 3.4","Embedded devices","-","A"],
                ["Misc","IE Mobile","Windows Mobile 6","-","C"],
                ["Misc","PSP browser","PSP","-","C"],
                ["Misc","NetFront 3.1","Embedded devices","-","C"],
                ["Misc","Links","Text only","-","X"],
                ["Misc","Lynx","Text only","-","X"],
                ["Misc","Dillo 0.8","Embedded devices","-","X"],
            ]
        },
        params => {
            'draw' => 1,
            'columns[0][data]' => 0,
            'columns[0][name]' => undef,
            'columns[0][searchable]' => 'true',
            'columns[0][orderable]' => 'true',
            'columns[0][search][value]' => undef,
            'columns[0][search][regex]' => 'false',
            'columns[1][data]' => 1,
            'columns[1][name]' => undef,
            'columns[1][searchable]' => 'true',
            'columns[1][orderable]' => 'true',
            'columns[1][search][value]' => undef,
            'columns[1][search][regex]' => 'false',
            'columns[2][data]' => 2,
            'columns[2][name]' => undef,
            'columns[2][searchable]' => 'true',
            'columns[2][orderable]' => 'true',
            'columns[2][search][value]' => undef,
            'columns[2][search][regex]' => 'false',
            'columns[3][data]' => 3,
            'columns[3][name]' => undef,
            'columns[3][searchable]' => 'true',
            'columns[3][orderable]' => 'true',
            'columns[3][search][value]' => undef,
            'columns[3][search][regex]' => 'false',
            'columns[4][data]' => 4,
            'columns[4][name]' => undef,
            'columns[4][searchable]' => 'true',
            'columns[4][orderable]' => 'true',
            'columns[4][search][value]' => undef,
            'columns[4][search][regex]' => 'false',
            'order[0][column]' => 4,
            'order[0][dir]' => 'asc',
            'order[1][column]' => 2,
            'order[1][dir]' => 'desc',
            'start' => 0,
            'length' => 10,
            'search[value]' => 'misc',
            'search[regex]' => 'false',
        },
    },
);

foreach my $test_href ( @tests ) {
    run_test($test_href->{params}, $test_href->{expected});
}


sub run_test {
    my $params = shift;
    my $expected = shift;

    my $q = CGI::Simple->new($params);
    
    my $dbname = $Bin . '/db/datatables_demo_data.sqlite';
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

    ok( Compare($data, $expected), 'data fetched via DataTables looks like expected' );
    
} # /run_test
