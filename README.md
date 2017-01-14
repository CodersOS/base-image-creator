# base-image-creator
These scripts create docker images which can be used as a basis for image creation.

Add an Image
------------

1. Clone or download the source to a linux distribution.
2. Run `./push-iso-to-dockerhub.sh <iso file>` and it pushes the image.

How to customize a live CD
--------------------------

1. [Add an Image][add-image]
2. Run something in the docker container i.e. `docker run --cidfile=/tmp/1 <image> apt-get install firefox`
3. Commit the container: ```docker commit `cat /tmp/1` > /tmp/2```
4. Create the iso file ```docker run --rm `cat /tmp/2` /toiso/command.sh > my.iso```
5. You will find your iso file in `my.iso`


[add-image]: #add-an-image
