import { Application } from "@hotwired/stimulus"
import CancelController from "fae/controllers/cancel_controller"
import ContrastController from "fae/controllers/contrast_controller"
import DeployController from "fae/controllers/deploy_controller"
import FilteringController from "fae/controllers/filtering_controller"
import LanguageController from "fae/controllers/language_controller"

const application = Application.start()
window.Stimulus = application

application.register("fae-cancel", CancelController)
application.register("fae-contrast", ContrastController)
application.register("fae-deploy", DeployController)
application.register("fae-filtering", FilteringController)
application.register("fae-language", LanguageController)

export { application }
