module WasSeedThumbsFixtures
  def thumbs_list
    <<-JSON
    {"thumbnails": [
      {
        "memento_uri": "https://swap.stanford.edu/20121129060351/http://naca.central.cranfield.ac.uk/",
        "memento_datetime": "20121129060351",
        "thumbnail_uri": "https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20121129060351/full/200,/0/default.jpg"
      },
      {
        "memento_uri": "https://swap.stanford.edu/20130412231301/http://naca.central.cranfield.ac.uk/",
        "memento_datetime": "20130412231301",
        "thumbnail_uri": "https://stacks.stanford.edu/image/iiif/gb089bd2251%2F20130412231301/full/200,/0/default.jpg"
      }
    ]}
    JSON
  end
  
  def empty_thumbs_list
    <<-JSON
    {"thumbnails": []}
    JSON
  end  
end