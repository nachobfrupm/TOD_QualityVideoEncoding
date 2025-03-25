Installation instructions ( Tested in Ubuntu 22.04 )  
=====================================================  

   ~~~shell
cd ..  
git clone https://github.com/Telecommunication-Telemedia-Assessment/bitstream_mode3_p1204_3.git   
cd bitstream_mode3_p1204_3/   
sudo apt-get -y install autoconf automake build-essential libass-dev libfreetype6-dev libsdl2-dev libtheora-dev libtool libva-dev lib  vdpau-dev libvorbis-dev libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev pkg-config texinfo wget zlib1g-dev yasm    
sudo apt install python3-poetry    
poetry lock   
mv poetry.lock poetry.lock.old  
poetry install  
   ~~~
