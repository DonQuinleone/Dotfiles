const target = decodeURIComponent(window.location.hash.slice(1));

// Sent after the address rather than handing it over from a
// frame: either reaches the desktop, but a page that closes
// itself takes the launch down with it, and the tab is cleared
// from the background instead, where nothing can interrupt it.
if (target) {
  window.location.replace(target);
}
