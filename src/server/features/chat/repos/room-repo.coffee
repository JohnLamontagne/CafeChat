class RoomRepo
  constructor: (@db) ->
    @collection = @db.rooms

  createRoom: (room) ->
    result = await @collection.insertOne(room)
    return { room..., _id: result.insertId }

  getRooms: () ->
    @collection.find().toArray()


module.exports = RoomRepo