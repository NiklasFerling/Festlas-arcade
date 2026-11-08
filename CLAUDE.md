# Puzzle Arcade

A phone-first PWA with nine puzzle games (Sudoku, Number Match, Wordle, Mastermind, Queens, Minesweeper, Word Ladder, KenKen, Block Blast), each with its own Elo rating. Plain HTML/CSS/JS: no build step, no package manager, no framework.

## Files

- `index.html`: the whole app. CSS in one `<style>` block, all JS in one IIFE `<script>`. Sections are marked with `/* ---------- Name ---------- */` comments: Ratings, Accounts, Shell, Rules, Tip card, Sudoku, Number Match, Wordle, Mastermind, Queens, Minesweeper, Word Ladder, KenKen, Block Blast.
- Block Blast is a score game: the rating sets the piece mix (`bbD`) and a target score (`bbTarget`), and the result is how the final score compares to the target. The target was calibrated against the greedy bot in `bbBest`, which also powers its tips.
- Every generator guarantees a fair puzzle: Sudoku, Queens and KenKen have exactly one solution, Minesweeper boards are laid after the first tap and only kept if logic alone clears them, Word Ladder par is the shortest route through common words. Difficulty (`puzzleR`) comes from grading the puzzle, not from the target rating.
- Word Ladder's word lists come from SCOWL (npm `wordlist-english`, Copyright 2000-2016 Kevin Atkinson). Its license asks that the copyright notice stays with the lists, so keep the comment above `LAD_COMMON`.
- `config.js`: Supabase URL and publishable key (`window.ARCADE_CONFIG`). Empty means local-only mode. The key is public by design.
- `sw.js`: service worker. Network-first for app files, cache-first for Google Fonts.
- `manifest.webmanifest` and the `icon-*.png` files: PWA install metadata.
- `setup.sql`: Supabase schema plus the five RPC functions (`arcade_register`, `arcade_login`, `arcade_load`, `arcade_save`, `arcade_logout`). Tables are locked down with RLS, so the app can only call those functions.
- `SETUP.md`: deploy and account setup steps written for a non-developer.

## Running locally

```sh
python3 -m http.server 8000
```

Open http://localhost:8000. The service worker needs http(s), so `file://` won't do. When testing changes, hard-reload or unregister the service worker in DevTools so you aren't served a stale cache.

## Conventions

- Keep the single-file structure and the existing dense code style (short names, compact one-line functions). Match the code around you.
- Colors come from CSS custom properties on `:root`, with dark-mode overrides in two places (the `prefers-color-scheme` media query and `[data-theme="dark"]`). Add new colors to all three blocks.
- Each game has an accent token: `--sdk`, `--num`, `--wrd`, `--mm`, `--qn`, `--ms`, `--lad`, `--ken`, `--bb`. Queens regions use the fixed pastel `QN_COLORS` with `--qink` for text and borders in both themes.
- Games in `TIMED` (Sudoku, Queens, KenKen) share the clock in `sdkStart`/`sdkPause` and the quick-solve bonus (`quickScore`).
- Saved progress lives in localStorage under `eloArcade.v1` (ratings) and `eloArcade.account` (session). Keep the shape compatible: `normalize()` fills defaults for each game in `GAMES`. If the shape changes, migrate old data rather than dropping it.
- Progress synced to Supabase is capped at 20 KB in `arcade_save`.
- **When you change any file in `SHELL` in `sw.js`, bump `CACHE` (e.g. `arcade-v5` → `arcade-v6`)** so installed phones drop the old cache.
- `setup.sql` must stay safe to re-run (`create ... if not exists`, `create or replace`).

## Deploying

Netlify deploys the repo root on every push to `main` (config in `netlify.toml`: no build step, `sw.js` and `config.js` served with `no-cache`). Pull requests get deploy previews. See `SETUP.md`.
