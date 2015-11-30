module.exports =
  ## Iced helper
  errify: (errCb) -> (continueCb) -> (err, args...) ->
    if err?
      errCb err
    else
      continueCb args...

  extend: (base, objects...) ->
      base[key] = value for key, value of object for object in objects
      base
