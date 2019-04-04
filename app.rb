require 'httparty'
require 'open-uri'
require 'json'

urls_file = 'urls.json'
filmUrls = Array.new

filmsDataSrc = HTTParty.get('http://www.tiff.net/data/films-events.json')
filmsData = JSON.parse(filmsDataSrc.body)

filmsData["items"].each do |film|
  if(film['url'].start_with?("/film"))
    filmUrls.push("http://www.tiff.net/data#{film['url']}.json")
  end
end
File.open("urls.json", "w") do |f|
  f.write(JSON.pretty_generate(filmUrls))
end

films = Array.new

for url in filmUrls do
  print url + "\n"
  tiffJSON = HTTParty.get(url)
  filmsJSON = JSON.parse(tiffJSON.body)
  film = Hash.new
  film["name"] = filmsJSON['title'] ? filmsJSON['title'] : "N/A"
  film["program"] = filmsJSON['programmes'] ? filmsJSON['programmes'][0] : "N/A"
  film["director"] = filmsJSON['credits']['leadCredits'] ? filmsJSON['credits']['leadCredits'][0] : "N/A"
  film["countries"] = filmsJSON['countries'] ? filmsJSON['countries'][0] : "N/A"
  film["runtime"] = filmsJSON['runtime'] ? filmsJSON['runtime'] : "N/A"
  film["premiere"] = filmsJSON['festivalPremiere'] ? filmsJSON['festivalPremiere'] : "N/A"
  film["year"] = filmsJSON['year'] ? filmsJSON['year'] :  "N/A"
  film["language"] = filmsJSON['languages'] ? filmsJSON['languages'][0] : "N/A"
  film["pitch"] = filmsJSON['pitch'] ? filmsJSON['pitch'] : "N/A"
  film["production"] = filmsJSON['credits']['productionCompany'] ? filmsJSON['credits']['productionCompany'][0] : "N/A"

  if filmsJSON['credits']['producers']
    filmsJSON['credits']['producers'].each do |producer|
      film["producers"] = film["producers"] ? film["producers"] + ", " + producer : producer
    end
  end

  film["screenplay"] = filmsJSON['credits']['screenplay'] ? filmsJSON['credits']['screenplay'][0] : "N/A"

  if filmsJSON['credits']['cinematographers']
    filmsJSON['credits']['cinematographers'].each do |cinematographer|
      film["cinematographers"] = film["cinematographers"] ? film["cinematographers"] + ", " + cinematographer : cinematographer
    end
  end

  if filmsJSON['credits']['editors']
    filmsJSON['credits']['editors'].each do |editor|
      film["editors"] = film["editors"] ? film["editors"] + ", " + editor : editor
    end
  end

  film["score"] = filmsJSON['credits']['originalScore'] ? filmsJSON['credits']['originalScore'][0] : "N/A"
  film["sound"] = filmsJSON['credits']['sound'] ? filmsJSON['credits']['sound'][0] : "N/A"

  if filmsJSON['credits']['cast']
    filmsJSON['credits']['cast'].each do |actor|
      film["cast"] = film["cast"] ? film["cast"] + ", " + actor : actor
    end
  end

  film["image"] = filmsJSON['image'] ? "http:" + filmsJSON['image'] + "?w=300&q=40" : "http://images.contentful.com/22n7d68fswlw/3gsxh563eUeWeYEUeOOce8/a021e2b89368133718742fca6a2d482d/FEST17-no-image.jpg?w=300?q=40"

  film["url"] = "http://www.tiff.net/tiff/film.html?v=" + filmsJSON['slug']
  #film["schedule"] = []
  #scheduleDom = tiffDOM.css("#schedule-buttons > div")
  #for dateDom in scheduleDom
  #    dateid = dateDom.attr("id")[0...-3].to_i
  #  date = Time.at(dateid).strftime('%A %B %e')
  #  hash = {:date => date, :shows => []}
  #  timeDom = tiffDOM.css("#" + dateDom.attr("id") + " a")
  #  for time in timeDom
  #    timeHash = {}
  #    timeHash[:time] = time.css(".time").text
  #    timeHash[:location] = time.css(".flags .location").text
  #    timeHash[:press] = time.at_css("i.press-industry") ? true : false
  #    timeHash[:premium] = time.at_css(".flag.premium") ? true : false
  #    hash[:shows].push(timeHash)
  #  end

  #  film["schedule"].push(hash)
  #end
  films.push(film)
end

films = films.sort{|a,b| a['name']<=>b['name']}

File.open("films.json","w") do |f|
  f.write(JSON.pretty_generate(films))
end
