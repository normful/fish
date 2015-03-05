
# TODO - I don't think I'll be using uid anymore, but account/:accountId

# Go back to mainadmin window
Robot = (name, greed) ->
  @name = name
  @greed = greed
  return
gameParameters = ->
  
  # Getting all the parameters from the page's fields
  @owner = user
  @name = $("#gid").val()
  @numFishers = parseInt($("#numfishers").val())
  @numHumans = parseInt($("#numhumans").val())
  @numOceans = parseInt($("#numoceans").val())
  @numSeasons = parseInt($("#seasons").val())
  @initialDelay = parseInt($("#initialdelay").val())
  @restDuration = parseInt($("#seasondelay").val())
  @spawnFactor = parseFloat($("#spawnfactor").val())
  @chanceOfCatch = parseFloat($("#chancecatch").val())
  @costDepart = parseFloat($("#costdeparture").val())
  @costAtSea = parseFloat($("#costsecond").val())
  @costCast = parseFloat($("#costcast").val())
  @valueFish = parseFloat($("#fishvalue").val())
  @currencySymbol = $("#currencysymbol").val()
  @seasonDuration = parseInt($("#seasonduration").val())
  @certainFish = parseInt($("#realfish").val())
  @maximumFish = parseInt($("#maxfish").val())
  @actualMysteryFish = parseInt($("#startingmysteryfish").val())
  @mysteryFish = parseInt($("#mysteryfish").val())
  @showOtherFishers = $("#showallfishers-yes").prop("checked")
  @showFisherNames = $("#shownames-yes").prop("checked")
  @showFisherStatus = $("#showstatus-yes").prop("checked")
  @showFishCaught = $("#shownumcaught-yes").prop("checked")
  @showBalance = $("#showbalance-yes").prop("checked")
  @pauseEnabled = $("#pauseenabled-yes").prop("checked")
  @earlyEndEnabled = $("#earlyendenabled-yes").prop("checked")
  if $("#greeduniformity-uniform").prop("checked")
    @greedUniformity = 0
  else if $("#greeduniformity-increasing").prop("checked")
    @greedUniformity = 1
  else
    @greedUniformity = -1
  @erratic = $("#erratic-yes").prop("checked")
  @hesitation = parseFloat($("#hesitation").val())
  @castsPerSecond = parseInt($("#castspersecond").val())
  @castingProbability = parseFloat($("#castingprobability").val())
  @robots = new Array()
  @robots[0] = new Robot($("#agent1name").val(), parseFloat($("#agent1greed").val()))
  @robots[1] = new Robot($("#agent2name").val(), parseFloat($("#agent2greed").val()))
  @robots[2] = new Robot($("#agent3name").val(), parseFloat($("#agent3greed").val()))
  @robots[3] = new Robot($("#agent4name").val(), parseFloat($("#agent4greed").val()))
  @robots[4] = new Robot($("#agent5name").val(), parseFloat($("#agent5greed").val()))
  @robots[5] = new Robot($("#agent6name").val(), parseFloat($("#agent6greed").val()))
  @robots[6] = new Robot($("#agent7name").val(), parseFloat($("#agent7greed").val()))
  @robots[7] = new Robot($("#agent8name").val(), parseFloat($("#agent8greed").val()))
  @robots[8] = new Robot($("#agent9name").val(), parseFloat($("#agent9greed").val()))
  @robots[9] = new Robot($("#agent10name").val(), parseFloat($("#agent10greed").val()))
  @robots[10] = new Robot($("#agent11name").val(), parseFloat($("#agent11greed").val()))
  @robots[11] = new Robot($("#agent12name").val(), parseFloat($("#agent12greed").val()))
  @prepText = $("#preptext").val()
  @depletedText = $("#depletedtext").val()
  @endText = $("#endtext").val()
  return
validateParameters = ->
  invalidMessage = ""
  invalidMessage += "The simulation name cannot contain spaces.\n"  if $("#gid").val().indexOf(" ") >= 0
  invalidMessage += "The simulation name cannot be empty.\n"  if $("#gid").val().length < 1
  invalidMessage += "The number of fishers per ocean must be between 1 and 13.\n"  if parseInt($("#numfishers").val()) > 13 or parseInt($("#numfishers").val()) < 1
  invalidMessage += "The number of humans per ocean must be at least 1 and at most equal to the total number of fishers.\n"  if parseInt($("#numhumans").val()) > parseInt($("#numfishers").val()) or parseInt($("#numfishers").val()) < 1
  invalidMessage
socket = io.connect()
user = $.url().param("uid")
socket.on "connect", (data) ->
  console.log "Connected to server."
  return

socket.on "group-created", ->
  location.href = "mainadmin?uid=" + user
  return

socket.on "group-not-created", ->
  $("#create").prop "disabled", false
  $(".status-message").toggleClass "red"
  $(".status-message").text "The simulation '" + $("#gid").val() + "' could not be created. That name may already be in use; please use a different one."
  return

CreateGroup = ->
  invalidMessage = validateParameters()
  if invalidMessage is ""
    gs = new gameParameters()
    $("#create").prop "disabled", true
    $(".status-message").toggleClass "blue"
    $(".status-message").text "Requesting server to create simulation " + $("#gid").val() + "..."
    console.log "Requesting server to create group " + $("#gid").val()
    socket.emit "create group", gs
  else
    alert invalidMessage
  return

ToggleGreed = ->
  
  # Enabling and disabling global and particular greed parameters
  constantGreed = $("#globalgreed-constant").prop("checked")
  $("#globalconstantgreed").prop "disabled", not constantGreed
  $(".agentgreed").prop "disabled", constantGreed
  $(".agentgreed").val $("#globalconstantgreed").val()  if constantGreed
  return

Main = ->
  $(".greedtoggler").change ToggleGreed
  $("#create").click CreateGroup
  return

$(document).ready Main
