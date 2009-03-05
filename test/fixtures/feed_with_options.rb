feed.title = 'Code from Eloy Duran (alloy)'
feed.description = 'The Ruby libraries, from Eloy Duran, available as open-source projects'

def feed.id_for_repo(repo)
  "#{repo.name}-#{repo.version}"
end

def feed.updated_for_repo(repo)
  'Right about NOW!'
end

def feed.title_for_repo(repo)
  "#{repo.name.capitalize} (#{repo.version})"
end

def feed.link_for_repo(repo)
  "http://google.com?q=#{repo.name}"
end

def feed.summary_for_repo(repo)
  "#{repo.name.capitalize} is awesome!"
end

def feed.description_for_repo(repo)
  summary_for_repo(repo)
end