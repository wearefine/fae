namespace :fae do
  desc "Seeds the parent app with Fae's defaults"
  task :seed_db => :environment do
    Fae::Role.delete_all
    super_admin = Fae::Role.create(name: 'Super Admin', position: 0)
    Fae::Role.create([
      {name: 'Admin', position: 1},
      {name: 'User', position: 2}
      ])

    Fae::User.create(
      first_name: 'FINE',
      last_name: 'admin',
      email: 'admin@finedesigngroup.com',
      password: 'doingfine',
      role: super_admin,
      active: true
      )
  end
end
