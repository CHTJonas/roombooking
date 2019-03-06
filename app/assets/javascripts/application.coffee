#= require rails-ujs
#= require activestorage
#= require jquery3
#= require popper
#= require bootstrap-sprockets
#= require flatpickr
#= require cookies_eu
#= require peek
#= require peek/views/performance_bar
#= require peek/views/rblineprof
#= require_tree .

window.rbModal = (title, message) ->
  $('#roombookingModalTitle').text(title)
  $('#roombookingModalContent').text(message)
  $('#roombookingModal').modal('show')

ajaxFail = ->
  alert "Oops something's gone wrong! Please try again after a few seconds..."

$ ->
  $("a").on "ajax:error", ajaxFail
  $("form").on "ajax:error", ajaxFail
