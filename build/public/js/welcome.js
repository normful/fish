var Main, lang, loadLabels, messages, socket, validateGroup;

loadLabels = function() {
  $("#welcome").text(messages.login_welcome);
  $("#instructions").text(messages.login_instructions);
  $("#gid_label").text(messages.login_simulationName + " ");
  $("#pid_label").text(messages.login_participantId + " ");
  $("#login").text(messages.login_getStarted);
};

"use strict";

socket = io.connect();

lang = $.url().param("lang");

messages = void 0;

if (lang && lang !== "" && lang.toLowerCase() in langs) {
  messages = langs[lang.toLowerCase()];
} else {
  messages = langs.en;
  lang = "en";
}

socket.on("connect", function() {
  console.log("Connected to Fish server.");
});

socket.on("valid-group", function() {
  location.href = "main.html?gid=" + $("#gid").val() + "&pid=" + $("#pid").val() + "&lang=" + lang;
});

socket.on("invalid-group", function() {
  $("#login").prop("disabled", false);
  $(".status-message").toggleClass("red").text(messages.login_invalidGroup);
});

validateGroup = function() {
  var gid;
  gid = $("#gid").val();
  $("#login").prop("disabled", true);
  $(".status-message").text(messages.login_validating);
  socket.emit("validate group", gid);
};

Main = function() {
  document.title = messages.login_title;
  loadLabels();
  $("#login").click(validateGroup);
};

$(document).ready(Main);
