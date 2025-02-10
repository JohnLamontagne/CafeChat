class ErrorResponse
  @send: (res, error) ->
    console.error 'Responding with error:', error

    message = switch
        when error.name == 'ValidationError'
          status: 400
          text: 'Please check your input and try again'
        when error.name == 'UnauthorizedError'
          status: 401
          text: 'Unauthorized'
        when error.name == 'DatabaseError'
          status: 500
          text: 'Service temporarily unavailable'
        else
          status: 500
          text: 'Internal server error'

    res.status(message.status).send("""
      <div class="error-message">
        #{message.text}
      </div>
    """)

module.exports = ErrorResponse
