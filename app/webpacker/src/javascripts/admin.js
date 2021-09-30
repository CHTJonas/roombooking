$(() => {
    $("a#batch-import").on("ajax:success", (event) => {
        rbModal("Batch Import", "The batch import job is now running in the background – please refresh the page after a few seconds...");
    });
    $('[id$="max_rehearsals"]').on('change', function() {
        Rails.fire(this.form, "submit");
    });
    $('[id$="max_auditions"]').on('change', function() {
        Rails.fire(this.form, "submit");
    });
    $('[id$="max_meetings"]').on('change', function() {
        Rails.fire(this.form, "submit");
    });
});
