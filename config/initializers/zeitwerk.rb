Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'fae-rails' => 'Fae',
    #'fae-options' => 'Fae',
  )
end

#Rails.autoloaders.main.ignore(Rails.root.join('lib/fae/options.rb'))