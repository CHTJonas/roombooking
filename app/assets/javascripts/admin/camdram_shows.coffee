$ ->
  $("a#batch-import").on "ajax:success", (event) ->
    alert "Success! The batch import job is now running in the background – please refresh the page after a few seconds..."
  $("a#new-term").on "ajax:success", (event) ->
    alert "Success! Previous shows are now being marked as dormant in the background – please refresh the page after a few seconds..."
