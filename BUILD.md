# Building the Plugins from Source

To build custom UGens on the Bela you now have to tell cmake where your external dependencies are. These include, for example, the Bela headers and API, the Trill library, and also also any other things you may want to include from 3rd party sources.

The UGens need to be built on the Bela. Make sure you have the SuperCollider source on your Bela. SSH in...

```
> ssh root@192.168.7.2
```

## Edit your CMakeLists.txt
CMakeLists.txt must have all the appropriate libraries included and that you've set the FILENAME var to the name of your UGen's .cpp file

Add these lines
```
set(FILENAME TrillCentroids.cpp)
set(CMAKE_BUILD_TYPE Release)

```

```
set(BELA_PATH /root/Bela/)

# Include all the search directories
include_directories(${SC_PATH}/include/plugin_interface)
include_directories(${SC_PATH}/include/common)
include_directories(${SC_PATH}/common)
include_directories(${BELA_PATH})
include_directories(${BELA_PATH}/include)
include_directories(${BELA_PATH}/lib)
# include_directories(${BELA_PATH}/libraries)
include_directories(${BELA_PATH}/libraries/Trill/)
```

```
# Build the shared library
add_library(${PROJECT} MODULE
  ${FILENAME}
  ${BELA_PATH}/libraries/Trill/Trill.cpp
)
```


## Go into the project dir for your UGen and make a build directory
```
> cd Trill_SC/Bela_UGens/TrillCentroids && mkdir build && cd build
```

## Configure CMAKE

If you are building against the installed SuperCollider version you can simply
```
> cmake ..
```
this assumes `SC_INCLUDE_PATH=/usr/include/SuperCollider` and `BELA_PATH=/root/Bela`. If these are different on your system, you can set them on the command line with `-D`.
If you are building against a non-installed version of SuperCollider, you should set `SC_INCLUDE_PATH` to point to the source's include folder, instead. If you also need the stuff in `supercollider/common`, then you cannot build against an installed version and you need to set `SC_PATH` to the source folder of SuperCollider, e.g.:

```
> cmake -DSC_PATH=~/supercollider3.10b/ ..
```

## Run the make command
```
> make
```

## Copy the compiled shared object (.so) into the ext directory

```
> mv TrillCentroids.so ../../../ext/Trill/
```

***remember to symlink this extensions directory to your SC Extensions***
```
> ln -s ~/Trill_SC/ext/ /usr/share/SuperCollider/Extensions/TrillUGens
```

## Debug... Repeat...

***note***
You can save some time in your workflow by running the server and running the language separately/remotely.

You can also combine the whole make/mv/scsynth process with a single line.

```
> make && mv TrillCentroids.so ../../../ext/Trill/ && scsynth -u 57110 -z 16 -J 8 -K 8 -G 16 -i 2 -o 2
```

...then on your laptop you can remotely attach to the server...
```
( // connect to the already-running remote belaserver
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 4; // should match the settings on the Bela
s.initTree;
s.startAliveThread;
);
s.plotTree;
s.freeAll;

// Make sure your UGen class file is visible to SC on your host machine..
// then you can test it out...
{
    var output;
    output = MyUGen.kr(1, 2, 3.0);
}.play(s);
```
