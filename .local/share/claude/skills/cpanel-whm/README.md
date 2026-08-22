# cpanel-whm

A Claude Code skill for systems engineers running cPanel & WHM
hosting servers. It covers choosing between WHM API 1, UAPI and
cPanel API 2, authenticating locally and remotely, the safety
rules for acting on live customer accounts, task recipes with
verified commands, and where the state and the logs live.

```
cpanel-whm/
├── SKILL.md
└── references/
    ├── whmapi1.md
    ├── uapi.md
    ├── hooks.md
    ├── easyapache.md
    └── scripts-and-paths.md
```

`SKILL.md` is the always-loaded part: the decision table,
authentication, invocation shapes, safety and the recipes. The
reference files carry the tables and are read on demand.

## Provenance

Everything was researched against the two official sites only,
`api.docs.cpanel.net` and `docs.cpanel.net`, in August 2026. No
blog posts, forum threads or third-party summaries were used.

| Area | Verified against |
|---|---|
| WHM API 1 functions and parameters | The bundled OpenAPI document at `api.docs.cpanel.net/_bundle/specifications/whm.openapi.yaml` (spec version 11.137.9999.106, 625 paths), read verbatim; existence of each function confirmed by `api.docs.cpanel.net/openapi/whm/operation/<name>/` returning 200 |
| UAPI and cPanel API 2 | The per-operation pages under `api.docs.cpanel.net/specifications/cpanel.openapi/` and `api.docs.cpanel.net/cpanel-api-2/`, read through their `.md` exports |
| Authentication and tokens | `api.docs.cpanel.net/guides/guide-to-api-authentication` and its access-hash, API-token and username-and-password subpages; `docs.cpanel.net/whm/development/manage-api-tokens-in-whm/` |
| Standardised hooks | `api.docs.cpanel.net/guides/guide-to-standardized-hooks` and every subpage: the manage_hooks utility, hook action code, describe method, checks, rollbacks, privilege escalation, exceptions, debug mode and all thirteen hookable-event category pages |
| EasyApache 4 | `docs.cpanel.net/ea4/` (about, file system layout, package manager basics, create a profile, the ea-cpanel-tools scripts, PHP inheritance) plus the WHM API 1 PHP and EasyApache Settings modules |
| Scripts, logs and paths | `docs.cpanel.net/whm/scripts/whm-scripts/` and the per-script pages for `pkgacct`, `restorepkg`, `restartsrv`, `rebuildhttpdconf`, `upcp`, `suspendacct`, `unsuspendacct`, `removeacct`, `wwwacct`, `autossl_check`, `checkallsslcerts`, `rebuild_phpconf` |
| Log locations | `docs.cpanel.net/knowledge-base/cpanel-product/the-cpanel-log-files/` |
| Suspension behaviour | `docs.cpanel.net/knowledge-base/accounts/what-happens-when-you-suspend-an-account/` and the suspension-versus-bandwidth-limiting page |
| Release tiers and updates | `docs.cpanel.net/knowledge-base/cpanel-product/product-versions-and-the-release-process/` and `.../the-cpanel-update-configuration-file-cpupdate-conf/` |
| Deprecations | `docs.cpanel.net/knowledge-base/cpanel-product/cpanel-deprecation-plan/` |
| Tweak Settings storage | `docs.cpanel.net/whm/server-configuration/tweak-settings/` and `docs.cpanel.net/installation-guide/customize-your-installation/` |

Two retrieval notes for anyone repeating this work. On
`api.docs.cpanel.net`, appending `.md` to a page path returns the
verbatim markdown, which is the only reliable way to read the
JavaScript-rendered API reference. `docs.cpanel.net` does not do
this, but it publishes a full-text index of all 1236 pages at
`docs.cpanel.net/index.json` and a summary index at
`docs.cpanel.net/llms.txt`.

## What remains unverified

Each reference file ends with its own list. In summary:

- **`whm.conf`.** The string appears nowhere in the
  `docs.cpanel.net` index. Tweak Settings live in
  `/var/cpanel/cpanel.config`; the basic server setup lives in
  `/etc/wwwacct.conf`. Any reference to `/var/cpanel/whm.conf` is
  unconfirmed.
- **`killacct`, `fixquotas`, `mailperm`, `whoowns`, `cpuser`.**
  None appear in the WHM scripts index, which warns against
  running scripts it does not list.
- **`/var/cpanel/packages/` and `/var/cpanel/version/`.** Not
  documented as stores. Only `/var/cpanel/packages/extensions/`
  is. Read packages via `whmapi1 listpkgs`, the version via
  `/usr/local/cpanel/cpanel -V`.
- **The `/scripts` symlink.** Confirmed only indirectly, from an
  installer changelog entry about making it relative.
- **Dry runs.** No cPanel utility documents `--dry-run`. Only
  `rebuildhttpdconf --preview`, `ea_install_profile` without
  `--install` and `rebuild_phpconf --dryrun` behave that way.
- **`ea_install_profile --system` and `--uninstall`.** Not
  documented; only `--install` is.
- **The EA4 repository filename.** Only the directory
  (`/etc/yum.repos.d/`) and the experimental repo IDs are named.
- **`php_vhosts`.** No such file exists in the documentation. The
  per-domain PHP version is the `phpversion:` key in
  `/var/cpanel/userdata/<user>/<domain>`.
- **`addzonerecord`'s `line` parameter.** The specification marks
  it required but defines no such property; it reads as a spec
  bug.
- **UAPI over `/execute/`.** Only the wrapped response schema is
  published, so whether a direct call returns the bare `result`
  object or the full wrapper is unconfirmed.
- **`Park` and `AddonDomain`.** The API 2 pages claim no UAPI
  equivalent exists while the UAPI specification documents one.
  Which path a given server version actually serves is
  unconfirmed.
- **`manage_hooks`.** No `reindex` subcommand is documented;
  `--exectype` appears in examples but not the options table; the
  `fullhelp` output is never shown; and the `Cpanel::UAPI::*`
  event names are generated mechanically rather than listed.
- **Transfer and restore API functions.** The guide describes the
  six-step session workflow but names no functions on its
  introduction page.

## Licence

MIT.
