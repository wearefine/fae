super_admin = Fae::Role.create(name: 'Super Admin', position: 0)
Fae::User.create(
  first_name: 'FINE',
  last_name: 'admin',
  email: 'admin@finedesigngroup.com',
  password: 'doingfine',
  role: super_admin
  )