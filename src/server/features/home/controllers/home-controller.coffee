class HomeController
  index: (req, res) ->
    res.render 'home/index'

module.exports = HomeController