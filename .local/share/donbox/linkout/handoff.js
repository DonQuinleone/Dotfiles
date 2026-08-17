const CLEAR_DELAY_MS = 900;

const target = decodeURIComponent(window.location.hash.slice(1));

// Handed over from a frame rather than by sending this page after
// it: navigating the page itself to an external scheme tears the
// document down, and everything it still had to do, closing the
// tab among it, goes with it.
function handOver(address) {
  const frame = document.createElement("iframe");
  frame.hidden = true;
  frame.src = address;
  document.body.appendChild(frame);
}

// A tab opened for the link has nothing behind it and is closed;
// one the link was followed in has the page it came from, which
// is where the reader expects to be left.
function stepAside() {
  if (window.history.length > 1) {
    window.history.back();
    return;
  }
  window.close();
}

if (target) {
  handOver(target);
  setTimeout(stepAside, CLEAR_DELAY_MS);
}
