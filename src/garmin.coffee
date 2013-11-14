{Communicator} = require('../src/Communicator')

exports.Garmin = class Garmin
  @statusCodes:
    idle:     0
    working:  1
    waiting:  2
    finished: 3
    error:    -1

  @fitnessTypes:
    activities:     ['FitnessHistory', 'FitnessDirectory']
    workouts:       ['FitnessWorkouts', 'FitnessData']
    courses:        ['FitnessCourses', 'FitnessData']
    goals:          ['FitnessActivityGoals', 'FitnessData']
    profile:        ['FitnessUserProfile', 'FitnessData']
    fitActivities:  ['FIT_TYPE_4', 'FITDirectory']

  @defaultUnlockCodes: [
    "file:///", "cb1492ae040612408d87cc53e3f7ff3c",
    "http://localhost", "45517b532362fc3149e4211ade14c9b2",
    "http://127.0.0.1", "40cd4860f7988c53b15b8491693de133"
  ]

  constructor: (options) ->
    # options = _(options).defaults
    #   derp: ""

    @communicator = new Communicator

    @communicator.unlock()
