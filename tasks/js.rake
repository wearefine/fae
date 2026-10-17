require_relative 'fae_js_builder'

namespace :fae do
  namespace :js do
    desc 'Build app/assets/builds/fae_admin.js from app/legacy_js'
    task :build do
      path = FaeJsBuilder.build
      puts "Wrote #{path.relative_path_from(FaeJsBuilder::ROOT)} (#{path.size / 1024}KB)"
    end

    desc 'Fail if the committed fae_admin.js is out of date with app/legacy_js'
    task :check do
      abort 'app/assets/builds/fae_admin.js is out of date. Run `rake fae:js:build`.' unless FaeJsBuilder.current?
    end

    desc 'Rebuild fae_admin.js whenever a legacy JavaScript source changes'
    task :watch do
      mtimes = -> { FaeJsBuilder.sources.map { |f| File.mtime(f) }.max }
      last = nil
      puts 'Watching app/legacy_js (Ctrl-C to stop)'
      loop do
        current = mtimes.call
        if current != last
          begin
            FaeJsBuilder.build
            puts "#{Time.now.strftime('%T')} rebuilt fae_admin.js"
          rescue StandardError => e
            puts e.full_message
          end
          last = current
        end
        sleep 1
      end
    end
  end

  desc 'Build all prebuilt admin assets (CSS and JS)'
  task build: %w[fae:css:build fae:js:build]
end
