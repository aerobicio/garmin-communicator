module.exports = {
  target: "web",
  context: __dirname,
  entry: ['./compile/src/garmin.js'],
  output: {
    path: __dirname + "/build/",
    filename: 'bundle.js'
  },
  plugins: []
}
