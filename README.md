# Vector

A vector for Elixir backed by Erlang's built-in
[array](http://erlang.org/doc/man/array.html), providing fast
random access, implementing [Access](https://hexdocs.pm/elixir/Access.html), [Enumerable](https://hexdocs.pm/elixir/Enumerable.html), and [Collectable](https://hexdocs.pm/elixir/Collectable.html), and [Inspect](https://hexdocs.pm/elixir/Inspect.html).

[![Build Status](https://travis-ci.org/ckampfe/vector.svg?branch=master)](https://travis-ci.org/ckampfe/vector)

## Installation

This package is [available on Hex](https://hex.pm/docs/publish), and can be installed
by adding `array_vector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:array_vector, "~> 0.1.0"}]
end
```

## Use

For examples and use, see [the documentation](https://hexdocs.pm/array_vector/Vector.html).

## Development

```elixir
$ mix run benchmark.exs
```

## Rationale

You may want to use this library if:

- you have large, ordered data
- you want to perform lots of random lookups and updates
- you want `Access`, `Collectable`, and `Enumerable`, and `Inspect` semantics
- you'd rather use an immutable collection than `ETS`

Elixir's List and Map are great, but they are targeted at linear access and
random, unordered access, respectively.

Vector is for when you want both ordered operations and sublinear lookup/updates.

## Limitations

From the [array](http://erlang.org/doc/man/array.html) documentation:

```
The representation is not documented and is subject to change without notice.
Notice that arrays cannot be directly compared for equality.
```

As such, any equality comparison will be linear time. I'll probably get around to implementing a `Vector.equals?/2` operation at some point. You can always do `Vector.to_list(x) === Vector.to_list(y)` at the expense of converting the underlying `array` to a `list`.

## Benchmark results

Microbenchmarks are generally trash. This is mostly just to confirm that things are working as expected.
See `benchmark.exs` for details.

```
xcxk066$> mix run benchmark.exs
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz
Number of Available Cores: 8
Available memory: 17.179869184 GB
Elixir 1.4.4
Erlang 19.3
Benchmark suite executing with the following configuration:
warmup: 5.00 s
time: 10.00 s
parallel: 1
inputs: none specified
Estimated total run time: 5.00 min

Benchmarking list lookup 1000...
Benchmarking list lookup 10000...
Benchmarking list lookup 100000...
Benchmarking list lookup 1000000...
Benchmarking list lookup 10000000...
Benchmarking list update 1000...
Benchmarking list update 10000...
Benchmarking list update 100000...
Benchmarking list update 1000000...
Benchmarking list update 10000000...
Benchmarking vector lookup 1000...
Benchmarking vector lookup 10000...
Benchmarking vector lookup 100000...
Benchmarking vector lookup 1000000...
Benchmarking vector lookup 10000000...
Benchmarking vector update 1000...
Benchmarking vector update 10000...
Benchmarking vector update 100000...
Benchmarking vector update 1000000...
Benchmarking vector update 10000000...

Name                             ips        average  deviation         median
vector lookup 1000            6.41 M       0.156 μs   ±209.17%       0.150 μs
vector lookup 10000           5.14 M       0.195 μs   ±194.33%       0.180 μs
vector lookup 100000          4.41 M        0.23 μs   ±116.40%        0.21 μs
vector lookup 1000000         3.83 M        0.26 μs    ±60.88%        0.24 μs
vector lookup 10000000        3.39 M        0.30 μs   ±487.48%        0.27 μs
vector update 1000            2.25 M        0.44 μs    ±46.48%        0.40 μs
vector update 10000           1.96 M        0.51 μs    ±25.20%        0.47 μs
vector update 100000          1.66 M        0.60 μs    ±30.32%        0.56 μs
vector update 1000000         1.45 M        0.69 μs    ±40.29%        0.64 μs
vector update 10000000        1.04 M        0.96 μs   ±950.62%        0.80 μs
list lookup 1000              0.32 M        3.13 μs    ±90.13%        3.00 μs
list update 1000             0.114 M        8.73 μs   ±208.10%        8.00 μs
list lookup 10000           0.0528 M       18.94 μs    ±76.38%       18.00 μs
list update 10000           0.0195 M       51.26 μs    ±62.02%       48.00 μs
list lookup 100000         0.00232 M      431.63 μs    ±18.37%      397.00 μs
list lookup 1000000        0.00148 M      677.25 μs    ±27.83%      616.00 μs
list update 100000         0.00083 M     1204.26 μs    ±14.70%     1143.00 μs
list update 1000000        0.00054 M     1835.51 μs    ±19.11%     1776.00 μs
list lookup 10000000       0.00002 M    49104.33 μs     ±5.86%    48766.00 μs
list update 10000000       0.00000 M   534208.53 μs    ±14.76%   548700.00 μs


Comparison:
vector lookup 1000            6.41 M
vector lookup 10000           5.14 M - 1.25x slower
vector lookup 100000          4.41 M - 1.45x slower
vector lookup 1000000         3.83 M - 1.68x slower
vector lookup 10000000        3.39 M - 1.89x slower
vector update 1000            2.25 M - 2.84x slower
vector update 10000           1.96 M - 3.28x slower
vector update 100000          1.66 M - 3.87x slower
vector update 1000000         1.45 M - 4.41x slower
vector update 10000000        1.04 M - 6.18x slower
list lookup 1000              0.32 M - 20.08x slower
list update 1000             0.114 M - 56.02x slower
list lookup 10000           0.0528 M - 121.50x slower
list update 10000           0.0195 M - 328.72x slower
list lookup 100000         0.00232 M - 2768.18x slower
list lookup 1000000        0.00148 M - 4343.48x slower
list update 100000         0.00083 M - 7723.37x slower
list update 1000000        0.00054 M - 11771.81x slower
list lookup 10000000       0.00002 M - 314924.53x slower
list update 10000000       0.00000 M - 3426079.89x slower
```
