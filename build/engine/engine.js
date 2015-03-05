"use strict";
var OceanManager, engine, log;

log = require("winston");

OceanManager = require("./ocean-manager").OceanManager;

exports.engine = engine = function(io) {
  var om;
  log.info("Starting engine");
  om = new OceanManager(io);
  io.sockets.on("connection", function(socket) {
    var clientOId, clientPId, enteredOcean;
    clientOId = void 0;
    clientPId = void 0;
    socket.on("enterOcean", function(mwId, pId) {
      clientPId = pId;
      clientOId = om.assignFisherToOcean(mwId, pId, enteredOcean);
    });
    enteredOcean = function(newOId) {
      var myOId, myPId;
      myOId = newOId;
      myPId = clientPId;
      socket.join(myOId);
      socket.emit("ocean", om.oceans[myOId].getParams());
      socket.on("readRules", function() {
        om.oceans[myOId].readRules(myPId);
        io.sockets["in"](myOId).emit("aFisherIsReady", myPId);
      });
      socket.on("attemptToFish", function() {
        om.oceans[myOId].attemptToFish(myPId);
      });
      socket.on("goToSea", function() {
        om.oceans[myOId].goToSea(myPId);
      });
      socket.on("return", function() {
        om.oceans[myOId].returnToPort(myPId);
      });
      socket.on("requestPause", function() {
        om.oceans[myOId].pause(myPId);
      });
      socket.on("requestResume", function() {
        om.oceans[myOId].resume(myPId);
      });
      socket.on("disconnect", function() {
        om.removeFisherFromOcean(myOId, myPId);
      });
    };
  });
};
