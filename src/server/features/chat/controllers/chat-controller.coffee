ErrorResponse = require '@utils/response-error-handler'
ejs = require 'ejs'
path = require 'path'

class ChatController
  constructor: (@chatService) ->
    @renderMessagePartial = @renderMessagePartial.bind(this)

  lobbyIndex: (req, res) ->

    rooms = await @chatService.getRooms()

    res.render('chat/index', {
      title: 'Lobby'
      rooms
      currentUser: req.session.user
    })

  renderRoomEntryPartial: (room) ->
    try
      html = await ejs.renderFile(
        path.resolve('src/server/views/chat/partials/room-entry.ejs'),
        {
          room: room,
          layout: false
        }
      )
      return html
    catch error
      console.error('Error rendering room entry:', error)
      throw error

  createRoom: (req, res) ->
    try
      room =
        name: req.body.roomName
        createdBy: req.session.user._id
        isPrivate: false

      newRoom = await @chatService.createRoom(room)
      html = await @renderRoomEntryPartial(newRoom)
      res.status(200).send(html)

    catch error
      console.error("Create room error:", error)
      res.status(500).send("Error creating room")

  roomIndex: (req, res) ->
    roomId = req.params.roomId

    messages = await @chatService.getMessages(roomId)

    res.render('chat/room', {
      title: 'Chat'
      messages,
      roomId,
      currentUser: req.session.user
    })

  sendMessage: (req, res) ->
    try
      message =
        content: req.body.message
        userId: req.session.user._id
        username: req.session.user.username
        roomId: req.body.roomId
        timestamp: new Date().toISOString()

      savedMessage = await @chatService.sendMessage(message)

      res.status(200).end()

    catch error
      console.error('Send message error:', error)
      ErrorResponse.send(res, error)

  renderMessagePartial: (message, currentUser) ->
    try
      console.log('Rendering message partial for:', message)
      html = await ejs.renderFile(
        path.resolve('src/server/views/chat/partials/message.ejs'),
        {
          message: message,
          currentUser: currentUser,
          layout: false
        }
      )
      console.log('Rendered HTML:', html.substring(0, 100) + '...')
      return html
    catch error
      console.error('Error rendering message:', error)
      throw error

  streamMessages: (req, res) ->
    res.writeHead(200, {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive'
    })

    roomId = req.params.roomId

    onMessage = (message) =>
      if message.roomId == roomId
        try
          html = await @renderMessagePartial(message, req.session.user)
          cleanHtml = html.replace(/[\n\r]/g, '').trim()
          res.write("event: message\n")
          res.write("data: #{cleanHtml}\n\n")
        catch error
          console.error("Error in onMessage:", error)

    @chatService.on('message', onMessage)

    req.on 'close', =>
      @chatService.removeListener('message', onMessage)

module.exports = ChatController