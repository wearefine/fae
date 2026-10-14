# Whether a Stimulus controller with `identifier` is connected to the first element matching `selector`
def controller_connected?(selector, identifier)
  page.evaluate_script(<<~JS)
    !!(window.Stimulus && window.Stimulus.getControllerForElementAndIdentifier(document.querySelector('#{selector}'), '#{identifier}'))
  JS
end
