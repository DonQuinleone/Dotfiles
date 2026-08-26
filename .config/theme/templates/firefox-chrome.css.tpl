/* idiom: symlink. Every Firefox profile's chrome/theme.css is a
 * link to current/theme/firefox-chrome.css, imported by
 * userChrome.css at launch and re-registered while the browser
 * runs by the loader donbox theme firefox install puts in
 * place. */
:root {
    color-scheme: {{ mode }} !important;

    --background-color-canvas: {{ background }} !important;
    --background-color-box: {{ dark_background }} !important;
    --text-color: {{ foreground }} !important;
    --text-color-deemphasized: {{ dark_foreground }} !important;
    --border-color: {{ muted }} !important;
    --border-color-deemphasized: {{ muted }} !important;
    --border-color-interactive:
        {{ mix muted foreground 25% }} !important;
    --border-color-selected: {{ accent }} !important;
    --focus-outline-color: {{ accent }} !important;

    --color-accent-primary: {{ accent }} !important;
    --color-accent-primary-hover:
        {{ mix accent background 25% }} !important;
    --color-accent-primary-active:
        {{ mix accent background 55% }} !important;
    --color-accent-primary-selected: {{ accent }} !important;
    --color-accent-attention: {{ accent }} !important;
    --text-color-accent-primary-selected: {{ background }} !important;
    --button-text-color-primary: {{ background }} !important;
    --table-header-text-color: {{ background }} !important;

    --link-color: {{ accent }} !important;
    --link-color-hover: {{ mix accent background 25% }} !important;
    --link-color-active: {{ mix accent background 55% }} !important;

    --input-text-background-color: {{ lighter_background }} !important;
    --input-text-color: {{ foreground }} !important;

    --toolbox-background-color: {{ background }} !important;
    --toolbox-background-color-inactive: {{ background }} !important;
    --toolbox-text-color: {{ foreground }} !important;
    --toolbox-text-color-inactive: {{ dark_foreground }} !important;

    --toolbar-background-color: {{ dark_background }} !important;
    --toolbar-text-color: {{ foreground }} !important;
    --toolbarbutton-icon-fill: {{ foreground }} !important;
    --toolbarbutton-icon-fill-attention: {{ accent }} !important;
    --toolbarbutton-icon-fill-attention-text:
        {{ background }} !important;

    --tab-background-color-selected: {{ dark_background }} !important;
    --tab-attention-dot-color: {{ accent }} !important;
    --tab-selected-outline-color: {{ accent }} !important;
    --tabs-navbar-separator-color: {{ muted }} !important;
    --chrome-content-separator-color: {{ muted }} !important;
    --lwt-tab-line-color: {{ accent }} !important;

    --toolbar-field-background-color:
        {{ lighter_background }} !important;
    --toolbar-field-text-color: {{ foreground }} !important;
    --toolbar-field-border-color: {{ muted }} !important;
    --toolbar-field-background-color-focus: {{ background }} !important;
    --toolbar-field-text-color-focus: {{ foreground }} !important;
    --toolbar-field-border-color-focus: {{ accent }} !important;
    --toolbar-field-focus-color: {{ foreground }} !important;
    --lwt-toolbar-field-highlight: {{ accent }} !important;
    --lwt-toolbar-field-highlight-text: {{ background }} !important;

    --urlbarview-background-color-selected: {{ accent }} !important;
    --urlbarview-text-color-selected: {{ background }} !important;
    --urlbarview-background-color-hover:
        {{ lighter_background }} !important;
    --urlbarview-text-color-action: {{ accent }} !important;
    --urlbarview-separator-color: {{ muted }} !important;
    --urlbarView-separator-color: {{ muted }} !important;
    --urlbarView-secondary-text-color: {{ dark_foreground }} !important;

    --panel-background-color: {{ dark_background }} !important;
    --panel-text-color: {{ foreground }} !important;
    --panel-border-color: {{ muted }} !important;
    --panel-separator-color: {{ muted }} !important;

    --sidebar-background-color: {{ dark_background }} !important;
    --sidebar-text-color: {{ foreground }} !important;
    --sidebar-border-color: {{ muted }} !important;
    --lwt-sidebar-highlight-background-color: {{ accent }} !important;
    --lwt-sidebar-highlight-text-color: {{ background }} !important;
}

panel,
menupopup {
    color-scheme: {{ mode }} !important;
    --panel-background-color: {{ dark_background }} !important;
    --panel-text-color: {{ foreground }} !important;
    --panel-border-color: {{ muted }} !important;
}

menupopup > menuitem[_moz-menuactive]:not([disabled]),
menupopup > menu[_moz-menuactive]:not([disabled]) {
    background-color: {{ accent }} !important;
    color: {{ background }} !important;
}

#urlbar-input::selection,
#urlbar-input:focus::selection,
.searchbar-textbox input::selection {
    background-color: {{ accent }} !important;
    color: {{ background }} !important;
}

/* Firefox draws its own close, minimise and maximise into the
   tab strip, which the compositor already answers for from the
   keyboard. */
.titlebar-buttonbox-container,
.titlebar-spacer[type="post-tabs"] {
    display: none !important;
}
