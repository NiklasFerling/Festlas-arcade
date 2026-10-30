# Puzzle Arcade

A phone-first PWA with four puzzle games (Sudoku, Number Match, Wordle, Mastermind), each with its own Elo rating. Plain HTML/CSS/JS: no build step, no package manager, no framework.

## Files

- `index.html`: the whole app. CSS in one `<style>` block, all JS in one IIFE `<script>`. Sections are marked with `/* ---------- Name ---------- */` comments: Ratings, Accounts, Shell, Rules, Tip card, Sudoku, Number Match, Wordle, Mastermind, Farm.
- The Farm is not a rated game and is not in `GAMES`. It is a persistent idle world: crops and animals run on real timestamps, so everything is computed from `Date.now()` when you look (`fPlot`, `fAni`, `fUpdate`) rather than simulated.
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
- Each game has an accent token: `--sdk`, `--num`, `--wrd`, `--mm`.
- Saved progress lives in localStorage under `eloArcade.v1` (ratings), `eloArcade.account` (session) and `eloArcade.farm` (farm, local only, not synced to accounts). Keep the shape compatible: `normalize()` fills defaults for each game in `GAMES`. If the shape changes, migrate old data rather than dropping it.
- Progress synced to Supabase is capped at 20 KB in `arcade_save`.
- **When you change any file in `SHELL` in `sw.js`, bump `CACHE` (e.g. `arcade-v5` → `arcade-v6`)** so installed phones drop the old cache.
- `setup.sql` must stay safe to re-run (`create ... if not exists`, `create or replace`).

## Deploying

Netlify deploys the repo root on every push to `main` (config in `netlify.toml`: no build step, `sw.js` and `config.js` served with `no-cache`). Pull requests get deploy previews. See `SETUP.md`.
