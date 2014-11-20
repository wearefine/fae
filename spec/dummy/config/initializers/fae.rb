Fae.setup do |config|

  config.devise_secret_key = '79a3e96fecbdd893853495ff502cd387e22c9049fd30ff691115b8a0b074505be4edef6139e4be1a0a9ff407442224dbe99d94986e2abd64fd0aa01153f5be0d'

  config.nav_items = [
    {
      text: "Releases", path: "/admin/releases"
    },
    {
      text: "Wines", path: "/admin/wines"
    },
    {
      text: "Acclaim", path: "/admin/acclaims"
    },
    {
      text: "Varietal", path: "/admin/varietals"
    },
    {
      text: "Selling Point", path: "/admin/selling_points"
    },
    {
      text: "Event", path: "/admin/events"
    },
    {
      text: "Event Hosts", path: "/admin/people"
    },
    {
      text: "Locations", path: "/admin/locations"
    }
  ]
end