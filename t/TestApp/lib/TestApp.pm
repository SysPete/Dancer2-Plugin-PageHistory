package TestApp;
use Dancer ':syntax';
use Dancer::Plugin::PageHistory;
use File::Temp;

our $VERSION = '0.1';

my $fh = File::Temp->new(
    TEMPLATE => 'page_history_XXXXX',
    EXLOCK   => 0,
    TMPDIR   => 1,
);

set plugins => {
    DBIC => {
        default => {
            dsn          => "dbi:SQLite:dbname=$fh",
            schema_class => "TestApp::Schema",
        }
    },
    PageHistory => {
        add_all_pages => 1,
        ignore_ajax   => 1,
        PageSet       => { max_items => 3, methods => [ 'default', 'product' ] }
    }
};

get '/' => sub {
    info setting('conffile');
    info config;
    template 'index';
};

get '/manual/**' => sub { 
    add_to_history;
    my $history = history;
    return $history;
};

get '/**' => sub {
    my $history = history;
    return $history;
};



true;
