Script to verify that all polygons in all MVTs are oriented clockwise (in
screen coordinates) correctly.

Usage:

```bash
find tiles -size +1c -type f -print0 | xargs -0 -P 6 tools/debug_mvt.py
```
