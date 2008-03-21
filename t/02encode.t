use strict;
use Test;

BEGIN { plan tests => ($^V ge v5.8.1)? 17: 12 }

use MIME::Charset qw(header_encode);
use MIME::EncWords qw(encode_mimewords);
$MIME::EncWords::Config = {
    Detect7bit => 'YES',
    Mapping => 'EXTENDED',
    Replacement => 'DEFAULT',
    Charset => 'ISO-8859-1',
    Encoding => 'A',
    Field => undef,
    Folding => "\n",
    MaxLineLen => 76,
    Minimal => 'YES',
};

my @testins = MIME::Charset::USE_ENCODE?
	      qw(encode-singlebyte encode-multibyte):
	      qw(encode-singlebyte);

{
  local($/) = '';
  foreach my $in (@testins) {
    open WORDS, "<testin/$in.txt" or die "open: $!";
    while (<WORDS>) {
	s{\A\s+|\s+\Z}{}g;    # trim

	my ($isgood, $dec, $expect) = split /\n/, $_, 3;
	$isgood = (uc($isgood) eq 'GOOD');
	my @params = eval $dec;

	my $enc = encode_mimewords(@params);
	ok((($isgood && !$@) or (!$isgood && $@)) and
           ($isgood ? ($enc eq $expect) : 1));
    }
    close WORDS;
  }
}    

1;

