// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import bulmaCalendar from "../vendor/bulma-calendar"

import Alpine from "alpinejs";

window.Alpine = Alpine
Alpine.start()

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

var dataPickerOptions = {
  isRange: true,
  displayMode: "dialog",
  showHeader: false,
  dateFormat: "dd-MM-yyyy"
}

DateRangeHook = {
  mounted() { 	  
    const picker = document.getElementById('dateRangePicker')
    
    if (! picker) return
    
    bulmaCalendar.attach(picker, dataPickerOptions)
    
    var that = this

    var element = document.querySelector('#dateRangePicker')
    
    if (element) {
      element.bulmaCalendar.on('select', function(datepicker) {
        that.pushEvent("set-date-range", {
          start: datepicker.data.startDate,
          end: datepicker.data.endDate
        })
      })
    }
  }
}


let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken},
  hooks: {DateRangeHook},
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to)
      }
    }
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())



// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
