// Loaded on every Fae admin page after Fae's own modules.
import { application } from "fae"
import GreetingController from "fae_custom/controllers/greeting_controller"

application.register("dummy-greeting", GreetingController)

// jQuery and the legacy `Fae` object are globals, so plain-JS customizations can live here too.
// `fae:load` fires after Fae initializes a page or newly swapped-in markup.
document.addEventListener("fae:load", () => {
  $(".login-body").addClass("test-class")
})

// Delegate from the document so these survive the body being replaced.
$(document).on("modal:show", function (e) {
  $(".modal-callback").remove()
  $(e.relatedTarget).closest(".input").append("<p class='modal-callback modal-callback--show'>Modal Open/Show</p>")

  // Add form listeners & close form on ajax success
  if (e.dialog.data[0].classList.contains("nested-form")) {
    Fae.form.ajax.htmlListeners()

    $("#fae-modal").on("ajax:success", function () {
      if (Fae.modals.modalOpen) {
        $.modal.close()
      }
    })
  }
})

$(document).on("modal:shown", function (e) {
  $(e.relatedTarget).closest(".input").append("<p class='modal-callback modal-callback--shown'>Modal Shown</p>")
})

$(document).on("modal:close", function (e) {
  $(e.relatedTarget).closest(".input").append("<p class='modal-callback modal-callback--close'>Modal Close</p>")
})

$(document).on("modal:closed", function (e) {
  $(e.relatedTarget).closest(".input").append("<p class='modal-callback modal-callback--closed'>Modal Closed</p>")
})
