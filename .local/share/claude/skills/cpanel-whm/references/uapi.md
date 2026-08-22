# UAPI and cPanel API 2

Verified against `api.docs.cpanel.net/cpanel/introduction`,
`api.docs.cpanel.net/cpanel-api-2` and the per-operation pages
under `api.docs.cpanel.net/specifications/cpanel.openapi/`. The
UAPI pages carry version `11.137.9999.106`.

## Calling

```bash
uapi --user=<user> --output=json <Module> <function> param=value
cpapi2 --user=<user> --output=json <Module> <function> param=value
```

Both binaries live in `/usr/local/cpanel/bin/`; call them by full
path on CloudLinux. `--output` accepts `json`, `jsonpretty` or
`yaml` (the default). Values are space-separated and must be
URI-encoded; quote anything containing shell metacharacters.

Over HTTPS, UAPI is `GET https://host:2083/execute/Module/func`
with `Authorization: cpanel <user>:<token>`. cPanel API 2 cannot
be called on cPanel's own ports: it is reachable only through the
WHM API wrapper on 2086/2087, as `/json-api/cpanel` with
`cpanel_jsonapi_user`, `cpanel_jsonapi_apiversion=2`,
`cpanel_jsonapi_module` and `cpanel_jsonapi_func`.

Pagination is available on UAPI through `api.paginate`,
`api.paginate_start`, `api.paginate_size` and
`api.paginate_page`.

## Doc URL patterns

- Canonical UAPI reference:
  `/specifications/cpanel.openapi/<tag>/<module-lowercased>-<function>`
- A legacy stub that redirects to it:
  `/openapi/cpanel/operation/<function>/` (function name only,
  no module prefix).
- API 2: `/cpanel-api-2/cpanel-api-2-modules-<module>/` then
  `cpanel-api-2-functions-<module>-<function>`
- <https://api.docs.cpanel.net/sitemap.xml> enumerates every page
  (2136 at the time of writing, 784 of them UAPI operations), and
  appending `.md` to any page URL returns the raw markdown,
  including the full parameter table.

## UAPI functions

### E-mail

| Function | Required | Useful optional |
|---|---|---|
| `Email::add_pop` | `email`, `password` | `domain`, `password_hash`, `quota`, `send_welcome_email`, `skip_update_db` |
| `Email::delete_pop` | `email` | `domain`, `flags` (`passwd` preserves the maildir), `skip_quota` |
| `Email::list_pops` | none | `no_validate`, `regex`, `skip_main` |
| `Email::passwd_pop` | `email`, `password` | `domain` |
| `Email::edit_pop_quota` | `domain`, `email` (username only) | `quota` |
| `Email::add_forwarder` | `domain`, `email`, `fwdopt` | `fwdemail`, `failmsgs`, `fwdsystem`, `pipefwd` |
| `Email::list_forwarders` | `domain` | `regex` |
| `Email::get_disk_usage` | `domain`, `user` | none |

Quotas are in megabytes, with `0` meaning unlimited. Related
usage functions in the same tag: `Email::get_pop_quota`,
`Email::list_pops_with_disk`, `Email::get_max_email_quota`,
`Email::get_default_email_quota`,
`Email::get_main_account_disk_usage`.

`Email::add_pop`'s own page recommends
`UserManager::create_user` instead, because `add_pop` is
incompatible with the Reset Password feature.

### Domains

| Function | Required | Useful optional |
|---|---|---|
| `DomainInfo::list_domains` | none | `hide_temporary_domains` |
| `DomainInfo::domains_data` | none | `format` (`hash`/`list`), `hide_temporary_domains`, `return_https_redirects_status` |
| `SubDomain::addsubdomain` | `domain` (the label), `rootdomain` | `canoff`, `dir`, `disallowdot` |
| `AddonDomain::addaddondomain` | `newdomain`, `subdomain` | `dir`, `disallowdot`, `force` |
| `Park::park` | `domain` | `topdomain`, `disallowdot`, `force` |

`Park::park` without `topdomain` parks on the primary domain;
with `topdomain` it parks on a subdomain of the primary, which is
how an addon domain is represented internally.
`AddonDomain::addaddondomain` does both steps in one call, and
removes the subdomain again if the park step fails.
`DomainInfo::single_domain_data`, `DomainInfo::primary_domain`,
`Park::listparkeddomains` and `AddonDomain::listaddondomains` are
also available.

### FTP and databases

| Function | Required | Useful optional |
|---|---|---|
| `Ftp::add_ftp` | `user` | `pass`, `pass_hash`, `domain`, `homedir`, `quota`, `disallowdot` |
| `Ftp::list_ftp` | none | `include_acct_types`, `skip_acct_types` (pipe-separated `anonymous`/`logaccess`/`main`/`sub`) |
| `Mysql::create_database` | `name` | `prefix-size` (8 or 16) |
| `Mysql::create_user` | `name`, `password` | `prefix-size` |
| `Mysql::set_privileges_on_database` | `database`, `user` | `privileges` |
| `Mysql::list_databases` | none | none |

`pass` is not marked required on `Ftp::add_ftp`: supply `pass` or
`pass_hash`, not both. `Mysql` names must carry the account
prefix (`cpuser_dbname`), and `privileges` replaces the existing
grant list rather than adding to it.
`Mysql::setup_db_and_user` does create-database, create-user and
grant in one call.

### DNS

| Function | Required | Useful optional |
|---|---|---|
| `DNS::parse_zone` | `zone` | none |
| `DNS::mass_edit_zone` | `serial`, `zone` | `add`, `edit`, `remove` |

`add` and `edit` take arrays of serialised JSON objects with keys
`dname`, `ttl`, `record_type`, `data`, plus `line_index` for
`edit`; `remove` takes line indexes. `serial` must match the
zone's current SOA serial or the call fails, which is what stops
two editors clobbering each other. Zone output is base64 and may
contain non-ASCII bytes. Other functions: `DNS::lookup`,
`DNS::has_local_authority`, `DNS::is_alias_available`,
`DNS::swap_ip_in_zones`,
`DNS::ensure_domains_reside_only_locally`,
`DNS::fetch_cpanel_generated_domains`.

### SSL, quotas, backups, PHP, tokens

| Function | Required | Useful optional |
|---|---|---|
| `SSL::install_ssl` | `cert`, `domain` | `key`, `cabundle`, `domain_dcv_method`, `vhost_names`, `order_item_id`, `originating_certificate_id`, `parent_cert_expiry` |
| `SSL::installed_hosts` | none | none |
| `Quota::get_quota_info` | none | none |
| `Backup::fullbackup_to_homedir` | none | `email`, `homedir` (`include`/`skip`) |
| `LangPHP::php_get_vhost_versions` | none | `vhost` |
| `LangPHP::php_set_vhost_versions` | `version`, `vhost` | none |
| `Tokens::create_full_access` | `name` | `expires_at` (Unix timestamp), `readonly` |

Certificate, key and CA bundle values must be URI-encoded. For a
dedicated IP use `SSL::installed_host` (singular).
`Quota::get_quota_info` returns `inode_limit`, `inodes_remain`,
`inodes_used`, `megabyte_limit`, `megabytes_remain`,
`megabytes_used`, `under_inode_limit`, `under_megabyte_limit`
and `under_quota_overall`. `Backup::fullbackup_to_homedir`
writes `backup-MM.DD.YYYY_HH-mm-ss_username.tar.gz`. To set PHP
on several vhosts at once, increment the parameter name:
`vhost-1`, `vhost-2` and so on; `LangPHP` is EasyApache 4 only.
Token names accept only alphanumerics, `-` and `_`.

For account-wide usage figures beyond quota, use
`ResourceUsage::get_usages` or `StatsBar::get_stats`. There is no
`Stats::get_disk_usage`: the `Stats` module contains only
`get_bandwidth`, `get_site_errors`, `get_stats_daily`,
`list_sites` and `list_stats_by_domain`.

## What still needs cPanel API 2

Cron is the clearest case: the UAPI specification has no cron tag
at all.

| API 2 function | Required parameters |
|---|---|
| `Cron::add_line` | `weekday`, `minute`, `hour`, `day`, `month`, `command` |
| `Cron::listcron` | none |
| `Cron::fetchcron` | see the docs |
| `Cron::edit_line` | see the docs |
| `Cron::remove_line` | see the docs |
| `Cron::get_email`, `Cron::set_email` | see the docs |

Note the asymmetric naming: the listing function is
`Cron::listcron`, not `list_lines`. It returns `weekday`,
`minute`, `hour`, `day`, `month`, `count`, `command`,
`command_htmlsafe` and `linekey`.

Legacy e-mail functions with no UAPI counterpart:
`Email::get_archiving_configuration`,
`Email::get_archiving_default_configuration`,
`Email::get_archiving_types`,
`Email::set_archiving_configuration`,
`Email::set_archiving_default_configuration`,
`Email::get_email_signing`, `Email::set_email_signing`,
`Email::getmxcheck`, `Email::setmxcheck`,
`Email::getalwaysaccept`, `Email::checkmaindiscard`,
`Email::clearpopcache`, `Email::getabsbrowsedir`,
`Email::listpopswithimage`, `Email::filteractions`,
`Email::filterlist`, `Email::filtername`, `Email::filterrules`.

The `ZoneEdit` API 2 functions (`add_zone_record`,
`edit_zone_record`, `get_zone_record`, `remove_zone_record`,
`fetchzone`, `fetchzone_records`, `fetchzones`) have no
same-named UAPI counterpart; the replacement is
`DNS::parse_zone` plus `DNS::mass_edit_zone`.

### Stale "no equivalent" claims

Several API 2 pages still say "no equivalent UAPI function
exists" when the current UAPI specification documents one. Do not
take those pages at face value; prefer UAPI for all of these.

| API 2 page's claim | Reality in cpanel.openapi |
|---|---|
| `Park::park`, `Park::unpark` | Both exist as UAPI |
| `AddonDomain::addaddondomain`, `AddonDomain::deladdondomain` | Both exist as UAPI |
| `SubDomain::delsubdomain`, `getreservedsubdomains`, `validregex` | All three exist as UAPI |
| `ZoneEdit::resetzone` | Exists as UAPI |

API 2 parameters for the domain functions, should you still need
them: `Park::park` requires `domain` (optional `topdomain`,
`disallowdot`); `SubDomain::addsubdomain` requires `domain` and
`rootdomain`; `AddonDomain::addaddondomain` requires `newdomain`
and `subdomain` (or `create_temporary_domain` in their absence),
optional `dir`, `ftp_is_optional`; `Email::addpop` requires
`domain`, `email` and `password`, with `quota` defaulting to
`250`.

## Response envelopes

UAPI, per the published OpenAPI response schema:

```json
{
  "apiversion": 3,
  "func": "add_pop",
  "module": "Email",
  "result": {
    "status": 1,
    "errors": null,
    "messages": null,
    "warnings": null,
    "data": null,
    "metadata": {}
  }
}
```

`status` is `1` on success and `0` on failure, in which case
`errors` holds the reason. `warnings` carries non-critical
problems. `metadata` may hold `transformed` (post-processing
altered the data) and, when pagination was requested, a
`paginate` hash of `total_pages`, `total_results`,
`current_page`, `results_per_page` and `start_result`.

The introduction warns that CLI `uapi` calls do not return the
metadata other transports return when an error prevents the run
from completing.

cPanel API 2, verbatim from the `Cron::add_line` page:

```json
{
  "cpanelresult": {
    "apiversion": 2,
    "func": "add_line",
    "data": [
      { "linekey": "1727752715",
        "statusmsg": "crontab installed",
        "status": 1 }
    ],
    "event": { "result": 1 },
    "module": "Cron"
  }
}
```

`data` is always an array of row objects even for a single
result. `event.result` is the outer dispatch success flag, `1` or
`0`, and is distinct from the per-row status. Rows commonly carry
`result` and `reason` (documented as failure-only, though some
modules populate it on success too) or `status` and `statusmsg`.
Errors surface inside the rows, not in a top-level errors array.

## Unverified

- Whether a direct `/execute/Module/function` call returns the
  bare `{status, errors, ...}` object or the full
  `{apiversion, func, module, result}` wrapper. Only the wrapped
  schema is published; no raw response body is shown.
- The narrative description of the UAPI envelope: the
  introduction links to a "UAPI Return Data" page that does not
  exist in the sitemap. The field list above comes from the
  per-operation response schemas, which are verified.
- Whether UAPI or API 2 actually serves `Park` and `AddonDomain`
  on a given server version, given the contradiction above.
- The API 2 `SubDomain::addsubdomain` page links its UAPI
  replacement to a WHM API path
  (`/openapi/whm/operation/create_subdomain/`) rather than to the
  cPanel UAPI function its link text names. Treat that
  cross-reference as unreliable.
- `StatsBar::get_stats` parameters were not read.
- A top-level error key on the API 2 envelope: none is shown on
  any fetched page.
