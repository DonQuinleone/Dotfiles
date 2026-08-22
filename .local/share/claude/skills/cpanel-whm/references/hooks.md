# Standardised hooks

Verified against
`api.docs.cpanel.net/guides/guide-to-standardized-hooks` and its
subpages.

A hook is three things: a hookable event, your hook action code,
and a registration that binds them. Registration is done with
`/usr/local/cpanel/bin/manage_hooks`.

## manage_hooks

Synopsis, verbatim from the docs:

```
bin/manage_hooks [action] [type] [reference] [options]
```

| Action | Meaning |
|---|---|
| `add` | Register a hook |
| `delete` | Deregister a hook |
| `describe` | Describe a hook's action |
| `list` | List a category's registered hooks |
| `fullhelp` | Print the utility's help |

`[type]` is `script` (any language the shell can execute) or
`module` (a Perl module). `[reference]` is the script's absolute
path, or the module's `package` value.

| Option | Values | Purpose |
|---|---|---|
| `--category` | `Cpanel`, `PkgAcct`, `Passwd`, `Stats`, `System`, `Whostmgr`, `RPM::Versions` | Event category; required when the code has no `describe()` |
| `--event` | see the category's page | Event name; required when the code has no `describe()` |
| `--stage` | `pre`, `post`, and the PkgAcct-only stages below | When the code runs |
| `--exectype` | `script`, `module` | Used in the docs' worked examples but absent from the official options table |
| `--blocking` | `1`, `0` | Let a `pre`-stage failure stop the event; requires `describe()` and enables `--rollback` |
| `--rollback` | script path or Perl package | Code to run when another hook on this event fails |
| `--check` | script path or Perl package | Runs first; if it fails the main code is skipped |
| `--escalateprivs` | `1`, `0` | Escalate to root before the code runs; only for events with the `escalateprivs` attribute |
| `--weight` | positive integer | Ordering within a stage; the first registration defaults to `100`, later ones to 100 above the current highest |
| `--manual` | `1`, `0` (default `0`) | Use only the CLI options rather than `describe()` |
| `--action` | `add`, `delete`, `list`, `fullhelp` | An additional hook action |
| `--output` | `HUMAN` (default), `JSON` | Output format for `list` |
| `--help` | none | Basic help |

There is no `--priority` (it is `--weight`) and no `--hook` flag
(`hook` is a `describe()` descriptor; on the CLI the location is
the positional `[reference]`).

Beware the documented caveat: a `--action` value that starts with
a hyphen can be misread as another option switch, so quote it,
as in `--action='--do_remove'`.

### Verbatim examples

```
/usr/local/cpanel/bin/manage_hooks add module MyApp::WHM
/usr/local/cpanel/bin/manage_hooks delete module MyApp::WHM
/usr/local/cpanel/bin/manage_hooks add script \
  /var/cpanel/myapp/whm.php
```

Manual registration, no `describe()` method:

```
/usr/local/cpanel/bin/manage_hooks add script \
  /var/cpanel/myapp/whm.php \
  --manual --category Whostmgr --event 'Accounts::Remove' \
  --stage pre --action='--do_remove'
```

With a check, a rollback and privilege escalation:

```
/usr/local/cpanel/bin/manage_hooks add script \
  /var/cpanel/myapp/boo.php \
  --manual 1 --category Passwd --event ChangePasswd --stage pre \
  --exectype script --action="--inverse_password" \
  --check "/var/cpanel/myapp/boo.php --check_some_conditional"

/usr/local/cpanel/bin/manage_hooks add script \
  /var/cpanel/myapp/boo.php \
  --manual 1 --category Passwd --event ChangePasswd --stage pre \
  --exectype script --action="--inverse_password" \
  --rollback "/var/cpanel/myapp/boo.php --rollback_my_change"

/usr/local/cpanel/bin/manage_hooks add script \
  /var/cpanel/myapp/do_extra.pl \
  --manual --category Passwd --event ChangePasswd --stage pre \
  --exectype script --escalateprivs
```

List what is registered:

```
/usr/local/cpanel/bin/manage_hooks list
/usr/local/cpanel/bin/manage_hooks list --output JSON
```

## Hook action code contract

Input arrives as a single JSON-encoded structure. Modules receive
it as arguments (`my ($context, $data) = @_;`); scripts must read
the entire input stream to end of line from stdin and decode it.

| Input | Type | Contents |
|---|---|---|
| `context` | string | `Category::Event`, e.g. `Passwd::ChangePasswd` |
| `data` | hash reference | The event's `key=value` information; undefined for events that provide none |

The primary return value must be a single-line print to stdout
of two space-separated values: `result` then `message`. `result`
is `1` for success and `0` for failure. Perl bare `return` values
are explicitly discouraged because the system may read them as
true. No exit-status contract is documented; the printed result
is what counts.

```perl
return $result, $message;                      # module
print "$result_result $result_message"; exit;  # script
```

Scripts registered without `--manual` are invoked with
`--describe` and must print a JSON-encoded array of one or more
hashes; modules return a Perl array reference of hash references.
The minimum descriptors are `category`, `event`, `stage`,
`exectype` and `hook`.

### Blocking an event

Two conditions, both required:

1. `blocking` is `1` in `describe()` (or `--blocking 1`, which
   itself requires a `describe()` method).
2. The code raises an exception whose message contains
   `BAILOUT`, for instance `die("BAILOUT $message")`. A script
   prints `BAILOUT` to stdout and exits.

Without `BAILOUT` the system will not block the event. Only
certain `pre`-stage events can block at all. A blocking failure
halts the dispatch loop, logs to
`/usr/local/cpanel/logs/error_log` and iterates the rollback
actions in reverse; a non-blocking exception is logged and the
loop continues.

Check and rollback code must be written in the same language as
the main hook: modules and scripts cannot be mixed within one
hook.

## Where the code lives

| Type | Location | Notes |
|---|---|---|
| Script | `/usr/local/cpanel/3rdparty/bin` | `root:root`, mode `755`; runs as a separate process, no access to cPanel environment variables |
| Module | `/opt/cpanel/perl5/514/site_lib/x86_64-linux-64int`, `/opt/cpanel/perl5/514/site_lib`, or `/var/cpanel/perl5/lib` | Runs inside `cpsrvd`; can read cPanel environment variables. Anywhere else gives an `@INC` error at registration |

## Stages

| Stage | Where it applies |
|---|---|
| `pre` | Universal |
| `post` | Universal |
| `preFinalize` | `PkgAcct::Create` only |
| `postFinalize` | `PkgAcct::Create` only |
| `postExtract` | `PkgAcct::Restore` only |

`PkgAcct::Create` has `pre`, `preFinalize`, `postFinalize` and no
plain `post`. `PkgAcct::Restore` has `postExtract` and `post` and
no `pre`. `DiskQuota` events have only `pre`.

## Categories and the events worth knowing

Thirteen categories are documented: `ConvertAddon`, `Cpanel`,
`DiskQuota`, `Log::Retention`, `modsec_vendor`, `ModSecurity`,
`Passwd`, `PkgAcct`, `RPM::Versions`, `Scripts`, `Stats`,
`System`, `Whostmgr`. The `--category` options table lists only
seven of those, which is a documentation inconsistency rather
than a restriction you can rely on.

### Whostmgr (runs as root)

| Event | Blocking | Notes |
|---|---|---|
| `Accounts::Create` | available | Returns the WHM API 1 `createacct` returns |
| `Accounts::Modify` | available | |
| `Accounts::Remove` | available | Returns the WHM API 1 `removeacct` returns |
| `Accounts::change_package` | available | |
| `Accounts::suspendacct` | available | `pre` gives `user`, `reason`, `disallowun`; `post` adds `rawout` |
| `Accounts::unsuspendacct` | available | `pre` gives `user`; `post` gives `user`, `rawout` |
| `Accounts::set_shell` | available | |
| `Accounts::SiteIP::set` | available | |
| `Accounts::Rearrangeacct` | available | |
| `AccountEnhancements::Assign` / `::Unassign` | available | |
| `AutoSSL::installssl`, `SSL::installssl` | available | |
| `Domain::addsubdomain`, `Domain::delsubdomain`, `Domain::park`, `Domain::zone_add`, `Domain::zone_remove` | available | |
| `ParkAdmin::park`, `ParkAdmin::unpark` | available | |
| `Lang::PHP::set_vhost_versions`, `::set_system_default_version`, `::set_handler`, `::ini_set_content`, `::ini_set_directives` | available | |
| `Packages::verify_input_data` | available | |
| `RemoteMySQL::activate_profile` | available | |
| `Server::Type::Change::enable` / `::disable` | available | |
| `Transfers::Session` | available | |
| `TweakSettings::Main` | available | |

### Cpanel (runs as the cPanel user)

Events are not enumerated; they are derived from the API surface
using `API::Module::function`, where `API` is the case-sensitive
`UAPI` or `Api2`. Full context strings therefore look like
`Cpanel::UAPI::Email::add_pop` and
`Cpanel::Api2::StatsBar::stat`.

One asymmetry matters: cPanel API 2 post-hooks always run and
report status in `data->{'output'}{'result'}`, whereas UAPI
post-hooks do not run at all if the call failed.

### Other categories

| Event | Runs as | Blocking | Notes |
|---|---|---|---|
| `PkgAcct::Create` | root, or the backup owner during backup generation | available | `postFinalize` is skipped when `skiphomedir` is `1` |
| `PkgAcct::Restore` | root | available | Returns `user`, `old_user`, `user_homedir`, `domain`, `extract_dir` |
| `Passwd::ChangePasswd` | root | available | The only event in the category; fires for WHM, cPanel, WHM API 1 `passwd` and API 2 `Passwd::change_password` |
| `Scripts::addpop`, `Scripts::delpop` | root | available | Mail account creation and deletion via `/usr/local/cpanel/scripts/addpop` and `delpop`; there is no `Mail` category |
| `System::upcp` | root | unavailable | A `pre` failure cannot block the update |
| `System::Backup` | root | unavailable | Does not fire for the legacy backup system |
| `Stats::RunAll` | root | unavailable | |
| `Stats::RunUser` | the cPanel user | unavailable | |
| `DiskQuota::warn`, `::critical`, `::fail` | root | unavailable | `pre` only |
| `Log::Retention::pre_deletion`, `::post_deletion` | root | unavailable | No custom user paths |
| `ConvertAddon::convert_addon` | root | unavailable | |
| `RPM::Versions::<rpmname>` | the WHM user | available | Preconfigured `/scripts/pre*up` and `/scripts/post*up` hooks for `dovecot`, `exim`, `proftpd`, `pure-ftpd` and `MySQL55-server`, gated by the `/var/cpanel/legacy_hooks` touch file |
| `modsec_vendor::*`, `ModSecurity::modsec_*` | | | 8 and 26 events respectively, all `pre`/`post` |

## State on disk

| Path | Contents |
|---|---|
| `/var/cpanel/hooks/data/<Category>/<event>.yaml` and `.cache` | Registration data. Do not edit by hand; use `manage_hooks` |
| `/var/cpanel/debughooks` | Debug mode value |
| `/var/cpanel/cpanel.config` | Fallback `debughooks` value, as integers `0` to `3` |
| `/var/cpanel/legacy_hooks` | Touch file suppressing the preconfigured `RPM::Versions` hooks |

## Debugging

There is no dedicated hooks log; everything lands in
`/usr/local/cpanel/logs/error_log`, tagged `[hook]`.

Debug mode is set in WHM >> Home >> Server Configuration >> Tweak
Settings >> Development >> Standardized Hooks - Debug Mode, which
writes `/var/cpanel/debughooks`.

| Value | Behaviour |
|---|---|
| `0` | Off |
| `log` | Display info while a hook executes, do not log |
| `logdata` | Display info and log debug data to the error log |
| `logall` | Display info for every stage of every hookable event, even where no hook exists |

The docs warn that this also enables debug mode in the cPanel
interface and severely affects its performance, and that it
generates a large amount of log noise. Turn it off with:

```bash
echo -n > /var/cpanel/debughooks
/scripts/restartsrv_cpsrvd
```

## Unverified

- A `reindex` subcommand: not documented anywhere in the guide.
- `--exectype` appears in worked examples but not in the options
  table, so its documented status is inconsistent.
- `manage_hooks fullhelp` output is never shown in the docs; run
  it on the server for the authoritative flag list.
- Per-function `Cpanel::UAPI::*` and `Cpanel::Api2::*` event
  names are generated mechanically and cannot be enumerated from
  the documentation.
