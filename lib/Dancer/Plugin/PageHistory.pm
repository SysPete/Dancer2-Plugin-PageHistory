package Dancer::Plugin::PageHistory;

=head1 NAME

Dancer::Plugin::PageHistory - store recent page history for user into session

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

use Dancer ':syntax';
use Dancer::Plugin;
use Dancer::Plugin::PageHistory::PageSet;
use Dancer::Plugin::PageHistory::Page;

=head1 DESCRIPTION

The C<add_to_history> keyword which is exported by this plugin allows you to 
add interesting items to the history lists. We also export the C<history>
keyword which returns the current L<Dancer::Plugin::PageHistory::PageSet>
object.

Page history from the session is not loaded until one of the keywords is called.
Once one has been called the <Dancer::Plugin::PageHistory::PageSet> object
is stashed in the L<var|Dancer/var> named C<page_history>.
See L</page_history_var> under </CONFIGURATION> below for how to change the
name of the C<var> that is used.

=head1 CONFIGURATION

No configuration is necessarily required.

If you wish to have arguments passed to
L<Dancer::Plugin::PageHistory::PageSet/new> these can be added to your
configuration along with configuration for the plugin itself, e.g.:

    plugins:
      PageHistory:
        add_all_pages: 1
        ingore_ajax: 1 
        page_history_var: someothername
        PageSet:
          default_type: all
          fallback_page:
            path: "/"
          max_items: 20
          methods:
            - default
            - product
            - navigation
 
Configuration options for the plugin itself:

=over

=item * add_all_pages

Defaults to 0. Set to 1 to have all pages added to the list
L<Dancer::Plugin::PageHistory::PageSet/default_type> in the L</before> hook.

=item * ignore_ajax

If L</add_all_pages> is true this controls whether ajax requests are added to
the list L<Dancer::Plugin::PageHistory::PageSet/default_type> in the
L</before> hook.

Defaults to 0. Set to 1 to have ajax requests ignored.

=item * page_history_var

This setting can be used to change the name of the C<var> used to stash
the history object from the default C<page_history> to something else.

=back

=head1 HOOKS

This plugin makes use of the following hooks:

=head2 before

Add current page to history. See L</add_all_pages> and L</ignore_ajax>.

=cut

hook before => sub {
    my $conf = plugin_setting;
    return
      if ( !$conf->{add_all_pages}
        || ( $conf->{ignore_ajax} && request->is_ajax ) );
    debug "adding current page to history in hook before";
    &add_to_history();
};

=head2 before_template_render

Puts history into the token C<page_history>.

=cut

hook before_template_render => sub {
    my $tokens = shift;
    $tokens->{history} = &history;
};

=head2 after

Save history back into session.

=cut

hook after => sub {
    session page_history => &history()->pages;
};

sub add_to_history {
    my $var = plugin_setting->{page_history_var} || 'page_history';
    my ( $self, @args ) = plugin_args(@_);

    use Data::Dumper::Concise;
    print STDERR Dumper(@args);
    my $path         = request->path;
    my $query_params = params('query');

    my %args = (
        path         => $path,
        query_params => $query_params,
        @args,
    );

    debug "adding page to history: ", \%args;

    my $history = &history;

    # add the page
    $history->add( %args );
    var $var => $history;
}

sub history {
    my $var = plugin_setting->{page_history_var} || 'page_history';
    debug "var is $var in history";
    unless ( var($var) ) {
        debug "no var";

        # var history has not yet been defined so pull history from session

        my $session_history = session('page_history');
        $session_history = {} unless ref($session_history) eq 'HASH';

        my $conf = plugin_setting;

        my %args = ( pages => $session_history );

        $args{max_items} = $conf->{max_items} if $conf->{max_items};

        $args{methods} = $conf->{methods}
          if ( $conf->{methods} && ref( $conf->{methods} ) eq 'ARRAY' );

        my $history = Dancer::Plugin::PageHistory::PageSet->new( %args );

        var $var => $history;
    }
    return var($var);
}

register add_to_history => \&add_to_history;

register history => \&history;

register_plugin;
1;
__END__

