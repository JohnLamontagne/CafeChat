Container = require('@utils/dependency-container')
Database = require('@/persistence/database')
UserRepo = require('@features/user/repos/user-repo')
MessageRepo = require('@features/chat/repos/message-repo')
RoomRepo = require('@features/chat/repos/room-repo')
AuthService = require '@features/auth/services/auth-service'
ChatService = require '@features/chat/services/chat-service'
ChatController = require '@features/chat/controllers/chat-controller'
AuthController = require '@features/auth/controllers/auth-controller'
HomeController = require '@features/home/controllers/home-controller'

class DependencyContainer
  constructor: ->
    @dependencies = {}

  register: (name, service) ->
    @dependencies[name] = service

  resolve: (name) ->
    @dependencies[name]

  @configure: ->
    try
      container = new DependencyContainer()

      console.log 'Configuring dependencies...'

      db = await Database.connect()
      container.register('db', db)

      userRepo = new UserRepo(db)
      messageRepo = new MessageRepo(db)
      roomRepo = new RoomRepo(db)
      container.register('roomRepo', roomRepo)
      container.register('userRepo', userRepo)
      container.register('messageRepo', messageRepo)

      chatService = new ChatService(messageRepo, roomRepo)
      authService = new AuthService(userRepo)
      container.register('chatService', chatService)
      container.register('authService', authService)

      chatController = new ChatController(chatService)
      authController = new AuthController(authService)
      homeController = new HomeController()
      container.register('homeController', homeController)
      container.register('chatController', chatController)
      container.register('authController', authController)

      return container
    catch error
      console.error 'DependencyContainer.configure error:', error
      throw error

module.exports = DependencyContainer
