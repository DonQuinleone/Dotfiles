/* idiom: symlink. The chat half of the style named "current" is
 * a link to current/theme/teamspeak-chat.qss, which TeamSpeak
 * reads for the message log and the info frame. */
p {
  padding: 0px;
  margin: 0px;
}

.TextMessage_UserLink {
  color: {{ accent }};
  font-weight: bold;
  text-decoration: none;
}

.TextMessage_OfflineLink,
.TextMessage_ChannelLink,
.TextMessage_ServerLink {
  color: {{ mix accent background 25% }};
  font-weight: bold;
  text-decoration: none;
}

.TextMessage_HostName {
  color: {{ accent }};
  font-weight: bold;
}

.TextMessage_Welcome,
.TextMessage_HostMessage,
.TextMessage_Poke {
  color: {{ green }};
}

.TextMessage_Normal,
.TextMessage_Connected,
.TextMessage_ClientConnected,
.TextMessage_ClientJoined {
  color: {{ dark_foreground }};
}

.TextMessage_Disconnected,
.TextMessage_ClientDisconnected,
.TextMessage_ClientSwitched,
.TextMessage_ClientLeft {
  color: {{ mix dark_foreground background 45% }};
}

.TextMessage_ClientDropped,
.TextMessage_ClientKicked,
.TextMessage_ClientBanned {
  color: {{ red }};
}

.TextMessage_ChannelCreated,
.TextMessage_ChannelDeleted,
.TextMessage_ChannelEdited,
.TextMessage_ChannelMoved,
.TextMessage_ServerEdited {
  color: {{ dark_foreground }};
}

.TextMessage_GroupAssigned,
.TextMessage_GroupRevoked,
.TextMessage_TalkPowerAssigned,
.TextMessage_TalkPowerRevoked,
.TextMessage_TalkPowerRequested {
  color: {{ yellow }};
}

.TextMessage_Text {
  color: {{ foreground }};
}

.TextMessage_Time {
  color: {{ dark_foreground }};
  font-weight: normal;
}

.TextMessage_BeginHistory,
.TextMessage_EndHistory {
  color: {{ mix dark_foreground background 45% }};
  font-weight: bold;
  font-style: italic;
}

.TextMessage_ServerError {
  color: {{ red }};
  font-weight: bold;
}

.InfoFrame_Title {
  font-size: x-large;
  color: {{ foreground }};
}

.InfoFrame_Title .TextMessage_UserLink,
.InfoFrame_Title .TextMessage_ChannelLink,
.InfoFrame_Title .TextMessage_ServerLink {
  color: {{ accent }};
  font-weight: normal;
}

.InfoFrame_Title .InfoFrame_CustomNick {
  color: {{ accent }};
}

.InfoFrame_Table {
  border-collapse: collapse;
  border-spacing: 0px;
  color: {{ foreground }};
}

.InfoFrame_Table td {
  padding: 0px 4px 0px 1px;
}

.Highlight,
.InfoFrame_Table td.Highlight {
  color: {{ accent }};
}

.Important,
.InfoFrame_Table td.Important {
  color: {{ red }};
}

.Active,
.InfoFrame_Table td.Active {
  color: {{ green }};
}

.Inactive,
.InfoFrame_Table td.Inactive {
  color: {{ mix dark_foreground background 45% }};
}

.InfoFrame_Table td.Label {
  font-weight: bold;
  color: {{ dark_foreground }};
}

.InfoFrame_Table td.Bottom {
  vertical-align: bottom;
}

.InfoFrame_Table td.List {
  padding: 0px 1px 0px 8px;
}

.InfoFrame_Table td.Badge {
  padding: 5px 5px 0px 5px;
}

.InfoFrame_Table td.Space-Top {
  padding: 10px 0px 0px 0px;
}

.InfoFrame_Table td.Space-Bot {
  padding: 0px 0px 10px 0px;
}

.InfoFrame_Table.Space-Top {
  margin: 10px 0px 0px 0px;
}

.InfoFrame_Table.Space-Bot {
  margin: 0px 0px 10px 0px;
}
