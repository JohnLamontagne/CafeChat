class ChatService
  constructor: (@messageRepo, @roomRepo) ->
    @subscribers = new Map()

  getMessages: (roomId) ->
    await @messageRepo.getMessages(roomId)

  getRooms: ->
    await @roomRepo.getRooms()

  createRoom: (room) ->
    await @roomRepo.createRoom(room)

  sendMessage: (message) ->
    try
      message.timestamp = new Date(message.timestamp).toISOString()
      savedMessage = await @messageRepo.createMessage(message)
      console.log('Saved message:', savedMessage)

      @notifySubscribers('message', savedMessage)
      console.log('Notified subscribers for message event')

      savedMessage

    catch error
      console.error 'ChatService.sendMessage error:', error
      throw error

  on: (event, listener) ->
    if not @subscribers.has(event)
      @subscribers.set(event, new Set())

    @subscribers.get(event).add(listener)
    console.log("Added listener for #{event}. Total listeners:", @subscribers.get(event).size)

  removeListener: (event, listener) ->
    if @subscribers.has(event)
      @subscribers.get(event).delete(listener)
      console.log("Removed listener for #{event}. Remaining listeners:", @subscribers.get(event).size)

  notifySubscribers: (event, message) ->
    if @subscribers.has(event)
      listeners = @subscribers.get(event)
      console.log("Notifying #{listeners.size} subscribers for event: #{event}")

      promises = Array.from(listeners).map (listener) ->
        try
          await listener(message)
        catch error
          console.error('Error in listener:', error)

      await Promise.all(promises)

module.exports = ChatService