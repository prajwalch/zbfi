# zbfi
zbfi is a BrainFuck programming language interpreter written in zig.
It is written only to learn zig for myself but you can experiment
with the code however you like.

Please note that still many features are yet to implement.

## Building
To build the project you only need to have a [zig compiler - v0.8.1](https://ziglang.org/download).
All the install instructions are there, so download and install it according to the instructions then follow the below steps.

1. Clone it with `git clone --recursive https://github.com/PrajwalCH/zbfi`
2. Change directory to zbfi
3. Run `zig build -Drelease-safe=true` to build it.
4. Run `./zig-out/bin/zbfi` for interactive mode or `./zig-out/bin -f <file-name>` to run source code
