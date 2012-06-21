package MARC::File::JSON;

use strict;
use warnings;
use JSON;
use JSON::Streaming::Reader;
use MARC::File::Generic;
use MARC::Record;
use MARC::File;

use vars qw( @ISA );
push @ISA, 'MARC::File';

# MARC::Record -> JSON
sub encode {
    my $record = shift;
    return JSON->new->utf8->encode( $record->as_generic );
}

# JSON -> MARC::Record
sub decode {
    my ($self, $data) = @_;

    if ( !ref($data) ) {
        $data = JSON->new->utf8->decode( $data );
    }
    return MARC::Record->new_from_generic( $data );
}

sub _next {
    my $self = shift;
    my $jsonr
        = $self->{jsonr} //= JSON::Streaming::Reader->for_stream($self->{fh});
    my $token = $jsonr->get_token;
    if ($token->[0] eq 'start_array') {
        $token = $jsonr->get_token;
    }
    return ($token->[0] eq 'end_array') ? undef : $jsonr->slurp;
}

### Methods injected into MARC::Record

sub MARC::Record::new_from_json {
    my ($class, $json) = @_;
    return __PACKAGE__->decode( JSON->new->utf8->decode($json) );
}

sub MARC::Record::as_json {
    my $self = shift;
    return encode( $self );
}

1;
