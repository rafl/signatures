use strict;
use warnings;
use inc::Module::Install;
use ExtUtils::Depends;

name 'signatures';
all_from 'lib/signatures.pm';

requires 'B::Hooks::OP::Check' => '0.13';
requires 'B::Hooks::OP::PPAddr';
requires 'B::Hooks::Parser' => '0.07';

build_requires 'B::Hooks::OP::Check' => '0.13';
build_requires 'B::Hooks::OP::PPAddr';
build_requires 'B::Hooks::Parser' => '0.07';

configure_requires 'ExtUtils::Depends';
configure_requires 'B::Hooks::OP::Check' => '0.13';
configure_requires 'B::Hooks::OP::PPAddr';
configure_requires 'B::Hooks::Parser' => '0.07';

my $pkg = ExtUtils::Depends->new('signatures', 'B::Hooks::OP::Check', 'B::Hooks::OP::PPAddr', 'B::Hooks::Parser');
$pkg->add_xs('signatures.xs');
$pkg->add_pm('lib/signatures.pm' => '$(INST_LIB)/signatures.pm');

makemaker_args($pkg->get_makefile_vars);

extra_tests();

WriteAll;
