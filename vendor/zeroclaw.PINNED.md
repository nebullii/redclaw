# Vendored ZeroClaw Pin

`redclaw` uses a dedicated vendored `zeroclaw` checkout at:

- `vendor/zeroclaw`

Current pinned source:

- source repo: `/Users/nehachaudhari/Developer/zeroclaw`
- source branch at clone time: `docs/remove-stale-strict-delta`
- pinned commit: `ceb2396aa3d81807ee6c52defa9630b45298d251`

The vendored checkout is intentionally detached at this commit so `redclaw` does not drift with contributor work in the main `zeroclaw` repo.

## Update process

To move `redclaw` to a newer `zeroclaw` revision:

```bash
cd /Users/nehachaudhari/Developer/redclaw/vendor/zeroclaw
git fetch origin
git checkout --detach <new-commit>
```

Then update this file with the new pinned commit.
