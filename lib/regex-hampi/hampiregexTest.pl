#/usr/bin/perl -w
#
#
# Author : Devdatta Akhawe
use strict;
use lib '.';
use pcre_tohampi;
use Cwd 'chdir';

my $startdir=$ENV{'PWD'};
chdir('../..');
while(<>){
  chomp;
  my $regex=$_;
  $regex=$1.$2 if( $regex =~ m/(\/.*?\/[^\/g]*)g([^\/g]*)/);
  $regex=eval 'qr'.$regex;
  my $p= pcre_tohampi->new($regex);
  $p->parse;
  my ($str,$min,$max)=$p->tothehampi();
  die "error calculating minimum for regex" if $min==0;
  open(HMP,'>','/tmp/foo.hmp') or die $!;
  print HMP "\nvar string:$min;\n$str\nassert string in flax0;\n";
  close(HMP);
  open(RES,"./hampi.sh /tmp/foo.hmp |") or die $!;
  while(<RES>){
    chomp;
    if(m/^\{VAR\(string\)\=(.*?)\}$/i){
      die "Failure for $regex\n" if $1 !~ $regex;
      print "SUCCESS for $regex\n";
    }
  }
}

chdir($startdir);
