# Scripts, paths and logs

Verified against `docs.cpanel.net/whm/scripts/`, the per-script
pages under `docs.cpanel.net/whm/scripts/the-<name>-script/`, and
the knowledge-base pages named below.

## Where the scripts live

cPanel installs its scripts into `/usr/local/cpanel/scripts` and
`/usr/local/cpanel/bin`; the installer also creates a `/scripts`
symlink, which is what most of cPanel's own examples use. Always
call a script by its full path, even from inside the directory.

The scripts index carries a warning worth respecting: do not run
scripts in those directories that the documentation does not
list, because you may damage the server.

## Account lifecycle

| Script | Path | Purpose |
|---|---|---|
| `wwwacct` | `/usr/local/cpanel/scripts/` | Create an account. Positional arguments only, in a fixed order; prefer `whmapi1 createacct` |
| `suspendacct` | `/usr/local/cpanel/scripts/` | Suspend one account |
| `unsuspendacct` | `/usr/local/cpanel/scripts/` | Unsuspend an account |
| `removeacct` | `/usr/local/cpanel/scripts/` | Terminate an account |
| `pkgacct` | `/usr/local/cpanel/scripts/` | Package an account into a cpmove archive |
| `restorepkg` | `/usr/local/cpanel/scripts/` | Restore an account from an archive |
| `transfer_accounts_as_root` | `/usr/local/cpanel/scripts/` | Pull accounts from a remote server |
| `addpop`, `delpop` | `/usr/local/cpanel/scripts/` | Create and remove an e-mail account |
| `updateuserdomains` | `/usr/local/cpanel/scripts/` | Rebuild `/etc/userdomains` from `/var/cpanel/users` |
| `updateuserdatacache` | `/usr/local/cpanel/scripts/` | Refresh the userdata cache |

### suspendacct

```
/usr/local/cpanel/scripts/suspendacct [account] [options]
```

| Option | Effect |
|---|---|
| `account` | Required. One account only; extra names are ignored. Reserved usernames such as `root` and `nobody` cannot be suspended |
| `reason` | The reason, quoted. Written to `/var/cpanel/suspended/<username>` |
| `disallow` | Only root may unsuspend. Requires `reason` |
| `--force` | Suspend even if already suspended |
| `--leave-ftp-accts-enabled` | Skip suspending FTP accounts. The docs warn this may cause security issues |
| `--child-ok` | Suspend a distributed account via a child node. Emergencies only |

```bash
/usr/local/cpanel/scripts/suspendacct exampleuser \
  "Failure to pay monthly fee."
```

Suspension sets `SUSPENDED=1` and `SUSPENDTIME=<epoch>` in the
account's `cpuser` file, stops the user's processes and cron
jobs, locks mailing lists, Web Disk and mail passwords, redirects
websites through an Apache `account_suspensions.conf` include,
runs `passwd -l`, sets `public_ftp` to `0000` and changes every
MySQL user password.

### unsuspendacct

`account` is required. `--retain-service-proxies` keeps the
account's service proxy settings, which are otherwise disabled.
`--child-ok` and `--help` as above.

### removeacct

```
/usr/local/cpanel/scripts/removeacct [account] [options]
```

| Option | Effect |
|---|---|
| `account` | Required |
| `--force` | Skip the confirmation prompt |
| `--keepdns` | Keep the account's DNS zone files |
| `--keep-remote-databases` | Keep remote databases and users |
| `--child-ok` | Terminate via a child node. Emergencies only |

This removes everything. The account cannot be recreated
immediately afterwards, because removing its MySQL users takes a
moment.

### pkgacct

```
/usr/local/cpanel/scripts/pkgacct [options] USERNAME DIRECTORY
```

Root only. `USERNAME` comes after the options and before
`DIRECTORY`; `DIRECTORY` defaults to whichever user home
directory has the most free space. The script uses strict option
matching, so an abbreviated flag prints help rather than being
expanded. Source and destination each need free space greater
than twice the largest account, plus 1 GB.

| Option | Effect |
|---|---|
| `--allow-override` | Use `/var/cpanel/lib/Whostmgr/Pkgacct/pkgacct` if present. Must come before any other option |
| `--dbbackup=all\|schema\|name` | How much of the databases to include; `all` is the default |
| `--dbbackup_mysql=TYPE` | Overrides `--dbbackup` for MySQL only |
| `--use_backups` | Use the last successful backup as a template, which is faster |
| `--incremental` | Update the destination with what changed, removing what no longer exists. Implies `--nocompress` |
| `--split` | Write `cpmove-USERNAME.tar.gz.partNNNNN` parts |
| `--nocompress` | Do not compress |
| `--userbackup` | Produce a user-facing `backup-MM.DD.YYYY_HH-MM-SS_USERNAME` file in `/home`. Also drops two ASCII files in the user's home that you must delete afterwards |
| `--backup` | Produce `username.tar.gz` at the given path |
| `--mysql=VERSION`, `--roundcube=VERSION` | Minimum versions the archive requires |
| `--serialized_output` | JSON-per-line output for streaming |
| `--get_version`, `--help`, `--man` | Version, brief help, full documentation |

Exclusions, all of the form `--skip<thing>`: `acctdb`,
`apitokens`, `authnlinks`, `bwdata`, `cron`, `customdmarc`,
`dnszones`, `domains`, `domainkeys`, `ftpusers`, `homedir`,
`integrationlinks`, `linkednodes`, `locale`, `logs`, `mail`,
`mailconfig`, `mailman`, `mysql`, `passwd`, `pgsql`,
`publichtml`, `quota`, `resellerconfig`, `shell`, `ssl`,
`userdata`.

Two limits worth knowing: `pkgacct` ignores
`/etc/cpbackup-exclude.conf`, and it cannot back up root or a
reseller account that has no associated domain.

### restorepkg

```
/usr/local/cpanel/scripts/restorepkg [arguments] [file|username]
```

Pass either the full path to an archive or an account username.
Given a username it searches `/home`, `/home2`, `/home3`,
`/root`, `/usr`, `/usr/home` and `/web`. Accepted filename
forms: `cpmove-{USER}`, `cpmove-{USER}.tar`,
`cpmove-{USER}.tar.gz`, `{USER}.tar`, `{USER}.tar.gz`,
`backup-{MM.DD.YYYY}{HH-MM-SS}{USER}.tar` and its `.tar.gz`
variant.

| Option | Effect |
|---|---|
| `--force` | Restore despite errors or warnings; existing data stays intact |
| `--ip=y\|n\|<address>` | `y` takes the next free pool address, `n` uses the shared IP, or name an address |
| `--newuser=<name>` | Rename the account on restore. Must not already exist; 16 characters or fewer, first eight unique |
| `--skipaccount` | Restore a package onto an existing account of the same name |
| `--allow_reseller` | Restore reseller privileges |
| `--restricted` | Restricted Restore: extra security checks on an untrusted archive |
| `--unrestricted` | The default. `--restricted` overrides it |
| `--shared_mysql_server` | Skip grants and databases that already exist |
| `--disable=<Mod,Mod>` | Disable restore modules by name, case-sensitive; `--help` lists them |
| `--mail_location=.local\|.existing\|ALIAS` | Where mail lives afterwards; `.existing` is the default |
| `--keep_local_cpuser_values=<KEY,KEY>` | Keep these keys from the local `cpuser` file. Only with `--newuser` or `--skipaccount` |
| `--update_dns_zone=1\|0` | Whether to restore zonefile data. Useful during a live transfer |

Restricted Restore is documented as experimental and explicitly
not an effective security control. It will not restore parked or
addon domains, forces `noshell` or `jailshell`, and can leave an
account in a broken state that must be removed and restored
again unrestricted.

Do not set `skip-name-resolve` in the server's MySQL
configuration: the docs warn it breaks restores and phpMyAdmin.

## Services

```
/usr/local/cpanel/scripts/restartsrv_<service> [options]
```

| Option | Effect |
|---|---|
| `--check` | Is the service running? |
| `--start`, `--stop`, `--restart` | Start, stop, soft restart |
| `--graceful` | Graceful restart |
| `--hard` | Hard stop and restart |
| `--reload` | Reload |
| `--notconfigured-ok` | An unconfigured service exits with a non-fatal error |
| `--help` | Help |

Not every option exists for every service.

```bash
/usr/local/cpanel/scripts/restartsrv_named --restart --hard
```

Service names: `apache` or `httpd`, `apache_php_fpm`, `bind`,
`chkservd` or `tailwatch`, `clamd`, `cpanalysticsd`,
`cpanellogd`, `cpanel_ccs`, `cpanel_dovecot_solr`,
`cpanel_php_fpm`, `cpdavd`, `cpgreylistd`, `cphulkd`, `cpipv6`,
`cpsrvd` or `cpanel`, `crond`, `dnsadmin`, `dovecot`, `exim`,
`ftpd`/`ftpmagic`/`ftpserver`, `imap`/`pop`/`pop3`, `ipaliases`,
`lmtp`, `mailman`, `mysql` or `mysqld`, `named`, `nscd`, `p0f`,
`pdns` or `powerdns`, `postgres` or `postgresql`, `proftpd`,
`pureftpd`, `queueprocd`, `rsyslog` or `rsyslogd`, `spamd`,
`sshd` or `openssh`, `tailwatchd`.

## Apache configuration

```bash
/usr/local/cpanel/scripts/rebuildhttpdconf
/usr/local/cpanel/scripts/restartsrv_httpd
```

`rebuildhttpdconf` takes `--preview` (writes
`httpd-preview.conf` so you can inspect it first) and `--nolock`
(skips the configuration lock). It does not restart Apache. A
successful run prints `Built /etc/apache2/conf/httpd.conf OK`.

## SSL

| Script | Path | Notes |
|---|---|---|
| `autossl_check` | `/usr/local/cpanel/bin/autossl_check` | `--user=<username>`, `--all`, `--help`. Runs daily from `/etc/cron.d` |
| `checkallsslcerts` | `/usr/local/cpanel/bin/checkallsslcerts` | Service and hostname certificates. `--allow-retry`, `--verbose`. Run it manually only if cPanel support asks |

`touch /var/cpanel/ssl/disable_auto_hostname_certificate`
disables automatic hostname certificate installation.

## Updates

```
/usr/local/cpanel/scripts/upcp [options]
```

| Option | Effect |
|---|---|
| `--bg` | Run in the background; output goes to `/var/cpanel/updatelogs/update.DATE` |
| `--cron` | Use the settings in `/etc/cpupdate.conf` |
| `--force` | Reinstall everything, overriding your update preferences. Cannot be combined with `--sync` |
| `--sync` | Repair the installed version without downloading a newer one |
| `--security` | Apply critical security updates; this is what the hourly cron job runs |
| `--log=<path>` | Override the log file |
| `--help` | Help |

`/etc/cpupdate.conf` drives all of it, as `KEY=value` lines with
no spaces:

| Key | Values | Default |
|---|---|---|
| `CPANEL` | `edge`, `current`, `release`, `stable`, `lts`, or an exact version such as `118.123.45` | `release` |
| `UPDATES` | `daily`, `manual`, `never` | `daily` |
| `SECURITY_UPDATES` | `hourly`, `never` | `hourly` |
| `RPMUP` | `daily`, `manual`, `never` | `daily` |
| `SARULESUP` | `daily`, `manual`, `never` | `daily` |
| `STAGING_DIR` | any valid path | `/usr/local/cpanel` |

An invalid or blank value is silently rewritten to its default.

### Release tiers

| Tier | Character |
|---|---|
| `LTS` | One version per year, supported for that year; security and critical updates only |
| `STABLE` | Publicly exposed, tested and verified; published less often than RELEASE |
| `RELEASE` | Feature-complete and thoroughly tested. New installations default here |
| `CURRENT` | Verified and tested, some features still in development. The release-candidate tier |
| `EDGE` | Rudimentary testing, published up to several times a week. Not for production |

An LTS release generally ends six months after the next LTS
reaches RELEASE. You cannot downgrade between major versions or
between tiers. Check the running version with
`/usr/local/cpanel/cpanel -V`, and distinguish cPanel & WHM from
WP Squared with `readlink /usr/local/cpanel/server.type`
(`cpanel` or `wp2`).

## Logs

| Path | Contents |
|---|---|
| `/usr/local/cpanel/logs/error_log` | General cPanel & WHM errors, and where standardised hooks log |
| `/usr/local/cpanel/logs/access_log` | cPanel & WHM account access, in Common Log Format |
| `/usr/local/cpanel/logs/login_log` | Login attempts against `cpsrvd`, including failures |
| `/usr/local/cpanel/logs/session_log` | Activity during a logged-in cPanel session |
| `/usr/local/cpanel/logs/panic_log` | Severe errors. This file should be empty; entries warrant investigation |
| `/usr/local/cpanel/logs/api_log` | Human-readable cPanel API 1, successful API 2 and successful UAPI calls for a user. Must be enabled in Tweak Settings |
| `/usr/local/cpanel/logs/api_tokens_log` | WHM API token use: status, user, token name, request |
| `/usr/local/cpanel/logs/cpwrapd_log` | `cpsrvd` service manager activity |
| `/usr/local/cpanel/logs/stats_log` | Bandwidth processing for all accounts |
| `/usr/local/cpanel/logs/cphulkd.log`, `cphulkd_errors.log` | cPHulk brute-force protection |
| `/usr/local/cpanel/logs/queueprocd.log` | TaskQueue processing daemon |
| `/usr/local/cpanel/logs/dnsadmin_log` | dnsadmin requests |
| `/usr/local/cpanel/logs/tailwatchd_log` | TailWatch drivers |
| `/usr/local/cpanel/logs/safeapacherestart_log` | Every Apache restart |
| `/usr/local/cpanel/logs/license_log` | Licence updates and errors |
| `/usr/local/cpanel/logs/cpbackup/` | Backup run logs, one per timestamp |
| `/usr/local/cpanel/logs/cpbackup_transporter/` | Backup transporter logs |
| `/usr/local/cpanel/logs/cpdavd_error_log`, `cpdavd_session_log` | WebDAV daemon |
| `/usr/local/cpanel/logs/php-fpm/error.log` | System PHP-FPM errors |
| `/var/cpanel/updatelogs/` | `update.<epoch>.log` for each cPanel & WHM update |
| `/var/cpanel/accounting.log` | Account actions: creation, deletion, reseller changes |
| `/var/cpanel/php-fpm/<user>/logs/error.log`, `slow.log` | Per-user PHP-FPM |
| `/var/log/chkservd.log` | Service status checks |
| `/var/log/exim_mainlog`, `exim_paniclog`, `exim_rejectlog` | Exim receipt, delivery, panics, rejections |
| `/var/log/maillog`, `/var/log/mail.log` | Dovecot and system mail |
| `/var/log/apache2/error_log` | Apache and CGI errors |
| `/var/log/apache2/suexec_log`, `suphp_log`, `modsec_audit.log` | suEXEC, suPHP, ModSecurity |
| `/etc/apache2/logs/domlogs/<user>/<domain>` | Per-domain access logs; `<domain>-ssl_log` for TLS |
| `/etc/apache2/logs/domlogs/ftpxferlog` | FTP transfers under EA4 |
| `/var/log/messages`, `/var/log/syslog`, `/var/log/secure` | System logs |
| `/var/log/mysqld.log`, `/var/lib/mysql/<hostname>.err` | MySQL |
| `/home/<user>/logs/`, `/home/<user>/access_logs` | The user's own copies |

## /var/cpanel and friends

| Path | Contents |
|---|---|
| `/var/cpanel/users/<user>` | The account's `cpuser` file. Suspension sets `SUSPENDED=1` and `SUSPENDTIME=<epoch>` here |
| `/var/cpanel/suspended/<user>` | The suspension reason, or the previous shell. `<user>.lock` marks root-only unsuspension |
| `/var/cpanel/bwlimited/` | `user` and `domain` files marking bandwidth-limited accounts. Separate from suspension |
| `/var/cpanel/userdata/<user>/<domain>` | Per-domain vhost data, including `phpversion:` |
| `/var/cpanel/userdata/<user>/<domain>.php-fpm.yaml` | Per-domain PHP-FPM pool |
| `/var/cpanel/cpanel.config` | Tweak Settings and other feature configuration |
| `/var/cpanel/hooks/data/<Category>/<event>.yaml` | Standardised hook registrations |
| `/var/cpanel/packages/extensions/` | Package extension definitions |
| `/var/cpanel/databases/` | YAML and JSON database grant maps |
| `/var/cpanel/resellers` | Reseller usernames and ACL privileges |
| `/var/cpanel/on_boot/` | Scripts run at boot by `cpanel-onboot` |
| `/etc/wwwacct.conf` | Basic WebHost Manager Setup: `ADDR`, `HOST`, `NS`, `NS2`, `CONTACTEMAIL`, `HOMEMATCH`, `TTL`, `NSTTL`, `SCRIPTALIAS`, `LOGSTYLE`, `ETHDEV` |
| `/etc/cpupdate.conf` | Update tier and update behaviour |
| `/etc/userdomains` | domain to user map, rebuilt by `updateuserdomains` |
| `/etc/trueuserdomains` | Primary domain to user map |

The published `cpuser` key list, taken from the
`massmodifyacct` example in the WHM OpenAPI bundle: `BACKUP`,
`BWLIMIT`, `CONTACTEMAIL`, `CONTACTEMAIL2`, `DBOWNER`,
`DEADDOMAINS`, `DEMO`, `DISK_BLOCK_LIMIT`, `DOMAIN`, `DOMAINS`,
`FEATURELIST`, `HASCGI`, `HASDKIM`, `HASDMARC`, `HASSPF`,
`HOMEDIRLINKS`, `IP`, `LANG`, `LEGACY_BACKUP`, `LOCALE`,
`MAILBOX_FORMAT`, `MAXADDON`, `MAXFTP`, `MAXLST`, `MAXPARK`,
`MAXPOP`, `MAXSQL`, `MAXSUB`, `MAX_DEFER_FAIL_PERCENTAGE`,
`MAX_EMAILACCT_QUOTA`, `MAX_EMAIL_PER_HOUR`, `MTIME`,
`MXCHECK-<domain>`, `OWNER`, `PLAN`, `RS`, `STARTDATE`, `USER`,
`UTF8MAILBOX`, `WORKER_NODE-Mail`, `_PACKAGE_EXTENSIONS`,
`__CACHE_DATA_VERSION`. Per-domain mail limits are set as
`MAX_EMAIL_PER_HOUR-example.com=500`, followed by
`/usr/local/cpanel/scripts/updateuserdomains`.

## Tweak Settings

Tweak Settings (WHM >> Home >> Server Configuration >> Tweak
Settings) is stored in `/var/cpanel/cpanel.config` as `key=value`
lines. Before installation the same keys can be seeded in
`/root/cpanel_profile/cpanel.config`, which the installer reads
and uses to populate `/var/cpanel/cpanel.config`.

Change settings through the API rather than the file:

```bash
whmapi1 --output=json get_tweaksetting key=allowremotedomains
whmapi1 set_tweaksetting key=allowremotedomains value=0
```

`module` defaults to `Main` and also accepts `Apache`, `Basic`
and `Mail`. `get_tweaksetting` reads both `cpanel.config` and the
Exim configuration; `set_tweaksetting` writes only
`cpanel.config`. Note that `/etc/wwwacct.conf` is a different
file holding Basic WebHost Manager Setup, not Tweak Settings.

## Unverified

- `whm.conf`: the string does not appear anywhere in the
  `docs.cpanel.net` full-text index. Tweak Settings live in
  `/var/cpanel/cpanel.config`, and the basic server setup lives
  in `/etc/wwwacct.conf`. Treat any reference to a
  `/var/cpanel/whm.conf` as unconfirmed.
- `killacct`, `fixquotas`, `mailperm`, `whoowns` and `cpuser`:
  none appear in the WHM scripts index. Account termination is
  `removeacct`. Given the index's warning about unlisted
  scripts, confirm on the box before running any of these.
- `/var/cpanel/packages/` as the package store, and
  `/var/cpanel/version/` as a version store: neither is
  documented. Only `/var/cpanel/packages/extensions/` is. Read
  packages via `whmapi1 listpkgs` or `getpkginfo`, and the
  version via `/usr/local/cpanel/cpanel -V`.
- The `/var/cpanel/userdata/<user>/main` and `main.cache` layout.
- The `/scripts` symlink is confirmed only indirectly, through
  an installer changelog entry describing it being made
  relative. The scripts index itself always uses
  `/usr/local/cpanel/scripts`.
- No cPanel utility documents a `--dry-run` flag. The closest
  equivalents are `rebuildhttpdconf --preview`,
  `ea_install_profile` without `--install`, and
  `rebuild_phpconf --dryrun`.
