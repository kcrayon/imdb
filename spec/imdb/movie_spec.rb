# encoding: utf-8

require 'spec_helper'

# This test uses "Die hard (1988)" as a testing sample:
#
#     http://www.imdb.com/title/tt0095016/reference
#

describe 'Imdb::Movie' do
  describe 'valid movie' do
    # Get Die Hard (1988)
    subject { Imdb::Movie.new('0095016') }

    it 'finds the cast members' do
      cast = subject.cast_members
      expected_cast = [
        'Bruce Willis',
        'Bonnie Bedelia',
        'Alan Rickman',
      ]

      expect(cast).to be_an(Array)
      expect(cast).to include(*expected_cast)
    end

    it 'finds the cast characters' do
      char = subject.cast_characters
      expected_cast_characters = [
        'Karl',
        'John McClane',
        'Police Detective',
        'Hostage',
      ]

      expect(char).to be_an(Array)
      expect(char).to include(*expected_cast_characters)
    end

    it 'associates the cast members to the characters' do
      cast = subject.cast_members
      char = subject.cast_characters
      cast_char = subject.cast_members_characters

      expect(cast_char[0]).to eq("Bruce Willis => John McClane")
      expect(cast_char[0]).to eq("#{cast[0]} => #{char[0]}")
      expect(cast_char[10]).to eq("#{cast[10]} => #{char[10]}")
      expect(cast_char[-1]).to eq("#{cast[-1]} => #{char[-1]}")

      cast_char = subject.cast_members_characters('as')

      expect(cast_char[1]).to eq("#{cast[1]} as #{char[1]}")
      expect(cast_char[11]).to eq("#{cast[11]} as #{char[11]}")
      expect(cast_char[-2]).to eq("#{cast[-2]} as #{char[-2]}")
    end

    it 'finds the starring actors' do
      stars = subject.starring_actors
      expect(stars).to eq(['Bruce Willis', 'Alan Rickman', 'Bonnie Bedelia'])
    end

    it 'can get the user reviews' do
      reviews = subject.user_reviews

      expect(reviews).to be_an(Enumerator)
      first_reviews = reviews.first(40) # Needs to load 2 pages since each page contains 24 reviews
      expect(first_reviews).to be_an(Array)

      first_reviews.each do |review|
        expect(review[:title]).not_to be_blank
        expect(review[:review]).not_to be_blank
      end

      reviews_with_ratings = first_reviews.select { |r| r[:rating] }
      expect(reviews_with_ratings.size).to be_between(20, 40)
      reviews_with_ratings.each do |review|
        expect(review[:rating]).to be_an(Integer)
        expect(review[:rating]).to be_between(0, 10)
      end

      ivo_cobra8_review = first_reviews.find { |r| r[:title].include?('hands down my personal favorite') }
      expect(ivo_cobra8_review).to_not be_nil
      expect(ivo_cobra8_review[:review]).to include('This film has heart and soul.')
      expect(ivo_cobra8_review[:rating]).to eq(10)
    end

    describe 'fetching a list of imdb actor ids for the cast members' do
      it 'does not require arguments' do
        expect { subject.cast_member_ids }.not_to raise_error
      end

      it 'does not allow arguments' do
        expect { subject.cast_member_ids(:foo) }.to raise_error(ArgumentError)
      end

      it 'returns the imdb actor number for each cast member' do
        expect(subject.cast_member_ids).to match_array(%w(
          nm0000246 nm0000614 nm0000889 nm0000952 nm0001108 nm0001817 nm0005598 nm0033749 nm0040472 
          nm0048326 nm0072054 nm0094770 nm0101088 nm0112505 nm0112779 nm0119594 nm0127960 nm0142420 
          nm0160690 nm0162041 nm0234426 nm0236525 nm0239958 nm0278010 nm0296791 nm0319739 nm0322339 
          nm0324231 nm0326276 nm0338808 nm0356114 nm0370729 nm0383487 nm0416429 nm0421114 nm0441665 
          nm0484360 nm0484650 nm0493493 nm0502959 nm0503610 nm0504342 nm0539639 nm0546076 nm0546747 
          nm0662568 nm0669625 nm0681604 nm0687270 nm0688235 nm0718021 nm0731114 nm0776208 nm0793363 
          nm0852311 nm0870729 nm0882139 nm0902455 nm0907234 nm0924636 nm0936591 nm0958105 nm2143912 
          nm2476262 nm2565888 nm0403767 nm0727004 nm1170673 nm0443038 nm2379889
        ))
      end
    end

    it 'returns the url to the movie trailer' do
      expect(subject.trailer_url).to be_a(String)
      expect(subject.trailer_url).to eq('https://www.imdb.com/videoplayer/vi581042457')
    end

    it 'finds the director' do
      expect(subject.director).to eq(['John McTiernan'])
    end

    it 'finds a production company' do
      expect(subject.company).to eq('Twentieth Century Fox')
    end

    it 'finds all production companies' do
      expect(subject.production_companies).to match_array(['Twentieth Century Fox', 'Gordon Company', 'Silver Pictures'])
    end

    it 'finds the genres' do
      expect(subject.genres).to match_array(%w(Action Thriller))
    end

    it 'finds the languages' do
      expect(subject.languages).to match_array(%w(English German Italian Japanese))
    end

    context 'the Dark Knight' do
      # The Dark Knight (2008)
      subject { Imdb::Movie.new('0468569') }

      it 'finds the countries' do
        expect(subject.countries).to match_array(['United States', 'United Kingdom'])
      end
    end

    it 'finds the length (in minutes)' do
      expect(subject.length).to eq(132)
    end

    it 'finds the plot' do
      expect(subject.plot).to eq('John McClane, officer of the NYPD, tries to save his wife Holly Gennaro and several others that were taken hostage by German terrorist Hans Gruber during a Christmas party at the Nakatomi...')
    end

    it 'finds plot synopsis' do
      expect(subject.plot_synopsis).to match(/John McClane, a detective with the New York City Police Department, arrives in Los Angeles to attempt a Christmas reunion and reconciliation with his estranged wife Holly/)
    end

    it 'finds plot summary' do
      expect(subject.plot_summary).to eq(
        "NYPD cop John McClane goes on a Christmas vacation to visit his wife Holly in Los Angeles where she works for the Nakatomi Corporation. " +
        "While they are at the Nakatomi headquarters for a Christmas party, a group of robbers led by Hans Gruber take control of the building " +
        "and hold everyone hostage, with the exception of John, while they plan to perform a lucrative heist. Unable to escape and with no " +
        "immediate police response, John is forced to take matters into his own hands."
      )
    end

    it 'finds the poster thumbnail' do
      expect(subject.poster_thumbnail).to eq('https://m.media-amazon.com/images/M/MV5BMzNmY2IwYzAtNDQ1NC00MmI4LThkOTgtZmVhYmExOTVhMWRkXkEyXkFqcGdeQXVyMTk5NDA3Nw@@._V1_SY150_CR0,0,101,150_.jpg')
    end

    it 'finds the poster' do
      expect(subject.poster).to eq('https://m.media-amazon.com/images/M/MV5BMzNmY2IwYzAtNDQ1NC00MmI4LThkOTgtZmVhYmExOTVhMWRkXkEyXkFqcGdeQXVyMTk5NDA3Nw@@.jpg')
    end

    it 'finds the rating' do
      expect(subject.rating).to eq(8.2)
    end

    it 'finds the metascore' do
      expect(subject.metascore).to eq(70)
    end

    it 'finds number of votes' do
      expect(subject.votes).to be_within(500_000).of(800_000)
    end

    it 'finds the title' do
      expect(subject.title).to eq('Die Hard')
    end

    it 'finds the tagline' do
      expect(subject.tagline).to eq('It will blow you through the back wall of the theater!')
    end

    it 'finds the year' do
      expect(subject.year).to eq(1988)
    end

    it 'finds the MPAA letter rating' do
      expect(subject.mpaa_letter_rating).to eq('R')
    end

    describe 'special scenarios' do
      context 'The Matrix Revolutions' do
        # The Matrix Revolutions (2003)
        subject { Imdb::Movie.new('0242653') }
        it 'finds multiple directors' do
          expect(subject.director).to match_array(%w(Lana\ Wachowski Lilly\ Wachowski))
        end
      end

      context 'Waar' do
        # Waar (2013)
        subject { Imdb::Movie.new('1821700') }
        it 'finds writers' do
          expect(subject.writers).to eq(['Hassan Rana'])
        end
      end
    end

    it 'finds multiple filming locations' do
      filming_locations = subject.filming_locations
      expect(filming_locations).to be_an(Array)
      expect(filming_locations.size).to eq(4)
      expect(filming_locations[0]).to match(/.*, USA$/i)
    end

    it "finds multiple 'also known as' versions" do
      also_known_as = subject.also_known_as
      aka_hash = Hash[*also_known_as.map { |h| h.values_at(:version, :title) }.flatten]
      expect(also_known_as).to be_a(Array)
      expect(also_known_as.size).to eql(52)
      expect(aka_hash['France']).to eql('Piège de cristal')
      expect(aka_hash['Germany']).to eql('Stirb langsam')
    end

    it "finds a specific 'also known as' version" do
      expect(subject.also_known_as).to include(version: 'Russia', title: 'Крепкий орешек')
    end

    context 'Star Trek: TOS' do
      subject { Imdb::Movie.search('Star Trek: TOS') }
      it 'provides a convenience method to search' do
        expect(subject).to respond_to(:each)
        subject.each { |movie| expect(movie).to be_an_instance_of(Imdb::Movie) }
      end
    end

    context 'top 250 Movies' do
      subject { Imdb::Movie.top_250 }
      it 'provides a convenience method to top 250' do
        expect(subject).to respond_to(:each)
        subject.each { |movie| expect(movie).to be_an_instance_of(Imdb::Movie) }
      end
    end
  end

  describe 'plot' do
    context 'Biography of Mohandas K. Gandhi' do
      subject { Imdb::Movie.new('0083987') }
      it 'finds a correct plot when HTML links are present' do
        expect(subject.plot).to eq("Gandhi's character is fully explained as a man of nonviolence. Through his patience, he is able to drive the British out of the subcontinent. And the stubborn nature of Jinnah and his...")
      end
    end

    context 'movie 0036855' do
      subject { Imdb::Movie.new('0036855') }
      it "does not have a 'more' link in the plot" do
        expect(subject.plot).to eq('Years after her aunt was murdered in her home, a young woman moves back into the house with her new husband. However, he has a secret that he will do anything to protect, even if it means...')
      end
    end
  end

  describe 'mpaa rating' do
    context 'movie 0111161' do
      subject { Imdb::Movie.new('0111161') }
      it 'finds the mpaa rating with explanation when present' do
        expect(subject.mpaa_rating).to eq('Rated R for language and prison violence')
      end
    end

    context 'movie 0095016' do
      subject { Imdb::Movie.new('0095016') }
      it 'is letter only when no explination is present' do
        expect(subject.mpaa_rating).to eq('R')
      end
    end
  end

  describe 'with no submitted poster' do
    context 'Up is Down' do
      # Up Is Down (1969)
      subject { Imdb::Movie.new('1401252') }

      it 'has a title' do
        expect(subject.title(true)).to eq('Up Is Down')
      end

      it 'has a year' do
        expect(subject.year).to eq(1969)
      end

      it 'returns nil as poster url' do
        expect(subject.poster).to be_nil
      end

      it 'returns nil as trailer url' do
        expect(subject.trailer_url).to be_nil
      end

      context 'movie 0111161' do
        subject { Imdb::Movie.new('0111161') }
        it 'returns the release date for movies' do
          expect(subject.release_date).to eq('14 Oct 1994 (USA)')
        end
      end
    end
  end

  describe 'with an old poster (no @@)' do
    context 'Pulp Fiction' do
      # Pulp Fiction (1994)
      subject { Imdb::Movie.new('0110912') }
      it 'has a poster' do
        expect(subject.poster).to eq('https://m.media-amazon.com/images/M/MV5BNGNhMDIzZTUtNTBlZi00MTRlLWFjM2ItYzViMjE3YzI5MjljXkEyXkFqcGdeQXVyNzkwMjQ5NzM@.jpg')
      end
    end
  end

  describe 'with title that has utf-8 characters' do
    context 'WALL-E' do
      # WALL-E
      subject { Imdb::Movie.search('Wall-E').first }

      it 'returns the proper title' do
        expect(subject.title).to eq('WALL·E (2008)')
        expect(subject.title(true)).to eq('WALL·E')
      end

      it 'returns the proper movie' do
        expect(subject.year).to eq(2008)
      end
    end

    context '8 1/2' do
      subject { Imdb::Movie.new('0056801') }

      it 'returns the proper title' do
        expect(subject.title).to include('8½')
      end
    end
  end

  describe 'with many writers and directors' do
    context "Paris, je t'aime" do
      # Paris, je t'aime (2006)
      subject { Imdb::Movie.new('0401711') }
      it 'has many writers' do
        expect(subject.writers.size).to eq(30)
      end

      it "shouldn't have a 'see more' writer" do
        expect(subject.writers).not_to include('See more »')
      end

      it 'has many directors' do
        expect(subject.directors.size).to eq(22)
      end

      it "shouldn't have a 'see more' director" do
        expect(subject.directors).not_to include('See more »')
      end
    end
  end

  describe 'with not much information' do
    context "Avatar 5 (2025)" do
      subject { Imdb::Movie.new('5637536') }
      it 'has one director' do
        expect(subject.director).to eq(['James Cameron'])
      end

      it 'returns nil as trailer url' do
        expect(subject.trailer_url).to be_nil
      end

      it 'returns nil as length' do
        expect(subject.length).to be_nil
      end

      it 'returns "unkown" as plot' do
        expect(subject.plot).to include('unknown')
      end

      it 'returns "missing" as plot synopsys' do
        expect(subject.plot_synopsis).to match(/we don't have a synopsis/i)
      end

      it 'returns nil as plot summary' do
        expect(subject.plot_summary).to be_nil
      end

      it 'returns nil as rating' do
        expect(subject.rating).to be_nil
      end

      it 'returns nil as metascore' do
        expect(subject.metascore).to be_nil
      end

      it 'returns nil as vote' do
        expect(subject.votes).to be_nil
      end

      it 'returns nil as tagline' do
        expect(subject.tagline).to be_nil
      end

      it 'returns an empty enumerable as reviews' do
        expect(subject.user_reviews.to_a).to be_empty
      end
    end

    context "Untitled Star Wars Trilogy: Episode I" do
      subject { Imdb::Movie.new('7617048') }
      it 'has one director' do
        expect(subject.director).to eq(['Rian Johnson'])
      end

      it 'returns nil as trailer url' do
        expect(subject.trailer_url).to be_nil
      end

      it 'returns nil as length' do
        expect(subject.length).to be_nil
      end

      it 'returns nil as year' do
        expect(subject.year).to be_nil
      end

      it 'returns nil as release date' do
        expect(subject.release_date).to be_nil
      end
    end
  end
end
