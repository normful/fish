"use strict";
var Fisher;

exports.Fisher = Fisher = function(name, type, params, o) {
  this.name = name;
  this.type = type;
  this.params = params;
  this.ocean = o;
  this.ready = this.type === "bot";
  this.hasReturned = false;
  this.seasonData = [];
  this.startMoney = 0;
  this.money = 0;
  this.totalFishCaught = 0;
  this.status = "At port";
  this.season = 0;
  this.isBot = function() {
    return this.type === "bot";
  };
  this.isErratic = function() {
    return this.params.predictability === "erratic";
  };
  this.getFishCaught = function() {
    return this.seasonData[this.season].fishCaught;
  };
  this.getIntendedCasts = function() {
    return this.seasonData[this.season].intendedCasts;
  };
  this.getActualCasts = function() {
    return this.seasonData[this.season].actualCasts;
  };
  this.calculateSeasonGreed = function() {
    var baseGreed, currentGreed, greedSpread, highBound, increment, lowBound, seasons, variation;
    greedSpread = 2.0;
    baseGreed = this.params.greed;
    lowBound = void 0;
    highBound = void 0;
    if (baseGreed < 0.5) {
      lowBound = baseGreed / greedSpread;
      highBound = baseGreed + lowBound;
    } else {
      highBound = ((1.0 - baseGreed) / greedSpread) + baseGreed;
      lowBound = greedSpread * baseGreed - highBound;
    }
    currentGreed = baseGreed;
    seasons = this.ocean.microworld.params.numSeasons;
    increment = (highBound - lowBound) / (1.0 * (seasons - 1));
    if (seasons > 1) {
      if (this.params.trend === "decrease") {
        currentGreed = highBound - (increment * (this.ocean.season - 1));
      } else {
        if (this.params.trend === "increase") {
          currentGreed = lowBound + (increment * (this.ocean.season - 1));
        }
      }
    }
    if (this.params.predictability === "erratic") {
      variation = 1.0 + ((Math.random() - 0.5) / 2.0);
      currentGreed = currentGreed * variation;
    }
    return currentGreed;
  };
  this.calculateSeasonCasts = function(greed) {
    var chanceCatch, numFishers, spawn, totalFish;
    totalFish = this.ocean.certainFish + this.ocean.mysteryFish;
    spawn = this.ocean.microworld.params.spawnFactor;
    numFishers = this.ocean.fishers.length;
    chanceCatch = this.ocean.microworld.params.chanceCatch;
    return Math.round(((totalFish - (totalFish / spawn)) / numFishers) * 2 * greed / chanceCatch);
  };
  this.prepareFisherForSeason = function(season) {
    this.season = season;
    this.seasonData[season] = {
      actualCasts: 0,
      greed: (this.isBot() ? this.calculateSeasonGreed() : undefined),
      fishCaught: 0,
      startMoney: 0,
      endMoney: 0
    };
    this.seasonData[season].intendedCasts = (this.isBot() ? this.calculateSeasonCasts(this.seasonData[season].greed) : undefined);
    this.hasReturned = false;
  };
  this.changeMoney = function(amount) {
    this.money += amount;
    this.seasonData[this.season].endMoney += amount;
  };
  this.incrementCast = function() {
    this.seasonData[this.season].actualCasts++;
  };
  this.incrementFishCaught = function() {
    this.totalFishCaught++;
    this.seasonData[this.season].fishCaught++;
  };
  this.goToPort = function() {
    if (this.status !== "At port") {
      this.status = "At port";
      this.hasReturned = true;
      this.ocean.log.info("Fisher " + this.name + " returned to port.");
    }
  };
  this.goToSea = function() {
    this.status = "At sea";
    this.changeMoney(-this.ocean.microworld.params.costDeparture);
    this.ocean.log.info("Fisher " + this.name + " sailed to sea.");
  };
  this.tryToFish = function() {
    this.changeMoney(-this.ocean.microworld.params.costCast);
    this.incrementCast();
    if (this.ocean.isSuccessfulCastAttempt()) {
      this.changeMoney(this.ocean.microworld.params.fishValue);
      this.incrementFishCaught();
      this.ocean.takeOneFish();
      this.ocean.log.info("Fisher " + this.name + " caught one fish.");
    } else {
      this.ocean.log.info("Fisher " + this.name + " tried to catch " + "a fish, and failed.");
    }
  };
  this.runBot = function() {
    if (this.status === "At sea") {
      this.changeMoney(-this.ocean.microworld.params.costSecond);
    }
    if (!this.isBot()) {
      return;
    }
    if (this.isErratic() && Math.random() > this.params.probAction) {
      return;
    }
    if (this.getIntendedCasts() <= this.getActualCasts()) {
      this.goToPort();
    } else {
      if (this.status === "At port") {
        this.goToSea();
      } else {
        if (this.status === "At sea" && this.ocean.areThereFish()) {
          this.tryToFish();
        }
      }
    }
  };
};
