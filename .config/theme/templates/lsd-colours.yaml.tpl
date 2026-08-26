user: "{{ accent }}"
group: "{{ dark_foreground }}"

permission:
  read: "{{ green }}"
  write: "{{ yellow }}"
  exec: "{{ red }}"
  exec-sticky: "{{ orange }}"
  no-access: "{{ mix dark_foreground background 45% }}"
  octal: "{{ orange }}"
  acl: "{{ orange }}"
  context: "{{ orange }}"

date:
  hour-old: "{{ green }}"
  day-old: "{{ orange }}"
  older: "{{ dark_foreground }}"

size:
  none: "{{ mix dark_foreground background 45% }}"
  small: "{{ dark_foreground }}"
  medium: "{{ orange }}"
  large: "{{ accent }}"

inode:
  valid: "{{ orange }}"
  invalid: "{{ mix dark_foreground background 45% }}"

links:
  valid: "{{ orange }}"
  invalid: "{{ mix dark_foreground background 45% }}"

tree-edge: "{{ muted }}"

git-status:
  default: "{{ mix dark_foreground background 45% }}"
  unmodified: "{{ mix dark_foreground background 45% }}"
  ignored: "{{ mix dark_foreground background 45% }}"
  new-in-index: "{{ green }}"
  new-in-workdir: "{{ green }}"
  typechange: "{{ yellow }}"
  deleted: "{{ red }}"
  renamed: "{{ orange }}"
  modified: "{{ yellow }}"
  conflicted: "{{ red }}"
