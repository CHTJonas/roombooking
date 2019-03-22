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
#= require @github/hotkey/dist/index.umd
#= require_tree .

window.rbModal = (title, message) ->
  $('#roombookingModalTitle').text(title)
  $('#roombookingModalContent').text(message)
  $('#roombookingModal').modal('show')

window.rbAjaxFail = ->
  rbModal "AJAX Error", "Oops something's gone wrong!
    Please try again after a few seconds and contact
    support if you continue experiencing issues."

$ ->
  $("a").on "ajax:error", rbAjaxFail
  $("form").on "ajax:error", rbAjaxFail
  hotkey.install el for el in document.querySelectorAll '[data-hotkey]'
