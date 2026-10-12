pin 'fae', to: 'fae/main.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from Fae::Engine.root.join('app/javascript/fae/controllers'), under: 'fae/controllers', to: 'fae/controllers'
