# NAME

Dancer::Plugin::PageHistory - store recent page history for user into session

# VERSION

Version 0.002

# DESCRIPTION

The `add_to_history` keyword which is exported by this plugin allows you to 
add interesting items to the history lists. We also export the `history`
keyword which returns the current [Dancer::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer::Plugin::PageHistory::PageSet)
object.

# SUPPORTED SESSION ENGINES

- [Cookie](https://metacpan.org/pod/Dancer::Session::Cookie)
- [DBIC](https://metacpan.org/pod/Dancer::Session::DBIC)
- [JSON](https://metacpan.org/pod/Dancer::Session::JSON)
- [Simple](https://metacpan.org/pod/Dancer::Session::Simple)
- [Storable](https://metacpan.org/pod/Dancer::Session::Storable)
- [YAML](https://metacpan.org/pod/Dancer::Session::YAML)

# CONFIGURATION

No configuration is necessarily required.

If you wish to have arguments passed to
["new" in Dancer::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer::Plugin::PageHistory::PageSet#new) these can be added to your
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
    ["default\_type" in Dancer::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer::Plugin::PageHistory::PageSet#default_type) in the ["before"](#before) hook.

- ignore\_ajax

    If ["add\_all\_pages"](#add_all_pages) is true this controls whether ajax requests are added to
    the list ["default\_type" in Dancer::Plugin::PageHistory::PageSet](https://metacpan.org/pod/Dancer::Plugin::PageHistory::PageSet#default_type) in the
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
- Add support for more session engines
- Create Dancer2 plugin

# AUTHOR

Peter Mottram (SysPete), "peter@sysnix.com"

# BUGS

This is BETA software so bugs and missing features are expected.

Please report any bugs or feature requests via the project's GitHub
issue tracker:

[https://github.com/SysPete/Dancer-Plugin-PageHistory/issues](https://github.com/SysPete/Dancer-Plugin-PageHistory/issues)

I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.

# SUPPORT

You can find documentation for this module with the perldoc command.

```
perldoc Dancer::Plugin::PageHistory
```

You can also look for information at:

- [GitHub repository](https://github.com/SysPete/Dancer-Plugin-PageHistory)
- [meta::cpan](https://metacpan.org/pod/Dancer::Plugin::PageHistory)

# LICENSE AND COPYRIGHT

Copyright 2015 Peter Mottram (SysPete).

This program is free software; you can redistribute it and/or modify
it under the same terms as the Perl 5 programming language system itself.

See http://dev.perl.org/licenses/ for more information.
