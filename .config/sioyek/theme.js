let bg = sioyek.get_config_no_dialog("custom_background_color").trim();
let parts = bg.split(/\s+/);

let value = Number(parts[1]);

if (value < 0.5) {
    sioyek.setconfig_custom_text_color("#242424");
    sioyek.setconfig_custom_background_color("#ebdbb2");
    sioyek.setconfig_custom_color_mode_empty_background_color("#ebdbb2");
} else {
    sioyek.setconfig_custom_text_color("#ebdbb2");
    sioyek.setconfig_custom_background_color("#242424");
    sioyek.setconfig_custom_color_mode_empty_background_color("#242424");
}
