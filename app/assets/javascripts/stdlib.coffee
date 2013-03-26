# stdlib.coffee - A variety of general-purpose CoffeeScript tools.

#####
# RegExp
#####

RegExp::flags = ->
  flags = ""
  flags += 'i' if @ignoreCase
  flags += 'm' if @multiline
  flags += 'g' if @global
  flags

#####
# Array
#####

apply_test = (test, el) ->
  if _.isFunction(test) and test(el)
    return true
  else
    for key of test
      return true if el[key] == test[key]
  null

Array::remove = (e) -> @[t..t] = [] if (t = @indexOf(e)) > -1
Array::find = (test) ->
  for el in this
    if apply_test(test, el)
      return el
  null

Array::find_index = (test) ->
  for el, i in this
    if apply_test(test, el)
      return i
  null

Array::find_all = (test) -> el for el in this when apply_test(test, el)
Array::select = Array::find_all
Array::reject = (test) -> el for el in this when not apply_test(test, el)
Array::remove_all = (test) -> @remove(el) for el in @find_all(test)
Array::insert = (index, el) -> @splice(index, 0, el)
Array::last = -> @[@.length - 1]
Array::first = -> @[0]
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0..@length-1]
  value for own key, value of output

Array::pluck = (args...) -> _.pluck(this, args...)
Array::all = (test) -> @find_all(test).length == @length
Array::reversed = -> Array.prototype.slice.call(this).reverse()
Array::extend = (arr) -> this.push.apply(this, arr) # Equivalent of += in saner languages
Array::flatten = ->
  arr = []
  for val in this
    if val instanceof Array then arr.extend(val.flatten())
    else arr.push(val)
  arr

Array::min = -> Math.min.apply Math, this
Array::max = -> Math.max.apply Math, this

#####
# String
#####

String::strip = (c=' ') -> @replace(new RegExp("^#{c}+|#{c}+$", 'g'), '')
String::lstrip = (c=' ') -> @replace(new RegExp("^#{c}+", 'g'), '')
String::rstrip = (c=' ') -> @replace(new RegExp("#{c}+$", 'g'), '')
String::downcase = -> @toLowerCase()
String::upcase = -> @toUpperCase()
String::gsub = (target, repl) -> @replace(new RegExp(target.source, target.flags()+'g'), repl)
String::startswith = (substr) -> @indexOf(substr) == 0
String::empty = -> @length == 0

#####
# Sets
#####

class window.Set
  add: (obj) -> @[obj] = true
  remove: (obj) -> delete @[obj]

#####
# jQuery
#####

if jQuery?
  $.fn.parametrize = ->
    """Find input element descendants and return a name->val mapping for them."""
    params = {}
    for input in $(this).find('input')
      key = $(input).attr('name') or $(input).attr('id')
      val = $(input).val()
      params[key] = val if key and val?
    params

#####
# Globals
#####

window.log = (args...) ->
  """Wrapper for console.log"""
  console.log(args...)

delayed = {}

window.delay = (args...) ->
  """A handy wrapper for setTimeout.
     Accepts 1-3 arguments, with the final argument always a function.
     delay: Microseconds to delay execution.
     key: A key that will be used to prevent multiple execution of the callback.
     callback: Function to delay."""
  if args[0] instanceof Function
    delay = 10
    callback = args[0]
  else
    delay = args[0]
    if typeof args[1] == 'string'
      key = args[1]
      callback = args[2]
    else
      callback = args[1]

  if key
    if delayed[key] then clearTimeout(delayed[key])
    delayed[key] = setTimeout(callback, delay)
  else
    setTimeout(callback, delay)

AssertException = (message) -> this.message = message

window.assert = (exp, message) ->
  if console.assert then console.assert(exp, message)
  else if !exp
    log message
    throw new AssertException(message)

window.redirect = (url) ->
  window.location.pathname = url

window.refresh = -> window.location.reload()
