# Favourite bookings are stored in browser local storage and not on the
# server. This is for privacy reasons. Bookings are stored as objects
# inside an array in the following format:
#
#    [ { id: model_id, visits: number_of_visits }, etc... ]

storageKey = 'rb_favourite_bookings'

clearFavourites = ->
  $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>')

getArray = ->
  arr = JSON.parse localStorage.getItem(storageKey)
  unless arr
    arr = []
  arr.sort (a, b) ->
    b.visits - a.visits

setArray = (arr) ->
  localStorage.setItem(storageKey, JSON.stringify(arr))

idToObj = (model_id, number_of_visits=1) ->
  { id: model_id, visits: number_of_visits }

getFavourites = (ids) ->
  $.post("bookings/favourites",
    { ids: ids.slice(0, 9) },
    (data) ->
      if data
        $('#favourite-bookings-container').replaceWith(data)
      else
        clearFavourites()
    , 'html')

$ ->
  regex = /^\/bookings\/([0-9]+)$/i
  if window.location.pathname == "/bookings"
    arr = getArray()
    if arr && arr.length > 0
      favouriteBookingIds = arr.map (o) -> o.id
      getFavourites(favouriteBookingIds)
    else
      clearFavourites()
  else
    match = window.location.pathname.match(regex)
    if match && match.length == 2
      booking_id = Number(match[1])
      arr = getArray()
      obj = arr.find (x) -> x.id == booking_id
      if obj
        obj.visits += 1
      else
        arr.push(idToObj(booking_id))
      setArray(arr)
