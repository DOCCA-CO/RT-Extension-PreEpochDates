package RT::Date;

use strict;
use warnings;
no warnings 'redefine';

use Time::Local ();
use POSIX ();

sub Set {
    my $self = shift;
    my %args = (
        Format   => 'unix',
        Value    => time,
        Timezone => 'user',
        @_
    );

    return $self->Unix(0) unless $args{'Value'} && $args{'Value'} =~ /\S/;

    my $format = lc $args{'Format'};

    if ( $format eq 'unix' ) {
        return $self->Unix( $args{'Value'} );
    }
    elsif ($format eq 'sql' && $args{'Value'} =~ /^(\d{4})-(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/) {
        local $@;
        my $u = eval { Time::Local::timegm($6, $5, $4, $3, $2-1, $1) } || 0;
        $RT::Logger->warning("Invalid date $args{'Value'}: $@") if $@ && !$u;
        return $self->Unix( $u );
    }
    elsif ( $format eq 'iso' &&
          ( $args{'Value'} =~ /^(\d{4})-(\d\d)-(\d\d)[ T](\d\d):(\d\d):(\d\d)Z?$/ ||
            $args{'Value'} =~ /^(\d{4})(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)Z?$/)) {
        local $@;
        my $u = eval { Time::Local::timegm($6, $5, $4, $3, $2-1, $1) } || 0;
        $RT::Logger->warning("Invalid date $args{'Value'}: $@") if $@ && !$u;
        return $self->Unix( $u );
    }
    elsif ( $format =~ /^(sql|datemanip|iso)$/ ) {
        $args{'Value'} =~ s!/!-!g;

        if (   ( $args{'Value'} =~ /^(\d{4})?(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/ )
            || ( $args{'Value'} =~ /^(\d{4})?(\d\d)(\d\d)(\d\d):(\d\d):(\d\d)$/ )
            || ( $args{'Value'} =~ /^(?:(\d{4})-)?(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)$/ )
            || ( $args{'Value'} =~ /^(?:(\d{4})-)?(\d\d)-(\d\d) (\d\d):(\d\d):(\d\d)\+00$/ )
          ) {

            my ($year, $mon, $mday, $hours, $min, $sec)  = ($1, $2, $3, $4, $5, $6);
            $year ||= (localtime time)[5] + 1900;
            $mon--;
            return $self->Unix(0) if $mon < 0 || $mon > 11;

            my $tz = lc $args{'Format'} eq 'datemanip'? 'user': 'utc';
            $self->Unix( $self->Timelocal( $tz, $sec, $min, $hours, $mday, $mon, $year ) );
        }
        else {
            $RT::Logger->warning(
                "Couldn't parse date '$args{'Value'}' as a $args{'Format'} format"
            );
            return $self->Unix(0);
        }
    }
    elsif ( $format eq 'unknown' ) {
        if ( RT->Config->Get('PreferDateTimeFormatNatural') ) {
            return $self->Unix(
                   $self->ParseByDateTimeFormatNatural(%args)
                || $self->ParseByTimeParseDate(%args)
                || 0
            );
        } else {
            return $self->Unix(
                   $self->ParseByTimeParseDate(%args)
                || $self->ParseByDateTimeFormatNatural(%args)
                || 0
            );
        }
    }
    else {
        $RT::Logger->error(
            "Unknown Date format: $args{'Format'}\n"
        );
        return $self->Unix(0);
    }

    return $self->Unix;
}

sub Diff {
    my $self = shift;
    my $other = shift;
    $other = time unless defined $other;
    if ( UNIVERSAL::isa( $other, 'RT::Date' ) ) {
        $other = $other->Unix;
    }
    return undef unless $other =~ /^-?\d+$/ && $other != 0;

    my $unix = $self->Unix;
    return undef unless $unix;

    return $unix - $other;
}

sub Unix {
    my $self = shift;

    if (@_) {
        $self->{'time'} = int(shift || 0);
    }
    return $self->{'time'};
}

sub Localtime
{
    my $self = shift;
    my $tz = $self->Timezone(shift);

    my $unix = shift || $self->Unix || 0;

    my @local;
    if ($tz eq 'UTC') {
        @local = gmtime($unix);
    } else {
        {
            local $ENV{'TZ'} = $tz;
            POSIX::tzset();
            @local = localtime($unix);
        }
        POSIX::tzset();
    }
    $local[5] += 1900;
    my $offset = Time::Local::timegm_nocheck(@local) - $unix;
    return @local, $offset;
}

1;