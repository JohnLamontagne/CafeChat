bcrypt = require 'bcrypt'

class AuthService
  constructor: (@userRepo) ->
    @salt = bcrypt.genSaltSync(10)

  hashPassword: (password) ->
    bcrypt.hash(password, @salt)

  comparePassword: (password, hash) ->
    bcrypt.compare(password, hash)

  login: (username, password) ->
    try
      user = await @userRepo.findByUsername(username)
      return null unless user

      isValid = await @comparePassword(password, user.password)
      return if isValid then user else null

    catch error
      console.error 'AuthService.login error:', error
      throw error


  register: (userData) ->
    try
      existingUser = await @userRepo.findByUsername(userData.username)
      if existingUser
        return null

      hashedPass = await @hashPassword(userData.password)
      userData.password = hashedPass
      user = await @userRepo.create({
        userData...,
        password: hashedPass
      })

      return user
    catch error
      console.error 'AuthService.register error:', error
      throw error

module.exports = AuthService