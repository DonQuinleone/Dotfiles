---
name: cpanel-whm
description: >-
  Administer cPanel & WHM hosting servers from the shell and over
  HTTP: pick the right API, write whmapi1 and uapi one-liners and
  jq pipelines, and run cPanel runbooks. Use whenever the task
  mentions WHM, cPanel, WHM API 1, UAPI, cPanel API 2, whmapi1,
  uapi, cpapi2, EasyApache, EA4, MultiPHP, AutoSSL, standardised
  hooks, manage_hooks, account creation, suspension or
  termination, packages and plans, resellers, addon domains and
  subdomains, e-mail accounts and quotas, DNS zones, /scripts,
  /usr/local/cpanel/scripts, pkgacct, restorepkg, rebuildhttpdconf,
  restartsrv, cpanel.config, tweak settings, the cPanel log files,
  or /var/cpanel.
metadata:
  licence: MIT
  author: hand-written
  sources: api.docs.cpanel.net, docs.cpanel.net
---

# cPanel & WHM administration

Pick the right API, call it safely, and know where the state and
the logs live. Every command here was checked against
`api.docs.cpanel.net` or `docs.cpanel.net`, and each reference
file ends with what could not be verified. The catalogue moves
between major versions, so confirm before quoting behaviour.

## Choosing an API

Three APIs coexist. Pick by whose privileges the job needs.

| API | Runs as | Use it for | CLI |
|---|---|---|---|
| WHM API 1 | root or a reseller | Server administration: accounts, packages, services, DNS zones, SSL, PHP versions, tweak settings | `whmapi1` |
| UAPI | one cPanel user | Anything inside a single account: e-mail, files, databases, subdomains | `uapi --user=<user>` |
| cPanel API 2 | one cPanel user | Legacy account-level functions with no UAPI equivalent, and nothing else | `cpapi2 --user=<user>` |

Where a function exists in both, prefer WHM API 1 as root. API 2
is deprecated: use it only after confirming there is no UAPI
equivalent. Cron is the clearest surviving case, since UAPI has
no cron module, so `Cron::add_line` and `Cron::listcron` remain
API 2. Several API 2 pages still claim "no equivalent UAPI
function exists" when one now does, so check the UAPI side first.
cPanel API 1 is gone: removed in 88.

## Authentication

Locally as root you need no credentials: `whmapi1`, `uapi` and
`cpapi2` authenticate from the invoking uid, which is the normal
path on the server itself. Remotely, use API tokens.

| Target | Header | Port |
|---|---|---|
| WHM API 1 | `Authorization: whm <user>:<token>` | 2087, or 443 via a service subdomain |
| UAPI | `Authorization: cpanel <user>:<token>` | 2083 |

WHM tokens come from WHM's *Manage API Tokens* or
`api_token_create`, and are revoked with `api_token_revoke`. A
token can carry an expiry, an allowed-IP list and ACL
restrictions, though the docs call ACL restriction experimental.
It is shown once and never again, and an expired token is not
deleted for you. cPanel-user tokens come from cPanel's *Manage
API Tokens* or UAPI `Tokens::create_full_access`. Access hashes
(`Authorization: WHM root:<hash>` from `~/.accesshash`) were
deprecated in 64; migrate them with
`/usr/local/cpanel/scripts/convert_accesshash_to_token`. HTTP
Basic works but the docs warn against it off TLS, and needs
Security Policy Extensions to coexist with 2FA.

Ports are strict: WHM on 2086/2087, cPanel on 2082/2083, Webmail
on 2095/2096. A correct call on the wrong port returns
"Permission denied" or "Function not found", which reads like a
permissions bug and is not one.

## Invocation and output

```bash
whmapi1 --output=jsonpretty listaccts
uapi --user=exampleuser --output=json Email list_pops
cpapi2 --user=exampleuser --output=json Cron listcron

curl -sS -H 'Authorization: whm root:APITOKEN' \
  'https://server.example.com:2087/json-api/listaccts?api.version=1'
curl -sS -H 'Authorization: cpanel exampleuser:APITOKEN' \
  'https://example.com:2083/execute/Email/list_pops'
```

`--output` takes `json`, `jsonpretty` or `yaml`; yaml is the
default, so pass `--output=json` when a machine reads the result.
On CloudLinux, call the binaries by full path under
`/usr/local/cpanel/bin/`. WHM API 1 over HTTP needs
`api.version=1` on every call, takes `1`/`0` for booleans (never
`true`/`false`), and URI-encodes every value. cPanel API 2 is not
reachable on cPanel's own ports: it goes through the WHM API
wrapper on 2087.

Check the result before trusting the payload. WHM API 1 returns
`data` plus `metadata` (`result` is `1` on success, `0` with the
message in `reason`); UAPI returns `result` with `status`,
`errors`, `messages`, `warnings`, `data` and `metadata`. WHM API
1 also accepts generic `api.filter.*`, `api.sort.*`,
`api.columns.*` and `api.chunk.*` controls.

```bash
whmapi1 --output=json listaccts | jq -r '.data.acct[].user'
whmapi1 --output=json accountsummary user=exampleuser \
  | jq -e '.metadata.result == 1' >/dev/null || echo 'call failed'
uapi --user=exampleuser --output=json Email list_pops \
  | jq -r '.result.data[].email'
```

## Safety

These commands act on live customer hosting.

- **Read before you write.** Establish current state
  (`accountsummary`, `get_domain_info`, the file under
  `/var/cpanel/`), then change one thing.
- **Never suspend, terminate or restore without explicit
  confirmation from the user, naming the account.** `removeacct`
  destroys the home directory, databases, mail and DNS zones, and
  the account cannot even be recreated immediately afterwards.
  There is no undo, only a restore from backup.
- **Back up first.** Take a `pkgacct` archive before any
  destructive or structural change, and confirm it is non-empty.
- **Dry runs barely exist.** No cPanel utility documents a
  `--dry-run`; the three real ones are `rebuildhttpdconf
  --preview`, `ea_install_profile` without `--install` and
  `rebuild_phpconf --dryrun`. Check `--help` on the box before
  assuming any other flag exists.
- **Test on a non-production server**, as cPanel's own guidance
  says: support cannot always help with third-party code.
- **Know the version.** Names, defaults and behaviour move
  between major versions. Check `/usr/local/cpanel/cpanel -V` and
  the tier in `/etc/cpupdate.conf` first.
- **Do not hand-edit generated files** (`httpd.conf`, zone files,
  `/var/cpanel/userdata/`): cPanel rebuilds them. Nor run scripts
  the WHM scripts index does not list, which it warns may damage
  the server.
- **Batch carefully.** A loop over `listaccts` calling a write
  function will suspend every account on the server. Print the
  plan, get it approved, then run it.

## Recipes

Accounts. `createacct` needs only `username`; omit the password
and one is generated. Prefer `changepackage` to `modifyacct` for
an account that uses a package.

```bash
whmapi1 --output=json listaccts \
  | jq -r '.data.acct[] | "\(.user)\t\(.domain)\t\(.suspended)"'
whmapi1 --output=json listpkgs | jq -r '.data.pkg[].name'
whmapi1 createacct username=exampleuser domain=example.com \
  plan=starter contactemail=owner@example.net
whmapi1 changepackage user=exampleuser pkg=business
whmapi1 suspendacct user=exampleuser reason='Non-payment'
whmapi1 unsuspendacct user=exampleuser
whmapi1 passwd user=exampleuser password='<generated>'
```

Domains:

```bash
whmapi1 --output=json get_domain_info | jq -r '.data.domains[]
  | select(.user=="exampleuser") | "\(.domain)\t\(.domain_type)"'
whmapi1 --output=jsonpretty domainuserdata domain=example.com
uapi --user=exampleuser --output=json DomainInfo list_domains
uapi --user=exampleuser SubDomain addsubdomain \
  domain=shop rootdomain=example.com
uapi --user=exampleuser AddonDomain addaddondomain \
  newdomain=other.example subdomain=other
```

E-mail. `edit_pop_quota` wants the mailbox name in `email` and
the domain apart; quotas are megabytes, `0` unlimited.

```bash
uapi --user=exampleuser --output=json Email list_pops
uapi --user=exampleuser Email add_pop email=sales@example.com \
  password='<generated>' quota=1024
uapi --user=exampleuser Email edit_pop_quota \
  domain=example.com email=sales quota=2048
```

DNS. `dumpzone` is deprecated in favour of `parse_dns_zone`.
Editing or removing needs the record's line number, so read the
zone first. `removezonerecord` takes `zone`, not `domain`.

```bash
whmapi1 --output=jsonpretty parse_dns_zone domain=example.com
whmapi1 addzonerecord domain=example.com name=www type=CNAME \
  cname=example.com. class=IN ttl=14400
whmapi1 removezonerecord zone=example.com line=12
```

SSL. Certificate, key and bundle values must be URI-encoded, and
`fetchsslinfo` reports what you *could* install, not what is.

```bash
whmapi1 start_autossl_check_for_one_user username=exampleuser
/usr/local/cpanel/bin/autossl_check --user=exampleuser   # or --all
whmapi1 installssl domain=example.com crt="$CRT" key="$KEY"
```

PHP per domain, under EA4. Set several vhosts at once by
incrementing the parameter name: `vhost-1`, `vhost-2`.

```bash
whmapi1 --output=json php_get_installed_versions
whmapi1 --output=json php_get_vhost_versions \
  | jq -r '.data.versions[] | "\(.vhost)\t\(.version)"'
whmapi1 php_set_vhost_versions vhost=example.com version=ea-php82
grep phpversion /var/cpanel/userdata/exampleuser/example.com
```

Backup and restore. `pkgacct` takes the username after any
options, the directory after it, and matches options strictly.

```bash
/usr/local/cpanel/scripts/pkgacct exampleuser \
  /usr/local/cpanel/backups
/usr/local/cpanel/scripts/restorepkg --ip=n \
  cpmove-exampleuser.tar.gz
```

Services and Apache. Rebuilding never restarts Apache.

```bash
whmapi1 --output=json servicestatus \
  | jq -r '.data.service[] | select(.running != 1) | .name'
/usr/local/cpanel/scripts/restartsrv_named --restart --hard
/usr/local/cpanel/scripts/rebuildhttpdconf --preview
/usr/local/cpanel/scripts/rebuildhttpdconf \
  && /usr/local/cpanel/scripts/restartsrv_httpd
```

EA4 profiles. Snapshot first: the generated profile is your
rollback, and the run without `--install` shows the change.

```bash
/usr/local/bin/ea_current_to_profile \
  --output=/etc/cpanel/ea4/profiles/custom/before-change.json
/usr/local/bin/ea_install_profile \
  /etc/cpanel/ea4/profiles/custom/target.json
/usr/local/bin/ea_install_profile --install \
  /etc/cpanel/ea4/profiles/custom/target.json
```

Hooks. Scripts need `root:root` and `755`, read JSON from stdin,
and print `<result> <message>`, result `1` or `0`.

```bash
/usr/local/cpanel/bin/manage_hooks list
/usr/local/cpanel/bin/manage_hooks add script \
  /usr/local/cpanel/3rdparty/bin/notify.sh \
  --manual --category Whostmgr --event 'Accounts::Create' \
  --stage post --exectype script
```

## Troubleshooting

`/usr/local/cpanel/logs/error_log` catches general errors and
everything hooks emit; `panic_log` beside it should be empty, and
entries there always warrant investigation.

```bash
tail -f /usr/local/cpanel/logs/error_log
tail -f /var/log/exim_mainlog
tail -f /var/log/apache2/error_log
tail -f /etc/apache2/logs/domlogs/exampleuser/example.com
```

Then the account's own state. `SUSPENDED=1` and `SUSPENDTIME=`
live in the `cpuser` file, the reason under
`/var/cpanel/suspended/`, and a `.lock` beside it means only root
may unsuspend. Bandwidth limiting is separate, flagged in
`/var/cpanel/bwlimited/`. Tweak Settings live in
`/var/cpanel/cpanel.config`; change them with `set_tweaksetting`.

```bash
cat /var/cpanel/users/exampleuser
cat /var/cpanel/suspended/exampleuser
cat /var/cpanel/userdata/exampleuser/example.com
whmapi1 --output=json get_tweaksetting key=<setting>
```

## Reference files

- `references/whmapi1.md`: functions, required parameters, the
  envelope, output controls, naming traps.
- `references/uapi.md`: UAPI functions and the API 2 remnants.
- `references/hooks.md`: `manage_hooks`, the hook contract,
  categories and events, debug mode.
- `references/easyapache.md`: packages, profiles, the `ea_*`
  scripts, per-domain PHP, Apache paths.
- `references/scripts-and-paths.md`: the scripts reference, log
  locations, the `/var/cpanel` layout, release tiers.
