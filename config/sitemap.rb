SitemapGenerator::Sitemap.default_host = "https://kurasera.life"
SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.create do
  # トップ（ポータル）
  add '/', changefreq: 'weekly', priority: 1.0

  # 暮らしサポートLP
  add '/baby',         changefreq: 'monthly', priority: 0.9
  add '/babysitter',   changefreq: 'monthly', priority: 0.9
  add '/housekeeping', changefreq: 'monthly', priority: 0.9
end
