require('module-alias/register')

express = require 'express'
expressLayouts = require('express-ejs-layouts');
path = require 'path'
session = require 'express-session'
morgan = require 'morgan'
flash = require 'connect-flash'
{ ensureAuthenticated } = require '@features/auth/middleware/auth-middleware'

DependencyContainer = require('@utils/dependency-container')


init = ->
  try
    console.log 'Initializing app...'
    container = await DependencyContainer.configure()

    app = express()

    app.use morgan('dev')
    app.use express.json()
    app.use express.urlencoded({extended: false})
    app.use express.static(path.join(__dirname, 'public'))

    # middleware
    app.use session
      secret: process.env.SESSION_SECRET
      resave: false
      saveUninitialized: false
      cookie:
        secure: process.env.NODE_ENV is 'production'
        maxAge: 1000 * 60 * 60 * 24 * 7 # 1 week

    app.use flash()

    app.use (req, res, next) ->
      res.locals.messages =
        error: req.flash('error')
        success: req.flash('success')
      next()

    app.set('view engine', 'ejs')
    app.use(expressLayouts)
    app.set('layout', path.join(__dirname, 'server', 'views', 'layouts', 'main'))
    app.set('views', path.join(__dirname, 'server', 'views'))

    authController = container.resolve('authController')
    homeController = container.resolve('homeController')
    chatController = container.resolve('chatController')

    app.get '/', (req, res) -> homeController.index(req, res)
    app.get '/login', (req, res) -> authController.loginForm(req, res)
    app.get '/register', (req, res) -> authController.registerForm(req, res)
    app.get '/lobby', ensureAuthenticated, (req, res) -> chatController.lobbyIndex(req, res)

    app.post '/chat/rooms', ensureAuthenticated, (req, res) -> chatController.createRoom(req, res)

    app.get '/chat/:roomId', ensureAuthenticated, (req, res) -> chatController.roomIndex(req, res)
    app.get '/chat/:roomId/stream', ensureAuthenticated, (req, res) -> chatController.streamMessages(req, res)


    app.post '/auth/logout', (req, res) -> authController.logout(req, res)
    app.post '/auth/login', (req, res) -> authController.login(req, res)
    app.post '/auth/register', (req, res) -> authController.register(req, res)
    app.post '/chat/messages', ensureAuthenticated, (req, res) -> chatController.sendMessage(req, res)

    app

do ->
  try
    console.log 'Starting server...'
    app = await init()

    # fire up the server
    port = process.env.PORT or 3000
    app.listen port, ->
      console.log 'Server is running on port', port