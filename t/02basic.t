#!/usr/bin/env perl
# vim: set ft=perl:

# ======================================================================
# 02basic.t
#
# Simple test, testing multiple format chars in a single string.
# There are many variations on this theme; a few are covered here.
# ======================================================================

BEGIN { print "1..7\n" }

use strict;
use String::Format;

# ======================================================================
# Lexicals.  $orig is the original format string.
# ======================================================================
my $orig = qq(I like %a, %b, and %g, but not %m or %w.);
my $target = "I like apples, bannanas, and grapefruits, ".
             "but not melons or watermelons.";
my %fruit = (
    'a' => "apples",
    'b' => "bannanas",
    'g' => "grapefruits",
    'm' => "melons",
    'w' => "watermelons",
);

# ======================================================================
# Test 1
#
# Standard test, with all elements in place.
# ======================================================================
unless (stringf($orig, \%fruit) eq $target) {
    print "not ";
}
print "ok 1\n";

# ======================================================================
# Test 2
#
# Test where some of the elements are missing.
# ======================================================================
delete $fruit{'b'};
$target = "I like apples, %b, and grapefruits, ".
          "but not melons or watermelons.";
unless (stringf($orig, \%fruit) eq $target) {
    print "not ";
}
print "ok 2\n";

# ======================================================================
# Test 3
#
# Field width
# ======================================================================
$orig = "I am being %5r.";
$target = "I am being trunc.";
unless (stringf($orig, { "r" => "truncated" }) eq $target) {
    print "not ";
}
print "ok 3\n";

# ======================================================================
# Test 4
#
# Alignment
# ======================================================================
$orig = "I am being %-30e.";
$target = "I am being                      elongated.";
unless (stringf($orig, { "e" => "elongated" }) eq $target) {
    print "not ";
}
print "ok 4\n";

# ======================================================================
# Test 5
#
# Testing of non-alphabet characters
# ======================================================================
# Test 5.1 => '/'
# ======================================================================
$orig = "holy shit %/.";
$target = "holy shit w00t.";
unless (stringf($orig, { '/' => "w00t" }) eq $target) {
    print "not ";
}
print "ok 5\n";

# ======================================================================
# Test 5.2 => numbers
# ======================================================================
$orig = "%1 %2 %3";
$target = "1 2 3";
unless (stringf($orig, { '1' => 1, '2' => 2, '3' => 3 }) eq $target) {
    print "not ";
}
print "ok 6\n";

# ======================================================================
# Test 5.3 => perl sigils ($@&)
# ======================================================================
# Note: The %$ must be single quoted so it does not interpolate!  This
# was causing this test to fail for no reason.
# ======================================================================
$orig = '%$ %@ %&';
$target = "1 2 3";
my $out = stringf($orig, { '$' => 1, '@' => 2, '&' => 3 });
unless ($out eq $target) {
    print "not ";
}
print "ok 7\n";
