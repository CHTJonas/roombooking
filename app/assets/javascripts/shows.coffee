$(document).ready ->
  $("input[data-url]").on('input', ->
    url = $(this).data("url")
    data = {}
    data[$(this).attr("name")] = $(this).val()
    $.ajax({
      url: url,
      type: 'PATCH',
      dataType: 'json',
      data: data
    })
  )
