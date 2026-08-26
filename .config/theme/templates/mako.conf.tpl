font={{ theme_font_ui }} {{ theme_size_ui }}
background-color={{ background }}
text-color={{ foreground }}
border-color={{ accent }}
progress-color=over {{ mix accent background 40% }}
width=440
height=180
margin=12
padding=14
border-size=2
border-radius=10
icon-path=/usr/share/icons/Adwaita
max-icon-size=48
default-timeout=6000
ignore-timeout=0
layer=overlay
anchor=top-right
max-visible=5

[urgency=low]
border-color={{ muted }}
text-color={{ dark_foreground }}
default-timeout=4000

[urgency=critical]
border-color={{ red }}
text-color={{ foreground }}
default-timeout=0

[mode=do-not-disturb]
invisible=1
