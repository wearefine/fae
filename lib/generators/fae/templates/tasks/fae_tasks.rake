namespace :fae do
  desc "Seeds the parent app with Fae's defaults"
  task :seed_db => :environment do
    Fae::Role.delete_all
    super_admin = Fae::Role.create(name: 'super admin', position: 0)
                  Fae::Role.create(name: 'admin', position: 1)
                  Fae::Role.create(name: 'user', position: 2)

    Fae::User.where(email: 'admin@finedesigngroup.com').delete_all
    Fae::User.create(
      first_name: 'FINE',
      last_name: 'admin',
      email: 'admin@finedesigngroup.com',
      password: 'doingfine',
      role: super_admin,
      active: true
      )

    if Fae::Option.first.blank?
      option = Fae::Option.new({
        title: 'My FINE Admin',
        singleton_guard: 0,
        time_zone: 'Pacific Time (US & Canada)'
        })
      option.save!
    end
  end
end
