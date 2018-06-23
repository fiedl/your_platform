#= require 'stimulus/dist/stimulus.umd'

if !('stimulus' of window)
  window.stimulus = Stimulus.Application.start()
