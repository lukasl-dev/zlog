{ pkgs, ... }:

{
  packages = [ pkgs.git ];

  languages.zig.enable = true;

  difftastic.enable = true;

  tasks = {
    "test:watch".exec = "zig build test --watch";
    "test:fuzz".exec = "zig build test --fuzz";
    "build:debug".exec = "zig build -Doptimize=Debug";
    "build:releaseFast".exec = "zig build -Doptimize=ReleaseFast";
    "build:releaseSafe".exec = "zig build -Doptimize=ReleaseSafe";
  };

  enterTest = ''
    zig build
    zig build test
  '';
}
