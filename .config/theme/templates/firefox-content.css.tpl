/* idiom: symlink. Every Firefox profile's chrome/theme-content.css
 * is a link to current/theme/firefox-content.css, imported by
 * userContent.css: it styles the page rather than the chrome. */
::selection {
    background-color: {{ accent }} !important;
    color: {{ background }} !important;
}
