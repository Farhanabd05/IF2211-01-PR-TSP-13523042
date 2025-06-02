#!/usr/bin/env perl
use strict;
use warnings;
use POSIX qw(INFINITY);
use Time::HiRes qw(time);

# Global variables
my $INF            = INFINITY;
my @graph;                          # Adjacency matrix
my $n             = 0;              # Number of cities
my $start_time    = 0;
my %dp            = ();             # dp{city}{mask} = cost
my %parent        = ();             # parent{city}{mask} = [prev_city, prev_mask]
my %path_counts   = ();             # path_counts{"city|mask"} = number of ways
my $min_cost      = $INF;
my @optimal_path  = ();
my $total_paths   = 0;
my $execution_time = 0;

# Entry point
solve();

# ----------------------
sub solve {
    display_welcome_message();
    setup_graph();
    validate_input();
    execute_algorithm();
    display_results();
    exit(0);
}

# ----------------------
sub display_welcome_message {
    print "=" x 50, "\n";
    print "           TSP SOLVER USING DYNAMIC PROGRAMMING\n";
    print "=" x 50, "\n\n";
    print "Available input formats:\n";
    print "  [1] Adjacency Matrix (N x N)\n";
    print "      → Enter matrix dimensions and values\n";
    print "  [2] Edge List (source destination weight)\n";
    print "      → Enter edges one by one, empty line to finish\n\n";
}

# ----------------------
sub setup_graph {
    my $input_type = get_input_type();
    if    ($input_type == 1) { process_matrix_input(); }
    elsif ($input_type == 2) { process_edge_list_input(); }
    else {
        print "Invalid option. Using matrix input as default.\n";
        process_matrix_input();
    }
    normalize_graph();
}

# ----------------------
sub get_input_type {
    while (1) {
        print "Select input type (1 or 2): ";
        chomp(my $input = <STDIN>);
        if ($input =~ /\A[12]\z/) {
            return $input;
        }
        print "Please enter 1 or 2.\n";
    }
}

# ----------------------
sub process_matrix_input {
    $n = get_matrix_size();
    @graph = read_matrix_data();
}

# ----------------------
sub get_matrix_size {
    while (1) {
        print "Enter number of cities (N): ";
        chomp(my $size = <STDIN>);
        if ($size =~ /\A\d+\z/ && $size > 0) {
            return $size;
        }
        print "Size must be a positive integer.\n";
    }
}

# ----------------------
sub read_matrix_data {
    print "Enter the adjacency matrix ($n rows, $n columns each):\n";
    print "Use 0 for no direct connection between different cities.\n\n";
    my @matrix;
    for my $row_index (0 .. $n - 1) {
        while (1) {
            print "Row ", ($row_index + 1), ": ";
            chomp(my $line = <STDIN>);
            my @row_data = split /\s+/, $line;
            if (@row_data == $n) {
                # Convert each to float
                for my $i (0 .. $#row_data) {
                    $row_data[$i] = $row_data[$i] + 0;    # force numeric
                }
                push @matrix, [ @row_data ];
                last;
            }
            print "Error: Expected $n values, got ", scalar(@row_data), ". Please try again.\n";
        }
    }
    return @matrix;
}

# ----------------------
sub process_edge_list_input {
    my $directional = ask_edge_direction();
    my @edges       = collect_edges();
    build_graph_from_edges(\@edges, $directional);
}

# ----------------------
sub ask_edge_direction {
    while (1) {
        print "Are the edges directional? (y/n): ";
        chomp(my $resp = <STDIN>);
        $resp = lc $resp;
        return 1 if $resp eq 'y';
        return 0 if $resp eq 'n';
        print "Please enter 'y' for yes or 'n' for no.\n";
    }
}

# ----------------------
sub collect_edges {
    print "Enter edges in format: source_city destination_city weight\n";
    print "Enter a blank line when finished:\n\n";
    my @edges;
    while (1) {
        chomp(my $line = <STDIN>);
        last if !defined($line) || $line eq '';
        my @parts = split /\s+/, $line;
        if (@parts == 3 && $parts[0] =~ /\A\d+\z/ && $parts[1] =~ /\A\d+\z/ && $parts[2] =~ /\A-?\d+(\.\d+)?\z/) {
            my ($s, $d, $w) = ($parts[0] + 0, $parts[1] + 0, $parts[2] + 0);
            push @edges, [ $s, $d, $w ];
        } else {
            print "Invalid format. Please use: source destination weight\n";
        }
    }
    return @edges;
}

# ----------------------
sub build_graph_from_edges {
    my ($edges_ref, $directional) = @_;
    my @edges = @$edges_ref;
    return if scalar(@edges) == 0;

    # Find all nodes mentioned
    my %seen;
    for my $e (@edges) {
        $seen{ $e->[0] } = 1;
        $seen{ $e->[1] } = 1;
    }
    my @all_nodes = sort { $a <=> $b } keys %seen;
    $n = $all_nodes[-1] + 1;    # assume nodes are zero-based or contiguous

    # Initialize graph with INF
    @graph = ();
    for my $i (0 .. $n - 1) {
        $graph[$i] = [ ( ($INF) x $n ) ];
    }

    # Fill in weights
    for my $e (@edges) {
        my ($s, $d, $w) = @$e;
        $graph[$s][$d] = $w;
        $graph[$d][$s] = $w unless $directional;
    }
}

# ----------------------
sub normalize_graph {
    for my $i (0 .. $n - 1) {
        for my $j (0 .. $n - 1) {
            if ($i == $j) {
                $graph[$i][$j] = 0;
            } elsif ($graph[$i][$j] <= 0) {
                $graph[$i][$j] = $INF;
            }
        }
    }
}

# ----------------------
sub validate_input {
    validate_connectivity();
    validate_graph_completeness();
}

# ----------------------
sub validate_connectivity {
    my @disconnected = find_disconnected_nodes();
    if (@disconnected) {
        print "Error: The following cities have no outgoing connections:\n";
        for my $c (@disconnected) {
            print "  - City $c\n";
        }
        print "Please ensure all cities are connected.\n";
        exit(1);
    }
}

# ----------------------
sub find_disconnected_nodes {
    my @bad;
    for my $i (0 .. $n - 1) {
        my $all_inf = 1;
        for my $w (@{ $graph[$i] }) {
            if ($w != $INF) {
                $all_inf = 0;
                last;
            }
        }
        push @bad, $i if $all_inf;
    }
    return @bad;
}

# ----------------------
sub validate_graph_completeness {
    if ($n < 2) {
        print "Error: Need at least 2 cities to solve TSP.\n";
        exit(1);
    }
}

# ----------------------
sub execute_algorithm {
    $start_time = time();
    initialize_dynamic_programming();
    perform_dynamic_programming();
    find_optimal_solution();
    $execution_time = time() - $start_time;
}

# ----------------------
sub initialize_dynamic_programming {
    %dp          = ();
    %parent      = ();
    %path_counts = ();

    # Starting: at city 0, mask = 1 (only city 0 visited)
    $dp{0}{1} = 0;
    $path_counts{"0|1"} = 1;
}

# ----------------------
sub perform_dynamic_programming {
    my $full_mask = (1 << $n) - 1;
    my @masks     = generate_ordered_masks($full_mask);
    for my $mask (@masks) {
        next if $mask == 0;
        process_mask($mask);
    }
}

# ----------------------
sub generate_ordered_masks {
    my ($fm) = @_;
    my @list = (0 .. $fm);
    return sort { count_set_bits($a) <=> count_set_bits($b) } @list;
}

# ----------------------
sub count_set_bits {
    my ($m) = @_;
    my $count = 0;
    while ($m > 0) {
        $count += ($m & 1);
        $m >>= 1;
    }
    return $count;
}

# ----------------------
sub process_mask {
    my ($mask) = @_;
    for my $current_city (0 .. $n - 1) {
        next unless city_visited_in_mask($current_city, $mask);
        my $current_cost = exists $dp{$current_city}{$mask} ? $dp{$current_city}{$mask} : $INF;
        next if $current_cost == $INF;
        explore_next_cities($current_city, $mask, $current_cost);
    }
}

# ----------------------
sub city_visited_in_mask {
    my ($city, $mask) = @_;
    return ($mask & (1 << $city)) > 0;
}

# ----------------------
sub explore_next_cities {
    my ($current_city, $mask, $current_cost) = @_;
    for my $next_city (0 .. $n - 1) {
        next if city_visited_in_mask($next_city, $mask);
        my $new_mask = $mask | (1 << $next_city);
        my $edge_cost = $graph[$current_city][$next_city];
        next if $edge_cost == $INF;    # no direct edge
        my $new_cost = $current_cost + $edge_cost;
        update_dynamic_programming_state($current_city, $next_city, $mask, $new_mask, $new_cost);
    }
}

# ----------------------
sub update_dynamic_programming_state {
    my ($cc, $nc, $cm, $nm, $ncost) = @_;
    my $key_cur = "$cc|$cm";
    my $key_new = "$nc|$nm";
    my $old_cost = exists $dp{$nc}{$nm} ? $dp{$nc}{$nm} : $INF;
    my $cur_count = $path_counts{$key_cur} // 0;

    if ($ncost < $old_cost) {
        $dp{$nc}{$nm}         = $ncost;
        $parent{$nc}{$nm}     = [ $cc, $cm ];
        $path_counts{$key_new} = $cur_count;
    }
    elsif ($ncost == $old_cost) {
        $path_counts{$key_new} += $cur_count;
    }
}

# ----------------------
sub find_optimal_solution {
    my $full_mask = (1 << $n) - 1;
    $min_cost    = $INF;
    $total_paths = 0;

    # Check all ending cities (except start = 0)
    for my $ec (1 .. $n - 1) {
        my $cost_to_ec = exists $dp{$ec}{$full_mask} ? $dp{$ec}{$full_mask} : $INF;
        next if $cost_to_ec == $INF;
        my $total_cost = $cost_to_ec + $graph[$ec][0];
        my $count_key  = "$ec|$full_mask";
        my $cnt        = $path_counts{$count_key} // 0;
        if      ($total_cost < $min_cost) {
            $min_cost    = $total_cost;
            $total_paths = $cnt;
        }
        elsif ($total_cost == $min_cost) {
            $total_paths += $cnt;
        }
    }

    if ($min_cost < $INF) {
        @optimal_path = @{ construct_optimal_path() };
    }
}

# ----------------------
sub construct_optimal_path {
    my $full_mask = (1 << $n) - 1;
    # Find ending city giving minimum cost
    my $best_ec;
    my $best_val = $INF;
    for my $ec (1 .. $n - 1) {
        my $c_ec = exists $dp{$ec}{$full_mask} ? $dp{$ec}{$full_mask} : $INF;
        next if $c_ec == $INF;
        my $val = $c_ec + $graph[$ec][0];
        if (!defined $best_ec || $val < $best_val) {
            $best_ec  = $ec;
            $best_val = $val;
        }
    }
    return [ ] unless defined $best_ec;

    # Backtrack
    my @path;
    my $cur_city = $best_ec;
    my $cur_mask = $full_mask;
    while ($cur_city != 0) {
        unshift @path, $cur_city;
        my ($pc, $pm) = @{ $parent{$cur_city}{$cur_mask} };
        $cur_city = $pc;
        $cur_mask = $pm;
    }
    return [ (0, @path, 0) ];
}

# ----------------------
sub display_results {
    print "\n", "=" x 50, "\n";
    print "                    SOLUTION RESULTS\n";
    print "=" x 50, "\n\n";

    if ($min_cost == $INF) {
        print "No valid TSP solution found!\n";
        return;
    }

    printf "Minimum tour cost:      %s\n", format_cost($min_cost);
    printf "Number of optimal tours: %d\n", $total_paths;
    printf "Execution time:         %s\n", format_time($execution_time);
    print  "Optimal tour:           ", join(" \u2192 ", @optimal_path), "\n\n";

    display_detailed_path_info();
}

# ----------------------
sub display_detailed_path_info {
    print "Path details:\n";
    my $total_distance = 0;
    for my $i (0 .. $#optimal_path - 1) {
        my $from = $optimal_path[$i];
        my $to   = $optimal_path[$i + 1];
        my $dist = $graph[$from][$to];
        $total_distance += $dist;
        printf "  City %d \u2192 City %d: %s\n", $from, $to, format_cost($dist);
    }
    print "  " . ("-" x 30) . "\n";
    printf "  Total distance: %s\n", format_cost($total_distance);
}

# ----------------------
sub format_cost {
    my ($c) = @_;
    return sprintf("%.2f", $c);
}

# ----------------------
sub format_time {
    my ($t) = @_;
    return sprintf("%.3f ms", $t * 1000);
}
# Row 1: 0 10 15
# Row 2: 20 0 35
# Row 3: 30 25 0

# 0 10 15 20
# 5  0  9 10
# 6 13  0 12
# 8  8  9  0

# 0 29 20 21 16
# 29 0 15 17 28
# 20 15 0 28 23
# 21 17 28 0 12
# 16 28 23 12 0

# 0 12 10 19 8 15
# 12 0 3 7 17 20
# 10 3 0 6 14 18
# 19 7 6 0 9 11
# 8 17 14 9 0 13
# 15 20 18 11 13 0

0 1 10
1 2 35
2 0 30
0 2 15
1 0 20
2 1 25