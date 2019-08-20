import flatpickr from "flatpickr";

$(() => {
    flatpickr(".flatdatetimepickr", {
        enableTime: true,
        dateFormat: "d/m/Y H:i"
    });
    flatpickr(".flatdatepickr", {
        enableTime: false,
        dateFormat: "d/m/Y"
    });
    flatpickr(".flatdaterangepickr", {
        enableTime: false,
        mode: "multiple",
        dateFormat: "d/m/Y"
    });
});
