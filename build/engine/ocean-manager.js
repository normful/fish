"use strict";
var Microworld, Ocean, OceanManager, log;

log = require("winston");

Microworld = require("../models/microworld-model").Microworld;

Ocean = require("./ocean").Ocean;

exports.OceanManager = OceanManager = function(io) {
  this.oceans = {};
  this.io = io;
  this.createOcean = function(mwId, cb) {
    var onFound;
    Microworld.findOne({
      _id: mwId
    }, (onFound = function(err, mw) {
      var ocean;
      ocean = new Ocean(mw, this.io);
      this.oceans[ocean.id] = ocean;
      ocean.log.info("Ocean created.");
      ocean.runOcean();
      return cb(null, ocean.id);
    }).bind(this));
  };
  this.deleteOcean = function(oId) {
    delete this.oceans[oId];
  };
  this.assignFisherToOcean = function(mwId, pId, cb) {
    var i, oId, oKeys, onCreated;
    oKeys = Object.keys(this.oceans);
    oId = null;
    for (i in oKeys) {
      oId = oKeys[i];
      if (this.oceans[oId].microworld._id.toString() === mwId && this.oceans[oId].hasRoom()) {
        this.oceans[oId].addFisher(pId);
        return cb(oId);
      }
    }
    this.createOcean(mwId, (onCreated = function(err, oId) {
      this.oceans[oId].addFisher(pId);
      return cb(oId);
    }).bind(this));
  };
  this.removeFisherFromOcean = function(oId, pId) {
    this.oceans[oId].removeFisher(pId);
  };
  this.purgeOceans = function() {
    var i, oId, oKeys;
    oKeys = Object.keys(this.oceans);
    oId = void 0;
    for (i in oKeys) {
      oId = oKeys[i];
      if (this.oceans[oId].isRemovable()) {
        log.info("Purging ocean " + this.oceans[oId].microworld.name + " " + oId + " (" + this.oceans[oId].microworld.experimenter.username + ")");
        this.deleteOcean(oId);
      }
    }
    setTimeout(this.purgeOceans.bind(this), 5000);
  };
  this.purgeOceans();
};
