exports.WorkoutFactory = class WorkoutFactory
  "use strict"

  FITFILE_TYPES:
    activities: 4
    goals:      11
    locations:  8
    monitoring: 9
    profiles:   2
    schedules:  7
    sports:     3
    totals:     10

  constructor: (device) ->
    @device = device

  _parseISODateString: (dateString) ->
    # http://stackoverflow.com/questions/14238261/convert-yyyy-mm-ddthhmmss-fffz-to-datetime-in-javascript-manually
    @REPLACE_DATE_DASHES_REGEX ||= /-/g
    @REPLACE_DATE_TZ_REGEX     ||= /[TZ]/g
    formattedDateString = dateString
      .replace(@REPLACE_DATE_DASHES_REGEX, "/")
      .replace(@REPLACE_DATE_TZ_REGEX, " ")
    new Date(formattedDateString)
