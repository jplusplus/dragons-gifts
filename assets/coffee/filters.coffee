abbreviateNumber = (value) ->
  newValue = value
  if value >= 1000
    suffixes = [
      ""
      "k"
      "m"
      "b"
      "t"
    ]
    suffixNum = Math.floor(("" + value).length / 3)
    shortValue = ""
    precision = 2

    while precision >= 1
      shortValue = parseFloat(((if suffixNum isnt 0 then (value / Math.pow(1000, suffixNum)) else value)).toPrecision(precision))
      dotLessShortValue = (shortValue + "").replace(/[^a-zA-Z 0-9]+/g, "")
      break  if dotLessShortValue.length <= 2
      precision--
    shortNum = shortValue.toFixed(1)  unless shortValue % 1 is 0
    newValue = shortValue + suffixes[suffixNum]
  newValue