module.exports = {
  target: "web",
  context: __dirname,
  entry: ['./compile/src/garmin.js'],
  output: {
    filename: 'main.js'
  },
  plugins: []
}
