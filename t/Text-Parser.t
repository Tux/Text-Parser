use strict;
use warnings;

use Test::More;
use Test::Exception;

BEGIN { use_ok 'Text::Parser'; }

my $fname = 'text-simple.txt';

my $pars = new Text::Parser;
throws_ok { $pars->filename($fname) } 'Text::Parser::Exception',
    'No file by this name';
throws_ok { $pars->read($fname); } 'Text::Parser::Exception',
    'Throws exception for non-existent file';

lives_ok { $pars->read(); } 'Returns doing nothing';
is( $pars->lines_parsed, 0, 'Nothing parsed' );
is_deeply( [ $pars->get_records ], [], 'No data recorded' );
is( $pars->last_record, undef, 'No records' );
is( $pars->pop_record,  undef, 'Nothing on stack' );

my $content = "This is a file with one line\n";
lives_ok { $pars->filename( 't/' . $fname ); } 'Now I can open the file';
lives_ok { $pars->read; } 'Reads the file now';
is_deeply( [ $pars->get_records ], [$content], 'Get correct data' );
is( $pars->lines_parsed, 1,        '1 line parsed' );
is( $pars->last_record,  $content, 'Worked' );
is( $pars->pop_record,   $content, 'Popped' );
is( $pars->lines_parsed, 1,        'Still lines_parsed returns 1' );

TODO: {
    local $TODO
        = 'This functionality is not yet implemented properly. The current code doesnt work as expected on all operating systems. Some operating systems actually treat output files as readable, and some dont';
    open OUTFILE, ">example";
    throws_ok { $pars->filehandle( \*OUTFILE ); } 'Text::Parser::Exception',
        'Throws no exception for reading an output file handle, because output file handles are readable!';
    close OUTFILE;
    `rm -rf example`;
    throws_ok { $pars->filehandle( \*STDOUT ); } 'Text::Parser::Exception',
        'No issues in reading from STDOUT';
}
lives_ok { $pars->filehandle( \*STDIN ); } 'No issues in reading from STDIN';

lives_ok { $pars->read( 't/' . $fname ); }
'reads the contents of a file without dying';
is( $pars->last_record,  $content, 'Last record is correct' );
is( $pars->lines_parsed, 1,        'Read only one line' );
is_deeply( [ $pars->get_records ], [$content], 'Got correct file content' );

my $add = "This record is added";
lives_ok { $pars->save_record($add); } 'Add another record';
is( $pars->lines_parsed, 1,    'Still only 1 line parsed' );
is( $pars->last_record,  $add, 'Last added record' );
is_deeply(
    [ $pars->get_records ],
    [ $content, $add ],
    'But will contain two elements'
);

is( $pars->pop_record,   $add,     'Popped a record' );
is( $pars->lines_parsed, 1,        'Still only 1 line parsed' );
is( $pars->last_record,  $content, 'Now the last record is the one earlier' );
is_deeply( [ $pars->get_records ],
    [$content], 'Got correct content after pop' );

done_testing;
