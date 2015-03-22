# samurai-crop-server


Server for uploading, cropping and rotating images. 



# Cropping images

```
curl http://docker:4567/egoas/crop/image1.jpg/407x408?cw:1.00&ch:0.99&dw:0.5&dy:123&a:0.0
```






# Configuration
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

