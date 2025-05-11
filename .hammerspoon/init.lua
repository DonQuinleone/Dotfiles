local mods = {"ctrl", "alt"}

local appBindings = {
  ["B"]       = "LibreWolf",
  ["M"]       = "Thunderbird",
  ["O"]       = "Microsoft Outlook",
  ["T"]       = "Microsoft Teams",
  ["return"]  = "Ghostty",
  ["E"]       = "Ente Auth",
  ["P"]       = "Bitwarden",
  ["D"]       = "Discord",
  ["S"]       = "Spotify",
  ["."]       = "System Settings",
  ["H"]       = "Home",
}

for key, app in pairs(appBindings) do
  hs.hotkey.bind(mods, key, function()
    hs.application.launchOrFocus(app)
  end)
end

hs.hotkey.bind(mods, "R", hs.reload)

