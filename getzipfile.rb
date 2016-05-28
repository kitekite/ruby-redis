require 'rubygems'
require 'open-uri'
require 'zip/zip'
require 'xml/to/json'
require File.join(File.dirname(__FILE__), 'newslist')
require File.join(File.dirname(__FILE__), 'ziplist')

Zips = ZipList.new
News = NewsList.new


def ziplist()
	Dir.glob("tmp/*/*.zip") do |filename|
		#p filename+" "+((File.join(Dir.pwd,filename)).to_s+" "+(File.basename(filename,File.extname(filename))).to_s)
		extractzip((File.join(Dir.pwd,filename)).to_s, (File.basename(filename,File.extname(filename))).to_s)
	end
	#if !filename.blank?

end

def extractzip(file_path, filename)
	Zip::ZipFile.open(file_path) do |zipfile|
		#p filename+"  -- "+file_path
		xmlf = File.join('tmp',filename)
		Dir.mkdir xmlf unless File.exists? xmlf
		zipfile.each{|e|
			fpath = File.join(xmlf, e.name) #e.to_s
			#the block is for handling an existing file. returning true will overwrite the files.
			zipfile.extract(e, fpath){ true }
		}
	end
	
end

def readxml()
	Dir.glob("tmp/*/*.xml") do |xmlfile|
		#p "inside readxml"+xmlfile
		data = Nokogiri::XML(open(xmlfile))
		News.push(data)
	end
		
end



begin
	
	Thread.abort_on_exception = true

	bigthreads = []
	bigthreads << Thread.new{
		Zips.getzip()
	}
	sleep 120
	bigthreads << Thread.new{
		10.times {
			ziplist()
		}
	}
	sleep 90
	bigthreads << Thread.new{
		30.times {
			readxml()
		}
	}

	sleep 60
	
	bigthreads.each(&:join)

rescue Exception => e
  	print e, "\n"
end





