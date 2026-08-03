import { computed } from 'vue'

/**
 * Submission rules for image and file fields.
 *
 * Unlike every other field type these are not columns on the record: they are
 * a has_one Fae::Image / Fae::File, saved through the
 * accepts_nested_attributes_for that has_fae_image / has_fae_file declares. So
 * on the way out they are renamed from `logo` to `logo_attributes`, and a
 * chosen File turns the request into a multipart one.
 *
 * @param {import('vue').Ref<Array>} fields the form's field descriptors
 */
export function useAssetFields(fields) {
  const assetFields = computed(() => fields.value.filter((field) => field.asset))
  const hasAssets = computed(() => assetFields.value.length > 0)

  function toParams(data) {
    const params = { ...data }

    for (const field of assetFields.value) {
      delete params[field.name]

      const attributes = assetAttributes(field, data[field.name])
      if (attributes) params[field.asset.paramKey] = attributes
    }

    return params
  }

  return { assetFields, hasAssets, toParams }
}

/**
 * Rack::MethodOverride only reads _method out of a form-encoded POST, so a
 * multipart PUT has to be spoofed. Forcing FormData even when no file was
 * chosen is what guarantees the override arrives as a form field rather than
 * inside a JSON body -- otherwise an untouched form would be taken as a POST
 * and create a second record.
 */
export function assetSubmitOptions(hasAssets, method) {
  const spoof = hasAssets && method !== 'post' && method !== 'get'

  return {
    method: spoof ? 'post' : method,
    extraParams: spoof ? { _method: method } : {},
    forceFormData: hasAssets,
  }
}

function assetAttributes(field, value) {
  const attributes = {}

  if (value?.id) attributes.id = value.id
  // Absent means "leave the stored asset alone", which is how the Slim form's
  // empty file input behaved.
  if (value?.asset) attributes.asset = value.asset

  if (field.asset.kind === 'image') {
    if (field.asset.showAlt) attributes.alt = value?.alt ?? ''
    if (field.asset.showCaption) attributes.caption = value?.caption ?? ''
  }

  // Fae::AssetsValidatable reads this off the record, so it has to travel with
  // the attributes exactly as the hidden field in the Slim uploader did.
  if (field.required) attributes.required = true

  // Nothing stored, nothing chosen and nothing to validate: say nothing rather
  // than build an assetless Fae::Image on every save.
  if (!attributes.id && !attributes.asset && !field.required) return null

  return attributes
}
