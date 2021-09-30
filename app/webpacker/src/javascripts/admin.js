$(() => {
    $("a#batch-import").on("ajax:success", (event) => {
        $('#roombookingModal').on('hidden.bs.modal', () => {
            location.reload();
        });
        rbModal("Batch Import", "A batch import job has been enqueued for processing in the background. The page will be refreshed once you close this alert.");
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
