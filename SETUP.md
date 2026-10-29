# Puzzle Arcade setup

The app works straight away and saves ratings on the phone. Accounts are optional. They let you log in with a username and password and keep your ratings on any phone.

## 1. Put the app online

**Option A, deploy from GitHub (updates automatically):** on https://app.netlify.com choose **Add new site → Import an existing project**, connect GitHub and pick this repository. The settings come from `netlify.toml`, so leave the build fields as they are and click **Deploy**. Every push to `main` redeploys the site, and pull requests get their own preview link.

**Option B, drag and drop:** go to https://app.netlify.com/drop and drag the project folder onto the page. Create the free account it offers so the site stays up.

Either way you get an address like `https://something.netlify.app`.

## 2. Turn on accounts (about 5 minutes, free)

1. Go to https://supabase.com, sign up, and click **New project**. Any name and region works (pick a European region for speed from Norway). Save the database password it shows, though the app doesn't need it.
2. When the project is ready, open **SQL Editor** in the left menu, click **New query**, paste everything from `setup.sql`, and press **Run**. It should say "Success".
3. Open **Project Settings → API Keys** (or the **Connect** button at the top). Copy:
   - the **Project URL**, like `https://abcdefghijkl.supabase.co`
   - the **publishable** key (`sb_publishable_…`), or on older projects the **anon public** key (`eyJ…`)
4. Open `config.js` in the app folder with any text editor and paste them in:

   ```js
   window.ARCADE_CONFIG = {
     supabaseUrl: "https://abcdefghijkl.supabase.co",
     supabaseKey: "sb_publishable_xxxxxxxxxxxx"
   };
   ```

5. Commit and push the change (Option A), or drag the folder onto Netlify again (Option B: the site's **Deploys** page has an upload box for new versions, which keeps the same address).

Open the app, tap **Sign in** (top right), then **Create account**.

## 3. Install it on your phone

- **iPhone:** open the address in Safari, tap Share, then **Add to Home Screen**.
- **Android:** open it in Chrome, tap ⋮, then **Install app**.

Always open it from the home-screen icon.

## Good to know

- Passwords are stored hashed with bcrypt, never as plain text. There is no password reset, so pick one you'll remember.
- If you play offline, the app saves locally and uploads when you're back online.
- Free Supabase projects pause after a week with no activity. If sign-in stops working, open the Supabase dashboard and press **Restore project**.
- The publishable/anon key is meant to be public. The database only accepts the app's five sign-in and save actions.
