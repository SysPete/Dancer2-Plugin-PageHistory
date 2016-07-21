# NAME

Dancer2::Plugin::PageHistory - store recent page history for user into session

# VERSION

Version 0.204

# SYNOPSIS

```perl
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
```

# DESCRIPTION

The `add_to_history` keyword which is exported by this plugin allows you to 
add interesting items to the history lists which are returned using the
`history` keyword.

# KEYWORDS

## add\_to\_history

Adds a page via ["add" in Dancer2::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::PageSet#add). Both of
[path](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::Page#path) and
[query\_string](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::Page#query_string) are optional
arguments
which will be set automatically from the current request if they are not
supplied.

## history

Returns the current [Dancer2::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::PageSet) object from the
user's session.

# SUPPORTED SESSION ENGINES

[CGISession](https://metacpan.org/pod/Dancer2::Session::CGISession),
[Cookie](https://metacpan.org/pod/Dancer2::Session::Cookie), 
[DBIC](https://metacpan.org/pod/Dancer2::Session::DBIC),
[JSON](https://metacpan.org/pod/Dancer2::Session::JSON),
[Memcached](https://metacpan.org/pod/Dancer2::Session::Memcached),
[MongoDB](https://metacpan.org/pod/Dancer2::Session::MongoDB),
[PSGI](https://metacpan.org/pod/Dancer2::Session::PSGI),
[Redis](https://metacpan.org/pod/Dancer2::Session::Redis),
[Sereal](https://metacpan.org/pod/Dancer2::Session::Sereal),
[Simple](https://metacpan.org/pod/Dancer2::Session::Simple),
[YAML](https://metacpan.org/pod/Dancer2::Session::YAML)

# CONFIGURATION

No configuration is necessarily required.

If you wish to have arguments passed to
["new" in Dancer2::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::PageSet#new) these can be added to your
configuration along with configuration for the plugin itself, e.g.:

```
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

```

Configuration options for the plugin itself:

- add\_all\_pages

    Defaults to 0. Set to 1 to have all pages added to the list
    ["default\_type" in Dancer2::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::PageSet#default_type) in the ["before"](#before) hook.

- ignore\_ajax

    If ["add\_all\_pages"](#add_all_pages) is true this controls whether ajax requests are added to
    the list ["default\_type" in Dancer2::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer2::Plugin::PageHistory::PageSet#default_type) in the
    ["before"](#before) hook.

    Defaults to 0. Set to 1 to have ajax requests ignored.

- history\_name

    This setting can be used to change the name of the key used to store
    the history object in the session from the default `page_history` to
    something else. This is also the key used for name of the token
    containing the history object that is passed to templates.

# HOOKS

This plugin makes use of the following hooks:

## before

Add current page to history. See ["add\_all\_pages"](#add_all_pages) and ["ignore\_ajax"](#ignore_ajax).

## before\_template\_render

Puts history into the token `page_history`.

# TODO

- Add more tests

# AUTHOR

Peter Mottram (SysPete), `<peter@sysnix.com>`

# CONTRIBUTORS

Slaven Rezić (eserte) - GH issue #1

# BUGS

Please report any bugs or feature requests via the project's GitHub
issue tracker:

[https://github.com/SysPete/Dancer2-Plugin-PageHistory/issues](https://github.com/SysPete/Dancer2-Plugin-PageHistory/issues)

I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes. PRs are always welcome.

# SUPPORT

You can find documentation for this module with the perldoc command.

```
perldoc Dancer2::Plugin::PageHistory
```

You can also look for information at:

- [GitHub repository](https://github.com/SysPete/Dancer2-Plugin-PageHistory)
- [meta::cpan](https://metacpan.org/pod/Dancer2::Plugin::PageHistory)

# LICENSE AND COPYRIGHT

Copyright 2015-2016 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify
it under the same terms as the Perl 5 programming language system itself.

See http://dev.perl.org/licenses/ for more information.
