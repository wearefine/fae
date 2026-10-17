import { Application } from "@hotwired/stimulus"
import "@hotwired/turbo-rails"
import CancelController from "fae/controllers/cancel_controller"
import ContrastController from "fae/controllers/contrast_controller"
import DeployController from "fae/controllers/deploy_controller"
import FilteringController from "fae/controllers/filtering_controller"
import FrameFilterController from "fae/controllers/frame_filter_controller"
import LanguageController from "fae/controllers/language_controller"

// Turbo is always loaded, but Drive only takes over navigation when `Fae.turbo_drive` is set.
// Otherwise elements opt in with `data-turbo="true"`.
const driveMeta = document.querySelector('meta[name="fae-turbo-drive"]')
window.Turbo.session.drive = driveMeta?.content === "true"

const application = Application.start()
window.Stimulus = application

application.register("fae-cancel", CancelController)
application.register("fae-contrast", ContrastController)
application.register("fae-deploy", DeployController)
application.register("fae-filtering", FilteringController)
application.register("fae-frame-filter", FrameFilterController)
application.register("fae-language", LanguageController)

export { application }
