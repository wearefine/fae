require 'pathname'
require 'sass-embedded'

# Compiles app/stylesheets/fae_admin.scss into the prebuilt stylesheet that ships
# with the gem. Hosts never compile Fae's SCSS, so this runs on the maintainer's machine only.
module FaeCssBuilder
  ROOT = Pathname.new(File.expand_path('..', __dir__))
  SOURCE_DIR = ROOT.join('app/stylesheets')
  ENTRY = SOURCE_DIR.join('fae_admin.scss')
  OUTPUT = ROOT.join('app/assets/builds/fae_admin.css')

  # Plain CSS, concatenated ahead of Fae's styles. Kept out of the Sass compilation so
  # Fae's @extend rules can't reach into the vendor selectors.
  VENDOR = %w[reset chosen daterangepicker simplemde.min trumbowyg].freeze

  # The sources still use @import and global functions; migrating to @use is a separate piece of work.
  SILENCED = %w[import global-builtin color-functions slash-div if-function].freeze

  def self.compile
    vendor = VENDOR.map do |name|
      Sass.compile_string(SOURCE_DIR.join("fae/vendor/#{name}.css").read, syntax: :css, style: :compressed, charset: false).css
    end

    fae = Sass.compile(
      ENTRY.to_s,
      load_paths: [SOURCE_DIR.to_s],
      style: :compressed,
      charset: false,
      quiet_deps: true,
      silence_deprecations: SILENCED
    ).css

    "#{(vendor + [fae]).join("\n")}\n"
  end

  def self.build
    OUTPUT.dirname.mkpath
    OUTPUT.write(compile)
    OUTPUT
  end

  def self.current?
    OUTPUT.exist? && OUTPUT.read == compile
  end

  def self.sources
    Dir[SOURCE_DIR.join('**/*')].select { |f| File.file?(f) }
  end
end
