# Xairo

Elixir API for the [cairo](https://cairographics.org) 2d graphics library.

It uses [Rust bindings for cairo](https://docs.rs/cairo-rs/0.14.9/cairo/) and the [Rustler](https://github.com/rusterlium/rustler) package to provide the NIF bridge to Elixir.

## Installation

Add Xairo as a dependency in your `mix.exs` file.

```elixir
def deps do
  [
    {:xairo, github: "mikowitz/xairo"}
  ]
end
```

Then run this in your shell to fetch the new dependency:

```
~$ mix deps.get
```

## Usage

Currently, Xairo supports

* creating images
* easily scaling images up or down
* drawing on those images with
  * straight lines
  * arcs
  * Bézier curves
  * rectangles
* creating solid, gradient, and mesh color sources
* saving images as *.png files

For full documentation, see the [`Xairo` module](lib/xairo.ex).

