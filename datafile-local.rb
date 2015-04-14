class DataFileLocal

	def save( tmpfile, name)
		IO.copy_stream(tmpfile, '/data/img/originals/' << name)
	end

	def cropExists( name) 
		return File.exists?('/data/img/public/' << name)
	end

	def saveCrop( image, name)
		aFile = File.new( '/data/img/public/' << name, "w")
		aFile.write( image)
		aFile.close
	end

	def load(name)
		return Magick::Image.read( '/data/img/originals/' << name).first
	end

	def publicUrl(name)
		return "/img/public/"<<name
	end
  
	def initialize()
		FileUtils.mkdir_p "/data/img/public"
		FileUtils.mkdir_p "/data/img/originals"
	end

end