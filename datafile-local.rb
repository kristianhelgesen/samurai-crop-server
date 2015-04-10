class DataFileLocal
    
    
	def save( tmpfile, name)
		aFile = File.new( 'img/originals/' << name, "w")
		aFile.write( tmpfile)
		aFile.close
	end
  
	def cropExists( name) 
		return File.exists?('img/public/' << name)
	end
  
	def saveCrop( image, name)
		aFile = File.new( 'img/public/' << name, "w")
		aFile.write( image)
		aFile.close
	end
  
	def load(name)
		picture = AWS::S3::S3Object.value('img/originals/' << name, @bucket)
		return picture
	end
  
	def readSecret()
		secret = AWS::S3::S3Object.value('secret', @bucket)
		return secret
	end
	
	def publicUrl(name) 
		return "http://"<<ENV['S3-HOST']<<"/"<<@bucket<<"/img/public/"<<name
	end
  
	def initialize()
		@bucket = ENV['S3-BUCKET']
    
		AWS::S3::Base.establish_connection!(
			:access_key_id     => ENV['S3-ACCESS-KEY'],
			:secret_access_key => ENV['S3-SECRET-KEY']
		)
		AWS::S3::DEFAULT_HOST.replace(ENV['S3-HOST'])		
		
	end    
  
end