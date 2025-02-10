class MessageRepo
  constructor: (@db) ->
    @collection = @db.messages

  createMessage: (message) ->
    result = await @collection.insertOne(message)
    return { message..., _id: result.insertId }

  getMessages: (roomId, limit = 50) ->
    @collection
      .find({ roomId })
      .sort({ timestamp: 1 })
      .limit(limit)
      .toArray()


module.exports = MessageRepo