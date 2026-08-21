# bash-pitfalls

Minimal, runnable reproductions of subtle shell traps. One script per pitfall;
each is self-contained, ASCII-source, and prints the surprising vs the correct
behaviour side by side.

## Pitfalls

- [`lc_all_c_case_fold.sh`](lc_all_c_case_fold.sh) -- `LC_ALL=C` silently breaks
  case-insensitive matching of non-ASCII text.
