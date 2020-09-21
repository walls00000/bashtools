#!/usr/bin/perl
use strict;
use warnings; 
use Net::SSH::Expect;

my $host = $ARGV[0];
my $pub_key_file = $ENV{"HOME"} ."/.ssh/id_rsa.pub";
my $port = 22;
my $default_user = "svtcli";

my $user;
if ($ARGV[1] eq '') {
  $user = $default_user;
} else {
  $user = $ARGV[1];
}

my $default_password = "foobar";
my $password;
if ($ARGV[2] eq '') {
  $password = $default_password;
} else {
  $password = $ARGV[2];
}
print "Using user: '$user'\n";
print "Using password: '$password'\n";

my $ssh = Net::SSH::Expect->new (
  host => $host,
  user => $user,
  port => $port,
  password=> $password,
  raw_pty => 1,
  timeout => 3
);

print("public key file: $pub_key_file \n");
my $key;

{
  local $/ = undef;
  open FILE, $pub_key_file or die "Couldn't open file: $!";
  $key = <FILE>;
  close FILE;
}
chomp $key;

print "Connecting to host " . $user . "@" .$host . "\n" ;

my $retry_count = 0;
my $retry_count_max = 3;
my $login_output;
while(1) {
  my $rc = eval{$login_output = $ssh->login();};
  last if defined $rc;
  last if $retry_count >= $retry_count_max;
  $retry_count++;
  sleep 1;
}
print $login_output . "\n";

#if ($login_output !~ /Welcome/) {
#  die "Something failed! $login_output";
#}

my $cmd = $ssh->exec("echo '$key' >> .ssh/authorized_keys");
print $cmd . "\n";
my $chmod = $ssh->exec("chmod 644 .ssh/authorized_keys");
print $chmod . "\n";
print "done!\n"
