#!/usr/bin/env perl
# vim: set ft=perl ts=4 sw=4:

# ======================================================================
# 03multiple.t
#
# Attempting to pass a multi-character format string will not work.
# This means that stringf will return the malformed format characters
# as they were passed in.
# ======================================================================

use String::Format;

BEGIN { print "1..1\n" };

my $fmt = "My %foot hurts.";
my $str = "My pretzel hurts.";

if (stringf($fmt, { 'foot' => 'pretzel' }) ne $fmt) {
    print "not ";
}
print "ok 1\n";
