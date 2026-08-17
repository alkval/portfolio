≠rá^—f•ñÿ¶{NÏy 'v√Æ∂õ≠# Alexander Kvalvaag ‚Äî Portfolio

Source for [alkval.com](https://alkval.com), served by Nginx through a Cloudflare Tunnel with no public router ports.

## Structure

- `site/` contains the static portfolio and its assets.
- `docker-compose.yml` runs Nginx and the existing Cloudflare Tunnel.
- `scripts/` and `deploy/` provide automatic production updates.

The production tunnel token is stored only in `/DATA/AppData/portfolio/secrets/tunnel-token` and is excluded from Git.

## Production

Production checks GitHub `main` every minute. It updates only when the commit changes, uses a deployment lock, verifies the Nginx container after updating, and rolls back the checkout if the health check fails.

Install the updater once on the Pop!_OS host as `alkval`:

```bash
cd /DATA/AppData/portfolio
bash scripts/install-autodeploy.sh
```

After installation, publishing a commit to `main` is sufficient to update the live portfolio.

