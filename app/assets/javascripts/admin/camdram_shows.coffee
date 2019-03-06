$ ->
  $("a#batch-import").on "ajax:success", (event) ->
    rbModal "Batch Import", "The batch import job
      is now running in the background – please
      refresh the page after a few seconds..."
  $("a#new-term").on "ajax:success", (event) ->
    rbModal "Start New Term", "Previous shows are
      now being marked as dormant in the
      background – please refresh the page after
      a few seconds..."
