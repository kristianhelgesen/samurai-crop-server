class DataFile
  
  
  def save( tmpfile, name)
    AWS::S3::S3Object.store( 'img/originals/' << name, tmpfile, @bucket)
  end
  
  def cropExists( name) 
    return AWS::S3::S3Object.exists?( 'img/public/' << name, @bucket)    
  end
  
  def saveCrop( image, name)
    AWS::S3::S3Object.store( 'img/public/' << name, image, @bucket, :access => :public_read)
  end
  
  def load(name)
    picture = AWS::S3::S3Object.value('img/originals/' << name, @bucket)
    return picture
  end
  
  def readSecret()
    secret = AWS::S3::S3Object.value('secret', @bucket)
    return secret
  end
  
  def initialize( bucket)
    @bucket = bucket
    
    AWS::S3::Base.establish_connection!(
      :access_key_id     => ENV['S3-ACCESS-KEY'],
      :secret_access_key => ENV['S3-SECRET-KEY']
    )
  end    
  
end