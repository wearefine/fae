(1..4).each do |i|

  Wine.create(name_en: "wine #{i}")

  Acclaim.create(score: "#{100-(2*1)}", publication: "The #{i.ordinalize} publication for an acclaim", description: "description"*i )

  Varietal.create(name: "varietal #{i}")

  SellingPoint.create(name: "selling point #{i}")

  Person.create(name: "host ##{i}")

end