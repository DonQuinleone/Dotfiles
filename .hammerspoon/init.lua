hs.hotkey.bind({"ctrl", "alt"}, "B", function()
  hs.application.launchOrFocus("LibreWolf")
end)

hs.hotkey.bind({"ctrl", "alt"}, "M", function()
  hs.application.launchOrFocus("Thunderbird")
end)

hs.hotkey.bind({"ctrl", "alt"}, "return", function()
  hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind({"ctrl", "alt"}, "E", function()
  hs.application.launchOrFocus("Ente Auth")
end)

hs.hotkey.bind({"ctrl", "alt"}, "P", function()
  hs.application.launchOrFocus("Bitwarden")
end)

hs.hotkey.bind({"ctrl", "alt"}, "R", function()
  hs.reload()
end)
