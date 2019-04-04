getFavourites = (ids) ->
  $.post("bookings/favourites",
    { ids: ids },
    (data) ->
      # $(data).appendTo("#bookings-favourite")
      $('#favourite-bookings-container').replaceWith(data)
    , 'html')

$ ->
  $(".flatdatetimepickr").flatpickr
    enableTime: true
    dateFormat: "d/m/Y H:i"
  $(".flatdatepickr").flatpickr
    enableTime: false
    dateFormat: "d/m/Y"
  $(".flatdaterangepickr").flatpickr
    enableTime: false
    mode: "multiple"
    dateFormat: "d/m/Y"
  if window.location.pathname == "/bookings"
    favouriteBookingIds = localStorage.getItem('rb_favourite_bookings')
    if favouriteBookingIds
      getFavourites(favouriteBookingIds)
    else
      $('#favourite-bookings-spinner').replaceWith('<p class="mt-4 my-3">None!</p>')
