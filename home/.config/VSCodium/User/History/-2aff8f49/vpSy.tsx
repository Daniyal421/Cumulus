import { Gtk } from "ags/gtk4"

export default function Power() {
    return (
        <window
            name="power"
            class="power-window"
            visible
            decorated={false}
            resizable={false}
        >
            <centerbox
                hexpand
                vexpand
            >
                <box />

                <box
                    class="power-panel"
                    spacing={18}
                    halign={Gtk.Align.CENTER}
                    valign={Gtk.Align.CENTER}
                >
                    <button class="power-button">
                        <label label="󰌾" />
                    </button>

                    <button class="power-button">
                        <label label="󰍃" />
                    </button>

                    <button class="power-button">
                        <label label="󰜉" />
                    </button>

                    <button class="power-button shutdown">
                        <label label="" />
                    </button>
                </box>

                <box />
            </centerbox>
        </window>
    )
}