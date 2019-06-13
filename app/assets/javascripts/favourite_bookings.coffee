# Favourite bookings are stored in an indexed database locally in the user's
# browser. This provides a level of isolation for privacy reasons.

clearFavourites = ->
  $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>')

showErrorFavourites = ->
  $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">An error occurred retrieving favourite bookings!</p>')

appendFavourites = (data) ->
  if data
    $('#favourite-bookings-container').replaceWith(data)
  else
    clearFavourites()

setupIDB = ->
  DBOpenRequest = indexedDB.open("roombooking", 1)
  DBOpenRequest.onupgradeneeded = (event) ->
    db = event.target.result
    db.onerror = (event) ->
      console.error(event)
      throw "An error occurred"
    objectStore = db.createObjectStore("favouriteShows", { keyPath: "bookingId" })
    objectStore.createIndex("numberOfVisits", "numberOfVisits", { unique: false })
    objectStore.createIndex("lastVisitDate", "lastVisitDate", { unique: false })
  DBOpenRequest

addBookingToFavourites = (id) ->
  DBOpenRequest = setupIDB()
  DBOpenRequest.onsuccess = (event) ->
    db = DBOpenRequest.result
    transaction = db.transaction("favouriteShows", "readwrite")
    objectStore = transaction.objectStore("favouriteShows")
    now = new Date()
    obj = { bookingId: id,  numberOfVisits: 1, lastVisitDate: now.toUTCString() }
    objectStoreRequest = objectStore.add(obj)

showFavouriteBookings = ->
  ids = []
  DBOpenRequest = setupIDB()
  DBOpenRequest.onerror = (event) ->
    showErrorFavourites()
  DBOpenRequest.onsuccess = (event) ->
    db = DBOpenRequest.result
    transaction = db.transaction("favouriteShows")
    objectStore = transaction.objectStore("favouriteShows")
    request = objectStore.openCursor()
    request.onsuccess = (event) ->
      cursor = event.target.result
      if cursor
        data = cursor.value.bookingId
        ids.push(data)
        cursor.continue()
      else
        params = { ids: ids.slice(0, 9) }
        $.post("bookings/favourites", params, appendFavourites, "html")

$ ->
  regex = /^\/bookings\/([0-9]+)$/i
  match = window.location.pathname.match(regex)
  if match && match.length == 2
    bookingId = Number(match[1])
    addBookingToFavourites(bookingId)
  else if window.location.pathname == "/bookings"
    showFavouriteBookings()
