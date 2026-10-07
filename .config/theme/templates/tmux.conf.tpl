set -g status-style "bg=default,fg={{ dark_foreground }}"
set -g status-left \
    "#{?#{==:#{pane_title},insert},#[fg={{ green }}] ● ,#{?#{==:#{pane_title},normal},#[fg={{ blue }}] ● , ● }}"
set -g status-right \
    "#(tmux-status-git '{{ dark_foreground }}' '{{ accent }}' '#{pane_current_path}')#[fg={{ dark_foreground }}]%a %d %b  #[fg={{ foreground }}]%H:%M "
set -g window-status-separator ""
set -g window-status-format \
    "#[fg={{ dark_foreground }}] #I #W#{?window_zoomed_flag, 󰁌,} "
set -g window-status-current-format \
    "#[fg={{ accent }},bold] #I #W#{?window_zoomed_flag, 󰁌,} "
set -g window-status-activity-style "fg={{ yellow }}"
set -g window-status-bell-style "fg={{ red }}"
set -g pane-border-style "fg={{ muted }}"
set -g pane-active-border-style "fg={{ accent }}"
set -g message-style "bg={{ lighter_background }},fg={{ foreground }}"
set -g message-command-style "bg={{ lighter_background }},fg={{ foreground }}"
set -g mode-style "bg={{ accent }},fg={{ background }}"
set -g copy-mode-match-style "bg={{ yellow }},fg={{ background }}"
set -g copy-mode-current-match-style "bg={{ accent }},fg={{ background }}"
set -g clock-mode-colour "{{ accent }}"
