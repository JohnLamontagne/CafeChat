ensureAuthenticated = (req, res, next) ->
  if req.session?.user
    next()
  else
      res.send('''
        <div class="error-message">
          Please login to continue
        </div>
        <script>
          window.location.href = '/login';
        </script>
      ''')

module.exports = { ensureAuthenticated }