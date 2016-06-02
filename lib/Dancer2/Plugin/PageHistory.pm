package Dancer2::Plugin::PageHistory;

=head1 NAME

Dancer2::Plugin::PageHistory - store recent page history for user into session

=head1 VERSION

Version 0.102

=cut

our $VERSION = '0.102';

use Dancer2::Core::Types qw/Bool HashRef Str/;
use Dancer2::Plugin;
use Dancer2::Plugin::PageHistory::PageSet;
use Dancer2::Plugin::PageHistory::Page;
use Data::Structure::Util qw/unbless/;

my $history_name = 'page_history';

=head1 SYNOPSIS

    get '/product/:sku/:name' => sub {
        add_to_history(
            type       => 'product',
            title      => param('name'),
            attributes => { sku => param('sku') }
        );
    };

    hook 'before_template_render' => sub {
        my $tokens = shift;
        $tokens->{previous_page} = history->previous_page->uri;
    };

=head1 DESCRIPTION

The C<add_to_history> keyword which is exported by this plugin allows you to 
add interesting items to the history lists which are returned using the
C<history> keyword.

=head1 KEYWORDS

=head2 add_to_history

Adds a page via L<Dancer2::Plugin::PageHistory::PageSet/add>. Both of
L<path|Dancer2::Plugin::PageHistory::Page/path> and
L<query_string|Dancer2::Plugin::PageHistory::Page/query_string> are optional
arguments
which will be set automatically from the current request if they are not
supplied.

=head2 history

Returns the current L<Dancer2::Plugin::PageHistory::PageSet> object from the
user's session.

=head1 SUPPORTED SESSION ENGINES

L<CHI|Dancer2::Session::CHI>,
x L<Cookie|Dancer2::Session::Cookie>, 
x L<DBIC|Dancer2::Session::DBIC>,
x L<JSON|Dancer2::Session::JSON>,
x L<Memcached|Dancer2::Session::Memcached>,
L<Memcached::Fast|Dancer2::Session::Memcached::Fast>,
x L<MongoDB|Dancer2::Session::MongoDB>,
x L<PSGI|Dancer2::Session::PSGI>,
x L<Simple|Dancer2::Session::Simple>,
L<Storable|Dancer2::Session::Storable>,
x L<YAML|Dancer2::Session::YAML>

Dancer2::Session::CGISession
Dancer2::Session::Redis
Dancer2::Session::Sereal - 

=head1 CAVEATS

L<Dancer2::Session::Cookie> and L<Dancer2::Session::PSGI> either don't handle
destroy at all or else do it wrong so I suggest you avoid those modules if
you want things like logout to work.

See L</TODO>.

=head1 CONFIGURATION

No configuration is necessarily required.

If you wish to have arguments passed to
L<Dancer2::Plugin::PageHistory::PageSet/new> these can be added to your
configuration along with configuration for the plugin itself, e.g.:

    plugins:
      PageHistory:
        add_all_pages: 1
        ingore_ajax: 1 
        history_name: someothername
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
L<Dancer2::Plugin::PageHistory::PageSet/default_type> in the L</before> hook.

=item * ignore_ajax

If L</add_all_pages> is true this controls whether ajax requests are added to
the list L<Dancer2::Plugin::PageHistory::PageSet/default_type> in the
L</before> hook.

Defaults to 0. Set to 1 to have ajax requests ignored.

=item * history_name

This setting can be used to change the name of the key used to store
the history object in the session from the default C<page_history> to
something else. This is also the key used for name of the token
containing the history object that is passed to templates and also the var
used to cache the history object during the request lifetime.

=back

=head1 HOOKS

This plugin makes use of the following hooks:

=head2 before

Add current page to history. See L</add_all_pages> and L</ignore_ajax>.

=head2 before_template_render

Puts history into the token C<page_history>.

=cut

has add_all_pages => (
    is          => 'ro',
    isa         => Bool,
    from_config => sub { 0 },
);

has ingore_ajax => (
    is          => 'ro',
    isa         => Bool,
    from_config => sub { 0 },
);

has history_name => (
    is          => 'ro',
    isa         => Bool,
    from_config => sub { 'page_history' },
);

has page_set_args => (
    is          => 'ro',
    isa         => HashRef,
    from_config => 'PageSet',
    default     => sub { +{} },
);

plugin_keywords 'add_to_history', 'history';

sub BUILD {
    my $plugin = shift;

    $plugin->app->add_hook(
        Dancer2::Core::Hook->new(
            name => 'before',
            code => sub {

                return
                  if ( !$plugin->add_all_pages
                    || ( $plugin->ignore_ajax && request->is_ajax ) );

                $plugin->add_to_history;
            },
        )
    );

    $plugin->app->add_hook(
        Dancer2::Core::Hook->new(
            name => 'before_template_render',
            code => sub {
                my $tokens = shift;
                $tokens->{$plugin->history_name} = $plugin->history;
            },
        )
    );
};

sub add_to_history {
    my ( $plugin, @args ) = @_;

    my %args = (
        path         => $plugin->app->request->path,
        query_string => $plugin->app->request->env->{QUERY_STRING},
        @args,
    );

    $plugin->app->log( "debug", "adding page to history: ", \%args );

    my $history = $plugin->history;

    # add the page and save back to session with pages all unblessed
    $history->add( %args );
    $plugin->app->session->write(
        $plugin->history_name => unbless( $history->pages ) );
}

sub history {
    my $plugin = shift;
    my $history;

    if ( my $history = $plugin->app->request->var( $plugin->history_name ) ) {
        return $history;
    }

    my $session_history = $plugin->app->session->read( $plugin->history_name );

    $session_history = {} unless ref($session_history) eq 'HASH';

    my $args = $plugin->page_set_args;
    $args->{pages} = $session_history;

    my $history = Dancer2::Plugin::PageHistory::PageSet->new(%$args);
    $plugin->app->request->var( $plugin->history_name => $history );

    return $history;
}

=head1 TODO

=over

=item * Add more tests

=item * Add support for more session engines

=item * investigate C<destroy> problems with L<Dancer2::Session::Cookie>
and L<Dancer2::Session::PSGI>

=back

=head1 AUTHOR

Peter Mottram (SysPete), "peter@sysnix.com"

=head1 BUGS

Please report any bugs or feature requests via the project's GitHub
issue tracker:

L<https://github.com/SysPete/Dancer2-Plugin-PageHistory/issues>

I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes. PRs are always welcome.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Dancer2::Plugin::PageHistory

You can also look for information at:

=over 4

=item * L<GitHub repository|https://github.com/SysPete/Dancer2-Plugin-PageHistory>

=item * L<meta::cpan|https://metacpan.org/pod/Dancer2::Plugin::PageHistory>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2015 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify
it under the same terms as the Perl 5 programming language system itself.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Dancer2::Plugin::PageHistory
