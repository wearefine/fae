require 'spec_helper'
require 'rails/generators'
require 'generators/fae/importmap_generator'

describe Fae::ImportmapGenerator do
  let(:destination) { Dir.mktmpdir }
  let(:manifest) { File.join(destination, 'app/assets/config/manifest.js') }

  after { FileUtils.remove_entry(destination) }

  def run_generator
    original = $stdout
    $stdout = StringIO.new
    described_class.start([], destination_root: destination)
  ensure
    $stdout = original
  end

  it 'creates the host importmap config and entry point' do
    run_generator

    expect(File.read(File.join(destination, 'config/fae_importmap.rb'))).to include("pin 'fae_custom'")
    expect(File).to exist(File.join(destination, 'app/javascript/fae_custom.js'))
    expect(File).to exist(File.join(destination, 'app/javascript/fae_custom/controllers/.keep'))
  end

  it 'links the host modules in the sprockets manifest once, on their own lines' do
    FileUtils.mkdir_p(File.dirname(manifest))
    File.write(manifest, '//= link application.js')

    run_generator
    run_generator

    expect(File.read(manifest)).to eq(<<~JS)
      //= link application.js
      //= link fae_custom.js
      //= link_tree ../../javascript/fae_custom .js
    JS
  end
end
