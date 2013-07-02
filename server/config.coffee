exports.config =
	# See http://brunch.readthedocs.org/en/latest/config.html for documentation.
	files:
		javascripts:
			joinTo:
				'javascripts/app.js': /^app/
				'javascripts/vendor.js': /^vendor/
				'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
				'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
			order:
				# Files in `vendor` directories are compiled before other files
				# even if they aren't specified in order.before.
				before: [
					'vendor/scripts/console-helper.js',
					'vendor/scripts/jquery.js',
					'vendor/scripts/lodash.js',
					'vendor/scripts/backbone.js',
					'vendor/scripts/bootstrap.js'
				]

		stylesheets:
			joinTo:
				'stylesheets/app.css': /^(app|vendor)/
				'test/stylesheets/test.css': /^test/
			order:
				before: [
					'vendor/styles/bootstrap.css',
					'vendor/styles/boostrap-responsive.css'
				]

		templates:
			joinTo: 'javascripts/app.js'
