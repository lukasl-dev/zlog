# zlog

<a href="https://ziglang.org/">
    <img src="https://img.shields.io/badge/Written_In-Zig-f4a41c?style=for-the-badge&logo=zig" alt="Zig" />
</a>

<br />
<br />

Small helper on top of Zig’s `std.log` that simplifies structured logging
without additional heap allocations.

## Installation

- Zig 0.14.1+
- Add the dependency:
  - `zig fetch --save git+https://github.com/lukasl-dev/zlog.git`
- In your `build.zig`:

```
const dep = b.dependency("zlog", .{ .target = target, .optimize = optimize });
exe.root_module.addImport("zlog", dep.module("zlog"));
```

## Usage

```
const std = @import("std");
const zlog = @import("zlog");

pub fn main() void {
    zlog.info("user logged in", .{ .user = "alice", .id = 1 });
    zlog.scoped(.auth).debug("token issued", .{ .token = "abc123" });
}
```

**Output:**

```
info: user logged in. user=alice id=1
debug(auth): token issued. token=abc123
```
