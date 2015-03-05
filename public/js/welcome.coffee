
#global document:true, location:true, io:true, console:true, $:true, 
#langs:true 

# Go to main window
loadLabels = ->
  $("#welcome").text messages.login_welcome
  $("#instructions").text messages.login_instructions
  $("#gid_label").text messages.login_simulationName + " "
  $("#pid_label").text messages.login_participantId + " "
  $("#login").text messages.login_getStarted
  return
"use strict"
socket = io.connect()
lang = $.url().param("lang")
messages = undefined
if lang and lang isnt "" and lang.toLowerCase() of langs
  messages = langs[lang.toLowerCase()]
else
  messages = langs.en
  lang = "en"
socket.on "connect", ->
  console.log "Connected to Fish server."
  return

socket.on "valid-group", ->
  location.href = "main.html?gid=" + $("#gid").val() + "&pid=" + $("#pid").val() + "&lang=" + lang
  return

socket.on "invalid-group", ->
  $("#login").prop "disabled", false
  $(".status-message").toggleClass("red").text messages.login_invalidGroup
  return

validateGroup = ->
  gid = $("#gid").val()
  $("#login").prop "disabled", true
  $(".status-message").text messages.login_validating
  socket.emit "validate group", gid
  return

Main = ->
  document.title = messages.login_title
  loadLabels()
  $("#login").click validateGroup
  return

$(document).ready Main
