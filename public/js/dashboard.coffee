"use strict"

#global document:true, location:true, $:true, alert:true, moment:true
df = "YYYY-MM-DD"
lastMwRes = null
microworldsSuccess = (mws) ->
  return  if _.isEqual(lastMwRes, mws)
  lastMwRes = mws
  anyTest = false
  anyActive = false
  anyArchived = false
  testTable = ""
  activeTable = ""
  archivedTable = ""
  for i of mws
    if mws[i].status is "test"
      anyTest = true
      testTable += "<tr onclick=\"location.href='./microworlds/" + mws[i]._id + "'\"><td>" + mws[i].name + "</td>" + "<td>" + mws[i].code + "</td>" + "<td>" + mws[i].desc + "</td></tr>"
    if mws[i].status is "active"
      anyActive = true
      activeTable += "<tr onclick=\"location.href='./microworlds/" + mws[i]._id + "'\"><td>" + mws[i].name + "</td>" + "<td>" + mws[i].code + "</td>" + "<td>" + mws[i].desc + "</td>" + "<td>" + moment(mws[i].dateActive).format(df) + "</td>" + "<td>" + mws[i].numCompleted + "</td>" + "<td>" + mws[i].numAborted + "</td></tr>"
    if mws[i].status is "archived"
      anyArchived = true
      archivedTable += "<tr onclick=\"location.href='./microworlds/" + mws[i]._id + "'\"><td>" + mws[i].name + "</td>" + "<td>" + mws[i].code + "</td>" + "<td>" + mws[i].desc + "</td>" + "<td>" + moment(mws[i].dateActive).format(df) + "</td>" + "<td>" + mws[i].numCompleted + "</td>" + "<td>" + mws[i].numAborted + "</td></tr>"
  $("#microworlds-test-loading").addClass "collapse"
  if anyTest
    $("#microworlds-test-none").addClass "collapse"
    $("#microworlds-test-table-rows").html testTable
    $("#microworlds-test-table").removeClass "collapse"
  else
    $("#microworlds-test-none").removeClass "collapse"
    $("#microworlds-test-table").addClass "collapse"
  $("#microworlds-active-loading").addClass "collapse"
  if anyActive
    $("#microworlds-active-none").addClass "collapse"
    $("#microworlds-active-table-rows").html activeTable
    $("#microworlds-active-table").removeClass "collapse"
  else
    $("#microworlds-active-none").removeClass "collapse"
    $("#microworlds-active-table").addClass "collapse"
  $("#microworlds-archived-loading").addClass "collapse"
  if anyArchived
    $("#microworlds-archived-none").addClass "collapse"
    $("#microworlds-archived-table-rows").html archivedTable
    $("#microworlds-archived-table").removeClass "collapse"
  else
    $("#microworlds-archived-none").removeClass "collapse"
    $("#microworlds-archived-table").addClass "collapse"
  return

microworldsError = (jqXHR) ->
  errors = JSON.parse(jqXHR.responseText).errors
  alert errors
  return

getMicroworlds = ->
  $.ajax
    type: "GET"
    url: "/microworlds"
    error: microworldsError
    success: microworldsSuccess

  setTimeout getMicroworlds, 60000
  return

overrideSubmit = ->
  false

main = ->
  $("form").submit overrideSubmit
  getMicroworlds()
  return

$(document).ready main
