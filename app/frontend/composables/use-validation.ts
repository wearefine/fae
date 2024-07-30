// This composable takes advantage of the HTML5 Constraint Validation API
// https://developer.mozilla.org/en-US/docs/Learn/Forms/Form_validation
// https://developer.mozilla.org/en-US/docs/Web/API/HTMLFormElement/reportValidity
// https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/invalid_event

import { ref, Ref } from 'vue'

interface Options {
  useCustomErrorMessages?: boolean
}

export function useValidation(
  inputRef: Ref<HTMLInputElement | HTMLTextAreaElement | null>, 
  options: Options = { useCustomErrorMessages: false }
) {

  const focused = ref(false)
  const blurred = ref(false)
  const isInvalid = ref(false)

  const errorsMap = {
    valueMissing: 'This field is required',
    tooShort: (len: string) => `Must be ${len} characters or more`,
    tooLong: (len: string) => `Must be ${len} characters or less`,
    type: (type: string) => `This field must be a valid ${type}`,
    patternMismatch: (pattern: string) => `This field must match the requested format ${pattern}`,
  }

  const attributesMap = {
    tooShort: 'minLength',
    tooLong: 'maxLength',
    type: 'type',
    patternMismatch: 'pattern'
  }

  function errorMessage() {
    if (options.useCustomErrorMessages && inputRef.value?.validity) {
      const invalidKeys = []
      const messages = []

      // check the input for validity errors
      for (const key in inputRef.value.validity) {
        if (inputRef.value.validity[key as keyof ValidityState]) {
          invalidKeys.push(key)
        }
      }

      // if there are errors, get the custom error message
      if (invalidKeys.length) {
        for (const key of invalidKeys) {
          let message = null
          const errorHandler = errorsMap[key as keyof typeof errorsMap]

          if (typeof errorHandler === 'function') {
            const attr = attributesMap[key as keyof typeof attributesMap]
            const attrValue = inputRef.value.getAttribute(attr)
            message = attrValue ? errorHandler(attrValue) : ''
          } else {
            message = errorHandler
          }

          // check for input specific override error messages. Example: "Please enter a valid phone number" as a user friendly message when using a regex pattern to validate the field format. 
          const dataKey = key.replace(/[A-Z]/g, m => "-" + m.toLowerCase())
          const overrideMessage = inputRef.value.getAttribute(`data-${dataKey}-message`)
          if (overrideMessage) {
            message = overrideMessage
          }

          messages.push(message)
        }
        return messages.join(', ')
      }
    }

    // use the default browser error messages
    return inputRef.value?.validationMessage ?? null
  }

  function valid() {
    return inputRef.value?.validity.valid ?? false
  }

  function showErrorMessage() {
    return !valid() && (blurred.value || isInvalid.value)
  }

  function handleFocus() {
    focused.value = true
    blurred.value = false
  }

  function handleBlur() {
    blurred.value = true
    focused.value = false
  }

  function handleInvalid(e: Event) {
    e.preventDefault()
    isInvalid.value = true
  }

  return { 
    valid,
    isInvalid, 
    blurred, 
    focused, 
    errorMessage, 
    showErrorMessage, 
    handleBlur,
    handleFocus, 
    handleInvalid
  }
}