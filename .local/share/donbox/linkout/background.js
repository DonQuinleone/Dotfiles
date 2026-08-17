const KEPT_HOSTS = [
  "mail.google.com",
  "calendar.google.com",
  "accounts.google.com",
  "accounts.youtube.com",
  "contacts.google.com",
  "drive.google.com",
  "docs.google.com",
];

// Google signs in and serves the mail through a wider set of hosts
// than the two the pad is pointed at, and a session that loses any
// of them mid-flow fails with no way back.
const KEPT_SUFFIXES = [
  ".google.com",
  ".googleusercontent.com",
  ".gstatic.com",
];

const SCHEME = "donbox";

function stays(url) {
  let host;
  try {
    host = new URL(url).hostname;
  } catch (error) {
    return true;
  }
  if (KEPT_HOSTS.includes(host)) {
    return true;
  }
  return KEPT_SUFFIXES.some((suffix) => host.endsWith(suffix));
}

// A tab cannot be sent straight to an external scheme by the
// extension, so the handoff is made from a page of our own, where
// it counts as the page navigating itself.
function handoffUrl(url) {
  const target = `${SCHEME}:${url}`;
  return browser.runtime.getURL(
    `handoff.html#${encodeURIComponent(target)}`,
  );
}

const CLEAR_DELAY_MS = 3000;

// Cleared from here rather than by the page itself, which cannot
// outlive the tab it is closing. A tab the link was followed in
// goes back to the page it came from; one opened for the link
// has nothing behind it, refuses to go back, and is closed.
function clearTab(tabId) {
  setTimeout(() => {
    browser.tabs.goBack(tabId).catch(() => {
      browser.tabs.remove(tabId).catch(() => {});
    });
  }, CLEAR_DELAY_MS);
}

// Redirected rather than cancelled and then steered: a tab told
// where to go while the navigation it is answering for is still
// being cancelled ignores the instruction, and the tab is left
// showing the failure instead of the handoff.
browser.webRequest.onBeforeRequest.addListener(
  (details) => {
    if (details.tabId < 0 || stays(details.url)) {
      return {};
    }
    clearTab(details.tabId);
    return { redirectUrl: handoffUrl(details.url) };
  },
  { urls: ["http://*/*", "https://*/*"], types: ["main_frame"] },
  ["blocking"],
);
