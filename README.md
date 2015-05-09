# samurai-crop-server


Server for uploading, server side cropping and rotating images. To define the crop rectangle client side, use http://croputils.sourceforge.net/



## Uploading images

Go to http://localhost:4567/uploadForm to upload a file.



## Cropping images

Example:
```
curl http://docker:4567/crop/image1.jpg/407x408?cw=1.00&ch=0.99&dx=0.5&dy=123&a=0.2
```

Parameters:

| Name          | Description   | Range  |
| ------------- | ------------- | ------ |
| cw            | width of crop rectangle relative to image width   | 0.0 - 1.0 |
| ch            | height of crop rectangle relative to image height | 0.0 - 1.0 |
| dx            | translate center of crop rectangle horizontaly relative to centre of image | -0.5 - 0.5|
| dy            | same as dx, only in vertical direction | -0.5 - 0.5 |
| a             | rotation of crop rectangle | +/- 45 degrees |


## Scaling images

Example:
```
curl http://docker:4567/scale/image1.jpg/600x400
```



# Running

## In container persistence
```
docker run -d -p 4567:4567 --name samurai k14n/samurai-crop-server
```



## Amazon s3
```
docker run -d -p 4567:4567 --name samurai --env-file=dockerenv.txt  k14n/samurai-crop-server
```
Environment variables (dockerenv.txt):

```
S3-ACCESS-KEY=xxxxxxxxxxxxxxxxxxxx
S3-SECRET-KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
S3-HOST=s3-eu-west-1.amazonaws.com
S3-BUCKET=my-S3-bucket
```


Use your favorite editor to enter your own environment values.





# Build

```
docker build -t k14n/samurai-crop-server .
```


# Development
```
$ git clone https://github.com/kristianhelgesen/samurai-crop-server.git
$ cd samurai-crop-server
$ docker run -it -p 4567:4567 --name samurai -$(pwd):/app  k14n/samurai-crop-server
/app # ruby samurai-crop-server.rb
```



