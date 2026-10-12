# Pins for the Fae admin's importmap. These are drawn after Fae's own pins, so a pin
# here with the same name as one of Fae's (e.g. "fae/controllers/contrast_controller")
# will override it.
pin 'fae_custom'
pin_all_from 'app/javascript/fae_custom', under: 'fae_custom'
