class StaticPageDecorator

  Fae::StaticPage.class_eval do
    def instance_is_decorated
      "Fae::StaticPage instance is decorated"
    end
  end

end