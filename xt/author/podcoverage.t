use strict;
use warnings;
use Test::Pod::Coverage;

all_pod_coverage_ok({
    also_private => [qw/
        import
        unimport
        setup
        setup_for
        teardown
        teardown_for
    /],
});
