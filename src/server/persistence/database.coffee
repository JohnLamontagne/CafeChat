{ MongoClient } = require 'mongodb'

class Database
  constructor: ->

  @connect: ->
    url = process.env.MONGODB_URI
    client = await MongoClient.connect(url)
    console.log('Connected to MongoDB')
    @db = client.db()

    @messages = client.db().collection('messages')
    @users = client.db().collection('users')
    @rooms = client.db().collection('rooms')

    return @

module.exports = Database