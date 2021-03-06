
crypto = require 'crypto'
{checkers} = require 'keybase-bjson-core'
C = require './const'

#=======================================================================

exports.generate = generate = (cfg, source) ->
  l = cfg.byte_length
  source or= crypto.prng(l-1)
  Buffer.concat [ source, (new Buffer cfg.lsb, 'hex') ]

#=======================================================================

exports.match = (id, cfg) ->
  (id.length is cfg.byte_length*2) and (id[(id.length - 2)...] is parseInt(cfg.lsb, 16))

#=======================================================================

exports.checker = checker = (cfg) -> 
  bufcheck = checkers.buffer(cfg.byte_length, cfg.byte_length)
  lsbcheck = (x) ->
    lsb_got = x[-1...].toString('hex')
    err = if (lsb_got is cfg.lsb) then null
    else new Error "Bad LSB, wanted #{cfg.lsb} but got #{lsb_got}"
  (x) -> bufcheck(x) or lsbcheck(x)

#=======================================================================

exports.checkers = c = {}
exports.generators = g = {}
for k,v of C.id
  ((type,cfg) -> 
    c[type] = checker(cfg)
    g[type] = (s) -> generate(cfg, s)
  )(k,v)

#=======================================================================
