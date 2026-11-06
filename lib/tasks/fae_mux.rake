namespace :fae do
  namespace :mux do
    desc 'Delete Mux assets in this non-production environment that no Fae::Video references. Dry run unless CONFIRM=1.'
    task purge_orphans: :environment do
      dry_run = ENV['CONFIRM'] != '1'

      begin
        orphans = Fae::Video.purge_orphaned_mux_assets(dry_run: dry_run)
      rescue ArgumentError => e
        abort e.message
      end

      verb = dry_run ? 'Would delete' : 'Deleted'
      orphans.each do |asset|
        created = Time.at(asset.created_at.to_i).utc.strftime('%Y-%m-%d %H:%M UTC')
        puts "#{verb} #{asset.id} (created #{created}, passthrough #{asset.passthrough.inspect})"
      end
      puts "#{verb} #{orphans.size} orphaned asset(s) in Mux environment '#{Fae::Video.mux_environment}'."
      puts 'Run again with CONFIRM=1 to delete them.' if dry_run && orphans.any?
    end
  end
end
