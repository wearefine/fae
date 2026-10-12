// Loaded on every Fae admin page after Fae's own modules.
import { application } from "fae"
import GreetingController from "fae_custom/controllers/greeting_controller"

application.register("dummy-greeting", GreetingController)
