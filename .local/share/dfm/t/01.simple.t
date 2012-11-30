#!perl

use Test::More;
use strict;
use FindBin qw($Bin);
use English qw( -no_match_vars );
use Fcntl ':mode';

use Test::Trap qw/ :output(systemsafe) /;

require "$Bin/helper.pl";

# unset the repo env override so that test work properly
$ENV{'DFM_REPO'} = undef;

my $file_slurp_available = load_mod('File::Slurp qw(read_file)');

check_minimum_test_more_version();

my $profile_filename = ( lc($OSNAME) eq 'darwin' ) ? '.profile' : '.bashrc';

subtest 'simplest' => sub {
    focus('simplest');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('simple');
    ( $home, $repo ) = minimum_home( 'simple2', { origin => $origin } );
    `touch $repo/.bashrc.load`;    # make sure there's a loader

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -d "$home/.backup",      'main backup dir exists' );
    ok( -l "$home/bin",          'bin is a symlink' );
    ok( !-e "$home/.git",        ".git does not exist in \$home" );
    ok( !-e "$home/.gitignore",  '.gitignore does not exist' );
    ok( !-e "$home/.dfminstall", '.dfminstall does not exist' );
    is( readlink("$home/bin"), '.dotfiles/bin', 'bin points into repo' );

SKIP: {
        skip 'File::Slurp not found', 1 unless $file_slurp_available;

        ok( read_file("$home/$profile_filename") =~ /bashrc.load/,
            "loader present in $profile_filename" );
    }

    ok( !-e "$home/README.md", 'no README.md in homedir' );
    ok( !-e "$home/t",         'no t dir in homedir' );
};

subtest 'dangling symlinks' => sub {
    focus('dangling');

    my ( $home, $repo ) = minimum_home_with_ssh('dangling');

    symlink( ".dotfiles/.other",         "$home/.other" );
    symlink( "../.dotfiles/.ssh/.other", "$home/.ssh/.other" );

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( !-l "$home/.other",      'dangling symlink is gone' );
    ok( !-l "$home/.ssh/.other", 'dangling symlink is gone' );
};

subtest 'with . ssh recurse( no . ssh dir )' => sub {
    focus('recurse_no');

    my ( $home, $repo ) = minimum_home_with_ssh( 'ssh_no', 1 );
    `touch $repo/.bashrc.load`;    # make sure there's a loader

    run_dfm( $home, $repo, 'install', '--verbose' );

    check_ssh_recurse($home);
};

subtest 'with .ssh recurse (with .ssh dir)' => sub {
    focus('recurse_with');

    my ( $home, $repo ) = minimum_home_with_ssh('ssh_with');
    `touch $repo/.bashrc.load`;    # make sure there's a loader

    run_dfm( $home, $repo, 'install', '--verbose' );

    check_ssh_recurse($home);
};

subtest 'with bin recurse' => sub {
    focus('bin_recurse');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin )
        = minimum_home( 'bin_recurse', { dfminstall_contents => 'bin' } );

    `mkdir -p $home/bin`;
    `echo "another bin" > $home/bin/another`;

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -d "$home/.backup", 'main backup dir exists' );
    ok( -d "$home/bin",     'bin is a directory' );
    ok( -l "$home/bin/dfm", 'dfm is a symlink' );
    ok( -e "$home/bin/another" && !-l "$home/bin/another",
        'existing binary still intact' );
};

subtest 'check deprecated recursion' => sub {
    focus('deprec');

    my ( $home, $repo );

    ( $home, $repo )
        = minimum_home( 'deprecated_recurse',
        { dfminstall_contents => 'bin' } );

    run_dfm( $home, $repo, 'install', '--verbose' );

    like(
        $trap->stdout,
        qr(using implied recursion in .dfminstall is deprecated),
        'warning present'
    );
    like( $trap->stdout, qr($repo/.dfminstall), '.dfminstall path present' );
    like(
        $trap->stdout,
        qr('bin recurse'),
        'proper .dfminstall contents mentioned'
    );

    ( $home, $repo )
        = minimum_home( 'deprecated_recurse',
        { dfminstall_contents => 'bin recurse' } );

    run_dfm( $home, $repo, 'install', '--verbose' );

    unlike(
        $trap->stdout,
        qr(using implied recursion in .dfminstall is deprecated),
        'warning present when keyword used'
    );

};

subtest 'switch to recursion' => sub {
    focus('rec_switch');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('switch_recurse');

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -d "$home/.backup", 'main backup dir exists' );
    ok( -l "$home/bin",     'bin is a symlink' );

    `echo "bin recurse" >> $repo/.dfminstall`;

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -d "$home/.backup", 'main backup dir exists' );
    ok( -d "$home/bin",     'bin is a directory' );
    ok( -l "$home/bin/dfm", 'dfm is a symlink' );
};

subtest 'parallel recursions work' => sub {
    focus('parallel_rec');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin )
        = minimum_home( 'parallel_recursions',
        { dfminstall_contents => "test1 recurse\ntest2 recurse" } );

    `mkdir -p $repo/test1`;
    `touch $repo/test1/file1`;
    `mkdir -p $repo/test2`;
    `touch $repo/test2/file2`;

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -d "$home/test1",       'first directory present' );
    ok( -l "$home/test1/file1", 'first file is symlink' );
    ok( -d "$home/test2",       'second directory present' );
    ok( -l "$home/test2/file2", 'second file is symlink' );
};

subtest 'exec option' => sub {
    focus('exec_option');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home(
        'exec option',
        {   dfminstall_contents =>
                "script1.sh exec\nscript1.sh skip\ntest2 recurse"
        }
    );

    # set up non-recurse script that needs to be set executable
    `echo "#!/bin/sh\n\necho 'message1';\ntouch testfile" > '$repo/script1.sh'`;

    # set up recurse script that is already executable
    `mkdir -p '$repo/test2'`;
    `echo "script2.sh exec" > '$repo/test2/.dfminstall'`;
    `echo "#!/bin/sh\n\necho 'message2';\ntouch testfile2" > '$repo/test2/script2.sh'`;
    `chmod +x '$repo/test2/script2.sh'`;

    run_dfm( $home, $repo, 'install', '--verbose' );

    like( $trap->stdout, qr/message1/,
        'output contains output from script1' );
    ok( -e "$home/testfile",    'file created by script1 exists' );
    ok( !-e "$home/script1.sh", 'script1 is not symlinked into home' );
    ok( -x "$repo/script1.sh",  'script1 file is executable' );

    like( $trap->stdout, qr/message2/,
        'output contains output from script2' );
    ok( -e "$home/test2/testfile2",  'file created by script2 exists' );
    ok( -x "$repo/test2/script2.sh", 'script2 file is executable' );
};

subtest 'switch to skip' => sub {
    focus('switch_to_skip');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('switch_to_skip');

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -l "$home/bin", 'bin is symlinked' );

    # now add skip
    `echo "bin skip" >> $repo/.dfminstall`;

    trap {
        $ENV{HOME} = $home;
        DFM::run_dfm( "$repo/bin", 'install', '--verbose' );
    };

    ok( !-e "$home/bin", 'bin directory is not symlinked' );
};

subtest 'spaces in username' => sub {
    focus('spaces_in_username');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('user name');

    `mkdir '$home/bin'`;
    `touch '$home/bin/old'`;

    run_dfm( $home, $repo, 'install', '--verbose' );

    ok( -l "$home/bin",             'bin is symlinked' );
    ok( -e "$home/.backup/bin/old", 'old files are in backup' );
};

subtest 'chmod option' => sub {
    focus('chmod_option');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('chmod_option');

    `echo ".ssh recurse" >> $repo/.dfminstall`;
    `mkdir -p $repo/.ssh`;
    `touch $repo/.ssh/config`;
    `chmod 0644 $repo/.ssh/config`;
    `echo "config chmod 0600" > $repo/.ssh/.dfminstall`;

    is( ( sprintf "%04o", S_IMODE( ( stat("$repo/.ssh/config") )[2] ) ),
        '0644', 'permissions before are correct' );

    run_dfm( $home, $repo, 'install', '--verbose' );

    is( ( sprintf "%04o", S_IMODE( ( stat("$repo/.ssh/config") )[2] ) ),
        '0600', 'permissions after are correct' );

    subtest 'no mode' => sub {
        `chmod 0644 $repo/.ssh/config`;

        `echo "config chmod" > $repo/.ssh/.dfminstall`;

        run_dfm( $home, $repo, 'install', '--verbose' );

        like(
            $trap->stdout,
            qr/chmod option requires a mode/,
            'error message in output'
        );
        is( ( sprintf "%04o", S_IMODE( ( stat("$repo/.ssh/config") )[2] ) ),
            '0644', 'permissions are untouched' );
    };

    subtest 'bad mode' => sub {
        `chmod 0644 $repo/.ssh/config`;

        `echo "config chmod himom" > $repo/.ssh/.dfminstall`;

        run_dfm( $home, $repo, 'install', '--verbose' );

        like( $trap->stdout, qr/bad mode 'himom'/,
            'error message in output' );
        is( ( sprintf "%04o", S_IMODE( ( stat("$repo/.ssh/config") )[2] ) ),
            '0644', 'permissions are untouched' );
    };
};

subtest 'repo dir env override' => sub {
    focus('repo_dir_override');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('first');

    local $ENV{'DFM_REPO'} = $repo;

    # simulate running dfm from the homedir instead of inside the repo
    run_dfm( $home, $home, 'install', '--verbose' );

    ok( -d "$home/.backup",      'main backup dir exists' );
    ok( -l "$home/bin",          'bin is a symlink' );
    ok( !-e "$home/.git",        ".git does not exist in \$home" );
    ok( !-e "$home/.gitignore",  '.gitignore does not exist' );
    ok( !-e "$home/.dfminstall", '.dfminstall does not exist' );
    is( readlink("$home/bin"), '.dotfiles/bin', 'bin points into repo' );
    ok( !-e "$home/README.md", 'no README.md in homedir' );
    ok( !-e "$home/t",         'no t dir in homedir' );
};

subtest 'repo dir env override not in home' => sub {
    focus('repo_dir_override_not_in_home');

    my ( $home, $repo, $origin );
    ( $home, $repo, $origin ) = minimum_home('first');
    `touch $repo/.bashrc.load`;    # make sure there's a loader

    diag("$repo");
    `rm -rf $Bin/rep`;
    `mv $repo $Bin/rep`;
    local $ENV{'DFM_REPO'} = "$Bin/rep";

    # simulate running dfm from the homedir instead of inside the repo
    run_dfm( $home, $home, 'install', '--verbose' );

    ok( -d "$home/.backup",      'main backup dir exists' );
    ok( -l "$home/bin",          'bin is a symlink' );
    ok( !-e "$home/.git",        ".git does not exist in \$home" );
    ok( !-e "$home/.gitignore",  '.gitignore does not exist' );
    ok( !-e "$home/.dfminstall", '.dfminstall does not exist' );
    is( readlink("$home/bin"), '../rep/bin', 'bin points into repo' );
    ok( !-e "$home/README.md", 'no README.md in homedir' );
    ok( !-e "$home/t",         'no t dir in homedir' );

SKIP: {
        skip 'File::Slurp not found', 1 unless $file_slurp_available;

        ok( read_file("$home/$profile_filename") =~ /bashrc.load/,
            "loader present in $profile_filename" );
    }

};

subtest 'command first' => sub {
    focus('command_first');

    my ( $home, $repo, $origin ) = minimum_home('simple');

    run_dfm( $home, $repo, '--verbose', 'install' );

    like(
        $trap->stdout,
        qr/command should be first/,
        'correct error message'
    );
};

done_testing;

sub check_ssh_recurse {
    my ($home) = @_;
    ok( -d "$home/.backup",          'main backup dir exists' );
    ok( -l "$home/bin",              'bin is a symlink' );
    ok( !-e "$home/.git",            '.git does not exist in $home' );
    ok( !-e "$home/.gitignore",      '.gitignore does not exist' );
    ok( !-e "$home/.dfminstall",     '.dfminstall does not exist' );
    ok( !-l "$home/.ssh",            '.ssh is not a symlink' );
    ok( !-e "$home/.ssh/.gitignore", '.ssh/.gitignore does not exist' );
    is( readlink("$home/bin"), '.dotfiles/bin', 'bin points into repo' );
    ok( -d "$home/.ssh/.backup", 'ssh backup dir exists' );

SKIP: {
        skip 'File::Slurp not found', 1 unless $file_slurp_available;

        ok( read_file("$home/$profile_filename") =~ /bashrc.load/,
            "loader present in $profile_filename" );
    }

    ok( !-e "$home/README.md", 'no README.md in homedir' );
    ok( !-e "$home/t",         'no t dir in homedir' );
}
