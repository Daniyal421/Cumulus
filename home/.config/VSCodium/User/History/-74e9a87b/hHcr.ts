import app from "ags/gtk4/app"
import css from "./style.css"

import Power from "./power"

app.start({
  css,

  main() {
    return <Power />
  },
})