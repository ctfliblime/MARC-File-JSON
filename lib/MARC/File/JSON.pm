package MARC::File::JSON;

use strict;
use warnings;
use JSON;
use MARC::File::Generic;
use MARC::Record;

# JSON -> MARC::Record
sub encode {
    my $json = shift;
    return MARC::Record->new_from_generic( JSON::XS->new->utf8->decode($json) );
}

# MARC::Record -> JSON
sub decode {
    my $record = shift;
    return JSON->new->utf8->encode( $record->as_generic );
}

### Methods injected into MARC::Record

sub MARC::Record::new_from_json {
    my ($class, $json) = @_;
    return encode( $json );
}

sub MARC::Record::as_json {
    my $self = shift;
    return decode( $self );
}

1;
