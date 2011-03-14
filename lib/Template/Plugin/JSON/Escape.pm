package Template::Plugin::JSON::Escape;
use strict;
use warnings;

use base qw/Class::Accessor::Fast Template::Plugin/;
use JSON ();

our $VERSION = "0.01";

__PACKAGE__->mk_accessors( qw/converter args/ );

sub new {
    my ($class, $context, @args) = @_;
    my $self = $class->SUPER::new( { args => ref $args[0] ? $args[0] : {} } );

	$context->define_vmethod( $_ => json => sub { $self->json( @_ ) } ) for qw(hash list scalar);
    $context->define_filter( json => \&json_filter );

    return $self;
}

sub json_converter {
	my $self = shift;
    return $self->converter if $self->converter;

	my $json = JSON->new->allow_nonref;
	my $args = $self->args;
	for ( keys %$args ) {
        $json->$_( $args->{ $_ } ) if $json->can( $_ );
	}
	return $self->converter( $json );
}

sub json {
	my ($self, $value) = @_;
	$self->json_converter->encode( $value );
}

sub json_decode {
	my ($self, $value) = @_;
	$self->json_converter->decode( $value );
}

sub json_filter {
    my $value = shift;
    $value =~ s!&!\\u0026!g;
    $value =~ s!<!\\u003c!g;
    $value =~ s!>!\\u003e!g;
    $value =~ s!\x{2028}!\\u2028!g;
    $value =~ s!\x{2029}!\\u2029!g;
    $value;
}

1;

__END__

=pod

=head1 NAME

Template::Plugin::JSON - Adds a .json vmethod for all TT values.

=head1 SYNOPSIS

	[% USE JSON ( pretty => 1 ) %];

	<script type="text/javascript">

		var foo = [% foo.json %];

	</script>

	or read in JSON

	[% USE JSON %]
	[% data = JSON.json_decode(json) %]
	[% data.thing %]

=head1 DESCRIPTION

This plugin provides a C<.json> vmethod to all value types when loaded. You
can also decode a json string back to a data structure.

It will load the L<JSON> module (you probably want L<JSON::XS> installed for
automatic speed ups).

Any options on the USE line are passed through to the JSON object, much like L<JSON/to_json>.

=head1 SEE ALSO

L<JSON>, L<Template::Plugin>

=head1 VERSION CONTROL

L<http://github.com/nothingmuch/template-plugin-json/>

=head1 AUTHOR

Yuval Kogman <nothingmuch@woobling.org>

=head1 COPYRIGHT & LICENSE

Copyright (c) 2006, 2008 Infinity Interactive, Yuval Kogman.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

=cut

