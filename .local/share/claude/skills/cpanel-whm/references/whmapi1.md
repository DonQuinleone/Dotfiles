# WHM API 1

Verified against `api.docs.cpanel.net/whm/introduction` and the
bundled OpenAPI specification at
`api.docs.cpanel.net/_bundle/specifications/whm.openapi.yaml`
(spec version 11.137.9999.106, 625 paths). Human pages live at
`https://api.docs.cpanel.net/openapi/whm/operation/<name>/`,
which returns 404 for a name that does not exist and so doubles
as an existence check. Verbatim markdown twins are served by
appending `.md` to a `/specifications/whm.openapi/...` path.

## Calling

```bash
whmapi1 <function> key=value --output=jsonpretty
```

Over HTTPS the base is `https://{host}:2087/json-api/<function>`
with `api.version=1` mandatory on every call. 2086 is the
unsecure port; the cPanel (2082/2083) and Webmail (2095/2096)
ports are rejected outright. Booleans are literal `1` and `0`;
`true` and `false` are not accepted. `--output` takes `json`,
`jsonpretty` or `yaml` (the default).

## Response envelope

```json
{
  "data": { "...": [] },
  "metadata": {
    "command": "listaccts",
    "reason": "OK",
    "result": 1,
    "version": 1
  }
}
```

`metadata.result` is `1` on success and `0` on failure, with the
message in `metadata.reason`. Always test it before reading
`data`. CLI calls do not return the metadata block for errors
that stop the function running at all.

## Output control

These work on any function.

| Family | Parameters |
|---|---|
| Columns | `api.columns.enable`, `api.columns.a`, `api.columns.b`, ... |
| Filter | `api.filter.enable`, `api.filter.a.field`, `api.filter.a.arg0`, `api.filter.a.type` |
| Sort | `api.sort.enable`, `api.sort.a.field`, `api.sort.a.method`, `api.sort.a.reverse` |
| Paginate | `api.chunk.enable`, `api.chunk.size`, `api.chunk.start` (1-indexed) |

Filter types: numeric `==`, `lt`, `lt_equal`,
`lt_handle_unlimited`, `gt`, `gt_equal`, `gt_handle_unlimited`;
string `begins`, `contains`, `eq` (the default). Sort methods:
`ipv4`, `numeric`, `numeric_zero_as_max`, `lexicographic`. A
numeric sort without an explicit `method` fails, and the sort key
must be a displayed column.

## Accounts

| Function | Required | Notable optional |
|---|---|---|
| `listaccts` | none | `search`, `searchmethod` (`exact`/`regex`), `searchtype` (`domain`/`owner`/`user`/`ip`/`package`), `want` |
| `accountsummary` | none in the spec, but you must pass `user` or `domain` | `search`, `searchmethod`, `searchtype` |
| `createacct` | `username` | see below |
| `removeacct` | `username` | `keepdns` (default 0). `user` is a deprecated alias |
| `suspendacct` | `user` | `reason` (default `Unknown`), `disallowun` (default 0), `leave-ftp-accts-enabled` (default 0) |
| `unsuspendacct` | `user` | `retain-service-proxies` |
| `changepackage` | `user`, `pkg` | none |
| `modifyacct` | `user` | see below |
| `passwd` | `user`, `password` | `db_pass_update` (default 1), `digestauth`, `enabledigest` |
| `verify_user_has_feature` | `feature`, `user` | none |

`listaccts` returns `data.acct[]` with `user`, `domain`, `owner`,
`ip`, `plan`, `suspended`, `suspendreason`, `suspendtime`,
`diskused`, `disklimit`, `inodeslimit`, `theme`, `shell`, `uid`,
`startdate`, `unix_startdate`, `backup`, `has_backup`,
`child_nodes[]`, `temporary` and more.

`createacct` takes 48 optional parameters. The ones that matter
day to day: `domain`, `plan` (default `default`), `pkgname`,
`savepkg`, `password` or `pass` (never both; omit and the system
generates one), `contactemail`, `quota` (default 0), `bwlimit`,
`ip` (`y`/`n`, default `n`), `customip`, `cgi` (default 1),
`hasshell`, `reseller`, `reseller_without_domain`, `owner`,
`featurelist` (default `default`), `cpmod`, `language`,
`maxpop`, `maxsub`, `maxpark`, `maxaddon`, `maxsql`, `maxftp`,
`maxlst`, `max_email_per_hour`, `max_emailacct_quota`,
`max_defer_fail_percentage`, `max_team_users`, `mailbox_format`
(`mdbox`/`maildir`), `mxcheck`, `spf`, `dkim`, `dmarc`,
`spamassassin`, `spambox`, `forcedns` (default 0), `homedir`,
`uid`, `gid`.

`modifyacct` takes 57 optional parameters and, unlike
`createacct`, uses uppercase names for the same attributes:
`QUOTA`, `BWLIMIT`, `HASSHELL`, `HASCGI`, `HASDKIM`, `HASDMARC`,
`HASSPF`, `MAXPOP`, `MAXSUB`, `MAXPARK`, `MAXADDON`, `MAXSQL`,
`MAXFTP`, `MAXLST`, `MAX_EMAIL_PER_HOUR`,
`MAX_EMAILACCT_QUOTA`, `MAX_DEFER_FAIL_PERCENTAGE`,
`MAILBOX_FORMAT`, `BACKUP`, `DNS`, `DBOWNER`, `LANG`, `LOCALE`,
`STYLE`, `STARTDATE`, `OUTGOING_EMAIL_SUSPENDED`, plus lowercase
`domain`, `newuser`, `owner`, `reseller`, `shell`,
`contactemail`, `spamassassin`, `rename_database_objects`,
`update_existing_email_account_quotas` and the `notify_*` family.
The docs warn strongly against modifying a single account that
uses a package: change the package instead.

## Packages

| Function | Required | Notable optional |
|---|---|---|
| `listpkgs` | none | `want` (`all` default, `creatable`, `editable`, `viewable`) |
| `addpkg` | `name` | `quota`, `bwlimit`, `cgi`, `cpmod`, `digestauth`, `featurelist`, `hasshell`, `ip`, `language`, `maxaddon`, `maxftp`, `maxlst`, `maxpark`, `maxpop`, `maxsql`, `maxsub`, `max_emailacct_quota`, `max_team_users`, `MAX_DEFER_FAIL_PERCENTAGE`, `MAX_EMAIL_PER_HOUR`, `_PACKAGE_EXTENSIONS` |
| `editpkg` | `name` | the same set, but with lowercase `max_defer_fail_percentage` and `max_email_per_hour` |
| `killpkg` | `pkgname` | none |
| `getpkginfo` | `pkg` | Returns one package's keys |

`listpkgs` returns uppercase keys: `name`, `BWLIMIT`, `CGI`,
`CPMOD`, `DIGESTAUTH`, `FEATURELIST`, `HASSHELL`, `IP`, `LANG`,
`MAXADDON`, `MAXFTP`, `MAXLST`, `MAXPARK`, `MAXPOP`, `MAXSQL`,
`MAXSUB`, `MAX_DEFER_FAIL_PERCENTAGE`, `MAX_EMAILACCT_QUOTA`,
`MAX_EMAIL_PER_HOUR`, `MAX_TEAM_USERS`, `QUOTA`,
`_PACKAGE_EXTENSIONS`.

Note the naming traps here: `killpkg` takes `pkgname` where its
siblings take `name`, and `addpkg` and `editpkg` disagree on the
case of two parameters.

## Domains, sessions, tokens, server

| Function | Required | Notes |
|---|---|---|
| `get_domain_info` | none | Every domain on the server; `data.domains[]` carries `domain`, `domain_type` (`main`/`sub`/`addon`/`parked`), `docroot`, `user`, `user_owner`, `parent_domain`, `php_version`, `ipv4`, `port`, `modsecurity_enabled` |
| `create_subdomain` | `document_root`, `domain` | `use_canonical_name` |
| `domainuserdata` | `domain` | Returns `documentroot`, `homedir`, `ip`, `owner`, `port`, `serveralias`, `servername`, `user`, `hascgi` and friends |
| `create_user_session` | `service` (`cpaneld`/`whostmgrd`/`webmaild`), `user` | `app`, `locale`, `preferred_domain`; returns `data.url`, `data.session`, `data.expires` |
| `api_token_create` | `token_name` (max 50 chars, alphanumerics, `-`, `_`) | `acl` (increment: `acl-1`, `acl-2`), `expires_at` (Unix epoch, `0` = never), `whitelist_ip` (IP or CIDR, incrementable) |
| `api_token_revoke` | `token_name` | |
| `applist` | none | Lists available WHM API 1 functions |
| `version` | none | The cPanel & WHM version |
| `gethostname` | none | |
| `systemloadavg` | none | `data.one`, `data.five`, `data.fifteen`, as a percentage of CPU capacity |
| `showbw` | none | `month`, `year`, `search`, `searchtype`, `showres` |
| `listips` | none | |

There is no `listsubdomains`, `list_subdomains` or `addsubdomain`
in WHM API 1: use `get_domain_info` to read and
`create_subdomain` to write, or the cPanel UAPI `SubDomain`
module for per-account work.

## Services

| Function | Required | Notes |
|---|---|---|
| `servicestatus` | none | `service` narrows it; returns `name`, `display_name`, `enabled`, `installed`, `monitored`, `running` |
| `restartservice` | `service` | `queue_task` (default 0). The function is `restartservice`; there is no `restartsrv` in the API |
| `configureservice` | `service` | `enabled`, `monitored`, `exim-altportnum` (default `26`) |

Documented service names include `apache_php_fpm`, `clamd`,
`cpanel-dovecot-solr`, `cpanel_php_fpm`, `cpanellogd`, `cpdavd`,
`cpgreylistd`, `cphulkd`, `cpsrvd`, `crond`, `dnsadmin`, `exim`,
`exim-altport`, `ftpd`, `httpd`, `imap`, `ipaliases`, `lmtp`,
`mailman`, `mysql`, `named`, `nscd`, `p0f`, `pop`, `postgresql`,
`queueprocd`, `rsyslogd`, `spamd`, `sshd`, `syslogd`,
`tailwatchd`.

## DNS

| Function | Method | Required | Notes |
|---|---|---|---|
| `adddns` | GET | `domain`, `ip` | `trueowner`, `template` (default `standard`), `ipv6` |
| `killdns` | GET | `domain` | |
| `dumpzone` | GET | `domain` | Deprecated in favour of `parse_dns_zone`; accepts `domain` or `zone` |
| `parse_dns_zone` | GET | see the docs | The current replacement for `dumpzone` |
| `getzonerecord` | GET | `domain`, `line` | |
| `addzonerecord` | POST | `domain`, `name`, `type`, `class` plus the type's data field | Body is `application/x-www-form-urlencoded` |
| `editzonerecord` | POST | `domain`, `line`, `ttl` plus the type's data field | Omitted `class`/`name` keep their current value |
| `removezonerecord` | GET | `zone`, `line` | `serialnum`. Note it takes `zone`, not `domain` |

`addzonerecord` and `editzonerecord` are discriminated on `type`
across `A`, `A6`, `AAAA`, `AFSDB`, `ALIAS`, `CAA`, `CNAME`,
`DNAME`, `DS`, `HINFO`, `LOC`, `MX`, `NS`, `PTR`, `RP`, `SOA`,
`SRV` and `TXT`. The type-specific fields:

| Type | Fields |
|---|---|
| `A`, `AAAA` | `address` |
| `CNAME` | `cname`, `flatten`, `flatten_to` |
| `MX` | `exchange`, `preference` |
| `TXT` | `txtdata` |
| `SRV` | `port`, `priority`, `target`, `weight` |
| `CAA` | `flag`, `tag`, `value` |
| `NS` | `nsdname` |
| `PTR` | `ptrdname`, `zone` |
| `SOA` | `mname`, `rname`, `serial`, `refresh`, `retry`, `expire`, `Lines` (spelled `lines` on the edit side) |
| `DS` | `algorithm`, `digtype`, `keyname` |
| `ALIAS` | `alias` |
| `DNAME` | `dname` |
| `HINFO` | `cpu`, `os` |
| `LOC` | `altitude`, `horiz_pre`, `latitude`, `longitude`, `size`, `version`, `vert_pre` |
| `RP` | `mbox`, `txtdname` |
| `AFSDB` | `hostname`, `subtype` |
| `A6` | `prefix`, `refer` |

To edit or remove a record, read the zone first to find the
record's line number.

## SSL and AutoSSL

| Function | Required | Notes |
|---|---|---|
| `installssl` | `domain`, `crt`, `key` | `cab` (auto-determined if omitted), `ip`. All PEM values must be URI-encoded |
| `fetchsslinfo` | none | `domain`, `crtdata`. Returns certificates you *could* install, not installed ones |
| `listcrts`, `fetchcrtinfo`, `fetch_ssl_vhosts` | | Use these for what is actually installed |
| `start_autossl_check_for_one_user` | `username` | Runs in the background; returns `data.pid` |
| `start_autossl_check_for_all_users` | none | |

Other AutoSSL functions: `get_autossl_providers`,
`set_autossl_provider`, `reset_autossl_provider`,
`disable_autossl`, `get_autossl_check_schedule`,
`get_autossl_log`, `get_autossl_logs_catalog`,
`get_autossl_metadata`, `set_autossl_metadata`,
`set_autossl_metadata_key`, `get_autossl_problems_for_domain`,
`get_autossl_problems_for_user`,
`get_autossl_user_excluded_domains`,
`set_autossl_user_excluded_domains`,
`add_autossl_user_excluded_domains`,
`remove_autossl_user_excluded_domains`.

## PHP (EasyApache 4 only)

| Function | Required | Notes |
|---|---|---|
| `php_get_installed_versions` | none | `data.versions` |
| `php_get_vhost_versions` | none | Per-vhost `account`, `documentroot`, `main_domain`, `php_fpm`, `phpversion_source`, `version`, `vhost` |
| `php_set_vhost_versions` | `version`, `vhost` | `php_fpm` (default 0), `php_fpm_pool_parms`. Multiple vhosts by incrementing: `vhost-1`, `vhost-2` |
| `php_get_system_default_version` | none | |
| `php_set_system_default_version` | `version` | e.g. `ea-php81`, `inherit`, or a custom package name |

The `version` enum in the specification stops at `ea-php72` and
is stale; the description confirms any custom PHP package name is
accepted. All five calls are disabled when the Web Server role is
off. The wider set also includes `php_get_handlers`,
`php_get_impacted_domains`, `php_get_vhosts_by_version`,
`php_ini_get_content`, `php_ini_get_directives`,
`php_ini_set_content` (POST), `php_ini_set_directives`,
`php_set_handler` and `php_set_session_save_path`.

## Tweak Settings

| Function | Required | Notes |
|---|---|---|
| `get_tweaksetting` | `key` | `module` (`Apache`, `Basic`, `Mail`, `Main`; default `Main`). Reads `/var/cpanel/cpanel.config` and the Exim configuration |
| `set_tweaksetting` | `key` | `module`, `value`. Pass `value` with nothing after it to set an empty value. Writes only `cpanel.config` |

## Traps

- The specification's `required` arrays are looser than the
  prose. `accountsummary` marks nothing required but needs
  `user` or `domain`; `dumpzone` marks only `domain` but needs
  `domain` or `zone`. Do not validate purely from the spec.
- Parameter casing is inconsistent between sibling functions
  (`createacct` versus `modifyacct`, `addpkg` versus `editpkg`).
- Repeated values use an increment convention rather than
  arrays: `acl-1`, `whitelist_ip-1`, `vhost-1`, and all the
  `api.filter.a`/`api.sort.a`/`api.columns.a` control variables.
- `removeacct`'s `user` parameter is flagged deprecated in the
  spec; pass `username`.

## Unverified

- `addzonerecord`'s shared base declares `line` as required but
  defines no such property. `line` is meaningful for edit and
  remove, not for add, so this reads as a specification bug.
  Confirm against a live server before relying on it.
- WHM API 1 transfer and restore functions: the guide describes
  the six-step session workflow (plan, create, check, queue,
  start, monitor) but its introduction page names no functions.
  Read
  <https://api.docs.cpanel.net/guides/guide-to-transfer-and-restore-api-functions>
  and its subpages before scripting a transfer.
