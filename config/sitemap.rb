require Rails.root.join("lib/public_sitemap")

host = "https://kurasera.life"
entries = PublicSitemap.compose(
  host: host,
  static_entries: [
    { path: "/", changefreq: "weekly", priority: 1.0 },
    { path: "/living", changefreq: "monthly", priority: 0.9 },
    { path: "/home-care", changefreq: "monthly", priority: 0.9 },
    { path: "/baby-care", changefreq: "monthly", priority: 0.9 }
  ]
)

PublicSitemap.write!(host: host, entries: entries)
