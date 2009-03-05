repos.each do |repo|
  xml.entry do
    xml.id      "#{repo.url}##{repo.version}"
    xml.updated repo.updated_at.iso8601
    xml.title   "#{repo.name} #{repo.version}"
    xml.link    :href => repo.url
    xml.summary repo.summary
    xml.content repo.description
  end
end