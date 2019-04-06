storageKey = 'rb_favourite_bookings'

getArray = ->
  JSON.parse localStorage.getItem(storageKey)

setArray = (arr) ->
  localStorage.setItem(storageKey, JSON.stringify(arr))

getFavourites = (ids) ->
  $.post("bookings/favourites",
    { ids: ids },
    (data) ->
      # $(data).appendTo("#bookings-favourite")
      $('#favourite-bookings-container').replaceWith(data)
    , 'html')

$ ->
  regex = /^\/bookings\/([0-9]+)$/i
  if window.location.pathname == "/bookings"
    favouriteBookingIds = getArray()
    if favouriteBookingIds
      getFavourites(favouriteBookingIds)
    else
      $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>')
  else
    match = window.location.pathname.match(regex)
    if match && match.length == 2
      booking_id = Number(match[1])
      favouriteBookingIds = getArray()
      unless favouriteBookingIds
        favouriteBookingIds = []
      favouriteBookingIds.push(booking_id)
      setArray(favouriteBookingIds)
