$(document).ready ->
  window.cookieconsent.initialise({
    "palette": {
      "popup": {
        "background": "#000"
      },
      "button": {
        "background": "#f1d600"
      }
    },
    "content": {
      "message": "Dieser Internetauftritt verwendet Cookies. Mit der fortgesetzten Nutzung erklären Sie sich damit einverstanden. Weitere Informationen:",
      "dismiss": "OK",
      "link": "Datenschutz-Infos",
      "href": "/datenschutz"
    }
  })
