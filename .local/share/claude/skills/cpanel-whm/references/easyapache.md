# EasyApache 4

Verified against `docs.cpanel.net/ea4/` and its subpages, the
`ea-cpanel-tools` scripts page, and the WHM API 1 PHP and
EasyApache Settings modules on `api.docs.cpanel.net`.

EA4 manages Apache, PHP and their extensions as ordinary
distribution packages, driven by a JSON profile. It replaced
EasyApache 3, which was deprecated in version 76 and removed in
version 78.

## Packages

cPanel-provided packages carry the `ea-` prefix. Each PHP version
is its own Software Collection with its own namespace, so an
extension must be installed for the version that needs it: the
SOAP extension for PHP 7.4 is `ea-php74-php-soap`, and a bare
`php-soap` will not do. The general convention is
`ea-php##-php-<module>`. Vendor-supplied PHP versions are
recognised too, provided they are SCL packages and do not use the
`ea-` prefix; extra prefixes are declared under
`/etc/cpanel/ea4/additional-pkg-prefixes/`.

As of the current documentation EA4 supports PHP 7.4 and 8.1
through 8.5, and the cPanel default profile ships 8.1 and 8.2.

| Path | Contents |
|---|---|
| `/opt/cpanel/ea-php##/root/etc/php.ini` | That version's `php.ini` |
| `/opt/cpanel/ea-php##/root/etc/php.d/` | Scanned for additional `.ini` files |
| `/opt/cpanel/ea-php##/root/etc/php-fpm.conf` | PHP-FPM master config |
| `/opt/cpanel/ea-php##/root/etc/php-fpm.d/<domain>.conf` | Per-domain FPM pool |
| `/opt/cpanel/ea-php##/root/usr/var/run/php-fpm/<sha1>.sock` | Per-domain FPM socket |
| `/opt/cpanel/ea-phpxx/root/usr/bin` | That version's binaries |
| `/usr/bin/php` | php-cgi of the configured version |
| `/usr/local/bin/php` | php-cli of the configured version |
| `/usr/bin/lsphp` | LSPHP of the configured version |
| `/usr/bin/ea-php##`, `/usr/local/bin/ea-php##` | php-cgi and php-cli for one specific version |
| `/usr/bin/ea-php##-pecl`, `/usr/bin/ea-php##-pear` | PECL and PEAR per version |

Repositories live in `/etc/yum.repos.d/` on CentOS, AlmaLinux and
Rocky, and in `/etc/apt/sources.list.d/` on Ubuntu.

| Task | CentOS | AlmaLinux / Rocky | Ubuntu |
|---|---|---|---|
| Install | `yum install ea-php82-php-gd` | `dnf install ea-php82-php-gd` | `apt install --purge ea-php82-php-gd` |
| Remove | `yum remove <pkg>` | `dnf remove <pkg>` | `apt purge <pkg>` |
| Refresh | `yum update` | `dnf upgrade` | `apt update` |

The docs advise against removing `ea-php` packages through the
package manager (use a profile), and against holding any EA4
package on Ubuntu.

## Profiles

A profile is a JSON template listing the packages the system
should have. Provisioning one installs its packages and
uninstalls everything else, and only one profile can be
provisioned at a time.

| Path | Contents |
|---|---|
| `/etc/cpanel/ea4/profiles/custom/` | Your profiles. Only files here appear in the WHM interface |
| `/etc/cpanel/ea4/profiles/cpanel/` | cPanel-supplied profiles, including `default.json` |
| `/etc/cpanel_initial_install_ea4_profile.json` | Pre-install seed; copied into `profiles/custom/` after installation |

```json
{
   "version":"1.2",
   "name":"SuperHost Profile",
   "tags":["Apache 2.4","PHP 7.0"],
   "desc":"This profile allows very high density",
   "pkgs":["ea-mod_xyz","ea-php70","ea-php71"]
}
```

All five keys are required. Validate the file with
`json_pp -t null < myprofile.json`: silence means the syntax is
good. The interface strips the `ea-` prefix when it displays
package names.

## The ea-cpanel-tools scripts

### ea_install_profile

```
/usr/local/bin/ea_install_profile [--install] profile_file
```

Without `--install` it prints the changes it would make: that is
the dry run, and it is the only one EA4 offers. `--install`
performs the provisioning.

```bash
/usr/local/bin/ea_install_profile \
  /etc/cpanel/ea4/profiles/custom/myprofile.json
/usr/local/bin/ea_install_profile --install \
  /etc/cpanel/ea4/profiles/custom/myprofile.json
```

Restoring the stock profile, verbatim from the PHP-FPM layout
page:

```bash
ea_install_profile --install \
  /etc/cpanel/ea4/profiles/cpanel/default.json
/usr/local/cpanel/scripts/restartsrv apache_php_fpm
```

### ea_current_to_profile

```
/usr/local/bin/ea_current_to_profile [options]
```

| Option | Effect |
|---|---|
| `--output=<file>` | Write to this path. The `.json` extension is required, and only `/etc/cpanel/ea4/profiles/custom/` shows in the interface. Without a path it writes to the current directory |
| `--target-os=<os>` | Exclude packages incompatible with the target OS (CloudLinux and Ubuntu only). The docs mark this internal use only |
| `--help` | Help |

With no arguments it writes into
`/etc/cpanel/ea4/profiles/custom` under a generated name such as
`current_state_at_2015-08-28_10:10:04.json`. Take one of these
before applying a new profile: it is your rollback.

### ea_sync_user_phpini_settings

```bash
/usr/local/bin/ea_sync_user_phpini_settings \
  --user=user1 --user=user2
/usr/local/bin/ea_sync_user_phpini_settings --all-users
```

Reconciles a user's document-root `php.ini` with the `.user.ini`
and `.htaccess` beside it. Root only. `--user` may be repeated.

### rebuild_phpconf

```bash
/usr/local/cpanel/bin/rebuild_phpconf \
  --default=ea-php71 --ea-php71=cgi
```

| Option | Effect |
|---|---|
| `--default=<version>` | Set the default PHP version Apache uses |
| `--<version>=<handler>` | Set that version's handler, e.g. `--ea-php71=suphp` |
| `--current` | Show the current handler settings |
| `--available` | Show available handlers and versions |
| `--dryrun` | Show what the arguments would change |
| `--no-restart` | Do not restart Apache afterwards |
| `--no-users` | Do not update user settings when changing a handler |
| `--errors` | Print errors to stderr as well as the log |
| `--help` | Help |

It writes `/etc/cpanel/ea4/php.conf` and backs the previous
version up to `/etc/cpanel/ea4/php.conf.bak/TIME.PID`, keeping
the twenty most recent.

## PHP versions per domain

The per-domain version lives in the account's userdata file:

```bash
grep phpversion /var/cpanel/userdata/<user>/<domain>
# phpversion: ea-php81
```

PHP-FPM pool settings for a domain sit alongside it in
`/var/cpanel/userdata/<user>/<domain>.php-fpm.yaml`, with
system-wide defaults in `/var/cpanel/ApachePHPFPM/system.yaml`
and `/var/cpanel/ApachePHPFPM/system_pool_defaults.yaml`.

Inheritance: Apache uses the PHP version in the first `.htaccess`
it finds in the domain's file structure, and falls back to the
system default when there is none. Setting a domain's version
creates that `.htaccess`. A domain cannot use `Inherit` while
PHP-FPM is enabled, and PHP-FPM is enabled by default. With an
active LiteSpeed installation these settings are not editable and
the handler is forced to `lsphp`.

### WHM API 1 PHP functions

`php_get_handlers`, `php_get_impacted_domains`,
`php_get_installed_versions`, `php_get_system_default_version`,
`php_get_vhost_versions`, `php_get_vhosts_by_version`,
`php_ini_get_content`, `php_ini_get_directives`,
`php_ini_set_content` (POST), `php_ini_set_directives`,
`php_set_handler`, `php_set_session_save_path`,
`php_set_system_default_version`, `php_set_vhost_versions`.

```bash
whmapi1 --output=json php_get_installed_versions
whmapi1 --output=json php_get_vhost_versions
whmapi1 php_set_vhost_versions vhost=example.com version=ea-php82
whmapi1 php_set_system_default_version version=ea-php82
```

Set several vhosts in one call by incrementing the parameter
name: `vhost-1`, `vhost-2`, `vhost-3`. `php_set_vhost_versions`
also accepts `php_fpm` (`1`/`0`) and `php_fpm_pool_parms`, a
JSON object such as `{"pm_max_children":5,
"pm_max_requests":20,"pm_process_idle_timeout":10}`.
`php_set_handler` takes `handler` (`cgi`, `suphp`, `dso`, `none`)
and `version`. The published `version` enum stops at `ea-php72`
and is stale; the prose confirms any custom package name works.

The cPanel-user equivalents are in the UAPI `LangPHP` module:
`php_get_domain_handler`, `php_get_impacted_domains`,
`php_get_installed_versions`, `php_get_system_default_version`,
`php_get_vhost_versions`, `php_ini_get_user_basic_directives`,
`php_ini_get_user_content`, `php_ini_get_user_paths`,
`php_ini_set_user_basic_directives`, `php_ini_set_user_content`,
`php_set_vhost_versions`.

### WHM API 1 EasyApache functions

| Function | Purpose |
|---|---|
| `ea4_list_profiles` | Lists cPanel and custom profiles with their packages; per profile: `active`, `desc`, `name`, `path`, `pkgs`, `tags`, `validation_data.not_on_server`, `version` |
| `ea4_save_profile` | Writes a profile into `/etc/cpanel/ea4/profiles/custom/`. Params `filename`, `name`, `pkg` (array), `desc`, `overwrite`, `tag` (array), `version` |
| `ea4_get_currently_installed_packages` | The installed EA4 packages |
| `ea4_metainfo` | Contents of `/etc/cpanel/ea4/ea4-metainfo.json` |
| `ea4_get_additional_pkg_prefixes` | Extra recognised package prefixes |
| `ea4_recommendations` | Recommendations attached to installed packages |
| `eol_php_sites` | Counts domains on end-of-life PHP |

Package installation itself goes through the generic
`package_manager_*` family: `package_manager_list_packages`,
`package_manager_get_package_info`,
`package_manager_resolve_actions`,
`package_manager_submit_actions`,
`package_manager_is_performing_actions`,
`package_manager_get_build_log`, `package_manager_fixcache`,
`package_manager_upgrade`.

There is no WHM API 1 function that provisions a profile.
`ea_install_profile` is the only documented way.

## Apache configuration

| Path | Contents |
|---|---|
| `/etc/cpanel/ea4/ea4.conf` | The Apache configuration store, replacing `/var/cpanel/conf/apache/local` and `/main`. Do not edit by hand |
| `/etc/cpanel/ea4/php.conf` | Default PHP version and handlers. Managed by `rebuild_phpconf` |
| `/etc/cpanel/ea4/ea4-metainfo.json` | Default PHP version, handler, and the Additional Packages list |
| `/etc/apache2/conf/httpd.conf` | The primary Apache configuration file, generated |
| `/etc/apache2/conf.d/` | Configuration directory; custom `.conf` files need `root:root` and mode `0600` |
| `/etc/apache2/conf.d/includes/` | Include files added to `httpd.conf` |
| `/etc/apache2/conf.d/userdata/` | Per-user and per-domain vhost includes (`ssl`/`std`) |
| `/var/cpanel/templates/apache2_4/` | The templates `httpd.conf` is built from |
| `/usr/sbin/httpd`, `/var/log/apache2/`, `/usr/lib64/apache2/modules/` | Binary, logs, modules |

Rebuild and restart are two separate steps:

```bash
/usr/local/cpanel/scripts/rebuildhttpdconf
/usr/local/cpanel/scripts/restartsrv_httpd
```

`rebuildhttpdconf` takes `--preview` (writes
`httpd-preview.conf` instead, so you can inspect it first) and
`--nolock` (skips the file lock). A successful run ends with
`Built /etc/apache2/conf/httpd.conf OK`. It does not restart
Apache.

## Unverified

- `ea_install_profile --system` and `--uninstall` do not appear
  in the documentation. Only `--install` is documented.
- No `php_vhosts` file exists in the documentation; the
  per-domain PHP version is the `phpversion:` key in
  `/var/cpanel/userdata/<user>/<domain>`.
- The EA4 repository filename (something like
  `/etc/yum.repos.d/EA4.repo`) is never named. Only the
  directory and the repo IDs `EA4-experimental-c7` and
  `EA4-experimental-c8` are documented.
- No single sentence states that PHP installs under
  `/opt/cpanel/ea-php##`; the prefix is established indirectly
  through its documented sub-paths.
- `ea_convert_php_ini` is named but given no path or flags, and
  the docs strongly recommend not running it by hand.
