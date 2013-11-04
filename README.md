shackles
========

With rfid wristbands, called [shackles](http://shackles.unimatrix21.org/)


# API
All REST-urls are within /api/

## User

###JSON Datastructure
	{
		_id: String 			- username
		rfids: [String] 	- array of rfids as md5 hash
		status: String		- current status, either 'logged in' or 'logged out'
		activity: [{			- array of activities
			date: Date 			- date of activity
			action: String	- action, either 'login' or 'logout'
		}]
	}


### List All Users
#### GET /api/user

returns:

	200 - all users as full objects as json.

### Get One User By Id/Username
#### GET /api/user/:id

returns:

	200 - user as json
	404 null - no matching username

### Get One User By RFID
#### GET /api/id/:id
#### GET /api/rfid/:id

returns:

	200 - user (with only last activity in activityarray) as json
	404 null - if there is no matching RFID


### Register User
#### POST /api/user
POST json: {username, rfid}

returns:

	200 - successful register


### Login User with :id
#### GET /api/user/:id/login

returns:

	200 - successful login

### Logout User with :id
#### GET /api/user/:id/logout

returns:

	200 - successful logout