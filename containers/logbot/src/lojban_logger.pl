#!/usr/bin/perl

# This code is a mixture of namer.pl from the Bot::BasicBot examples,
# Bot::BasicBot::Pluggable::Module::Log , and my own hacking.  To
# whatever extent this doesn't violate anyone else's licenses,
# everything here is in the public domain.

package LojbanLogger;
use utf8;
use base qw(Bot::BasicBot);
use warnings;
use strict;
use autodie;
use IRC::Utils ':ALL';

binmode STDOUT, ':utf8';
binmode STDIN, ':utf8';
binmode STDERR, ':utf8';

# Give backtraces please
use Carp 'verbose';
$SIG{ __DIE__ } = sub { Carp::confess( @_ ) };

# https://stackoverflow.com/questions/45761700/cant-ignore-signal-chld-forcing-to-default
use POSIX ":sys_wait_h"; # for nonblocking read
$SIG{CHLD} = sub {
    while ((my $child = waitpid(-1, WNOHANG)) > 0) {
        # $Kid_Status{$child} = $?;
    }
};

$ENV{'PATH'} = '/usr/local/bin:/usr/bin:/bin';

use POSIX qw(strftime);
use File::Spec::Functions qw(catfile curdir splitpath);

if( ! $ARGV[0] || $ARGV[0] =~ m{^\s*$} || ! -d $ARGV[0] ) {
  print STDERR "Give directory as first argument.\n";
  exit 1;
}

my $user_log_path = $ARGV[0];
my $user_timestamp_fmt = '%F %T %Z/%z';

sub said {
  my $self = shift;
  my $message = shift;
  my $body = $message->{body};
  my $who = $message->{who};
  my $channel = $message->{channel};

  if( Encode::is_utf8($body) )
  {
    $body = Encode::encode_utf8($body);
  }
  $body = strip_formatting(strip_color(decode_irc($body)));

  ## print STDERR "who: $who, body: $body\n";

  if( $body =~ /^\s*<(\S+)>:\s\s*(.*)/ ) {
    $who = $1;
    $body = $2;
    # print STDERR "who munged $who, body: $body\n";
  }

  return if $self->_filter_message($body);

  if( $who ) {
    $self->_log( $message, '<' . $who . '> ' . $body );
  }
  return undef;
}

sub emoted {
  my $self = shift;
  my $message = shift;
  my $body = strip_formatting(strip_color(decode_irc(Encode::_utf8_off($message->{body}))));
  my $who = $message->{who};
  my $channel = $message->{channel};

  if( $body =~ /^\s*<(\S+)>:\s\s*(.*)/ ) {
    $who = $1;
    $body = $2;
    # print STDERR "who munged $who, body: $body\n";
  }

  return if $self->_filter_message($body);

  if( $who ) {
    $self->_log( $message, '* ' . $message->{who} . ' ' . $body );
  }
  return undef;
}


# Return 1 to drop the message, 0 to log it.
#
# This is extremely slow, on account of calling vlatai for each
# line, but since only one line comes in at a time it shouldn't be a
# big deal.
sub _filter_message {
  my ( $self, $line ) = @_;

  use IPC::Open2;

  my ($from_fl, $to_fl);
  my $pid = open2($from_fl, $to_fl, 'find_lojban' ) or die "find_lojban won't run\n";

  binmode $to_fl, ':utf8';
  binmode $from_fl, ':utf8';

  print $to_fl $line;
  close $to_fl;
  my @fl_says = <$from_fl>;
  close $from_fl;

  if( scalar(@fl_says) == 1 ) {
      return 0;
  }

  return 1;
}

sub _log {
  my ( $self, $message, $text ) = @_;
  my $logstr = $self->_format_message( $message, $text );
##  print STDERR "message: $logstr\n";
  $self->_log_to_file( $message, $logstr );
  return 1;
}

sub _log_to_file {
    my ( $self, $message, $logstr ) = @_;

    my $file = $self->_filename($message);

    open( my $log, '>>', catfile($file) ) || die( "Can't open logfile $file\n" );
    binmode $log, ':utf8';
    print {$log} $logstr . "\n";
    close($log);
    return;
}

sub _filename {
    my ( $self, $message ) = @_;

    my $channel = $message->{channel};
    $channel =~ s/^#*//;
    my $file = strftime( '%Y_%m_%d', localtime ) . '.txt';
    my $month = strftime( '%Y_%m', localtime );
    my $path = $user_log_path;
    print STDERR "filename: $path, $channel, $month\n";
    my $dir = catfile( $path, $channel, $month  );

    if( ! -d $dir ) {
      mkdir $dir || die( "Can't create directory $dir\n" );
    }

    return catfile( $path, $channel, $month, $file );
}

sub _format_message {
    my ( $self, $message, $text ) = @_;

    my $timestamp = strftime( $user_timestamp_fmt, localtime );
    my $log_str = $timestamp . ' ' . $text;

    return $log_str;
}

my $starttime=0;
sub tick {
  my $self = shift;
  if( $starttime == 0  ){
    $starttime = time();
  }
  my $chan=$self->pocoirc()->channels();
  my $chan_count=keys %$chan;
  print STDERR "channel count: $chan_count\n";
  if( (time() - $starttime) > 300 && $chan_count < 1 ) {
    $starttime=time();
    print STDERR "mail output: " . qx{echo "Maybe try 'sudo service lojban_logger restart'?" | /usr/bin/mailx -s 'lojban_logger cannot connect!' webmaster\@lojban.org} . "\n"
  }
  return 60;
}


LojbanLogger->new(
  server => "irc.lojban.org",
  channels => [ '#lojban', '#jbosnu', '#ckule', ],
  nick => 'vreji',
  password => 'ban4iyaiLoo9Mu',
)->run();

