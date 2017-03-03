moment = require 'moment'
expressjs = require 'express'
express = expressjs()
http = require 'http'
https = require 'https'
server = http.Server express
exec = require('child_process').exec

express.use expressjs.static 'public'
format = 'DD. MM. YYYY, hh:mm:ss'
port = process.env.PORT || 4000

server.listen port, ->
  console.log moment().format(format) + ' Server started on port ' + port

express.get '/', (req, res) ->
  console.log moment().format(format) + ' GET /'

  server = req.query.server || 'pool.sks-keyservers.net'
  client = req.query.client || '0x65BDCDAB70974BA9'

  cmd1 = "gpg --keyid-format 0xLONG --keyserver #{server} --recv-keys #{client}"
  cmd2 = "gpg --keyid-format 0xLONG --fingerprint #{client} | grep -v '^$'"
  exec cmd1, (error1, stdout1, stderr1) ->
    console.log '$ '+cmd1
    console.log stderr1
    exec cmd2, (error2, stdout2, stderr2) ->
      console.log '$ '+cmd2
      console.log stdout2

      data = { out1: stderr1, out2: stdout2, server: server, client: client }
      res.render 'index.ejs', data
