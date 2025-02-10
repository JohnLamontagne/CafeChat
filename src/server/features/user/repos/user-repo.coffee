class UserRepo
  constructor: (@db) ->
    @collection = @db.users

  findByUsername: (username) ->
    @collection.findOne({ username })

  create: (user) ->
    @collection.insertOne(user)
    return user


module.exports = UserRepo