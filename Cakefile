{spawn} = require 'child_process'
os = require 'os'

cmd = (name) ->
	if os.platform() is 'win32' then name + '.cmd' else name


npm = cmd 'npm'
coffee = cmd 'coffee'
brunch = cmd 'brunch'
nodemon = cmd 'nodemon'
mocha = cmd 'mocha'
forever = cmd 'forever'

task 'bones', 'throw a bone', ->
	spawn 'coffee', ['bones/index.coffee'], {stdio:'inherit'}

task 'watch', 'Watches all brunches', ->
	brunch = spawn brunch, ['watch'], {cwd: 'server', stdio: 'inherit'}
	nodemon = spawn nodemon, ['-L', '-w', 'lib'], {cwd: 'server', stdio: 'inherit'}

task 'test', 'test with mocha', ->
	proc1 = spawn mocha, ['test/test_server.coffee'], {cwd: 'server', stdio: 'inherit'}