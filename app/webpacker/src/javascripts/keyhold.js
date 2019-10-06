$(() => {
    const start_time_input_box = $('#booking_start_time')[0];
    const start_time_hint = $('#booking_start_time_management_hours_hint')[0];
    const length_input_box = $('#booking_length')[0];
    const length_hint = $('#booking_length_management_hours_hint')[0];
    const warn_text = "Keyholder warning! This booking falls outside Management office hours (11am to 6pm).";

    if (start_time_input_box) {
        start_time_input_box.onchange = () => {
            check_if_keyholder_needed();
        }
    }

    if (length_input_box) {
        length_input_box.onchange = () => {
            check_if_keyholder_needed();
        }
    }

    check_if_keyholder_needed = () => {
        check_start_time();
        check_length();
    }

    check_start_time = () => {
        try {
            [start_hour, _] = start_time_input_box.value.split(" ")[1].split(":").map((el) => { return Number(el) });
            if (start_hour < 11 || start_hour > 17) {
                start_time_hint.innerText = warn_text;
            } else {
                start_time_hint.innerText = "";
            }
        } catch {}
    }

    check_length = () => {
        try {
            [start_hour, _] = start_time_input_box.value.split(" ")[1].split(":").map((el) => { return Number(el) });
            const length_hours = Number(length_input_box.value.match(/(\d+)\s*hour/i)[1]);
            let length_minutes;
            try {
                length_minutes = Number(length_input_box.value.match(/(\d+)\s*minutes/i)[1]);
            } catch {
                length_minutes = 0;
            }
            const length = length_hours + length_minutes / 60;
            if (start_hour + length > 18) {
                if (start_time_hint.innerText == "") {
                    length_hint.innerText = warn_text;
                } else {
                    length_hint.innerText = "";
                }
            } else {
                length_hint.innerText = "";
            }
        } catch {}
    }
});
