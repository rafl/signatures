use strict;
use warnings;
use inc::Module::Install;
use ExtUtils::Depends;

name 'Sub-Signature';
all_from 'lib/Sub/Signature.pm';

requires 'B::Hooks::OP::Check' => '0.11';
requires 'B::Hooks::Parser' => '0.05';

build_requires 'B::Hooks::OP::Check' => '0.11';
build_requires 'B::Hooks::Parser' => '0.05';

configure_requires 'ExtUtils::Depends';
configure_requires 'B::Hooks::OP::Check' => '0.11';
configure_requires 'B::Hooks::Parser' => '0.05';

my $pkg = ExtUtils::Depends->new('Sub::Signature', 'B::Hooks::OP::Check', 'B::Hooks::Parser');
$pkg->add_xs('Signature.xs');
$pkg->add_pm('lib/Sub/Signature.pm' => '$(INST_LIB)/Sub/Signature.pm');

makemaker_args($pkg->get_makefile_vars);

WriteAll;
