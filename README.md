# samurai-crop-server


Server for uploading, cropping and rotating images. 



# Uploading images

Go to http://localhost:4567/uploadForm to upload a file.




# Cropping images


Parameters:

| Name          | Description   | Range  |
| ------------- | ------------- | ------ |
| cw            | width of crop rectangle relative to image width   | 0.0 - 1.0 |
| ch            | height of crop rectangle relative to image height | 0.0 - 1.0 |
| dx            | translate center of crop rectangle horizontaly relative to centre of image | -0.5 - 0.5|
| dy            | same as dx, only in vertical direction | -0.5 - 0.5 |
| a             | rotation of crop rectangle | +/- 45 degrees |


```
curl http://docker:4567/crop/image1.jpg/407x408?cw=1.00&ch=0.99&dx=0.5&dy=123&a=0.2
```




# Configuration

Environment variables:

* S3-ACCESS-KEY
* S3-SECRET-KEY
* S3-HOST
* S3-BUCKET


```
cp dockerenv-example.txt dockerenv.txt
```


Use your favorite editor to enter your own environment values.


# Run
```
docker run -d -p 4567:4567 --name samurai --env-file=dockerenv.txt  k14n/samurai-crop-server
```





# Build

```
docker build -t k14n/samurai-crop-server .
```

