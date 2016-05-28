require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'curb'

class ZipList

  def initialize
    @page = 'http://feed.omgili.com/5Rh5AMTrc4Pv/mainstream/posts/'
    @urls = []

    #force delete 'tmp' folder if exists
    if Dir.exists?('tmp') == true
      FileUtils.remove_dir('tmp',force=false)
    end
    
  end

  def findziplist(page, urls)
    doc = Nokogiri::HTML(open(@page))
    doc.traverse do |el|
      [el[:src], el[:href]].grep(/\.(zip)$/i).map{|l| URI.join(@page, l).to_s}.each do |link| @urls << link  end
    end
  end

  def zipfolder
    
    tmpdir = File.join(Dir.pwd,'tmp')
    Dir.mkdir tmpdir unless File.exists? tmpdir
  end

  def zipdownload
    responses = {}
    m = Curl::Multi.new

    # add a few easy handles
    @urls.each do |url|
      responses[url] = Curl::Easy.new(url)
      puts "Queuing #{ url }..."
      m.add(responses[url])
    end

    spinner_counter = 0
    spinner = %w[ | / - \ ]
    m.perform do
      print 'Performing downloads ', spinner[spinner_counter], "\r"
      spinner_counter = (spinner_counter + 1) % spinner.size
    end

    puts

    @urls.each do |url|
      print "[#{ url } #{ responses[url].total_time } seconds] Saving ..."
      filename = File.basename(url)
      IO.copy_stream(open(url), File.join(tmpdir,filename))
      puts 'done.'
    end
  end

  def getzip
    
    findziplist(@page, @urls)

    if @urls.length != 0
      zipfolder()
      p "Queue size:"+(@urls.length).to_s
      zipdownload()
    end

  end 

end






