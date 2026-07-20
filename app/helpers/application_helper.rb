module ApplicationHelper
  def default_meta_tags
    {
      site: "暮らしのサポートなら『J Work』｜ベビーシッター・家事代行",
      description: "ベビーシッター・外国人シッター・家事代行まで。暮らしを支えるサービスなら『J Work』（kurasera.life）にお任せください。",
      canonical: request.original_url,
      charset: "UTF-8",
      reverse: true,
      separator: '|',
      icon: [
        { href: image_url('favicon.ico') },
        { href: image_url('favicon.ico'), rel: 'apple-touch-icon' },
      ],
    }
  end
end
