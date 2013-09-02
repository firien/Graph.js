{spawn, exec} = require 'child_process'
fs            = require 'fs'
{print}       = require 'util'

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
  exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

task "compile", "Build project from src/*.coffee to lib/app.js", ->
  #order matters!
  listOfFiles = "src/graph.coffee src/bar.coffee src/line.coffee"
  exec "coffee -j app.js -c -o lib/ " + listOfFiles, (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

task "compileTest", "Build project from test/*.coffee to lib/app.js", ->
  #order matters!
  listOfFiles = "test/graph_test.coffee"
  exec "coffee -j test/test.js -c -o test/ " + listOfFiles, (err, stdout, stderr) ->
    throw err if err
    console.log stdout + stderr

# build = (watch, callback) ->
#   if typeof watch is 'function'
#     callback = watch
#     watch = false
#   options = ['-c', '-o', 'lib']
#   options.unshift '-w' if watch
# 
#   coffee = spawn 'coffee', options
#   coffee.stdout.on 'data', (data) -> print data.toString()
#   coffee.stderr.on 'data', (data) -> print data.toString()
#   coffee.on 'exit', (status) -> callback?() if status is 0
    
task 'docs', 'Generate annotated source code with Docco', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'docco', files
    docco.stdout.on 'data', (data) -> print data.toString()
    docco.stderr.on 'data', (data) -> print data.toString()
    # docco.on 'exit', (status) -> callback?() if status is 0

# task 'build', 'Compile CoffeeScript source files', ->
#   build()

# task 'watch', 'Recompile CoffeeScript source files when modified', ->
#   build true
