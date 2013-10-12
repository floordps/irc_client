#!/usr/bin/perl
use strict;
use warnings;
use Tk;
use Tk::DynaTabFrame;
use IRC;
use Socket qw(PF_INET SOCK_STREAM);
socket( my $sock, PF_INET, SOCK_STREAM, 0 )
  or die "socket: $!";
my $client = IRC->new(
    {
        sock    => $sock,
        server  => "irc.perl.org",
        port    => 6667,
        channel => ['#perl']
    }
);

#$client->connect;
#$client->join_chan;

my $mw        = new MainWindow;
my $main_menu = $mw->Menu();
$mw->geometry("500x450");
$mw->configure( -menu => $main_menu, );
my $file_menu = $main_menu->cascade(
    -label     => "File",
    -underline => 0,
    -tearoff   => 0,
);
$file_menu->command(
    -label     => "Connect",
    -underline => 0,
    -command   => \&menu_connect
);
$file_menu->command(
    -label     => "Exit",
    -underline => 0,
    -command   => sub { exit }
);
$mw->title("IRC Client");
my $tab_mw =
  $mw->DynaTabFrame()->pack( -side => 'top', -expand => 1, -fill => 'both' );
my $tab_1 = $tab_mw->add(
    -caption  => 'Tab 1',
    -tabcolor => 'red',
    -hidden   => 0
);
my $t = $tab_1->Scrolled(
    'Text',
    -scrollbars => 'osoe',
    -foreground => 'gray',
    -background => 'black',
    -wrap       => 'word',
    -state      => 'disabled'
)->pack( -fill => 'both', -expand => 1, -side => 'top', -anchor => 'nw' );

my $entry = $mw->Entry()->pack(
    -side   => 'left',
    -fill   => 'x',
    -expand => 1,
);
$entry->focus();
$entry->bind( '<Return>', \&send_sock );
$mw->Button(
    -text    => 'Send',
    -command => \&send_sock,
)->pack( -side => "right", );

center_window($mw);

MainLoop;

sub menu_connect {
    $client->connect;
    $mw->fileevent( $sock, 'readable', \&get );
}

sub send_sock {
    my $cmd = $entry->get() . "\n";
    write_t("$cmd");
    $client->write($cmd);
    $entry->delete( 0, 'end' );
}

sub get {
    $_ = $client->read;
    write_t($_) if $_;
}

sub write_t {
    my $str = shift;
    $t->configure( -state => 'normal' );
    $t->insert( 'end', $str );
    $t->see('end');
    $t->configure( -state => 'disabled' );
}

sub center_window {
    my ($window) = @_;
    $window->update;
    my $new_width  = int( ( $window->screenwidth() - $window->width ) / 2 );
    my $new_height = int( ( $window->screenheight() - $window->height ) / 2 );
    $window->geometry(
        $window->width . 'x' . $window->height . "+$new_width+$new_height" );
    $window->update;
    return;
}
__END__
my $t = $mw->Scrolled(
    'Text',
    -scrollbars => 'osoe',
    -foreground => 'gray',
    -background => 'black',
    -wrap       => 'word',
    -state      => 'disabled'
)->pack( -fill => 'both', -expand => 1, -side => 'top', -anchor => 'w' );
