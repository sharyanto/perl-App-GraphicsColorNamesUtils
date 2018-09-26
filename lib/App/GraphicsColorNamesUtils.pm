package App::GraphicsColorNamesUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %SPEC;

$SPEC{list_color_schemes} = {
    v => 1.1,
    summary => 'List all installed Graphics::ColorNames schemes',
};
sub list_color_schemes {
    require Graphics::ColorNames;

    my %args = @_;
    [200, "OK", [Graphics::ColorNames::all_schemes()]];
}

$SPEC{list_color_names} = {
    v => 1.1,
    summary => 'List all color names from a Graphics::ColorNames scheme',
    args => {
        scheme => {
            schema => 'perl::modname*',
            req => 1,
            pos => 0,
        },
        detail => {
            schema => 'true*',
            cmdline_aliases => {l=>{}},
        },
    },
};
sub list_color_names {
    require Graphics::ColorNames;

    my %args = @_;

    tie my %colors, 'Graphics::ColorNames', $args{scheme};

    my @rows;
    my $resmeta = {};
    for (sort keys %colors) {
        push @rows, {name=>$_, rgb=>$colors{$_}};
    }

    if ($args{detail}) {
        $resmeta->{'table.fields'} = [qw/name rgb/];
    } else {
        @rows = map {$_->{name}} @rows;
    }

    [200, "OK", \@rows, $resmeta];
}

$SPEC{show_color_swatch} = {
    v => 1.1,
    summary => 'List all color names from a Graphics::ColorNames scheme as a color swatch',
    args => {
        scheme => {
            schema => 'perl::modname*',
            req => 1,
            pos => 0,
        },
        width => {
            schema => 'posint*',
            default => 80,
            cmdline_aliases => {w=>{}},
        },
    },
};
sub show_color_swatch {
    require Color::ANSI::Util;
    require Color::RGB::Util;
    require String::Pad;

    my %args = @_;
    my $width = $args{width} // 80;

    my $res = list_color_names(scheme => $args{scheme}, detail=>1);
    return $res unless $res->[0] == 200;

    my $reset = Color::ANSI::Util::ansi_reset();
    for my $row (@{ $res->[2] }) {
        my $empty_bar = " " x $width;
        my $text_bar  = String::Pad::pad("$row->{name} ($row->{rgb})", $width, "center", " ", 1);
        my $bar = join(
            "",
            Color::ANSI::Util::ansibg($row->{rgb}), $empty_bar, $reset, "\n",
            Color::ANSI::Util::ansibg($row->{rgb}), Color::ANSI::Util::ansifg(Color::RGB::Util::rgb_is_dark($row->{rgb}) ? "ffffff" : "000000"), $text_bar, $reset, "\n",
            Color::ANSI::Util::ansibg($row->{rgb}), $empty_bar, $reset, "\n",
            $empty_bar, "\n",
        );
        print $bar;
    }
    [200];
}

1;
#ABSTRACT: Utilities related to Graphics::ColorNames

=head1 DESCRIPTION

This distributions provides the following command-line utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

=cut
