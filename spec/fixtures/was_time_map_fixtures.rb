module WasTimeMapFixtures
  def timemap
    <<-TXT
    <http://ennejah.info/>; rel="original",
    <https://swap.stanford.edu/timemap/link/http://ennejah.info/>; rel="self"; type="application/link-format"; from="Sat, 18 Jul 2009 21:34:31 GMT"; until="Wed, 15 Jun 2011 19:24:24 GMT",
    <https://swap.stanford.edu/http://ennejah.info/>; rel="timegate",
    <https://swap.stanford.edu/20090718213431/http://ennejah.info/>; rel="first memento"; datetime="Sat, 18 Jul 2009 21:34:31 GMT",
    <https://swap.stanford.edu/20090720172528/http://ennejah.info/>; rel="memento"; datetime="Mon, 20 Jul 2009 17:25:28 GMT",
    <https://swap.stanford.edu/20090722192411/http://ennejah.info/>; rel="memento"; datetime="Wed, 22 Jul 2009 19:24:11 GMT",
    <https://swap.stanford.edu/20090729192407/http://ennejah.info/>; rel="memento"; datetime="Wed, 29 Jul 2009 19:24:07 GMT",
    <https://swap.stanford.edu/20100623192415/http://ennejah.info/>; rel="memento"; datetime="Wed, 23 Jun 2010 19:24:15 GMT",
    <https://swap.stanford.edu/20100630192433/http://ennejah.info/>; rel="memento"; datetime="Wed, 30 Jun 2010 19:24:33 GMT",
    <https://swap.stanford.edu/20110615192424/http://ennejah.info/>; rel="last memento"; datetime="Wed, 15 Jun 2011 19:24:24 GMT"
    TXT
  end

  def timemap_new
    <<-TXT
    <https://swap.stanford.edu/timemap/link/http://ennejah.info/>; rel="self"; type="application/link-format"; from="Sat, 18 Jul 2009 21:34:31 GMT",
    <https://swap.stanford.edu/http://ennejah.info/>; rel="timegate",
    <http://ennejah.info/>; rel="original",
    <https://swap.stanford.edu/20090718213431/http://ennejah.info/>; rel="memento"; datetime="Sat, 18 Jul 2009 21:34:31 GMT"; collection="was",
    <https://swap.stanford.edu/20090720172528/http://ennejah.info/>; rel="memento"; datetime="Mon, 20 Jul 2009 17:25:28 GMT"; collection="was",
    <https://swap.stanford.edu/20090722192411/http://ennejah.info/>; rel="memento"; datetime="Wed, 22 Jul 2009 19:24:11 GMT"; collection="was",
    <https://swap.stanford.edu/20090729192407/http://ennejah.info/>; rel="memento"; datetime="Wed, 29 Jul 2009 19:24:07 GMT"; collection="was",
    <https://swap.stanford.edu/20100623192415/http://ennejah.info/>; rel="memento"; datetime="Wed, 23 Jun 2010 19:24:15 GMT"; collection="was",
    <https://swap.stanford.edu/20100630192433/http://ennejah.info/>; rel="memento"; datetime="Wed, 30 Jun 2010 19:24:33 GMT"; collection="was",
    <https://swap.stanford.edu/20110615192424/http://ennejah.info/>; rel="memento"; datetime="Wed, 15 Jun 2011 19:24:24 GMT"; collection="was"
    TXT
  end
end
