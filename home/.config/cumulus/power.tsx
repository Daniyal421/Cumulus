import app from "ags/gtk4/app"
import { exec } from "ags/process"
import { Astal, Gdk, Gtk } from "ags/gtk4"

type PowerAction = {
  label: string
  icon: string
  className: string
  command: string[]
}

const actions: PowerAction[] = [
  {
    label: "Lock",
    icon: "󰌾",
    className: "lock",
    // Launch through Hyprland so the lock screen survives this menu closing.
    command: ["hyprlock"],
  },
  {
    label: "Logout",
    icon: "󰍃",
    className: "logout",
    command: ["hyprctl", "dispatch", "exit"],
  },
  {
    label: "Reboot",
    icon: "󰜉",
    className: "reboot",
    command: ["systemctl", "reboot"],
  },
  {
    label: "Shutdown",
    icon: "",
    className: "shutdown",
    command: ["systemctl", "poweroff"],
  },
]

function runAction(command: string[]) {
  try {
    // Wait for Hyprland/systemd to accept the request before closing the menu.
    exec(command)
  } catch (error) {
    console.error(error)
    return
  }

  app.quit()
}

function PowerButton({ label, icon, className, command }: PowerAction) {
  return (
    <button
      class={`power-button ${className}`}
      tooltipText={label}
      onClicked={() => runAction(command)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        <label class="power-icon" label={icon} />
        <label class="power-label" label={label} />
      </box>
    </button>
  )
}

export default function Power() {
  return (
    <window
      application={app}
      name="power"
      namespace="cumulus-power"
      class="power-window"
      visible
      decorated={false}
      resizable={false}
      anchor={Astal.WindowAnchor.BOTTOM}
      layer={Astal.Layer.OVERLAY}
      keymode={Astal.Keymode.EXCLUSIVE}
      marginBottom={302}
      onCloseRequest={() => app.quit()}
      $={(window) => {
        const keys = new Gtk.EventControllerKey()
        keys.connect("key-pressed", (_, keyval) => {
          if (keyval !== Gdk.KEY_Escape) return false
          app.quit()
          return true
        })
        window.add_controller(keys)
      }}
    >
      <box class="power-backdrop" orientation={Gtk.Orientation.VERTICAL} hexpand vexpand>
        <box vexpand />
        <box
          class="power-panel"
          orientation={Gtk.Orientation.VERTICAL}
          spacing={18}
          halign={Gtk.Align.CENTER}
        >
          <box class="power-heading" orientation={Gtk.Orientation.VERTICAL} spacing={3}>
            <label class="power-title" label="Power menu" />
            <label class="power-subtitle" label="Choose an action" />
          </box>

          <box class="power-actions" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
            {[actions.slice(0, 2), actions.slice(2)].map((row) => (
              <box class="power-action-row" spacing={10} homogeneous>
                {row.map((action) => (
                  <PowerButton {...action} />
                ))}
              </box>
            ))}
          </box>

          <label class="power-hint" label="Esc to close" />
        </box>
        <box vexpand />
      </box>
    </window>
  )
}
