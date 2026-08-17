const target = decodeURIComponent(window.location.hash.slice(1));

if (target) {
  window.location.replace(target);
  // The tab is left behind once the browser hands the scheme over,
  // and a tab showing this page is not something to keep.
  setTimeout(() => {
    browser.tabs.getCurrent().then((tab) => {
      if (tab) {
        browser.tabs.remove(tab.id);
      }
    });
  }, 1000);
}
