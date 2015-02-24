package # Hide from PAUSE
  Dancer::Plugin::PageHistory::Pages;

use Moo;

use MooX::Types::MooseLike::Base qw(ArrayRef HashRef Int);
use Sub::Quote qw(quote_sub);

=head1 ATTRIBUTES

=head2 max_items

The maximum number of each history C<type> stored in L</pages>.

=cut

has max_items => (
    is      => 'ro',
    isa     => Int,
    default => 10,
);

=head2 pages

A hash reference of arrays of hash references.

Primary key is the history C<type> such as C<all> or C<product>. For each 
C<type> an array reference of pages is stored with newest pages added at 
the start of the list.

=cut

has pages => (
    is => 'rw',
    isa =>
      HashRef [ ArrayRef [ InstanceOf ['Dancer::Plugin::PageHistory::Page'] ] ],
);

=head2 current_page

Returns the first page from L</pages> of type C<all>.  Returns undef if
L</pages> has no C<type> named C<all>.

=cut

has current_page => (
    is => 'lazy',
    isa => HashRef,
);

sub _build_current_page {
    my $self = shift;
    if ( defined $self->pages->{all} ) {
        return $self->pages->{all}->[0];
    }
    return undef;
}

=head2 previous_page

Returns the second page from L</pages> of type C<all>. Returns undef if
L</pages> has no C<type> named C<all>.

=cut

has previous_page => (
    is  => 'lazy',
    isa => HashRef,
);

sub _build_previous_page {
    my $self = shift;
    if ( defined $self->pages->{all} ) {
        return $self->pages->{all}->[1];
    }
    return undef;
}

=head2 methods

An array reference of extra method names that should be added to the class.
For example if one of these method names is 'product' then the following
shortcut method will be added:

    sub product {
        return shift->pages->{"product"};
    }

=cut

has methods => (
    is      => 'ro',
    isa     => ArrayRef,
    default => sub { [] },
    trigger => 1,
);

sub _trigger_methods {
    my ( $self, $methods ) = @_;
    foreach my $method ( @$methods ) {
        unless ( $self->can( $method )) {
            quote_sub "Dancer::Plugin::PageHistory::Pages::$method",
              q{ return shift->pages->{$method}; },
              { '$method' => \$method };
        }
    }
}

=head1 METHODS

=head2 add( %args )

If C<$args{type}> is not defined then we die.

=cut

sub add {
    my ( $self, %args ) = @_;
    my $type = delete $args{type};

    die "type must be defined for Dancer::Plugin::PageHistory->add"
      unless $type;
    die "uri must be defined for Dancer::Plugin::PageHistory->add"
      unless $args{uri};

    if (   !$self->pages->{$type}
        || !$self->pages->{$type}->[0]
        || $self->pages->{$type}->[0]->{uri} ne $args{uri} )
    {

        # not same uri as newest items on this list so add it

        unshift( @{ $self->pages->{$type} }, \%args );

        # trim to max_items if necessary
        pop @{ $self->pages->{$type} }
          if @{ $self->pages->{$type} } > $self->max_items;
    }
}

1;
