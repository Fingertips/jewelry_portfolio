repos.each do |repo|
  xml.entry do
    xml.title   "#{repo.name} #{repo.version}"
    xml.link    :href => repo.url
    xml.summary repo.summary
    xml.content repo.description
  end
end