require './datafile-s3.rb'
require './datafile-local.rb'
require './transformparams.rb'

require 'rubygems'
require 'sinatra'
require 'haml'
require 'RMagick'
require 'aws/s3'
require 'tmpdir'
require 'uuid'
require 'json'
require 'digest/sha1'
require 'fileutils'


if ENV.has_key?('S3-BUCKET')
	df = DataFileS3.new()
else

end


get '/status' do
	df.save('status OK','status.txt');
	"OK"
end


get '/' do
	File.read(File.join('public', 'index.html'))
end


get '/scale/:imagename/:imagesize' do
	srcImgFileName = params[:imagename]
	imagesize = params[:imagesize]
	t = TransformParams.new( params)
  

	srcImgFile = df.load( srcImgFileName)
  
	resultW = imagesize.split("x")[0].to_i
	resultH = imagesize.split("x")[1].to_i

	if (resultW<=0 && resultH<=0) then
		status 400
		content_type :json
		return { :errorMessage => 'result image width or height must be provided!', :status => 'error' }.to_json
	end
  
  
	resultImageName = '' << srcImgFileName.split('.')[0] << '_'
	resultImageName = resultImageName << 's'
	resultImageName = resultImageName << resultW.to_s if resultW > 0.0
	resultImageName = resultImageName << 'x'
	resultImageName = resultImageName << resultH.to_s if resultH > 0.0
	resultImageName = resultImageName << '.' << srcImgFileName.split('.')[-1] # appending extension  
  
	url = df.publicUrl(resultImageName)
  
	if( df.cropExists( resultImageName)) then
		content_type :json
		return { :imageName => resultImageName, :status => 'exists', :url=>url }.to_json
	end

	puts "generating scaled version "<<resultImageName
  
	uuid = UUID.new
	randomFileNamePart = uuid.generate(:compact)
  
	workFolder = File.join( Dir.tmpdir, randomFileNamePart)
	workFileName =  File.join( workFolder, srcImgFileName)

	Dir.mkdir( workFolder);
	aFile = File.new( workFileName, "w")
	aFile.write( srcImgFile)
	aFile.close
  
	srcImg = Magick::Image.read( workFileName).first

	resultW = (srcImg.columns*resultH)/srcImg.rows if resultW<=0
	resultH = (srcImg.rows*resultW)/srcImg.columns if resultH<=0
  

	srcImg.resize_to_fit!( resultW, resultH)
	srcImg.write( workFileName)
  
	df.saveCrop( open(workFileName), resultImageName)
	puts "image done: #{workFileName} in folder #{workFolder}"
  
	FileUtils.rm_rf(workFolder)  
  
	status 201
	content_type :json
	return { :imageName => resultImageName, :status => 'created', :url=>url }.to_json
  
end

#i.e. http://localhost:4567/crop/imagename/100x100?cw=1.00&ch=0.99&dx=0.5&dy=123&a=0.0
get '/crop/:imagename/:imagesize' do
  
	srcImgFileName = params[:imagename]
	imagesize = params[:imagesize]
	t = TransformParams.new( params)
  
	resultW = imagesize.split("x")[0].to_i
	resultH = imagesize.split("x")[1].to_i


	if (resultW<=0 && resultH<=0) then
		status 400
		content_type :json
 		return { :errorMessage => 'result image width or height must be provided!', :status => 'error' }.to_json
	end

  
	resultImageName = '' << srcImgFileName.split('.')[0] << '_'
	resultImageName = resultImageName << resultW.to_s if resultW > 0.0
	resultImageName = resultImageName << 'x'
	resultImageName = resultImageName << resultH.to_s if resultH > 0.0
	resultImageName = resultImageName << '_'
  
	resultImageName = resultImageName << 'cw' << sprintf("%0.4f", t.cw) << '_' if t.cw<1.0
	resultImageName = resultImageName << 'ch' << sprintf("%0.4f", t.ch) << '_' if t.ch<1.0
	resultImageName = resultImageName << 'dx' << sprintf("%0.4f", t.dx) << '_' if t.dx!=0.0
	resultImageName = resultImageName << 'dy' << sprintf("%0.4f", t.dy) << '_' if t.dy!=0.0
	resultImageName = resultImageName << 'a'  << sprintf("%0.4f", t.a)  << '_' if t.a !=0.0
	resultImageName = resultImageName.slice(0..-2)  # removing last comma.
#  resultImageName = Digest::SHA1.hexdigest(resultImageName) # garbling filename
	resultImageName = resultImageName << '.' << srcImgFileName.split('.')[-1] # appending extension
  
	url = df.publicUrl(resultImageName)
  
	if( df.cropExists( resultImageName)) then
		content_type :json
		return { :cropName => resultImageName, :status => 'exists', :url=>url }.to_json
	end

	puts "generating crop "<<resultImageName
  
	srcImgFile = df.load( srcImgFileName)
 
	uuid = UUID.new
	randomFileNamePart = uuid.generate(:compact)
  
	workFolder = File.join( Dir.tmpdir, randomFileNamePart)
	workFileName =  File.join( workFolder, srcImgFileName)

	Dir.mkdir( workFolder);
  
	aFile = File.new( workFileName, "w")
	aFile.write( srcImgFile)
	aFile.close

	srcImg = Magick::Image.read( workFileName).first

	srcW = Float( srcImg.columns)
	srcH = Float( srcImg.rows)
    
 	# Cropping box around tilted rectangle 
	preCropW = srcW*t.cw*Math.cos(t.a).abs + srcH*t.ch*Math.sin(t.a).abs
	preCropH = srcH*t.ch*Math.cos(t.a).abs + srcW*t.cw*Math.sin(t.a).abs
	preCropX = -srcW*t.dx + srcW*0.5 - preCropW*0.5;
	preCropY = -srcH*t.dy + srcH*0.5 - preCropH*0.5;
  
	#puts "T:#{t.dx},#{t.dy},#{t.cw},#{t.ch},#{t.a}"
  
	srcImg.crop!( preCropX, preCropY, preCropW, preCropH)
  
	#puts "cropparams: #{preCropX}, #{preCropY}, #{preCropW}, #{preCropH}"
  
	workFileName[".jpg"] = "-after-pre-crop.jpg"
	srcImg.write( workFileName);
	srcImg = Magick::Image.read( workFileName).first;
  
	srcImg.rotate!( t.a*180.0/Math::PI)
  
	rotateOffsetX = srcH*t.ch * Math.cos(t.a).abs * Math.sin(t.a).abs
	rotateOffsetY = srcW*t.cw * Math.cos(t.a).abs * Math.sin(t.a).abs
  
	srcImg.crop!( rotateOffsetX, rotateOffsetY, srcW*t.cw, srcH*t.ch)
  
	workFileName["-after-pre-crop.jpg"] = "-after-all.jpg"
	srcImg.write( workFileName)
	srcImg = Magick::Image.read( workFileName).first;  
  
	resultW = resultH*srcW*t.cw/(srcH*t.ch) if resultW<=0  
	resultH = resultW*srcH*t.ch/(srcW*t.cw) if resultH<=0
	#puts "result image size: #{resultW}x#{resultH}"
  
	srcImg.resize_to_fill!( resultW, resultH, Magick::CenterGravity)
  
	workFileName["-after-all.jpg"] = "-final.jpg"
	srcImg.write( workFileName)
  
	df.saveCrop( open(workFileName), resultImageName)
	puts "image done: #{workFileName} in folder #{workFolder}"
  
	FileUtils.rm_rf(workFolder)  
  
	status 201
	content_type :json
	return { :cropName => resultImageName, :status => 'created', :url=>url }.to_json

end

get '/uploadForm' do
	haml :upload
end


post '/uploadForm' do
 
	unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])
		status 400
		content_type :json
		return { :status => 'Invalid form. File input field with name "file" required' }.to_json
	end
  
	df.save( tmpfile, name)
	status 200
	content_type :json
	return { :status => 'file received', :imageName => name }.to_json
end





__END__

@@upload
%h2 Upload
%form{:action=>"/uploadForm",:method=>"post",:enctype=>"multipart/form-data"}
  %input{:type=>"file",:name=>"file"}
  %input{:type=>"submit",:value=>"Upload"}
  

