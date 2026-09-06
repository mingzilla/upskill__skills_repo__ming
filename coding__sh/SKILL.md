---
name: coding__sh
description: sh coding rules — patterns, conventions, and anti-patterns to follow
---

## .sh file pattern

```text
definition (ns means suitable namespace):
ns::fun1
ns::fun2
ns::fun3

then run:
ns::fun1
ns::fun2
ns::fun3
```

## Path agnostic

Add suitable entry root (adapt surrounding code convention) to allow running code from any dir

```bash
#!/bin/bash
cd "$(dirname "$0")/../.."  # suitable entry root
```
