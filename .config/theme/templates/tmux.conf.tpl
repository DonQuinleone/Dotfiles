set -g status-style "bg={{ dark_background }},fg={{ dark_foreground }}"
set -g status-left \
    "#[fg={{ background }},bg=#{?#{@mode_colour},#{@mode_colour},{{ accent }}},bold] 󰒋 #h #[fg=#{?#{@mode_colour},#{@mode_colour},{{ accent }}},bg={{ dark_background }}]"
set -g status-right \
    "#(tmux-status-git '{{ lighter_background }}' '{{ dark_background }}' '{{ dark_foreground }}' '{{ accent }}' '#{pane_current_path}')#[fg={{ lighter_background }},bg={{ dark_background }}]#[fg={{ foreground }},bg={{ lighter_background }}] %a %d %b #[fg={{ accent }},bg={{ lighter_background }}]#[fg={{ background }},bg={{ accent }},bold] %H:%M "
set -g window-status-separator ""
set -g window-status-format \
    "#[fg={{ dark_foreground }},bg={{ dark_background }}] #I #W#{?window_zoomed_flag, 󰁌,} "
set -g window-status-current-format \
    "#[fg={{ dark_background }},bg={{ lighter_background }}]#[fg={{ foreground }},bg={{ lighter_background }},bold] #I #W#{?window_zoomed_flag, 󰁌,} #[fg={{ lighter_background }},bg={{ dark_background }}]"
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
