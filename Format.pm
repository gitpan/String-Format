package String::Format;

# ----------------------------------------------------------------------
# $Id: Format.pm,v 1.10 2002/02/06 21:01:41 dlc Exp $
# ----------------------------------------------------------------------
#  Copyright (C) 2002 darren chamberlain <darren@cpan.org>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; version 2.
#
#  This program is distributed in the hope that it will be useful, but
#  WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#  USA
# -------------------------------------------------------------------

use strict;
use vars qw($VERSION @EXPORT);
use Exporter;
use base qw(Exporter);

$VERSION = sprintf "%d.%02d", q$Revision: 1.10 $ =~ /(\d+)\.(\d+)/;
@EXPORT = qw(stringf);

sub _replace {
    my ($args, $orig, $alignment, $width, $passme, $formchar) = @_;

    # For unknown escapes, return the orignial
    return $orig unless defined $args->{$formchar};

    $alignment = '+' unless defined $alignment;

    my $replacment = $args->{$formchar};
    if (ref $replacment eq 'CODE') {
        # $passme gets passed to subrefs.
        $passme ||= "";
        $passme =~ tr/{}//d;
        $replacment = $replacment->($passme);
    }

    $width ||= length $replacment;

    return substr($replacment, 0, $width) unless $width > length $replacment;

    if ($alignment eq '-') {
        return " " x ($width - length $replacment) . $replacment;
    }

    return $replacment . " " x ($width - length $replacment);
}

sub stringf {
    my $format = shift || return;
    my $args = UNIVERSAL::isa($_[0], 'HASH') ? shift : { @_ };
       $args->{'n'} = "\n" unless defined $args->{'n'};
       $args->{'t'} = "\t" unless defined $args->{'t'};
       $args->{'%'} = "%"  unless defined $args->{'%'};
    my $chars = join '', keys %{$args};
    my $regex = qr!
                   (%             # leading '%'
                    ([+-])?       # optional alignment specifier
                    (\d*)?        # optional field width
                    ({.*?})?      # optional stuff inside
                    ([$chars])    # actual format character
                 )!x;

    $format =~ s/$regex/_replace($args, $1, $2, $3, $4, $5)/ge;

    return $format;
}

1;
__END__

=head1 NAME

String::Format - printf-like string formatting capabilities with
arbitrary format definitions

=head1 ABSTRACT

String::Format allows for printf-style formatting capabilities with
arbitrary format definitions

=head1 SYNOPSIS

  # In a script invoked as:
  # script.pl -f "I like %a, %b, and %g, but not %m or %w."

  use String::Format;
  use Getopt::Std;

  my %fruit = (
        'a' => "apples",
        'b' => "bannanas",
        'g' => "grapefruits",
        'm' => "melons",
        'w' => "watermelons",
  );

  use vars qw($opt_f);
  getopt("f");

  print stringf($opt_f, %fruit);
  
  # prints:
  # I like apples, bannanas, and grapefruits, but not melons or watermelons.

=head1 DESCRIPTION

String::Format lets you define arbitrary printf-like format sequences
to be expanded.  This module would be most useful in configuration
files and reporting tools, where the results of a query need to be
formatted in a particular way.  It was inspired by mutt's index_format
and related directives (see http://www.mutt.org/doc/manual/manual-6.html#index_format).

=head1 FUNCTIONS

=head2 stringf

String::Format exports a single function called stringf.  stringf
takes two arguments:  a format string (see FORMAT STRINGS, below) and
a hash (or reference to a hash) of name => value pairs.  These name =>
value pairs are what will be expanded in the format string.

=head1 FORMAT STRINGS

Format strings must match the following regular expression:

    /(%              # leading '%'
       ([+-])?       # optional alignment specifier
       (\d*)?        # optional field width
       ({.*?})?      # optional stuff inside
       ([$chars])    # actual format character
     )/

where $chars is:

    join '', keys %args;

where %args is the hash passed as the second parameter to B<stringf>.  If
the escape character specified does not exist in %args, then the
original string is used.  The alignment and field width options
function identically to how they are defined in sprintf(3) (any
variation is a bug, and should be reported).

The value attached to the key can be a scalar value or a subroutine
reference; if it is a subroutine reference, then anything between the
'{' and '}' ($4 in the above regex) will be passed as $_[0] to the
subroutine reference.  This allows for entries such as this:

  %args = (
      d => sub { POSIX::strftime($_[0], localtime) }, 
  );

Which can be invoked with this format string:

  "It is %{%M:%S}d right now, on %{%A, %B %e}d."

And result in (for example):

  It is 17:45 right now, on Monday, February 4.

Note that since the string is passed unmolested to the subroutine
reference, and strftime would Do The Right Thing with this data, the
above format string could be written as:

  "It is %{%M:%S right now, on %A, %B %e}d."

By default, the formats 'n' and 't' are defined to be a newline and
tab, respectively, if they are not already defined in the hash of
arguments that gets passed it.  So we can add carriage returns simply:

  "It is %{%M:%S right now, on %A, %B %e}d.%n"

Because of how the string is parsed, the normal "\n" and "\t" are
turned into two characters each, and are not treated as a newline and
tab.  This is a bug.

=head1 TODO

=over 4

=item *

Make sure that the handling of formatting, such as the alignment and
field width pieces, are consistent with sprintf.

=back

=head1 AUTHOR

darren chamberlain <darren@cpan.org>





