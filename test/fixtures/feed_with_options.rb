feed.title = 'Code from Eloy Duran (alloy)'
feed.description = 'The Ruby libraries, from Eloy Duran, available as open-source projects'

feed.entry = lambda do |xml, repo|
  xml.entry do
    xml.id      "#{repo.url}##{repo.version}"
    xml.updated repo.updated_at.iso8601
    xml.title   "#{repo.name.capitalize} #{repo.version}"
    xml.link    :href => repo.url
    xml.summary repo.summary
    xml.content repo.description
  end
end