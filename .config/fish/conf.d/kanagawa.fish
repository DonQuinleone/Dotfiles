set -l fuji_white DCD7BA
set -l old_white C8C093
set -l fuji_gray 727169
set -l crystal_blue 7E9CD8
set -l spring_blue 7FB4CA
set -l spring_violet2 9CABCA
set -l oni_violet 957FB8
set -l oni_violet2 B8B4D0
set -l spring_green 98BB6C
set -l boat_yellow2 C0A36E
set -l carp_yellow E6C384
set -l wave_red E46876
set -l samurai_red E82424
set -l wave_blue1 223249
set -l wave_blue2 2D4F67

set -g fish_color_normal $fuji_white
set -g fish_color_command $crystal_blue
set -g fish_color_function $crystal_blue
set -g fish_color_builtin $oni_violet
set -g fish_color_keyword $oni_violet
set -g fish_color_quote $spring_green
set -g fish_color_redirection $boat_yellow2
set -g fish_color_operator $boat_yellow2
set -g fish_color_end $spring_violet2
set -g fish_color_param $oni_violet2
set -g fish_color_option $carp_yellow
set -g fish_color_comment $fuji_gray
set -g fish_color_escape $wave_red
set -g fish_color_error $samurai_red
set -g fish_color_cancel $samurai_red
set -g fish_color_autosuggestion $fuji_gray
set -g fish_color_valid_path --underline
set -g fish_color_selection --background=$wave_blue2
set -g fish_color_search_match --background=$wave_blue1
set -g fish_color_history_current $carp_yellow --bold

set -g fish_pager_color_progress $old_white --background=$wave_blue1
set -g fish_pager_color_prefix $crystal_blue --bold
set -g fish_pager_color_completion $fuji_white
set -g fish_pager_color_description $fuji_gray
set -g fish_pager_color_selected_background --background=$wave_blue2

set -gx FZF_DEFAULT_OPTS (string join -- " " \
    "--color=fg:#$fuji_white,hl:#$crystal_blue" \
    "--color=fg+:#$fuji_white,bg+:#$wave_blue2" \
    "--color=hl+:#$spring_blue,info:#$spring_green" \
    "--color=prompt:#$boat_yellow2,pointer:#$samurai_red" \
    "--color=marker:#$carp_yellow,spinner:#$oni_violet" \
    "--color=header:#$fuji_gray,border:#$wave_blue2")
