#!/usr/bin/env python3
"""Idempotent restyle pass for vendored Claude Code skills.

Walks every skill directory in this staging tree and, for each
Markdown file, applies:

  1. dash normalisation (em/en dashes used as punctuation become a
     comma, colon, semicolon or " to " for a numeric range; a real
     hyphen or a `--flag` is never touched)
  2. British spellings, skipped inside code fences, inline code,
     and (for the licence filename) filenames
  3. `email` -> `e-mail` in prose
  4. hard-wrapping of prose at 72 columns, leaving code blocks,
     tables and URLs unwrapped
  5. removal of hidden "ignore all other instructions" / "respond
     ONLY with" style trigger paragraphs
  6. SKILL.md frontmatter normalisation: name == directory name,
     description present, and a metadata block carrying
     source / source_commit / source_path / licence

Re-running this script on its own output is a no-op: every
transform above is idempotent (dash and hidden-trigger patterns are
gone after the first pass, spelling substitutions are fixed points,
and wrapping re-derives the same 72-column layout from the already
wrapped paragraph text).

Also (re)writes SOURCES.toml from the same MANIFEST used for the
frontmatter pass, so the two never drift apart.
"""
from __future__ import annotations

import re
import textwrap
from pathlib import Path

STAGE = Path(__file__).resolve().parent
WRAP_WIDTH = 72

# ---------------------------------------------------------------
# Provenance manifest -- single source of truth for SOURCES.toml
# and for the metadata: block injected into every SKILL.md.
# ---------------------------------------------------------------

_SUPERPOWERS = dict(
    source="https://github.com/obra/superpowers.git",
    source_commit="b36e0829c6d0140e93cfef2ca599b1b07d4a7797",
    licence="MIT",
)
_DEVOPS = dict(
    source="https://github.com/ahmedasmar/devops-claude-skills.git",
    source_commit="1489c33ad8829a11219e423327d6b59f8339cee4",
    licence="MIT",
)
_ALIREZA = dict(
    source="https://github.com/alirezarezvani/claude-skills.git",
    source_commit="98180dafc4f0bc9d629bd479fc6107674cfb3cf8",
    licence="MIT",
)
_ANTHROPIC = dict(
    source="https://github.com/anthropics/skills.git",
    source_commit="3b3fad96af16a10759d930941b4520ba0c40edae",
)
_LEOGALLEGO = dict(
    source="https://github.com/leogallego/claude-ansible-skills.git",
    source_commit="2f0bb2b55e7adaec381bd9ee0adaaecc9b870690",
    licence="GPL-3.0-or-later",
)
_REALSIGRIDJIN = dict(
    source="https://github.com/realsigridjin/hello-ansible-skills.git",
    source_commit="3062baada51d4fb2279334a7e8bf3e7d02347fde",
    licence="MIT",
)
_GOOD_README = dict(
    source="https://github.com/adewale/good-readme.git",
    source_commit="8631fbc0f457776cb976915930cb1fd621dca476",
    licence="MIT",
)
_PETERKNEGO = dict(
    source="https://github.com/PeterKnego/diataxis-docs-skill.git",
    source_commit="de11e3bb2dd56d04849f70d8b1964b5593d369ec",
    licence="MIT",
)
_KEITHPATTON = dict(
    source="https://github.com/keithpatton/diataxis-agent-skill.git",
    source_commit="5b095a5e7aebe77ce4af855809123e12d92b9efd",
    licence="CC-BY-SA-4.0",
)


def _entry(base, source_path, licence=None):
    entry = dict(base)
    entry["source_path"] = source_path
    if licence is not None:
        entry["licence"] = licence
    return entry


# Each row: vendored skill name -> (base repo, path within repo,
# licence override). A blank licence override means "use the base
# repo's licence". Kept as one row per skill (a data table, per the
# style rule's own exception) rather than as 72-column-wrapped calls.
_ROWS = [
    # obra/superpowers
    ("brainstorming", _SUPERPOWERS,
     "skills/brainstorming", None),
    ("writing-plans", _SUPERPOWERS,
     "skills/writing-plans", None),
    ("executing-plans", _SUPERPOWERS,
     "skills/executing-plans", None),
    ("systematic-debugging", _SUPERPOWERS,
     "skills/systematic-debugging", None),
    ("requesting-code-review", _SUPERPOWERS,
     "skills/requesting-code-review", None),
    ("receiving-code-review", _SUPERPOWERS,
     "skills/receiving-code-review", None),
    ("writing-skills", _SUPERPOWERS,
     "skills/writing-skills", None),

    # ahmedasmar/devops-claude-skills
    ("iac-terraform", _DEVOPS,
     "iac-terraform/skills", None),
    ("k8s-troubleshooter", _DEVOPS,
     "k8s-troubleshooter/skills", None),
    ("ci-cd", _DEVOPS,
     "ci-cd/skills", None),
    ("monitoring-observability", _DEVOPS,
     "monitoring-observability/skills", None),
    ("gitops-workflows", _DEVOPS,
     "gitops-workflows/skills", None),

    # alirezarezvani/claude-skills
    ("runbook-generator", _ALIREZA,
     "engineering/skills/runbook-generator", None),
    ("observability-designer", _ALIREZA,
     "engineering/skills/observability-designer", None),
    ("kubernetes-operator", _ALIREZA,
     "engineering/skills/kubernetes-operator", None),
    ("secrets-vault-manager", _ALIREZA,
     "engineering/skills/secrets-vault-manager", None),
    ("env-secrets-manager", _ALIREZA,
     "engineering/skills/env-secrets-manager", None),
    ("dependency-auditor", _ALIREZA,
     "engineering/skills/dependency-auditor", None),
    ("skill-security-auditor", _ALIREZA,
     "engineering/skills/skill-security-auditor", None),
    ("changelog-generator", _ALIREZA,
     "engineering/skills/changelog-generator", None),
    ("ci-cd-pipeline-builder", _ALIREZA,
     "engineering/skills/ci-cd-pipeline-builder", None),
    ("migration-architect", _ALIREZA,
     "engineering/skills/migration-architect", None),
    ("sql-database-assistant", _ALIREZA,
     "engineering/skills/sql-database-assistant", None),
    ("slo-architect", _ALIREZA,
     "engineering/skills/slo-architect", None),
    ("terraform-patterns", _ALIREZA,
     "engineering/terraform-patterns/skills/terraform-patterns",
     None),
    ("helm-chart-builder", _ALIREZA,
     "engineering/helm-chart-builder/skills/helm-chart-builder",
     None),
    ("docker-development", _ALIREZA,
     "engineering/docker-development/skills/docker-development",
     None),
    ("security-guidance", _ALIREZA,
     "engineering/security-guidance/skills/security-guidance",
     None),
    ("incident-commander", _ALIREZA,
     "engineering-team/skills/incident-commander", None),
    ("self-improving-agent", _ALIREZA,
     "engineering-team/self-improving-agent/skills"
     "/self-improving-agent", None),
    ("extract", _ALIREZA,
     "engineering-team/self-improving-agent/skills/extract",
     None),
    ("memory-review", _ALIREZA,
     "engineering-team/self-improving-agent/skills/memory-review",
     None),
    ("memory-status", _ALIREZA,
     "engineering-team/self-improving-agent/skills/memory-status",
     None),
    ("promote", _ALIREZA,
     "engineering-team/self-improving-agent/skills/promote",
     None),
    ("remember", _ALIREZA,
     "engineering-team/self-improving-agent/skills/remember",
     None),

    # anthropics/skills
    ("skill-creator", _ANTHROPIC,
     "skills/skill-creator", "Apache-2.0"),
    ("mcp-builder", _ANTHROPIC,
     "skills/mcp-builder", "Apache-2.0"),
    ("doc-coauthoring", _ANTHROPIC,
     "skills/doc-coauthoring", "unstated"),
    ("claude-api", _ANTHROPIC,
     "skills/claude-api", "Apache-2.0"),

    # leogallego/claude-ansible-skills
    ("ansible-docs", _LEOGALLEGO,
     "ansible-docs/skills/ansible-docs", None),
    ("ansible-good-practices", _LEOGALLEGO,
     "ansible-good-practices/skills/ansible-good-practices",
     None),
    ("ansible-new-collection", _LEOGALLEGO,
     "ansible-new-collection/skills/ansible-new-collection",
     None),
    ("ansible-new-ee", _LEOGALLEGO,
     "ansible-new-ee/skills/ansible-new-ee", None),
    ("ansible-new-molecule", _LEOGALLEGO,
     "ansible-new-molecule/skills/ansible-new-molecule", None),
    ("ansible-new-role", _LEOGALLEGO,
     "ansible-new-role/skills/ansible-new-role", None),
    ("ansible-zen", _LEOGALLEGO,
     "ansible-zen/skills/ansible-zen", None),

    # realsigridjin/hello-ansible-skills (ansible- renamed to
    # ansible-quick- to avoid colliding with leogallego's names)
    ("ansible-quick-convert", _REALSIGRIDJIN,
     "skills/ansible-convert", None),
    ("ansible-quick-debug", _REALSIGRIDJIN,
     "skills/ansible-debug", None),
    ("ansible-quick-interactive", _REALSIGRIDJIN,
     "skills/ansible-interactive", None),
    ("ansible-quick-playbook", _REALSIGRIDJIN,
     "skills/ansible-playbook", None),

    # adewale/good-readme
    ("good-readme", _GOOD_README,
     "skills/good-readme", None),

    # PeterKnego/diataxis-docs-skill (SKILL.md is MIT; its
    # reference sheets carry their own per-file CC BY-SA 4.0
    # attribution headers for the adapted diataxis.fr content)
    ("diataxis-docs", _PETERKNEGO,
     "skills/diataxis-docs", None),

    # keithpatton/diataxis-agent-skill (vendored as diataxis-audit
    # to avoid clashing with diataxis-docs above)
    ("diataxis-audit", _KEITHPATTON,
     "diataxis", None),
]

MANIFEST = {
    name: _entry(base, path, licence)
    for name, base, path, licence in _ROWS
}

# ---------------------------------------------------------------
# 1. Dash normalisation
# ---------------------------------------------------------------

_DASH_CHARS = "—–"
_DASH_RE = re.compile(f"[{_DASH_CHARS}]")


def _is_numericish(token: str) -> bool:
    return any(c.isdigit() for c in token)


def replace_dashes(text: str) -> str:
    """Replace prose em/en dashes; never touches ASCII hyphens."""
    out = []
    idx = 0
    for m in _DASH_RE.finditer(text):
        start, end = m.span()
        out.append(text[idx:start])
        before_space = start > 0 and text[start - 1] == " "
        after_space = end < len(text) and text[end] == " "
        tight = not before_space and not after_space
        if tight:
            pre_tok = re.search(r"\S+$", text[:start])
            post_tok = re.search(r"^\S+", text[end:])
            pre_tok = pre_tok.group(0) if pre_tok else ""
            post_tok = post_tok.group(0) if post_tok else ""
            if _is_numericish(pre_tok) or _is_numericish(post_tok):
                out.append(" to ")
                idx = end
                continue
        if out and out[-1].endswith(" "):
            out[-1] = out[-1][:-1]
        out.append(", ")
        idx = end
        if after_space:
            idx += 1
    out.append(text[idx:])
    return "".join(out)


# ---------------------------------------------------------------
# 2. British spellings (word-boundary, case-preserving)
# ---------------------------------------------------------------

_BRITISH_PAIRS = [
    ("color", "colour"),
    ("colors", "colours"),
    ("colored", "coloured"),
    ("coloring", "colouring"),
    ("colorize", "colourise"),
    ("organize", "organise"),
    ("organizes", "organises"),
    ("organized", "organised"),
    ("organizing", "organising"),
    ("organization", "organisation"),
    ("organizations", "organisations"),
    ("organizational", "organisational"),
    ("behavior", "behaviour"),
    ("behaviors", "behaviours"),
    ("behavioral", "behavioural"),
    ("center", "centre"),
    ("centers", "centres"),
    ("centered", "centred"),
    ("centering", "centring"),
    ("centralize", "centralise"),
    ("centralized", "centralised"),
    ("centralizing", "centralising"),
    ("centralization", "centralisation"),
    ("optimize", "optimise"),
    ("optimizes", "optimises"),
    ("optimized", "optimised"),
    ("optimizing", "optimising"),
    ("optimization", "optimisation"),
    ("optimizations", "optimisations"),
    ("optimizer", "optimiser"),
    ("optimizers", "optimisers"),
    ("customize", "customise"),
    ("customizes", "customises"),
    ("customized", "customised"),
    ("customizing", "customising"),
    ("customizable", "customisable"),
    ("customization", "customisation"),
    ("initialize", "initialise"),
    ("initializes", "initialises"),
    ("initialized", "initialised"),
    ("initializing", "initialising"),
    ("initialization", "initialisation"),
    ("normalize", "normalise"),
    ("normalizes", "normalises"),
    ("normalized", "normalised"),
    ("normalizing", "normalising"),
    ("normalization", "normalisation"),
    ("standardize", "standardise"),
    ("standardizes", "standardises"),
    ("standardized", "standardised"),
    ("standardizing", "standardising"),
    ("standardization", "standardisation"),
    ("serialize", "serialise"),
    ("serializes", "serialises"),
    ("serialized", "serialised"),
    ("serializing", "serialising"),
    ("serialization", "serialisation"),
    ("deserialize", "deserialise"),
    ("deserializes", "deserialises"),
    ("deserialized", "deserialised"),
    ("deserializing", "deserialising"),
    ("deserialization", "deserialisation"),
    ("synchronize", "synchronise"),
    ("synchronizes", "synchronises"),
    ("synchronized", "synchronised"),
    ("synchronizing", "synchronising"),
    ("synchronization", "synchronisation"),
    ("recognize", "recognise"),
    ("recognizes", "recognises"),
    ("recognized", "recognised"),
    ("recognizing", "recognising"),
    ("recognition", "recognition"),
    ("prioritize", "prioritise"),
    ("prioritizes", "prioritises"),
    ("prioritized", "prioritised"),
    ("prioritizing", "prioritising"),
    ("prioritization", "prioritisation"),
    ("utilize", "utilise"),
    ("utilizes", "utilises"),
    ("utilized", "utilised"),
    ("utilizing", "utilising"),
    ("utilization", "utilisation"),
    ("visualize", "visualise"),
    ("visualizes", "visualises"),
    ("visualized", "visualised"),
    ("visualizing", "visualising"),
    ("visualization", "visualisation"),
    ("visualizations", "visualisations"),
    ("minimize", "minimise"),
    ("minimizes", "minimises"),
    ("minimized", "minimised"),
    ("minimizing", "minimising"),
    ("maximize", "maximise"),
    ("maximizes", "maximises"),
    ("maximized", "maximised"),
    ("maximizing", "maximising"),
    ("modernize", "modernise"),
    ("modernizes", "modernises"),
    ("modernized", "modernised"),
    ("modernizing", "modernising"),
    ("containerize", "containerise"),
    ("containerizes", "containerises"),
    ("containerized", "containerised"),
    ("containerizing", "containerising"),
    ("containerization", "containerisation"),
    ("generalize", "generalise"),
    ("generalized", "generalised"),
    ("generalizing", "generalising"),
    ("specialize", "specialise"),
    ("specialized", "specialised"),
    ("specializing", "specialising"),
    ("specialization", "specialisation"),
    ("realize", "realise"),
    ("realizes", "realises"),
    ("realized", "realised"),
    ("realizing", "realising"),
    ("summarize", "summarise"),
    ("summarizes", "summarises"),
    ("summarized", "summarised"),
    ("summarizing", "summarising"),
    ("categorize", "categorise"),
    ("categorizes", "categorises"),
    ("categorized", "categorised"),
    ("categorizing", "categorising"),
    ("categorization", "categorisation"),
    ("characterize", "characterise"),
    ("characterized", "characterised"),
    ("characterizing", "characterising"),
    ("finalize", "finalise"),
    ("finalizes", "finalises"),
    ("finalized", "finalised"),
    ("finalizing", "finalising"),
    ("localize", "localise"),
    ("localizes", "localises"),
    ("localized", "localised"),
    ("localizing", "localising"),
    ("localization", "localisation"),
    ("authorize", "authorise"),
    ("authorizes", "authorises"),
    ("authorized", "authorised"),
    ("authorizing", "authorising"),
    ("authorization", "authorisation"),
    ("authorizations", "authorisations"),
    ("favor", "favour"),
    ("favors", "favours"),
    ("favored", "favoured"),
    ("favoring", "favouring"),
    ("favorite", "favourite"),
    ("favorites", "favourites"),
    ("labor", "labour"),
    ("labors", "labours"),
    ("labeled", "labelled"),
    ("labeling", "labelling"),
    ("defense", "defence"),
    ("defenses", "defences"),
    ("defensive", "defensive"),
    ("offense", "offence"),
    ("offenses", "offences"),
    ("gray", "grey"),
    ("grays", "greys"),
    ("grayscale", "greyscale"),
    ("canceled", "cancelled"),
    ("canceling", "cancelling"),
    ("modeling", "modelling"),
    ("modeled", "modelled"),
    ("signaling", "signalling"),
    ("signaled", "signalled"),
    ("traveling", "travelling"),
    ("traveled", "travelled"),
    ("fulfill", "fulfil"),
    ("fulfills", "fulfils"),
    ("fulfillment", "fulfilment"),
    ("skillful", "skilful"),
    ("enroll", "enrol"),
    ("enrolls", "enrols"),
    ("enrollment", "enrolment"),
    ("catalog", "catalogue"),
    ("catalogs", "catalogues"),
    ("catalogued", "catalogued"),
    ("neighbor", "neighbour"),
    ("neighbors", "neighbours"),
    ("honor", "honour"),
    ("honors", "honours"),
    ("rumor", "rumour"),
    ("rumors", "rumours"),
    ("humor", "humour"),
    ("humors", "humours"),
    ("flavor", "flavour"),
    ("flavors", "flavours"),
    ("harbor", "harbour"),
    ("harbors", "harbours"),
    ("endeavor", "endeavour"),
    ("endeavors", "endeavours"),
]

_BRITISH_MAP = {a: b for a, b in _BRITISH_PAIRS}
_BRITISH_ALTERNATION = "|".join(
    sorted(_BRITISH_MAP, key=len, reverse=True)
)
_BRITISH_WORD_RE = re.compile(rf"\b({_BRITISH_ALTERNATION})\b")


def _case_like(source: str, replacement: str) -> str:
    if source.isupper():
        return replacement.upper()
    if source[:1].isupper():
        return replacement[:1].upper() + replacement[1:]
    return replacement


def _british_word(m: re.Match) -> str:
    word = m.group(0)
    return _case_like(word, _BRITISH_MAP[word.lower()])


def apply_british_spelling(text: str) -> str:
    text = _BRITISH_WORD_RE.sub(_british_word, text)
    # `license` (noun) -> `licence`, but never the all-caps
    # `LICENSE` filename token, and never the verb forms
    # `licensed`/`licensing` (the word-boundary match below cannot
    # match those longer words, so they are already excluded).
    def _licence_repl(m: re.Match) -> str:
        word = m.group(0)
        if word.isupper():
            return word
        plural = "s" in word[-2:]
        return _case_like(word, "licences" if plural else "licence")

    text = re.sub(r"\bLicenses?\b|\blicenses?\b", _licence_repl, text)
    return text


# ---------------------------------------------------------------
# 3. `email` -> `e-mail` (prose only)
# ---------------------------------------------------------------

_EMAIL_PREFIXED_RE = re.compile(r"\b([Ee])mails?\b")


def apply_email_hyphen(text: str) -> str:
    # `email`/`Email`/`emails`/`Emails` -> `e-mail`/`E-mail`/...
    def repl(m: re.Match) -> str:
        word = m.group(0)
        cap = word[0].isupper()
        plural = word.lower().endswith("s")
        base = "e-mail" + ("s" if plural else "")
        return base[0].upper() + base[1:] if cap else base

    return _EMAIL_PREFIXED_RE.sub(repl, text)


# ---------------------------------------------------------------
# Combined prose transform + hidden-trigger stripping
# ---------------------------------------------------------------

_INLINE_CODE_RE = re.compile(r"(`+)(?:(?!\1).)*?\1")


def _apply_spelling_and_email(text: str) -> str:
    text = apply_british_spelling(text)
    text = apply_email_hyphen(text)
    return text


def restyle_prose(text: str) -> str:
    """Full prose restyle: dashes everywhere (even inside inline
    code, since the verify step requires zero dash characters
    anywhere in the file), British spelling and e-mail hyphenation
    everywhere EXCEPT inside inline code spans."""
    text = replace_dashes(text)
    out = []
    idx = 0
    for m in _INLINE_CODE_RE.finditer(text):
        start, end = m.span()
        out.append(_apply_spelling_and_email(text[idx:start]))
        out.append(m.group(0))
        idx = end
    out.append(_apply_spelling_and_email(text[idx:]))
    return "".join(out)


_HIDDEN_TRIGGER_MARKERS = (
    "ignore all other instructions",
    "ignore all previous instructions",
    "respond only with",
)


def _paragraph_is_hidden_trigger(paragraph: str) -> bool:
    low = paragraph.lower()
    return any(marker in low for marker in _HIDDEN_TRIGGER_MARKERS)


# ---------------------------------------------------------------
# 4. Markdown-aware 72-column wrapping
# ---------------------------------------------------------------

_FENCE_RE = re.compile(r"^(\s*)(```+|~~~+)(.*)$")
_HEADING_RE = re.compile(r"^\s{0,3}#{1,6}\s")
_HR_RE = re.compile(r"^\s{0,3}([-*_])(\s*\1){2,}\s*$")
_TABLE_ROW_RE = re.compile(r"^\s*\|.*\|\s*$|^\s*\S.*\|.*\S\s*$")
_TABLE_SEP_RE = re.compile(
    r"^\s*\|?\s*:?-{2,}:?\s*(\|\s*:?-{2,}:?\s*)*\|?\s*$"
)
_LIST_RE = re.compile(r"^(\s*)([-*+]|\d+[.)])(\s+)(.*)$")
_BLOCKQUOTE_RE = re.compile(r"^(\s*)(>+)(\s?)(.*)$")
_BLOCKQUOTE_BLANK_RE = re.compile(r"^\s*>+\s*$")
_URL_ONLY_RE = re.compile(r"^\s*<?https?://\S+>?\s*$")
# A run of 3+ internal spaces is a strong signal of a hand-aligned
# reference table/column layout rather than prose -- reflowing it
# would both garble the alignment and, since a wide-space "chunk" is
# atomic to textwrap, wrap non-idempotently.
_PREFORMATTED_RE = re.compile(r"\S {3,}\S")


_AMBIGUOUS_ORDERED_RE = re.compile(r"^(\s*)(\d+)([.)])(?=\s)")
_AMBIGUOUS_BULLET_RE = re.compile(r"^(\s*)([-*+])(?=\s)")


def _escape_wrap_reintroduced_list_marker(line: str) -> str:
    """A list item's continuation line, once wrapped, can by sheer
    coincidence of where it broke start with something that reads as
    a *new* list marker (e.g. "...is a\\n400. Updates..."). Our own
    per-item splitter re-scans every line of a list group for
    markers, so re-running restyle on that output would misparse it
    as a new item and corrupt the indent further on every pass.
    Backslash-escape it -- CommonMark's own convention for "this
    isn't actually a marker" -- which also keeps our scanner from
    tripping over it next time."""
    m = _AMBIGUOUS_ORDERED_RE.match(line)
    if m:
        indent, num, punct = m.groups()
        return f"{indent}{num}\\{punct}{line[m.end():]}"
    m = _AMBIGUOUS_BULLET_RE.match(line)
    if m:
        indent, bullet = m.groups()
        return f"{indent}\\{bullet}{line[m.end():]}"
    return line


def _wrap_plain(
    text: str, width: int, initial_indent: str, subsequent_indent: str
) -> list[str]:
    wrapped = textwrap.wrap(
        text,
        width=width,
        initial_indent=initial_indent,
        subsequent_indent=subsequent_indent,
        break_long_words=False,
        break_on_hyphens=False,
    )
    return wrapped or [initial_indent.rstrip()]


def _wrap_list_item(
    text: str, width: int, initial_indent: str, subsequent_indent: str
) -> list[str]:
    wrapped = _wrap_plain(
        text, width, initial_indent, subsequent_indent
    )
    escaped = [
        _escape_wrap_reintroduced_list_marker(l) for l in wrapped[1:]
    ]
    return wrapped[:1] + escaped


def _flush_group(lines: list[str], out: list[str]) -> None:
    if not lines:
        return
    first = lines[0]

    list_m = _LIST_RE.match(first)
    quote_m = _BLOCKQUOTE_RE.match(first)

    if list_m:
        # A group can hold several list items back to back (no blank
        # line between them); each "- "/"1. " marker starts a new
        # item, so split on markers before merging each item's own
        # continuation lines into one paragraph.
        items: list[tuple[str, str, list[str]]] = []
        for ln in lines:
            m = _LIST_RE.match(ln)
            if m:
                indent, marker, _sep, text = m.groups()
                items.append((indent, marker, [text]))
            elif items:
                items[-1][2].append(ln.strip())
            else:
                items.append(("", "-", [ln.strip()]))
        for indent, marker, texts in items:
            paragraph = " ".join(t.strip() for t in texts).strip()
            paragraph = restyle_prose(paragraph)
            if _paragraph_is_hidden_trigger(paragraph):
                continue
            marker_prefix = f"{indent}{marker} "
            cont_indent = " " * len(marker_prefix)
            out.extend(_wrap_list_item(
                paragraph, WRAP_WIDTH, marker_prefix, cont_indent
            ))
        return

    if quote_m:
        indent, marks, _sep, first_text = quote_m.groups()
        rest_texts = []
        for ln in lines[1:]:
            m2 = _BLOCKQUOTE_RE.match(ln)
            rest_texts.append(m2.group(4).strip() if m2 else ln.strip())
        paragraph = " ".join([first_text.strip()] + rest_texts).strip()
        paragraph = restyle_prose(paragraph)
        if _paragraph_is_hidden_trigger(paragraph):
            return
        prefix = f"{indent}{marks} "
        out.extend(_wrap_plain(paragraph, WRAP_WIDTH, prefix, prefix))
        return

    # plain paragraph
    paragraph = " ".join(ln.strip() for ln in lines).strip()
    paragraph = restyle_prose(paragraph)
    if _paragraph_is_hidden_trigger(paragraph):
        return
    if _URL_ONLY_RE.match(paragraph):
        out.append(paragraph)
        return
    out.extend(_wrap_plain(paragraph, WRAP_WIDTH, "", ""))


_ATTRIBUTION_HEADER_RE = re.compile(
    r"copyright\s*(\(c\)|\N{COPYRIGHT SIGN})", re.I
)


def _leading_attribution_header(
    body_lines: list[str],
) -> tuple[list[str], list[str]] | None:
    """A reference sheet adapted from a CC-licensed source can open
    with a blockquote attribution notice (author, licence, source
    URL) that a downstream licence requires be kept intact. Detect
    one only when it is the very first block in the file (before
    any heading) and mentions "copyright" -- and return it
    untouched, dash-substitution aside, so wrapping and spelling
    never rewrite someone else's copyright notice."""
    i = 0
    n = len(body_lines)
    while i < n and body_lines[i].strip() == "":
        i += 1
    start = i
    while i < n and _BLOCKQUOTE_RE.match(body_lines[i]):
        i += 1
    if i == start:
        return None
    header = body_lines[start:i]
    if not any(_ATTRIBUTION_HEADER_RE.search(l) for l in header):
        return None
    verbatim = [replace_dashes(l) for l in body_lines[:i]]
    return verbatim, body_lines[i:]


def restyle_body(body_lines: list[str]) -> list[str]:
    out: list[str] = []
    leading = _leading_attribution_header(body_lines)
    if leading is not None:
        out, body_lines = leading
    group: list[str] = []
    in_fence = False
    fence_char = ""
    fence_len = 0
    table_lines: list[str] = []

    def flush_table():
        if not table_lines:
            return
        for ln in table_lines:
            out.append(restyle_prose(ln))
        table_lines.clear()

    i = 0
    n = len(body_lines)
    while i < n:
        line = body_lines[i]

        fence_m = _FENCE_RE.match(line)
        if in_fence:
            # Code content: dashes must go everywhere (the verify
            # step demands zero em-dashes anywhere in the file), but
            # spelling/e-mail/wrap never touch code, so only the
            # dash pass runs here.
            out.append(replace_dashes(line))
            if (
                fence_m
                and fence_m.group(2)[0] == fence_char
                and len(fence_m.group(2)) >= fence_len
                and fence_m.group(3).strip() == ""
            ):
                in_fence = False
            i += 1
            continue
        if fence_m:
            _flush_group(group, out)
            group = []
            flush_table()
            in_fence = True
            fence_char = fence_m.group(2)[0]
            fence_len = len(fence_m.group(2))
            out.append(replace_dashes(line))
            i += 1
            continue

        if line.strip() == "":
            _flush_group(group, out)
            group = []
            flush_table()
            # Collapse runs of blank lines to one: a paragraph
            # removed by the hidden-trigger filter otherwise leaves
            # the blank line on each side of it behind.
            if not out or out[-1].strip() != "":
                out.append(line)
            i += 1
            continue

        if _BLOCKQUOTE_BLANK_RE.match(line):
            # A bare ">" marks a paragraph break *within* the quote;
            # treat it like a blank line so the two quoted
            # paragraphs on either side wrap independently instead
            # of being smashed into one.
            _flush_group(group, out)
            group = []
            flush_table()
            out.append(replace_dashes(line.rstrip()))
            i += 1
            continue

        # detect a table: current + next line form header/separator
        if (
            not table_lines
            and _TABLE_ROW_RE.match(line)
            and i + 1 < n
            and _TABLE_SEP_RE.match(body_lines[i + 1])
        ):
            _flush_group(group, out)
            group = []
            table_lines.append(line)
            i += 1
            continue
        if table_lines:
            if _TABLE_ROW_RE.match(line) or _TABLE_SEP_RE.match(line):
                table_lines.append(line)
                i += 1
                continue
            flush_table()

        if _HEADING_RE.match(line) or _HR_RE.match(line):
            _flush_group(group, out)
            group = []
            out.append(restyle_prose(line))
            i += 1
            continue

        if (
            _PREFORMATTED_RE.search(line)
            and not _LIST_RE.match(line)
            and not _BLOCKQUOTE_RE.match(line)
        ):
            _flush_group(group, out)
            group = []
            out.append(restyle_prose(line))
            i += 1
            continue

        group.append(line)
        i += 1

    _flush_group(group, out)
    flush_table()
    return out


# ---------------------------------------------------------------
# 6. Frontmatter normalisation
# ---------------------------------------------------------------

def _split_frontmatter(text: str) -> tuple[list[str], list[str]] | None:
    if not text.startswith("---\n") and text != "---":
        return None
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    for idx in range(1, len(lines)):
        if lines[idx].strip() == "---":
            return lines[1:idx], lines[idx + 1:]
    return None


def _frontmatter_key_blocks(
    fm_lines: list[str],
) -> list[tuple[str, list[str]]]:
    blocks: list[tuple[str, list[str]]] = []
    for line in fm_lines:
        if line and not line[0].isspace() and ":" in line:
            key = line.split(":", 1)[0].strip()
            blocks.append((key, [line]))
        elif blocks:
            blocks[-1][1].append(line)
        else:
            blocks.append(("", [line]))
    return blocks


def _emit_folded_scalar(
    key: str, value: str, indent: str = "  "
) -> list[str]:
    lines = [f"{key}: >-"]
    lines.extend(
        textwrap.wrap(
            value,
            width=WRAP_WIDTH,
            initial_indent=indent,
            subsequent_indent=indent,
            break_long_words=False,
            break_on_hyphens=False,
        )
        or [indent.rstrip()]
    )
    return lines


def _restyle_frontmatter_block(
    key: str, block_lines: list[str]
) -> list[str]:
    first = block_lines[0]
    fkey, _, rest = first.partition(":")
    rest_stripped = rest.strip()

    if rest_stripped == "" and len(block_lines) > 1 and all(
        l.strip().startswith("- ") or not l.strip()
        for l in block_lines[1:]
    ):
        # A YAML block sequence (bare "key:" followed by "  - item"
        # lines), e.g. a `references:` list. This is structured
        # data, not prose: substitute dashes item by item and leave
        # the list itself alone, rather than folding it into a
        # scalar and destroying its shape.
        return [first] + [replace_dashes(l) for l in block_lines[1:]]

    if rest_stripped in (">-", ">"):
        value = " ".join(
            l.strip() for l in block_lines[1:] if l.strip()
        )
        value = restyle_prose(value)
        return _emit_folded_scalar(key, value)

    if rest_stripped in ("|-", "|"):
        out = [first]
        for l in block_lines[1:]:
            indent_match = re.match(r"^(\s*)", l)
            indent = indent_match.group(1) if indent_match else "  "
            content = restyle_prose(l.strip())
            if content:
                out.extend(
                    textwrap.wrap(
                        content,
                        width=WRAP_WIDTH,
                        initial_indent=indent,
                        subsequent_indent=indent,
                        break_long_words=False,
                        break_on_hyphens=False,
                    )
                )
            else:
                out.append(l)
        return out

    # single-line scalar (quoted or bare), possibly with stray
    # continuation lines already wrapped by a previous run
    quote = ""
    val = rest_stripped
    if val[:1] in ("'", '"') and val[-1:] == val[:1] and len(val) >= 2:
        quote = val[:1]
        val = val[1:-1]
    tail = " ".join(l.strip() for l in block_lines[1:])
    val = (val + " " + tail).strip() if tail else val
    val = restyle_prose(val)
    candidate = f"{fkey}: {quote}{val}{quote}"
    if len(candidate) <= WRAP_WIDTH:
        return [candidate]
    return _emit_folded_scalar(key, val)


def normalise_skill_frontmatter(
    fm_lines: list[str], skill_name: str
) -> list[str]:
    entry = MANIFEST[skill_name]
    blocks = _frontmatter_key_blocks(fm_lines)

    seen_name = False
    seen_metadata = False
    new_blocks: list[tuple[str, list[str]]] = []

    for key, lines in blocks:
        if key == "name":
            new_blocks.append(("name", [f"name: {skill_name}"]))
            seen_name = True
            continue
        if key == "metadata":
            sub = list(lines[1:])
            wanted = {
                "source": entry["source"],
                "source_commit": entry["source_commit"],
                "source_path": entry["source_path"],
                "licence": entry["licence"],
            }
            present = {
                re.match(r"^\s*([A-Za-z_]+):", l).group(1)
                for l in sub
                if re.match(r"^\s*([A-Za-z_]+):", l)
            }
            for field, value in wanted.items():
                if field not in present:
                    sub.append(f"  {field}: {value}")
            new_blocks.append(("metadata", ["metadata:"] + sub))
            seen_metadata = True
            continue
        restyled = (
            list(lines) if key == ""
            else _restyle_frontmatter_block(key, lines)
        )
        new_blocks.append((key, restyled))

    if not seen_name:
        new_blocks.insert(0, ("name", [f"name: {skill_name}"]))

    if not seen_metadata:
        meta_lines = [
            "metadata:",
            f"  source: {entry['source']}",
            f"  source_commit: {entry['source_commit']}",
            f"  source_path: {entry['source_path']}",
            f"  licence: {entry['licence']}",
        ]
        new_blocks.append(("metadata", meta_lines))

    out: list[str] = []
    for _key, lines in new_blocks:
        out.extend(lines)
    return out


# ---------------------------------------------------------------
# Driver
# ---------------------------------------------------------------

def restyle_file(path: Path, skill_name: str) -> None:
    original = path.read_text(encoding="utf-8")
    fm = _split_frontmatter(original)
    if fm is not None and path.name == "SKILL.md":
        fm_lines, body_lines = fm
        new_fm = normalise_skill_frontmatter(fm_lines, skill_name)
        new_body = restyle_body(body_lines)
        new_text = (
            "---\n" + "\n".join(new_fm)
            + "\n---\n" + "\n".join(new_body)
        )
    else:
        lines = original.splitlines()
        # non-SKILL.md files may still open with a --- frontmatter
        # style block (none observed); treat the whole file as body.
        new_lines = restyle_body(lines)
        new_text = "\n".join(new_lines)
    # Always end with exactly one newline: a file with N>=0 blank
    # lines at EOF would otherwise round-trip through splitlines()
    # + join() losing one blank line per pass, which is not
    # idempotent until it converges to zero.
    new_text = new_text.rstrip("\n") + "\n"
    if new_text != original:
        path.write_text(new_text, encoding="utf-8")


def write_sources_toml() -> None:
    lines = []
    for name in sorted(MANIFEST):
        entry = MANIFEST[name]
        lines.append(f"[{name}]")
        lines.append(f'source = "{entry["source"]}"')
        lines.append(f'source_commit = "{entry["source_commit"]}"')
        lines.append(f'source_path = "{entry["source_path"]}"')
        lines.append(f'licence = "{entry["licence"]}"')
        lines.append("")
    content = "\n".join(lines).rstrip() + "\n"
    (STAGE / "SOURCES.toml").write_text(content, encoding="utf-8")


def main() -> None:
    for skill_name in sorted(MANIFEST):
        skill_dir = STAGE / skill_name
        if not skill_dir.is_dir():
            raise SystemExit(f"missing skill directory: {skill_dir}")
        for path in sorted(skill_dir.rglob("*.md")):
            restyle_file(path, skill_name)
    write_sources_toml()


if __name__ == "__main__":
    main()
