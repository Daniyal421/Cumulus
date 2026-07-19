import { Gtk } from "ags/gtk4"

export default function Power() {
  return (
    <window
      name="power"
      visible
      class="power-window"
    >
      <box
        class="power-box"
        orientation={Gtk.Orientation.VERTICAL}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
        spacing={20}
      >
        <label
          class="power-title"
          label="Power"
        />

        <box
          class="power-buttons"
          spacing={12}
          homogeneous
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

          <button class="power-button">
            <label label="" />
          </button>
        </box>
      </box>
    </window>
  )
}