super_admin = Fae::Role.create(name: 'Super Admin', position: 0)
Fae::User.create(
  first_name: 'FINE',
  last_name: 'admin',
  email: 'admin@finedesigngroup.com',
  password: 'doingfine',
  role: super_admin,
  active: true
  )

(1..4).each do |i|

  Wine.create(name: "wine #{i}")

  Acclaim.create(score: "#{100-(2*1)}", publication: "The #{i.ordinalize} publication for an acclaim", description: "description"*i )

  Varietal.create(name: "varietal #{i}")

  SellingPoint.create(name: "selling point #{i}")

  Person.create(name: "host ##{i}")

end