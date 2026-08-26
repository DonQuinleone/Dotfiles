QWidget {
	background-color: {{ background }};
	color: {{ foreground }};
	selection-background-color: {{ accent }};
	selection-color: {{ background }};
}

QMainWindow, QDialog, QFrame {
	background-color: {{ background }};
}

QWidget:disabled {
	color: {{ mix dark_foreground background 45% }};
}

QMenuBar {
	background-color: {{ background }};
	border-bottom: 1px solid {{ muted }};
}

QMenuBar::item {
	background: transparent;
	padding: 4px 10px;
}

QMenuBar::item:selected {
	background-color: {{ lighter_background }};
	color: {{ foreground }};
}

QMenuBar::item:pressed {
	background-color: {{ accent }};
	color: {{ background }};
}

QMenu {
	background-color: {{ dark_background }};
	border: 1px solid {{ muted }};
	padding: 4px;
}

QMenu::item {
	padding: 5px 24px 5px 24px;
	background: transparent;
}

QMenu::item:selected {
	background-color: {{ accent }};
	color: {{ background }};
}

QMenu::item:disabled {
	color: {{ mix dark_foreground background 45% }};
}

QMenu::separator {
	height: 1px;
	background-color: {{ muted }};
	margin: 4px 8px;
}

QToolBar {
	background-color: {{ background }};
	border: none;
	spacing: 2px;
	padding: 2px;
}

QToolBar::separator {
	width: 1px;
	background-color: {{ muted }};
	margin: 4px 4px;
}

QToolButton {
	background: transparent;
	border: 1px solid transparent;
	border-radius: 4px;
	padding: 3px;
}

QToolButton:hover {
	background-color: {{ lighter_background }};
	border: 1px solid {{ mix muted foreground 25% }};
}

QToolButton:pressed, QToolButton:checked {
	background-color: {{ accent }};
	border: 1px solid {{ accent }};
}

QPushButton {
	background-color: {{ lighter_background }};
	border: 1px solid {{ mix muted foreground 25% }};
	border-radius: 4px;
	padding: 5px 14px;
	min-height: 16px;
}

QPushButton:hover {
	background-color: {{ mix muted foreground 25% }};
	border-color: {{ mix dark_foreground background 45% }};
}

QPushButton:pressed {
	background-color: {{ mix dark_foreground background 45% }};
}

QPushButton:default {
	background-color: {{ accent }};
	border-color: {{ accent }};
	color: {{ background }};
	font-weight: bold;
}

QPushButton:default:hover {
	background-color: {{ mix accent background 15% }};
	border-color: {{ mix accent background 15% }};
}

QPushButton:default:pressed {
	background-color: {{ mix accent background 55% }};
}

QPushButton:disabled {
	background-color: {{ lighter_background }};
	border-color: {{ muted }};
	color: {{ mix dark_foreground background 45% }};
}

QLineEdit, QTextEdit, QPlainTextEdit, QSpinBox, QDoubleSpinBox {
	background-color: {{ dark_background }};
	border: 1px solid {{ muted }};
	border-radius: 4px;
	padding: 4px;
	color: {{ foreground }};
	selection-background-color: {{ accent }};
	selection-color: {{ background }};
}

QLineEdit:focus, QTextEdit:focus, QPlainTextEdit:focus,
QSpinBox:focus, QDoubleSpinBox:focus {
	border: 1px solid {{ accent }};
}

QLineEdit:disabled, QTextEdit:disabled, QPlainTextEdit:disabled {
	background-color: {{ dark_background }};
	color: {{ mix dark_foreground background 45% }};
}

QComboBox {
	background-color: {{ lighter_background }};
	border: 1px solid {{ mix muted foreground 25% }};
	border-radius: 4px;
	padding: 4px 8px;
	min-height: 18px;
}

QComboBox:hover {
	background-color: {{ mix muted foreground 25% }};
}

QComboBox:focus {
	border: 1px solid {{ accent }};
}

QComboBox::drop-down {
	subcontrol-origin: padding;
	subcontrol-position: center right;
	width: 18px;
	border-left: 1px solid {{ mix muted foreground 25% }};
}

QComboBox QAbstractItemView {
	background-color: {{ dark_background }};
	border: 1px solid {{ muted }};
	selection-background-color: {{ accent }};
	selection-color: {{ background }};
	outline: none;
}

QTreeView, QTableView, QListView, QListWidget, QTreeWidget,
QTableWidget {
	background-color: {{ background }};
	alternate-background-color: {{ dark_background }};
	border: 1px solid {{ muted }};
	outline: none;
}

QTreeView::item, QTableView::item, QListView::item {
	padding: 2px;
	border: none;
}

QTreeView::item:hover, QTableView::item:hover,
QListView::item:hover {
	background-color: {{ lighter_background }};
}

QTreeView::item:selected, QTableView::item:selected,
QListView::item:selected {
	background-color: {{ accent }};
	color: {{ background }};
}

QTreeView#ServerTreeView {
	background-color: {{ background }};
	alternate-background-color: transparent;
	border: none;
}

QHeaderView::section {
	background-color: {{ dark_background }};
	color: {{ foreground }};
	border: none;
	border-right: 1px solid {{ muted }};
	border-bottom: 1px solid {{ muted }};
	padding: 4px 6px;
}

QHeaderView::section:hover {
	background-color: {{ lighter_background }};
}

QTabWidget::pane {
	border: 1px solid {{ muted }};
	background-color: {{ background }};
	top: -1px;
}

QTabBar::tab, ImprovedTabBar::tab {
	background-color: {{ dark_background }};
	color: {{ dark_foreground }};
	border: 1px solid {{ muted }};
	border-bottom: none;
	border-top-left-radius: 4px;
	border-top-right-radius: 4px;
	padding: 6px 12px;
	margin-right: 2px;
}

QTabBar::tab:hover, ImprovedTabBar::tab:hover {
	background-color: {{ lighter_background }};
	color: {{ foreground }};
}

QTabBar::tab:selected, ImprovedTabBar::tab:selected {
	background-color: {{ background }};
	color: {{ accent }};
	border-bottom: 2px solid {{ accent }};
}

QScrollBar:vertical {
	background-color: {{ background }};
	width: 12px;
	margin: 0px;
	border: none;
}

QScrollBar::handle:vertical {
	background-color: {{ muted }};
	border-radius: 5px;
	min-height: 24px;
	margin: 2px;
}

QScrollBar::handle:vertical:hover {
	background-color: {{ mix muted foreground 25% }};
}

QScrollBar:horizontal {
	background-color: {{ background }};
	height: 12px;
	margin: 0px;
	border: none;
}

QScrollBar::handle:horizontal {
	background-color: {{ muted }};
	border-radius: 5px;
	min-width: 24px;
	margin: 2px;
}

QScrollBar::handle:horizontal:hover {
	background-color: {{ mix muted foreground 25% }};
}

QScrollBar::add-line, QScrollBar::sub-line {
	height: 0px;
	width: 0px;
	border: none;
	background: none;
}

QScrollBar::add-page, QScrollBar::sub-page {
	background: none;
}

QGroupBox {
	border: 1px solid {{ muted }};
	border-radius: 4px;
	margin-top: 10px;
	padding-top: 8px;
	font-weight: bold;
}

QGroupBox::title {
	subcontrol-origin: margin;
	subcontrol-position: top left;
	left: 10px;
	padding: 0px 4px;
	color: {{ accent }};
}

QCheckBox, QRadioButton {
	spacing: 6px;
	background: transparent;
}

QCheckBox::indicator, QRadioButton::indicator {
	width: 15px;
	height: 15px;
	border: 1px solid {{ mix dark_foreground background 45% }};
	background-color: {{ dark_background }};
}

QCheckBox::indicator {
	border-radius: 3px;
}

QRadioButton::indicator {
	border-radius: 8px;
}

QCheckBox::indicator:hover, QRadioButton::indicator:hover {
	border-color: {{ accent }};
}

QCheckBox::indicator:checked, QRadioButton::indicator:checked {
	background-color: {{ accent }};
	border-color: {{ accent }};
}

QStatusBar {
	background-color: {{ background }};
	border-top: 1px solid {{ muted }};
	color: {{ dark_foreground }};
}

QStatusBar QLabel {
	padding: 0px 3px;
	border: 0px;
	background: transparent;
}

QToolTip {
	background-color: {{ dark_background }};
	color: {{ foreground }};
	border: 1px solid {{ accent }};
	padding: 4px;
}

QProgressBar {
	background-color: {{ dark_background }};
	border: 1px solid {{ muted }};
	border-radius: 4px;
	text-align: center;
	color: {{ foreground }};
}

QProgressBar::chunk {
	background-color: {{ accent }};
	border-radius: 3px;
}

QSlider::groove:horizontal {
	background-color: {{ lighter_background }};
	height: 4px;
	border-radius: 2px;
}

QSlider::sub-page:horizontal {
	background-color: {{ accent }};
	border-radius: 2px;
}

QSlider::handle:horizontal {
	background-color: {{ foreground }};
	width: 14px;
	height: 14px;
	margin: -6px 0px;
	border-radius: 7px;
}

QSlider::handle:horizontal:hover {
	background-color: {{ accent }};
}

QSplitter::handle {
	background-color: {{ muted }};
}

QSplitter::handle:hover {
	background-color: {{ accent }};
}

QTextEdit#InfoFrame, QTextEdit#ChatTab {
	background-color: {{ background }};
	background-image: none;
	border: 1px solid {{ muted }};
}

QTextEdit#ChatLineEdit[helpTextVisible="true"] {
	color: {{ dark_foreground }};
}

QLabel#OptionsHeadlineTitleLabel {
	font: 18px 'TeamSpeak 2020';
	color: {{ accent }};
	background: transparent;
}

QLabel#OptionsHeadlineDescriptionLabel {
	color: {{ dark_foreground }};
	background: transparent;
}

QLabel#appNameLabel {
	color: {{ accent }};
	text-transform: lowercase;
	font: 32px 'TeamSpeak 2020';
	font-weight: bold;
	background: transparent;
}

QWidget#HeadlineLabel {
	background-color: {{ dark_background }};
	border-bottom: 1px solid {{ muted }};
}

QLabel#bookmarksBanner, QLabel#identitiesBanner,
QLabel#accountLoginBanner, QLabel#accountCreateBanner {
	background: {{ dark_background }};
	border-left: 3px solid {{ accent }};
	color: {{ foreground }};
	padding-left: 6px;
	font-weight: bold;
	qproperty-minimumSize: 0px 32px;
}

QListWidget#localIconsListWidget::item:selected,
QListWidget#remoteIconsListWidget::item:selected {
	border: 1px solid {{ accent }};
}

com--teamspeak--ui--ServerIntegrationsWidget
QWidget#ExistingServerIntegration,
com--teamspeak--ui--ServerIntegrationsWidget
QWidget#AvailableServerIntegration {
	background: {{ dark_background }};
}

com--teamspeak--ui--ServerIntegrationsWidget
com--teamspeak--ui--IntegrationResponseWidget {
	background: {{ background }};
	border: 1px solid {{ muted }};
	border-radius: 2px;
}

com--teamspeak--ui--ServerIntegrationsWidget
com--teamspeak--ui--IntegrationBubble {
	background: {{ dark_background }};
	border: 1px solid {{ muted }};
	border-radius: 2px;
}

com--teamspeak--ui--IntegrationBubbleEditable
QComboBox#IntegrationBubbleEditableComboBox {
	border: 2px groove {{ accent }};
	background: {{ dark_background }};
	padding: 0px 9px 1px 9px;
}
