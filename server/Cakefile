{exec} = require 'child_process'
{spawn} = require 'child_process'
{fork} = require 'child_process'
os = require 'os'

if os.platform() is 'win32'
	coffee = 'coffee.cmd'
	brunch = 'brunch.cmd'
	nodemon = 'nodemon.cmd'
else
	coffee = 'coffee'
	brunch = 'brunch'
	nodemon = 'nodemon'

task 'run', 'Launch the server', ->
	server = spawn coffee, ['lib/server'], {stdio: 'inherit'}

task 'watch', 'Watches all brunches', ->
	brunch = spawn brunch, ['w'], {stdio: 'inherit'}
	nodemon = spawn nodemon, ['-w', 'lib', '-L'], {stdio: 'inherit'}

