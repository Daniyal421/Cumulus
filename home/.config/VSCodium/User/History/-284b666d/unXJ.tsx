import { App } from "astal/gtk4";
import Gtk from "gi://Gtk?version=4.0";

import { PowerWindow } from "./power";

App.start({
    css: "./style.css",

    main() {
        PowerWindow();
    },
});