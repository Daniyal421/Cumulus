import app from "ags/gtk4/app"
import theme from "../waybar/colors/gruvbox-material.css"
import style from "./style.css"

import Power from "./power"

app.start({
  instanceName: "cumulus",
  css: `${theme}\n${style}`,

  main() {
    Power()
  },
})
