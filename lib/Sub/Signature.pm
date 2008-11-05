use strict;
use warnings;

package Sub::Signature;

use XSLoader;
use B::Hooks::Parser;
use B::Hooks::OP::Check;
use B::Hooks::EndOfScope;

our $VERSION = '0.01';

XSLoader::load(__PACKAGE__, $VERSION);

{
    my %pkgs;

    sub import {
        my ($class) = @_;
        my $caller = caller();
        $pkgs{$caller} = $class->setup_for($caller);
        return;
    }

    sub unimport {
        my ($class) = @_;
        my $caller = caller();
        $class->teardown_for(delete $pkgs{$caller});
        return;
    }
}

sub setup_for {
    my ($class, $caller) = @_;
    my $ret = $class->setup($caller);

    my $old_warn = $SIG{__WARN__};
    $SIG{__WARN__} = sub {
        if ($_[0] !~ /^Illegal character in prototype for /) {
            $old_warn ? $old_warn->(@_) : warn @_;
        }
    };

    my $unregister;
    {
        my $called = 0;
        $unregister = sub {
            return if $called++;
            $class->teardown_for([$ret, $unregister]);
            $SIG{__WARN__} = $old_warn;
        };
    }

    &on_scope_end($unregister);

    return [$ret, $unregister];
}

sub teardown_for {
    my ($class, $data) = @_;
    $class->teardown($data->[0]);
    $data->[1]->();
    return;
}

sub callback {
    my ($class, $offset, $proto) = @_;
    my $inject = $class->proto_unwrap($proto);
    $class->inject($offset, $inject);
    return;
}

sub proto_unwrap {
    my ($class, $proto) = @_;
    return '' unless length $proto;
    return "my ($proto) = \@_;";
}

sub inject {
    my ($class, $offset, $inject) = @_;
    my $linestr = B::Hooks::Parser::get_linestr();
    substr($linestr, $offset + 1, 0) = $inject;
    B::Hooks::Parser::set_linestr($linestr);
    return;
}

1;

__END__

=head1 NAME

Sub::Signature - subroutine signatures with no source filter

=head1 SYNOPSIS

    use Sub::Signature;

    sub foo ($bar, $baz) {
        return $bar + $baz;
    }

=head1 METHODS

=head2 proto_unwrap ($prototype)

Turns the extracted C<$prototype> into code.

The default implementation returns C<< my (${prototype}) = @_; >> or an empty
string, if no prototype is given.

=head2 inject ($offset, $code)

Inserts a C<$code> string into the line perl currently parses at the given
C<$offset>.

=head2 callback (offset, $prototype)

This gets called as soon as a sub definition is encountered. Arguments are the
C<$offset> within the current line perl is parsing and extracted C<$prototype>.

The default implementation calls C<proto_unwrap> with the prototype and passes
the returned value and the offset to C<inject>.

=head1 SEE ALSO

L<Method::Signatures>

L<MooseX::Method::Signatures>

L<Sub::Signatures>

L<Attribute::Signature>

L<Perl6::Subs>

L<Perl6::Parameters>

=head1 AUTHOR

Florian Ragwitz E<lt>rafl@debian.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008  Florian Ragwitz

This module is free software.

You may distribute it under the same license as Perl itself.

=cut
