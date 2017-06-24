# Vector

A vector for Elixir backed by Erlang's built-in
[array](http://erlang.org/doc/man/array.html), providing fast
random access, implementing [Access](https://hexdocs.pm/elixir/Access.html), [Enumerable](https://hexdocs.pm/elixir/Enumerable.html), [Collectable](https://hexdocs.pm/elixir/Collectable.html), and [Inspect](https://hexdocs.pm/elixir/Inspect.html).

[![Build Status](https://travis-ci.org/ckampfe/vector.svg?branch=master)](https://travis-ci.org/ckampfe/vector)

## Installation

This package is [available on Hex](https://hex.pm/packages/array_vector), and can be installed
by adding `array_vector` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:array_vector, "~> 0.2"}]
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
Operating System: macOS
CPU Information: Intel(R) Core(TM) i7-4870HQ CPU @ 2.50GHz
Number of Available Cores: 8
Available memory: 17.179869184 GB
Elixir 1.4.5
Erlang 20.0
Benchmark suite executing with the following configuration:
warmup: 5.00 s
time: 10.00 s
parallel: 1
inputs: none specified
Estimated total run time: 15.00 min


Benchmarking list new 1000000...
Benchmarking vector to_list 10000...
Benchmarking vector update 1000000...
Benchmarking list update 1000000...
Benchmarking vector lookup 100000...
Benchmarking vector reverse 10000...
Benchmarking vector lookup 1000000...
Benchmarking vector new from list 1000...
Benchmarking vector map + 1 1000...
Benchmarking vector new raw initialize 1000...
Benchmarking vector new raw initialize 1000000...
Benchmarking list reverse 10000...
Benchmarking list reverse 1000...
Benchmarking vector lookup 10000000...
Benchmarking list lookup 10000...
Benchmarking list map + 1 100000...
Benchmarking list lookup 10000000...
Benchmarking vector update 10000000...
Benchmarking list map + 1 1000000...
Benchmarking vector map + 1 10000000...
Benchmarking vector new from list 100000...
Benchmarking list reverse 1000000...
Benchmarking list map + 1 10000000...
Benchmarking vector new raw initialize 100000...
Benchmarking vector update 10000...
Benchmarking vector lookup 10000...
Benchmarking list reverse 10000000...
Benchmarking vector new from list 10000000...
Benchmarking list lookup 1000000...
Benchmarking vector new from list 1000000...
Benchmarking list new 10000000...
Benchmarking vector new from list 10000...
Benchmarking list lookup 100000...
Benchmarking vector map + 1 1000000...
Benchmarking vector to_list 100000...
Benchmarking vector map + 1 100000...
Benchmarking list update 100000...
Benchmarking vector new raw initialize 10000...
Benchmarking list map + 1 1000...
Benchmarking vector update 100000...
Benchmarking list update 10000000...
Benchmarking vector to_list 10000000...
Benchmarking list new 1000...
Benchmarking list new 10000...
Benchmarking vector map + 1 10000...
Benchmarking vector reverse 1000000...
Benchmarking vector reverse 100000...
Benchmarking list map + 1 10000...
Benchmarking list reverse 100000...
Benchmarking vector to_list 1000000...
Benchmarking list new 100000...
Benchmarking vector reverse 1000...
Benchmarking vector new raw initialize 10000000...
Benchmarking list lookup 1000...
Benchmarking list update 1000...
Benchmarking vector lookup 1000...
Benchmarking vector update 1000...
Benchmarking vector to_list 1000...
Benchmarking list update 10000...
Benchmarking vector reverse 10000000...

Name                                         ips        average  deviation         median
vector lookup 1000                    6464726.41       0.155 μs   ±274.26%       0.140 μs
vector new raw initialize 1000        5860396.12       0.171 μs   ±195.76%       0.160 μs
vector lookup 10000                   5466636.03       0.183 μs   ±170.40%       0.170 μs
vector new raw initialize 10000       5312765.81       0.188 μs   ±175.05%       0.170 μs
vector new raw initialize 100000      4887599.30        0.20 μs   ±164.90%       0.190 μs
vector lookup 100000                  4500313.00        0.22 μs   ±114.90%        0.20 μs
vector new raw initialize 10000000    4193030.45        0.24 μs   ±106.02%        0.22 μs
vector lookup 1000000                 4034980.36        0.25 μs    ±70.77%        0.23 μs
vector new raw initialize 1000000     3837327.86        0.26 μs  ±3299.96%        0.20 μs
vector lookup 10000000                3228157.67        0.31 μs   ±472.50%        0.28 μs
vector update 1000                    2255899.67        0.44 μs    ±48.03%        0.41 μs
vector update 10000                   1910655.87        0.52 μs    ±26.15%        0.48 μs
vector update 100000                  1488714.34        0.67 μs   ±795.60%        0.60 μs
vector update 1000000                 1311684.48        0.76 μs    ±70.97%        0.67 μs
vector update 10000000                 861867.99        1.16 μs  ±7100.42%        1.00 μs
list lookup 1000                       538176.92        1.86 μs   ±159.90%        1.70 μs
list reverse 1000                      327210.85        3.06 μs    ±43.49%        2.50 μs
list update 1000                       196502.89        5.09 μs    ±24.80%        4.70 μs
vector to_list 1000                     57372.83       17.43 μs    ±79.76%       16.00 μs
vector new from list 1000               40466.37       24.71 μs    ±30.47%       23.00 μs
list new 1000                           35675.23       28.03 μs    ±50.50%       25.00 μs
list reverse 10000                      24634.15       40.59 μs    ±75.05%       25.00 μs
vector map + 1 1000                     18064.10       55.36 μs    ±19.92%       53.00 μs
list lookup 10000                       15703.65       63.68 μs    ±32.76%       59.00 μs
list map + 1 1000                       11953.95       83.65 μs    ±22.92%       78.00 μs
vector reverse 1000                     11173.90       89.49 μs    ±21.14%       85.00 μs
list update 10000                        6083.59      164.38 μs    ±16.87%      160.00 μs
vector to_list 10000                     4949.35      202.05 μs    ±21.69%      183.00 μs
vector new from list 10000               3404.03      293.77 μs    ±36.33%      264.00 μs
list new 10000                           3118.23      320.70 μs    ±21.48%      311.00 μs
list reverse 100000                      2532.00      394.94 μs    ±79.38%      232.00 μs
list lookup 100000                       1928.03      518.66 μs    ±18.65%      476.00 μs
vector map + 1 10000                     1583.21      631.63 μs    ±22.54%      573.00 μs
list map + 1 10000                       1177.98      848.91 μs    ±15.72%      834.00 μs
vector reverse 10000                      829.62     1205.38 μs    ±23.93%     1081.00 μs
list update 100000                        650.67     1536.88 μs     ±7.08%     1514.00 μs
vector to_list 100000                     529.95     1886.97 μs    ±14.25%     1995.00 μs
list new 100000                           319.84     3126.58 μs    ±15.82%     3276.00 μs
vector new from list 100000               254.60     3927.78 μs    ±28.77%     3527.00 μs
list lookup 1000000                       169.87     5886.73 μs    ±14.93%     5439.00 μs
vector map + 1 100000                     158.98     6290.27 μs    ±12.13%     5924.00 μs
list reverse 1000000                      100.69     9931.31 μs    ±46.44%     9099.00 μs
list map + 1 100000                        88.38    11315.04 μs    ±16.46%    11164.50 μs
vector reverse 100000                      71.16    14052.05 μs    ±15.67%    13752.00 μs
list lookup 10000000                       65.54    15257.65 μs    ±11.04%    14829.00 μs
list update 1000000                        32.93    30370.29 μs     ±6.21%    29811.00 μs
vector to_list 1000000                     32.03    31224.72 μs    ±25.98%    29335.00 μs
vector new from list 1000000               23.83    41962.28 μs    ±26.28%    36328.00 μs
list update 10000000                       16.47    60719.26 μs    ±21.23%    61108.00 μs
list new 1000000                           13.97    71566.26 μs     ±4.32%    71299.00 μs
vector map + 1 1000000                     13.73    72812.56 μs    ±12.65%    69022.00 μs
list map + 1 1000000                        8.18   122219.85 μs    ±12.67%   119922.50 μs
list reverse 10000000                       6.64   150527.52 μs    ±45.15%   135144.00 μs
vector reverse 1000000                      6.55   152588.91 μs    ±15.31%   143807.50 μs
vector to_list 10000000                     3.54   282089.33 μs    ±21.21%   270121.50 μs
list new 10000000                           1.80   555152.33 μs    ±38.68%   512246.00 μs
vector new from list 10000000               1.71   583588.88 μs    ±15.54%   616824.00 μs
vector map + 1 10000000                     1.18   848710.67 μs    ±14.01%   822347.00 μs
list map + 1 10000000                       0.72  1384228.88 μs    ±14.75%  1378561.50 μs
vector reverse 10000000                     0.57  1740072.50 μs     ±9.61%  1773625.00 μs

Comparison:
vector lookup 1000                    6464726.41
vector new raw initialize 1000        5860396.12 - 1.10x slower
vector lookup 10000                   5466636.03 - 1.18x slower
vector new raw initialize 10000       5312765.81 - 1.22x slower
vector new raw initialize 100000      4887599.30 - 1.32x slower
vector lookup 100000                  4500313.00 - 1.44x slower
vector new raw initialize 10000000    4193030.45 - 1.54x slower
vector lookup 1000000                 4034980.36 - 1.60x slower
vector new raw initialize 1000000     3837327.86 - 1.68x slower
vector lookup 10000000                3228157.67 - 2.00x slower
vector update 1000                    2255899.67 - 2.87x slower
vector update 10000                   1910655.87 - 3.38x slower
vector update 100000                  1488714.34 - 4.34x slower
vector update 1000000                 1311684.48 - 4.93x slower
vector update 10000000                 861867.99 - 7.50x slower
list lookup 1000                       538176.92 - 12.01x slower
list reverse 1000                      327210.85 - 19.76x slower
list update 1000                       196502.89 - 32.90x slower
vector to_list 1000                     57372.83 - 112.68x slower
vector new from list 1000               40466.37 - 159.76x slower
list new 1000                           35675.23 - 181.21x slower
list reverse 10000                      24634.15 - 262.43x slower
vector map + 1 1000                     18064.10 - 357.88x slower
list lookup 10000                       15703.65 - 411.67x slower
list map + 1 1000                       11953.95 - 540.80x slower
vector reverse 1000                     11173.90 - 578.56x slower
list update 10000                        6083.59 - 1062.65x slower
vector to_list 10000                     4949.35 - 1306.18x slower
vector new from list 10000               3404.03 - 1899.14x slower
list new 10000                           3118.23 - 2073.21x slower
list reverse 100000                      2532.00 - 2553.21x slower
list lookup 100000                       1928.03 - 3353.03x slower
vector map + 1 10000                     1583.21 - 4083.29x slower
list map + 1 10000                       1177.98 - 5487.96x slower
vector reverse 10000                      829.62 - 7792.43x slower
list update 100000                        650.67 - 9935.48x slower
vector to_list 100000                     529.95 - 12198.75x slower
list new 100000                           319.84 - 20212.50x slower
vector new from list 100000               254.60 - 25392.00x slower
list lookup 1000000                       169.87 - 38056.09x slower
vector map + 1 100000                     158.98 - 40664.90x slower
list reverse 1000000                      100.69 - 64203.19x slower
list map + 1 100000                        88.38 - 73148.61x slower
vector reverse 100000                      71.16 - 90842.68x slower
list lookup 10000000                       65.54 - 98636.52x slower
list update 1000000                        32.93 - 196335.65x slower
vector to_list 1000000                     32.03 - 201859.25x slower
vector new from list 1000000               23.83 - 271274.66x slower
list update 10000000                       16.47 - 392533.43x slower
list new 1000000                           13.97 - 462656.32x slower
vector map + 1 1000000                     13.73 - 470713.27x slower
list map + 1 1000000                        8.18 - 790117.92x slower
list reverse 10000000                       6.64 - 973119.20x slower
vector reverse 1000000                      6.55 - 986445.55x slower
vector to_list 10000000                     3.54 - 1823630.36x slower
list new 10000000                           1.80 - 3588907.95x slower
vector new from list 10000000               1.71 - 3772742.46x slower
vector map + 1 10000000                     1.18 - 5486682.26x slower
list map + 1 10000000                       0.72 - 8948660.97x slower
vector reverse 10000000                     0.57 - 11249092.65x slower
```