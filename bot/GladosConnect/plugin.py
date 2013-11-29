###
# Copyright (c) 2013, rashfael
# All rights reserved.
#
#
###

import redis
import threading

import supybot.utils as utils
from supybot.commands import *
import supybot.plugins as plugins
import supybot.ircutils as ircutils
import supybot.callbacks as callbacks

class RedisListener(threading.Thread):
	def __init__(self, irc, r, channels):
		threading.Thread.__init__(self)
		self.irc = irc
		self.redis = r
		self.pubsub = self.redis.pubsub()
		self.pubsub.subscribe(channels)
	
	def work(self, item):
		if item['type'] == "message" and self.irc:
			self.irc.reply(item['data'])
			self.irc = None
	
	def run(self):
		for item in self.pubsub.listen():
			self.work(item)

class GladosConnect(callbacks.Plugin):
	"""Add the help for "@plugin help GladosConnect" here
	This should describe *how* to use this plugin."""
	threaded = True

	def __init__(self, irc):
		self.__parent = super(GladosConnect, self)
		self.__parent.__init__(irc)
		r = redis.Redis(host='glados.shack')
		self.redis = r
		client = RedisListener(irc, r, ['!bot'])
		client.start()
		self.redisListener = client

	def online(self, irc, msg, args):
		"""takes no arguments

		Returns online shackle users.
		"""
		self.redisListener.irc = irc
		self.redis.publish('bot', '.online')
		
	online = wrap(online)

	def die(self):
		self.redisListener.join(0)
		self.__parent.die()

Class = GladosConnect


# vim:set shiftwidth=4 softtabstop=4 expandtab textwidth=79:
