[mgr]
cwd = { fg = "{{ accent }}" }
find_keyword = { fg = "{{ yellow }}", bold = true }
find_position = { fg = "{{ dark_foreground }}" }
symlink_target = { fg = "{{ dark_foreground }}", italic = true }
marker_copied = { fg = "{{ green }}", bg = "{{ green }}" }
marker_cut = { fg = "{{ red }}", bg = "{{ red }}" }
marker_marked = { fg = "{{ accent }}", bg = "{{ accent }}" }
marker_selected = { fg = "{{ accent }}", bg = "{{ accent }}" }
count_copied = { fg = "{{ background }}", bg = "{{ green }}" }
count_cut = { fg = "{{ background }}", bg = "{{ red }}" }
count_selected = { fg = "{{ background }}", bg = "{{ accent }}" }
border_style = { fg = "{{ muted }}" }

[mode]
normal_main = { fg = "{{ background }}", bg = "{{ accent }}", bold = true }
normal_alt = { fg = "{{ accent }}", bg = "{{ lighter_background }}" }
select_main = { fg = "{{ background }}", bg = "{{ green }}", bold = true }
select_alt = { fg = "{{ green }}", bg = "{{ lighter_background }}" }
unset_main = { fg = "{{ background }}", bg = "{{ yellow }}", bold = true }
unset_alt = { fg = "{{ yellow }}", bg = "{{ lighter_background }}" }

[status]
overall = { fg = "{{ foreground }}", bg = "{{ lighter_background }}" }
progress_label = { fg = "{{ foreground }}", bold = true }
progress_normal = { fg = "{{ accent }}", bg = "{{ lighter_background }}" }
progress_error = { fg = "{{ red }}", bg = "{{ lighter_background }}" }

[tabs]
active = { fg = "{{ background }}", bg = "{{ accent }}", bold = true }
inactive = { fg = "{{ dark_foreground }}", bg = "{{ lighter_background }}" }

[input]
border = { fg = "{{ accent }}" }
title = { fg = "{{ foreground }}" }
value = { fg = "{{ foreground }}" }
selected = { fg = "{{ background }}", bg = "{{ accent }}" }

[cmp]
border = { fg = "{{ accent }}" }
active = { fg = "{{ background }}", bg = "{{ accent }}" }
inactive = { fg = "{{ foreground }}" }

[tasks]
border = { fg = "{{ accent }}" }
title = { fg = "{{ foreground }}" }
hovered = { fg = "{{ background }}", bg = "{{ accent }}" }

[help]
on = { fg = "{{ accent }}" }
run = { fg = "{{ green }}" }
desc = { fg = "{{ foreground }}" }
hovered = { fg = "{{ background }}", bg = "{{ accent }}", bold = true }
footer = { fg = "{{ foreground }}", bg = "{{ lighter_background }}" }
