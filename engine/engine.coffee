"use strict"
log = require("winston")
OceanManager = require("./ocean-manager").OceanManager
exports.engine = engine = (io) ->
  log.info "Starting engine"
  om = new OceanManager(io)
  io.sockets.on "connection", (socket) ->
    clientOId = undefined
    clientPId = undefined
    socket.on "enterOcean", (mwId, pId) ->
      clientPId = pId
      clientOId = om.assignFisherToOcean(mwId, pId, enteredOcean)
      return

    enteredOcean = (newOId) ->
      myOId = newOId
      myPId = clientPId
      socket.join myOId
      socket.emit "ocean", om.oceans[myOId].getParams()
      socket.on "readRules", ->
        om.oceans[myOId].readRules myPId
        io.sockets.in(myOId).emit "aFisherIsReady", myPId
        return

      socket.on "attemptToFish", ->
        om.oceans[myOId].attemptToFish myPId
        return

      socket.on "goToSea", ->
        om.oceans[myOId].goToSea myPId
        return

      socket.on "return", ->
        om.oceans[myOId].returnToPort myPId
        return

      socket.on "requestPause", ->
        om.oceans[myOId].pause myPId
        return

      socket.on "requestResume", ->
        om.oceans[myOId].resume myPId
        return

      socket.on "disconnect", ->
        om.removeFisherFromOcean myOId, myPId
        return

      return

    return

  return
