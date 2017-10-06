moment = require 'moment'
helmet = require 'helmet'
expressjs = require 'express'
express = expressjs()
http = require 'http'
https = require 'https'
server = http.Server express
exec = require('child_process').exec

express.use expressjs.static 'public'
express.use helmet()
express.disable 'x-powered-by'

format = 'DD. MM. YYYY, hh:mm:ss'
port = process.env.PORT || 4000

server.listen port, ->
  console.log moment().format(format) + ' Server started on port ' + port

express.get '/', (req, res) ->
  console.log moment().format(format) + ' GET /'

  if req.query.server and req.query.client
    server = if /^[a-z0-9._-]+$/i.test(req.query.server) then req.query.server else 'E'
    client = if /^[a-z0-9]+$/i.test(req.query.client) then req.query.client else 'E'
  else
    server = 'pool.sks-keyservers.net'
    client = '65BDCDAB70974BA9'

  console.log server+' '+client

  cmd1 = "gpg --keyid-format 0xLONG --keyserver #{server} --recv-keys #{client}"
  cmd2 = "gpg --keyid-format 0xLONG --fingerprint #{client} | grep -v '^$'"
  exec cmd1, (error1, stdout1, stderr1) ->
    console.log '$ '+cmd1
    console.log stderr1
    exec cmd2, (error2, stdout2, stderr2) ->
      console.log '$ '+cmd2
      console.log stdout2

      stdout2 = stdout2.replace /pub.*[a-zA-Z0-9]*\/0x/, "0x"
      stdout2 = stdout2.replace /\[.*\] \[expires: (.*)\]/, "$1"
      stdout2 = stdout2.replace /.*Key fingerprint = /, "fingerprint: "
      stdout2 = stdout2.replace /(fingerprint: .*)  (.*)/, "$1\n             $2"
      stdout2 = stdout2.replace /.*\[ unknown\] /g, ""
      stdout2 = stdout2.replace /.*image of size.*/, ""
      stdout2 = stdout2.replace /sub.*/g, ""
      stdout2 = stdout2.replace /^\s*\n/gm, ""

      server = if server == 'E' then req.query.server else server
      client = if client == 'E' then req.query.client else client

      data = { out1: stderr1, out2: stdout2, server: server, client: client }
      res.render 'index.ejs', data
