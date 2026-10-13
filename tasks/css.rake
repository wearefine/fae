require_relative 'fae_css_builder'

namespace :fae do
  namespace :css do
    desc 'Build app/assets/builds/fae_admin.css from app/stylesheets'
    task :build do
      path = FaeCssBuilder.build
      puts "Wrote #{path.relative_path_from(FaeCssBuilder::ROOT)} (#{path.size / 1024}KB)"
    end

    desc 'Fail if the committed fae_admin.css is out of date with app/stylesheets'
    task :check do
      abort 'app/assets/builds/fae_admin.css is out of date. Run `rake fae:css:build`.' unless FaeCssBuilder.current?
    end

    desc 'Rebuild fae_admin.css whenever a stylesheet source changes'
    task :watch do
      mtimes = -> { FaeCssBuilder.sources.map { |f| File.mtime(f) }.max }
      last = nil
      puts 'Watching app/stylesheets (Ctrl-C to stop)'
      loop do
        current = mtimes.call
        if current != last
          begin
            FaeCssBuilder.build
            puts "#{Time.now.strftime('%T')} rebuilt fae_admin.css"
          rescue Sass::CompileError => e
            puts e.full_message
          end
          last = current
        end
        sleep 1
      end
    end
  end
end
