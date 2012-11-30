#!perl

use Test::More;
use strict;
use FindBin qw($Bin);
use English qw( -no_match_vars );

use Test::Trap qw/ :output(systemsafe) /;

require "$Bin/helper.pl";

# unset the repo env override so that test work properly
$ENV{'DFM_REPO'} = undef;

my $file_slurp_available = load_mod('File::Slurp qw(read_file)');

check_minimum_test_more_version();

my $profile_filename = ( lc($OSNAME) eq 'darwin' ) ? '.profile' : '.bashrc';

subtest 'updates and mergeandinstall' => sub {
    focus('up_mi');

    my ( $home, $repo, $origin ) = minimum_home('host1');
    my ( $home2, $repo2 ) = minimum_home( 'host2', { origin => $origin } );

    add_file_and_push( $home, $repo );

    run_dfm( $home2, $repo2, 'updates' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    # remove the origin repo, to make sure that --no-fetch
    # still works (because the updates are already local,
    # --no-fetch doesn't refetch)
    `rm -rf $origin`;

    run_dfm( $home2, $repo2, 'updates', '--no-fetch' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    run_dfm( $home2, $repo2, 'mi' );

    like( $trap->stdout, qr/\.testfile/, 'message in output' );
    ok( -e "$repo2/.testfile", 'updated file is there' );
    ok( -l "$home2/.testfile", 'updated file is installed' );
};

# identical to above, with spaces
subtest 'spaces in username' => sub {
    focus('mi_spaces_in_username');

    my ( $home, $repo, $origin ) = minimum_home('host one');
    my ( $home2, $repo2 ) = minimum_home( 'host two', { origin => $origin } );

    add_file_and_push( $home, $repo );

    run_dfm( $home2, $repo2, 'updates' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    # remove the origin repo, to make sure that --no-fetch
    # still works (because the updates are already local,
    # --no-fetch doesn't refetch)
    `rm -rf '$origin'`;

    run_dfm( $home2, $repo2, 'updates', '--no-fetch' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    run_dfm( $home2, $repo2, 'mi' );

    like( $trap->stdout, qr/\.testfile/, 'message in output' );
    ok( -e "$repo2/.testfile", 'updated file is there' );
    ok( -l "$home2/.testfile", 'updated file is installed' );
};

subtest 'modifications in two repos, rebase' => sub {
    focus('rebase');

    my ( $home, $repo, $origin ) = minimum_home('host1_rebase');
    my ( $home2, $repo2 )
        = minimum_home( 'host2_rebase', { origin => $origin } );

    add_file_and_push( $home, $repo );
    add_file( $home2, $repo2, '.otherfile' );

    run_dfm( $home2, $repo2, 'updates' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    run_dfm( $home2, $repo2, 'mi' );
    like(
        $trap->stdout,
        qr/local changes detected/,
        'conflict message in output'
    );
    ok( !-e "$repo2/.testfile", 'updated file is still not there' );

    run_dfm( $home2, $repo2, 'mi', '--rebase' );

    like(
        $trap->stdout,
        qr/rewinding head to replay/,
        'git rebase info message seen'
    );
    ok( -e "$repo2/.testfile", 'updated file is there' );
    ok( -l "$home2/.testfile", 'updated file is installed' );

    run_dfm( $home2, $repo2, 'log' );
    unlike(
        $trap->stdout,
        qr/Merge remote-tracking branch 'origin\/master'/,
        'no git merge log message seen'
    );
};

subtest 'modifications in two repos, merge' => sub {
    focus('merge');

    my ( $home, $repo, $origin ) = minimum_home('host1_merge');
    my ( $home2, $repo2 )
        = minimum_home( 'host2_merge', { origin => $origin } );

    add_file_and_push( $home, $repo );
    add_file( $home2, $repo2, '.otherfile' );

    run_dfm( $home2, $repo2, 'updates' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    ok( !-e "$repo2/.testfile", 'updated file is not there' );

    run_dfm( $home2, $repo2, 'mi' );

    like(
        $trap->stdout,
        qr/local changes detected/,
        'conflict message in output'
    );
    ok( !-e "$repo2/.testfile", 'updated file is still not there' );

    run_dfm( $home2, $repo2, 'mi', '--merge' );

    like(
        $trap->stdout,
        qr/merge made.*recursive/i,
        'git merge info message seen'
    );
    ok( -e "$repo2/.testfile", 'updated file is there' );
    ok( -l "$home2/.testfile", 'updated file is installed' );

    run_dfm( $home2, $repo2, 'log' );

    like(
        $trap->stdout,
        qr/Merge remote(-tracking)? branch 'origin\/master'/,
        'git merge log message seen'
    );
};

subtest 'umi' => sub {
    focus('umi');

    my ( $home, $repo, $origin ) = minimum_home('host1');
    my ( $home2, $repo2 ) = minimum_home( 'host2', { origin => $origin } );

    add_file_and_push( $home, $repo );

    run_dfm( $home2, $repo2, 'umi' );

    like( $trap->stdout, qr/adding \.testfile/, 'message in output' );
    like( $trap->stdout, qr/\.testfile/,        'message in output' );
    ok( -e "$repo2/.testfile", 'updated file is there' );
    ok( -l "$home2/.testfile", 'updated file is installed' );
};

subtest 'non origin remote' => sub {
    focus('non_origin');

    my ( $home,  $repo,  $origin )  = minimum_home('host1');
    my ( $home2, $repo2, $origin2 ) = minimum_home('host2');

    # first, make a personal branch in repo 1, and add a new file
    run_dfm( $home, $repo, qw/checkout -b personal/ );
    add_file( $home, $repo, 'testfile' );
    run_dfm( $home, $repo, qw(push origin personal) );

    # on the second host, add the first as a remote
    # and install from the personal branch
    run_dfm( $home2, $repo2, qw/remote add upstream/, $origin );
    run_dfm( $home2, $repo2, qw/fetch upstream/ );
    run_dfm( $home2, $repo2, qw(checkout -b personal upstream/personal) );
    run_dfm( $home2, $repo2, qw/install/ );

    # next, make a change in the first, on the personal branch
    add_file( $home, $repo, 'testfile2', 'contents2' );
    run_dfm( $home, $repo, qw/push origin personal/ );

    # and finally, run updates to make sure we can pull
    # from the non-origin upstream
    run_dfm( $home2, $repo2, qw/updates/ );

    like( $trap->stdout, qr/adding testfile2/, 'message in output' );
};

subtest 'non origin remote different name' => sub {
    focus('non_origin_diff_name');

    my ( $home,  $repo,  $origin )  = minimum_home('host1');
    my ( $home2, $repo2, $origin2 ) = minimum_home('host2');

    # first, make a personal branch in repo 1, and add a new file
    run_dfm( $home, $repo, 'checkout', '-b', 'personal' );
    add_file( $home, $repo, 'testfile' );
    run_dfm( $home, $repo, 'push', 'origin', 'personal' );

    # on the second host, add the first as a remote
    # and install from the personal branch
    run_dfm( $home2, $repo2, 'remote', 'add', 'upstream', $origin );
    run_dfm( $home2, $repo2, 'fetch', 'upstream' );
    run_dfm( $home2, $repo2, 'checkout', '-b', 'business',
        'upstream/personal' );
    run_dfm( $home2, $repo2, 'install' );

    # next, make a change in the first, on the personal branch
    add_file( $home, $repo, 'testfile2', 'contents2' );
    run_dfm( $home, $repo, 'push', 'origin', 'personal' );

    # and finally, run updates to make sure we can pull
    # from the non-origin upstream
    run_dfm( $home2, $repo2, 'updates' );
    like( $trap->stdout, qr/adding testfile2/, 'message in output' );
};

subtest 'check remote branch' => sub {
    focus('check_remote');

    my ( $home, $repo, $origin ) = minimum_home('host1');

    # first, make a personal branch in repo 1, and add a new file
    run_dfm( $home, $repo, 'checkout', '-b', 'personal' );
    run_dfm( $home, $repo, 'updates' );

    ok( $trap->exit() != 0, 'updates throws non-zero exit code' );
    like(
        $trap->stdout,
        qr/no remote found for branch personal/,
        '"no remote" message in output'
    );

    run_dfm( $home, $repo, 'mergeandinstall' );

    ok( $trap->exit() != 0, 'mergeandinstall throws non-zero exit code' );
    like(
        $trap->stdout,
        qr/no remote found for branch personal/,
        '"no remote" message in output'
    );
};

done_testing;

sub add_file_and_push {
    my $home = shift || die;
    my $repo = shift || die;
    my $filename = shift;
    my $contents = shift;

    add_file( $home, $repo, $filename, $contents );

    run_dfm( $home, $repo, qw/push origin master/ );
}

sub add_file {
    my $home     = shift || die;
    my $repo     = shift || die;
    my $filename = shift || '.testfile';
    my $contents = shift || 'contents';

    chdir($home);
    `echo '$contents' > '$filename'`;
    `mv $filename '$repo/$filename'`;
    run_dfm( $home, $repo, 'add',         $filename );
    run_dfm( $home, $repo, qw/commit -m/, "adding $filename" );
    chdir($Bin);
}
