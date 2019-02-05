$ ->
  $("a#batch-import").on "ajax:success", (event) ->
    alert "The batch import job has been enqueued for background processing! Try refreshing the page after a few seconds..."
