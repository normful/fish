"use strict"
exports.Fisher = Fisher = (name, type, params, o) ->
  @name = name
  @type = type
  @params = params
  @ocean = o
  @ready = (@type is "bot")
  @hasReturned = false
  @seasonData = []
  @startMoney = 0
  @money = 0
  @totalFishCaught = 0
  @status = "At port"
  @season = 0
  @isBot = ->
    @type is "bot"

  @isErratic = ->
    @params.predictability is "erratic"

  @getFishCaught = ->
    @seasonData[@season].fishCaught

  @getIntendedCasts = ->
    @seasonData[@season].intendedCasts

  @getActualCasts = ->
    @seasonData[@season].actualCasts

  @calculateSeasonGreed = ->
    
    # greedSpread determines how far the low and high greed bounds will
    # deviate from the mean
    greedSpread = 2.0
    baseGreed = @params.greed
    lowBound = undefined
    highBound = undefined
    if baseGreed < 0.5
      lowBound = baseGreed / greedSpread
      highBound = baseGreed + lowBound
    else
      highBound = ((1.0 - baseGreed) / greedSpread) + baseGreed
      lowBound = greedSpread * baseGreed - highBound
    currentGreed = baseGreed
    seasons = @ocean.microworld.params.numSeasons
    increment = (highBound - lowBound) / (1.0 * (seasons - 1))
    if seasons > 1
      if @params.trend is "decrease"
        currentGreed = highBound - (increment * (@ocean.season - 1))
      else currentGreed = lowBound + (increment * (@ocean.season - 1))  if @params.trend is "increase"
    if @params.predictability is "erratic"
      
      # variation between 0.75 and 1.25
      variation = 1.0 + ((Math.random() - 0.5) / 2.0)
      currentGreed = currentGreed * variation
    currentGreed

  @calculateSeasonCasts = (greed) ->
    totalFish = @ocean.certainFish + @ocean.mysteryFish
    spawn = @ocean.microworld.params.spawnFactor
    numFishers = @ocean.fishers.length
    chanceCatch = @ocean.microworld.params.chanceCatch
    Math.round ((totalFish - (totalFish / spawn)) / numFishers) * 2 * greed / chanceCatch

  @prepareFisherForSeason = (season) ->
    @season = season
    @seasonData[season] =
      actualCasts: 0
      greed: (if @isBot() then @calculateSeasonGreed() else `undefined`)
      fishCaught: 0
      startMoney: 0
      endMoney: 0

    @seasonData[season].intendedCasts = (if @isBot() then @calculateSeasonCasts(@seasonData[season].greed) else `undefined`)
    @hasReturned = false
    return

  @changeMoney = (amount) ->
    @money += amount
    @seasonData[@season].endMoney += amount
    return

  @incrementCast = ->
    @seasonData[@season].actualCasts++
    return

  @incrementFishCaught = ->
    @totalFishCaught++
    @seasonData[@season].fishCaught++
    return

  @goToPort = ->
    if @status isnt "At port"
      @status = "At port"
      @hasReturned = true
      @ocean.log.info "Fisher " + @name + " returned to port."
    return

  @goToSea = ->
    @status = "At sea"
    @changeMoney -@ocean.microworld.params.costDeparture
    @ocean.log.info "Fisher " + @name + " sailed to sea."
    return

  @tryToFish = ->
    @changeMoney -@ocean.microworld.params.costCast
    @incrementCast()
    if @ocean.isSuccessfulCastAttempt()
      @changeMoney @ocean.microworld.params.fishValue
      @incrementFishCaught()
      @ocean.takeOneFish()
      @ocean.log.info "Fisher " + @name + " caught one fish."
    else
      @ocean.log.info "Fisher " + @name + " tried to catch " + "a fish, and failed."
    return

  @runBot = ->
    @changeMoney -@ocean.microworld.params.costSecond  if @status is "At sea"
    return  unless @isBot()
    
    # Don't do anything if I'm erratic and I don't feel like it
    return  if @isErratic() and Math.random() > @params.probAction
    
    # Am I done?
    if @getIntendedCasts() <= @getActualCasts()
      @goToPort()
    else
      
      # Should I go out or try to fish?
      if @status is "At port"
        @goToSea()
      else @tryToFish()  if @status is "At sea" and @ocean.areThereFish()
    return

  return
