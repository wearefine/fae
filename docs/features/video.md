# Video (Mux)

* [Overview](#overview)
* [Setup](#setup)
* [Adding Video to a Model](#adding-video-to-a-model)
* [Adding Video to a Page](#adding-video-to-a-page)
* [Displaying Video on Your Site](#displaying-video-on-your-site)
* [How It Works](#how-it-works)
* [Multiple Deployments (prod and dev)](#multiple-deployments-prod-and-dev)
* [Cleaning Up Orphaned Assets](#cleaning-up-orphaned-assets)
* [Local Development](#local-development)
* [Limitations](#limitations)
* [Reference](#reference)

---

## Overview

Fae can attach videos to your models with `Fae::Video`, which stores and streams them through [Mux](https://www.mux.com/). It works much like `Fae::Image`, but the video file never passes through your app server or your S3 bucket:

1. The admin picks a file in the form, and the browser uploads it straight to Mux.
2. Mux transcodes the video and tells Fae when it's ready by sending a webhook.
3. Fae stores the asset's **playback ID**, which your site uses to stream the video and fetch thumbnails from Mux's CDN.

In the admin, a video field shows a processing message while Mux works, then a thumbnail that opens the video in a modal player.

## Setup

### 1. Install the migration

`Fae::Video` uses the `fae_videos` table.

```bash
rake fae:install:migrations
rake db:migrate
```

### 2. Create a Mux access token

In the Mux dashboard, go to **Settings → Access Tokens** and create a token with **Mux Video** read and write permissions for the environment this deployment will use. Fae uses it to create uploads and to read, update, list and delete assets.

### 3. Set environment variables

| variable | required | description |
| -------- | -------- | ----------- |
| `MUX_TOKEN_ID` | yes | Access token ID. |
| `MUX_TOKEN_SECRET` | yes | Access token secret. |
| `MUX_WEBHOOK_SECRET` | yes | Signing secret for the webhook you create in step 4. Without it, every webhook is rejected and videos stay "processing". |
| `MUX_ENVIRONMENT` | yes, for any deployment that shares a database with another | A name for the Mux environment these tokens belong to, e.g. `production` or `development`. See [Multiple Deployments](#multiple-deployments-prod-and-dev). Defaults to `Rails.env`. |
| `MUX_DATA_ENV_KEY` | no | [Mux Data](https://www.mux.com/data) environment key, exposed as `Fae.mux_data_env_key`. Only needed when this Rails app renders your site; headless frontends set their own key. See [Displaying Video on Your Site](#displaying-video-on-your-site). |

Fae configures the `mux_ruby` client from `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET`. To configure it some other way, call `MuxRuby.configure` in your own initializer.

`MUX_ENVIRONMENT` and `MUX_DATA_ENV_KEY` are read into `Fae.mux_environment` and `Fae.mux_data_env_key`, which you can also set in `config/initializers/fae.rb`:

```ruby
Fae.setup do |config|
  config.mux_environment = ENV['MUX_ENVIRONMENT']
  config.mux_data_env_key = ENV['MUX_DATA_ENV_KEY']
end
```

### 4. Add the webhook

In the Mux dashboard, go to **Settings → Webhooks**, choose the same environment as your access token, and add a webhook pointing at:

```
https://your-site.com/<fae mount path>/mux/webhook
```

For the usual `mount Fae::Engine => '/admin'`, that's `https://your-site.com/admin/mux/webhook`. Copy the webhook's signing secret into `MUX_WEBHOOK_SECRET`.

The endpoint doesn't need a Fae login. Instead, it [verifies Mux's signature](https://www.mux.com/docs/core/verify-webhook-signatures) and rejects requests with a missing or wrong signature, or a timestamp more than 5 minutes old.

### 5. Allow Mux in your Content Security Policy

If your app sets a Content Security Policy, the admin needs to:

- load scripts from `cdn.jsdelivr.net` (`@mux/mux-uploader` and `@mux/mux-player`)
- load images from `image.mux.com`
- stream from `stream.mux.com`
- upload to the URL Mux returns for each direct upload

## Adding Video to a Model

### In the Model

```ruby
has_fae_video :intro_video
```

which is a shorthand convenience method for

```ruby
has_one :intro_video, -> { where(attached_as: 'intro_video') },
  as: :videoable,
  class_name: '::Fae::Video',
  dependent: :destroy
accepts_nested_attributes_for :intro_video, allow_destroy: true
```

### In the Controller

As with images, build the video in `build_assets` so the form has an object to render:

```ruby
module Admin
  class LocationsController < Fae::BaseController

    private

    def build_assets
      @item.build_intro_video if @item.intro_video.blank?
    end
  end
end
```

### In the Form

```ruby
fae_video_form f, :intro_video
```

| option | type | default | description |
| ------ | ---- | ------- | ----------- |
| label | string | video_name.to_s.titleize | the uploader's label |
| helper_text | string | | the uploader's helper text |
| alt_label | string | "#{label} Alt Text" | the alt field's label |
| alt_helper_text | string | "Read by search engines and visually impaired readers." | the alt field's helper text |
| show_alt | boolean | true | displays the alt field, label, and helper text |
| required | boolean | false | requires a video to be uploaded before the form can be saved |
| attached_as | symbol | video_name.to_s | Sets the `attached_as` attribute. Customize this if your `attached_as` condition doesn't match the association name. |
| show_form_manager | boolean | true | include the field in the [Form Manager](form_manager.md) |

**Examples**

```ruby
fae_video_form f, :intro_video, label: 'Intro Video', required: true
fae_video_form f, :hero_loop, show_alt: false, helper_text: 'Plays muted on the homepage.'
```

**Uploading before the record is saved.** On an existing record, the upload is saved to the video as soon as it finishes, and the field updates itself when Mux is done processing. On a new record, the upload is saved with the form; the preview appears after you save, once Mux finishes.

**Removing a video.** The delete button clears the video from the record right away; the upload field reappears so a new video can be added. The Mux asset itself is kept and tagged as deleted (see [Asset tagging](#asset-tagging)).

## Adding Video to a Page

Videos can also be [content blocks](../topics/pages.md) on static pages. Add a `Fae::Video` field to the page's `fae_fields`:

```ruby
class AboutUsPage < Fae::StaticPage

  @slug = 'about_us'

  def self.fae_fields
    {
      hero_video: { type: Fae::Video },
      intro_video: { type: Fae::Video, languages: Fae.languages.keys }
    }
  end

end
```

and render it in the page's form:

```ruby
= fae_video_form f, :hero_video
= fae_video_form f, :intro_video
```

With `languages`, `fae_video_form` renders one uploader per language, each saved as its own video (`intro_video_en`, `intro_video_zh`, ...). As with other translated blocks, `intro_video` returns the default language's video.

The page generator supports a `video` type:

```bash
rails g fae:page AboutUs hero_video:video introduction:text
```

Unlike regular models, pages don't need `build_assets`: the page controller creates each video record when the edit page loads, so an upload is saved to its record as soon as it finishes, even before the page is saved.

In a page's JSON (`as_json`), a video block returns the video's attributes, including `playback_id` and `status`. With GraphQL, the generator types video fields as `Types::FaeVideoType`, which you define in your app; the [GraphQL tutorial](../tutorials/graphql_support.md) has an example.

## Displaying Video on Your Site

Fae doesn't render video on your site for you. Your site plays the stored `playback_id` with whatever player you like; the simplest is [Mux Player](https://www.mux.com/docs/guides/mux-player-web).

### Headless frontends

When Fae serves content to a separate frontend over GraphQL or JSON, expose the video's fields through the API and let the frontend handle playback.

**In Fae,** add a `Types::FaeVideoType` (see the [GraphQL tutorial](../tutorials/graphql_support.md)) and use it for your video fields. The frontend needs:

| field | use |
| ----- | --- |
| `playbackId` | the player's playback ID; also builds stream and image URLs |
| `ready` / `status` | only render a player when `ready` is true |
| `thumbnailUrl` | poster or preview image |
| `aspectRatio`, `duration` | sizing the player, showing a runtime |
| `title`, `alt` | player title and accessible text |

```graphql
{
  aboutUsPage {
    heroVideo {
      playbackId
      ready
      thumbnailUrl
      aspectRatio
      title
      alt
    }
  }
}
```

**On the frontend,** set the [Mux Data](https://www.mux.com/data) environment key as one of the frontend's own environment variables (e.g. `MUX_DATA_ENV_KEY`, or whatever prefix your framework needs to expose it to the browser), with a different key for each frontend environment. Don't serve it from Fae's API: page views happen on the frontend's deployments (production, staging, preview builds), and Fae can't tell which of those is asking. `Fae.mux_data_env_key` isn't used in this setup.

For example, with [Mux Player React](https://www.mux.com/docs/guides/mux-player-web#react):

```jsx
import MuxPlayer from '@mux/mux-player-react';

export function HeroVideo({ video }) {
  if (!video?.ready) return null;

  return (
    <MuxPlayer
      playbackId={video.playbackId}
      streamType="on-demand"
      envKey={process.env.NEXT_PUBLIC_MUX_DATA_ENV_KEY}
      metadata={{ video_title: video.title }}
      onError={() => { /* hide the player or show a fallback */ }}
    />
  );
}
```

### Rails-rendered sites

When the same Rails app that runs Fae renders your site, set `MUX_DATA_ENV_KEY` on each deployment and pass `Fae.mux_data_env_key` to the player:

```slim
/ in your layout, pinned to a specific version
script src="https://cdn.jsdelivr.net/npm/@mux/mux-player@3.14.0"
```

```slim
- video = @location.intro_video
- if video&.ready?
  mux-player[
    playback-id=video.playback_id
    stream-type="on-demand"
    metadata-video-title=video.title
    env-key=Fae.mux_data_env_key
    accent-color="#ff6600"
  ]
```

### Things to know

- **Check `ready?`.** A video is only playable once Mux has finished processing it and `playback_id` is set.
- **Always set an env key, one per site environment,** so viewer analytics are reported to the right Mux Data environment. This matters for development and staging, which play production's playback IDs after a database copy; their views shouldn't land in production's analytics.
- **Handle missing assets.** If a video is deleted in Mux (or a copied database points at another deployment's deleted asset), its playback ID stops working. Listen for the player's `error` event and hide or replace it.
- **Other players** can use the HLS URL `https://stream.mux.com/{playback_id}.m3u8`.
- **Thumbnails** are available from `thumbnail_url` (640px wide), or `video.thumbnail_url(width: 1280)` in Ruby. See [Mux's thumbnail docs](https://www.mux.com/docs/guides/get-images-from-a-video) for more options, such as a different width or a frame at a specific time.

## How It Works

### Upload flow

1. When a file is chosen, `<mux-uploader>` asks Fae (`POST /videos/create_upload`) for a [direct upload](https://www.mux.com/docs/guides/upload-files-directly) URL. Fae creates it with a public playback policy, limited to the admin's origin.
2. The browser uploads the file directly to that URL.
3. When the upload finishes, the upload ID is saved to the `Fae::Video`. On an existing record this happens immediately (`POST /videos/:id/attach_upload`); on a new record, it happens when the form is saved.
4. Mux sends webhooks as the asset is created and processed. Fae finds the video by upload ID or asset ID and updates its `asset_id`, `status`, `playback_id`, `duration` and `aspect_ratio`.
5. While the video is processing, the form polls `GET /videos/:id/status` every 3 seconds and swaps in the thumbnail when it's ready.

Webhooks can arrive before a new record's form is saved. To cover that, Fae fetches the upload and asset from Mux the first time it saves an upload ID.

### Webhook events

| event | effect |
| ----- | ------ |
| `video.upload.asset_created` | stores `asset_id`, sets status to `preparing` |
| `video.upload.errored`, `video.upload.cancelled` | sets the error status |
| `video.asset.ready`, `video.asset.errored` | stores the asset's status, public playback ID, duration and aspect ratio |
| `video.asset.deleted` | clears the video's Mux attributes |

Other events, and events for assets no `Fae::Video` references, are ignored.

### Asset tagging

Fae never deletes a video's Mux asset when it's removed in the admin. Instead it tags the asset's `passthrough` field so abandoned and deleted assets can be found and cleaned up later. Each tag includes the [Mux environment](#multiple-deployments-prod-and-dev) name and ends with `^`:

| tag | when |
| --- | ---- |
| `source-<env>^` | added on upload; marks which deployment uploaded the asset |
| `orphaned-<env>^` | added on upload, removed once a saved `Fae::Video` owns the asset; still present if the form was abandoned |
| `deleted-<env>^` | appended when the video is removed in the admin or its record is destroyed |

For example, a video uploaded on production and later deleted has a passthrough of `source-production^deleted-production^`.

Removed assets still count toward Mux storage until they're deleted in Mux. On non-production deployments the [cleanup task](#cleaning-up-orphaned-assets) handles this. On production, find them in the Mux dashboard by their passthrough tags.

## Multiple Deployments (prod and dev)

A common setup has a production and a development deployment, each with its own database and S3 bucket, and the production database periodically copied down to development. Videos are designed to work with this:

- **Give each deployment its own Mux environment**, with its own access token, webhook and `MUX_WEBHOOK_SECRET`. Mux environments are fully isolated, so each deployment only receives webhooks for its own uploads. Don't share one Mux environment between deployments; the cleanup task relies on this isolation.
- **Set `MUX_ENVIRONMENT` on each deployment** (e.g. `production` and `development`). Don't rely on the `Rails.env` default, since both deployments may run with `RAILS_ENV=production`.
- **Use a separate Mux Data env key per site environment** so analytics aren't mixed: `MUX_DATA_ENV_KEY` on each Fae deployment for Rails-rendered sites, or the frontend's own environment variables for headless sites.

Each `Fae::Video` records the Mux environment that owns it in `mux_environment`. After production's database is copied to development:

- **Playback just works.** Public playback IDs work from any app, so development streams production's videos without copying anything.
- **Mux is only changed by the owner.** Removing or destroying a production video on development only changes development's database row; Fae never calls the Mux API for assets another environment owns.
- **Status polling stops.** A production video that was still processing when the database was copied shows "Processing in production. It will be playable here after the next database sync" instead of polling for a webhook that will never arrive.
- **Deleted assets degrade gracefully.** If production deletes a video, development's copy of the row still points at it until the next database sync. The admin shows "Video unavailable" when the thumbnail or player fails to load; your site should handle the player's `error` event the same way.
- **Development's own uploads become orphans.** Videos uploaded on development lose their database rows the next time production's database is copied down, but the assets stay in development's Mux environment. Use the cleanup task below.

## Cleaning Up Orphaned Assets

```bash
# dry run: lists what would be deleted
rake fae:mux:purge_orphans

# actually delete
CONFIRM=1 rake fae:mux:purge_orphans
```

The task lists every asset in this deployment's Mux environment and deletes the ones that no `Fae::Video` references by asset ID or upload ID. To keep it safe, it:

- **refuses to run** when `MUX_ENVIRONMENT` is blank, `production` or `prod` (case-insensitive)
- **only deletes assets this app uploaded**, i.e. whose passthrough starts with `source-<MUX_ENVIRONMENT>^`; assets uploaded through the Mux dashboard or another app are skipped
- **skips assets less than 24 hours old**, so uploads on forms that haven't been saved yet aren't deleted
- **is a dry run unless `CONFIRM=1`** is set

Deleting a Mux asset is permanent. Run the dry run first and check its output.

A good time to run it is right after copying production's database to development, since that's when development's uploads become orphans.

## Local Development

Mux needs to reach your webhook URL, so local development needs a public tunnel such as [ngrok](https://ngrok.com/):

1. Start a tunnel to your local server, e.g. `ngrok http 3000`.
2. Allow the tunnel's host in `config/environments/development.rb`, e.g. `config.hosts << 'abc123.ngrok-free.app'`. Don't commit this.
3. Point a webhook in your development Mux environment at `https://abc123.ngrok-free.app/admin/mux/webhook` and set `MUX_WEBHOOK_SECRET` to its signing secret.

Without webhooks, uploads still work but videos stay "processing" in the admin. Saving a new record pulls in the video's current state from Mux, so a video that finished processing before you saved will still show as ready.

## Limitations

- **One video per association.** `has_fae_video` and `fae_video_form` support a single `has_one` video; there's no equivalent of a gallery.
- **Public playback only.** Fae creates assets with a public playback policy and stores only the public playback ID. Signed playback isn't supported.
- **No originals are kept.** Fae doesn't store the uploaded file anywhere but Mux. If you ever need the original back, you can enable Mux's [`master_access`](https://www.mux.com/docs/guides/download-for-offline-editing) on the asset at that time; it makes the master available for 24 hours.
- **No captions or text tracks** are managed through the admin.

## Reference

### `Fae::Video` attributes

| attribute | description |
| --------- | ----------- |
| `upload_id` | Mux direct upload ID |
| `asset_id` | Mux asset ID, set once Mux creates the asset |
| `playback_id` | public playback ID, set when the asset is ready |
| `mux_environment` | name of the Mux environment that owns the asset |
| `status` | Mux upload or asset status, e.g. `waiting`, `preparing`, `ready`, `errored`, `cancelled`, `timed_out` |
| `duration` | length in seconds |
| `aspect_ratio` | e.g. `16:9` |
| `title` | the uploaded file's name |
| `alt` | alt text entered in the admin |
| `attached_as` | association name on the parent |
| `required` | whether the form requires a video |

### `Fae::Video` methods

| method | description |
| ------ | ----------- |
| `ready?` | processing finished and a playback ID is available |
| `processing?` | uploaded but not yet ready or errored |
| `errored?` | the upload or asset failed (`errored`, `cancelled` or `timed_out`) |
| `uploaded?` | has an upload or asset |
| `thumbnail_url(width: 640)` | Mux thumbnail URL, or `nil` without a playback ID |
| `owned_by_current_mux_environment?` | `mux_environment` matches this deployment's |
| `Fae::Video.mux_environment` | this deployment's Mux environment name (`Fae.mux_environment`, or `Rails.env` when unset) |

### Customizing

Add methods to `Fae::Video` with `app/models/concerns/fae/video_concern.rb`, as with Fae's [other concerns](../topics/concerns.md).
