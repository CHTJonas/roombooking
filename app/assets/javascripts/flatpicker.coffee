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
