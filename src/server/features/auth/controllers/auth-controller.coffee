ErrorResponse = require '@utils/response-error-handler'

class AuthController
  constructor: (@authService) ->


  loginForm: (req, res) ->
    res.render('auth/login', {
        title: 'Login'
        error: req.flash('error')
      }
    )

  registerForm: (req, res) ->
    res.render('auth/register', {
        title: 'Register'
        error: req.flash('error')
      }
    )

  logout: (req, res) ->
    req.session.destroy()
    res.redirect('/')

  login: (req, res) ->
    try
      username = req.body.username
      password = req.body.password

      user = await @authService.login(username, password)

      unless user
        return res.status(401).send('''
          <div class="error-message">
            Invalid username or password
          </div>
        ''')

      req.session.user = user
      res.send('''
          <div class="success-message">
            Login successful! Redirecting...
          </div>
          <script>
            window.location.href = '/lobby';
          </script>
        ''')

    catch error
      ErrorResponse.send(res, error)


  register: (req, res) ->
    try
      user = await @authService.register({
        username: req.body.username
        password: req.body.password
      })

      unless user
        res.status(409).send('''
          <div class="error-message">
            User already exists
          </div>
        ''')

      req.session.user = user
      res.send('''
        <div class="success-message">
          Registration successful! Redirecting...
        </div>
        <script>
          window.location.href = '/lobby';
        </script>
      ''')

module.exports = AuthController