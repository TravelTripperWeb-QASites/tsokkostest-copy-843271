Jekyll::Hooks.register :site, :post_read do |site|
  locale = site.active_lang
  default_locale = site.default_lang

  site.pages.each do |page|
    page.data = translate_data(page.data, locale, default_locale)
    permalink = page.data['permalink']
    if permalink && !(permalink.end_with?('/') || permalink.end_with?('.html'))
      p "Permalink #{permalink} is invalid. Must ends with '/' or html extension"
      page.data['permalink'] += '.html'
    end
  end
end
