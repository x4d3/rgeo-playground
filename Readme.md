- Install [docker](https://docs.docker.com/engine/install/ubuntu/)
- Install dependencies
    ```
    sudo apt update
    sudo apt install libtiff-dev libgeos++-dev libgeos-3.8.0 libgeos-c1v5 libgeos-dev libgeos-doc  libpq-dev  
    ```
- Install [proj](https://proj.org/install.html)
    ```
    wget https://download.osgeo.org/proj/proj-8.2.1.tar.gz
    tar -xcf proj-8.2.1.tar.gz
    cd proj-8.2.1
    mkdir build
    cd build
    cmake ..
    cmake --build .
    cmake --build . --target install
    ```
- Install rvm and ruby
    ```
    rvm install 2.7.5
    rvm use 2.7.5
    gem install bundler
    bundle install
    ```
- Start the postgres db
  ```
  docker-compose db up
  ```
