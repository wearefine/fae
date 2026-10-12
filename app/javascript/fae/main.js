import { Application } from "@hotwired/stimulus"
import ContrastController from "fae/controllers/contrast_controller"

const application = Application.start()
window.Stimulus = application

application.register("fae-contrast", ContrastController)

export { application }
