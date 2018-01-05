# By default if you have the FakeWeb gem installed when the specs are
# run they will hit recorded responses.  However, if you don't have
# the FakeWeb gem installed or you set the environment variable
# LIVE_TEST then the tests will hit the live site IMDB.com.
#
# Having both methods available for testing allows you to quickly
# refactor and add features, while also being able to make sure that
# no changes to the IMDB.com interface have affected the parser.
###

require 'rspec'

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'imdb'

def read_fixture(path)
  File.read(File.expand_path(File.join(File.dirname(__FILE__), 'fixtures', path)))
end

IMDB_SAMPLES = {
  'http://akas.imdb.com:80/find?q=Kannethirey+Thondrinal;s=tt' => 'search_kannethirey_thondrinal',
  'http://akas.imdb.com/title/tt0330508/?fr=c2M9MXxsbT01MDB8ZmI9dXx0dD0xfG14PTIwfGh0bWw9MXxjaD0xfGNvPTF8cG49MHxmdD0xfGt3PTF8cXM9S2FubmV0aGlyZXkgVGhvbmRyaW5hbHxzaXRlPWFrYXxxPUthbm5ldGhpcmV5IFRob25kcmluYWx8bm09MQ__;fc=1;ft=1' => 'tt0330508',
  'http://akas.imdb.com:80/find?q=I+killed+my+lesbian+wife;s=tt' => 'search_killed_wife',
  'http://akas.imdb.com/find?q=Star+Trek%3A+TOS;s=tt' => 'search_star_trek',
  'http://akas.imdb.com:80/title/tt0117731/reference' => 'tt0117731',
  'http://akas.imdb.com:80/title/tt0095016/reference' => 'tt0095016',
  'http://akas.imdb.com/title/tt0095016/' => 'apex',
  'http://akas.imdb.com/title/tt0095016/reviews' => 'userreviews',
  'http://akas.imdb.com/title/tt0095016/plotsummary' => 'plotsummary',
  'http://akas.imdb.com/title/tt0095016/locations' => 'locations',
  'http://akas.imdb.com/title/tt0095016/releaseinfo' => 'releaseinfo',
  'http://akas.imdb.com:80/title/tt0242653/reference' => 'tt0242653',
  'http://akas.imdb.com:80/title/tt1821700/reference' => 'tt1821700',
  'http://akas.imdb.com/title/tt1821700/fullcredits' => 'fullcredits',
  'http://akas.imdb.com/title/tt0166222/?fr=c2M9MXxsbT01MDB8ZmI9dXx0dD0xfG14PTIwfGh0bWw9MXxjaD0xfGNvPTF8cG49MHxmdD0xfGt3PTF8cXM9SSBraWxsZWQgbXkgbGVzYmlhbiB3aWZlfHNpdGU9YWthfHE9SSBraWxsZWQgbXkgbGVzYmlhbiB3aWZlfG5tPTE_;fc=1;ft=7' => 'tt0166222',
  'http://akas.imdb.com:80/chart/top' => 'top_250',
  'http://akas.imdb.com/chart/boxoffice' => 'box_office',
  'http://akas.imdb.com/title/tt0111161/reference' => 'tt0111161',
  'http://akas.imdb.com/title/tt0111161/' => 'tt0111161_apex',
  'http://akas.imdb.com/title/tt1401252/reference' => 'tt1401252',
  'http://akas.imdb.com/title/tt0083987/reference' => 'tt0083987',
  'http://akas.imdb.com/title/tt0036855/reference' => 'tt0036855',
  'http://akas.imdb.com/title/tt0110912/reference' => 'tt0110912',
  'http://akas.imdb.com/title/tt0468569/reference' => 'tt0468569',
  'http://akas.imdb.com/title/tt1520211/reference' => 'tt1520211',
  'http://akas.imdb.com/title/tt1520211/episodes?season=1' => 'thewalkingdead-s1',
  'http://akas.imdb.com/title/tt1628064/reference' => 'thewalkingdead-s1e2',
  'http://akas.imdb.com/title/tt0898266/episodes?season=1' => 'tbbt-s1',
  'http://akas.imdb.com/title/tt0898266/reference' => 'tt0898266',
  'http://akas.imdb.com/title/tt0056801/reference' => 'tt0056801',
  'http://akas.imdb.com/title/tt0804503/reference' => 'tt0804503',
  'http://akas.imdb.com/title/tt0804503/' => 'tt0804503_apex',
  'http://www.imdb.com/name/nm0000019/' => 'nm0000019',
  'http://www.imdb.com/name/nm0000229/' => 'nm0000229',
  'http://www.imdb.com/name/nm0051482/' => 'nm0051482',
  'http://www.imdb.com/name/nm1879589/' => 'nm1879589',
  'http://www.imdb.com/name/nm0000206/' => 'nm0000206',
}

unless ENV['LIVE_TEST']
  begin
    require 'rubygems'
    require 'fakeweb'

    FakeWeb.allow_net_connect = false
    IMDB_SAMPLES.each do |url, fixture|
      FakeWeb.register_uri(:get, url, response: read_fixture(fixture))
    end
  rescue LoadError
    puts 'Could not load FakeWeb, these tests will hit IMDB.com'
    puts 'You can run `gem install fakeweb` to stub out the responses.'
  end
end
