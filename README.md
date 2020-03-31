# Trill_SC
Trill UGens for SuperCollider on the Bela

# Trill Project Links
* https://blog.bela.io/2019/09/16/trill-touch-sensors-kickstarter-bela/
* https://github.com/BelaPlatform/Trill

# How to Install
To install the Trill UGens you'll need to do a bit of work at the command line.

1. First copy the Trill_SC repository over to your Bela using the provided update.sh script.
```
your.pc> ./update push -n
```

*You can alternatively use scp*
```
your.pc> scp -r Trill_SC root@192.168.7.2:
```

2. SSH into your Bela (make sure it's connected to your PC)
```
your.pc> ssh root@192.168.7.2
```

3. Make a symbolic link inside the SuperCollider extensions directory to the UGen files.
*nice to know: on Linux the extensions directory is `/usr/local/share/SuperCollider/Extensions`*
```
bela> ln -s ~/Trill_SC/ext/ /usr/local/share/SuperCollider/Extensions/TrillUGens
```

4. ***(Not required)*** Make symbolic links to all the example projects.

```
bela> ln -s ~/Trill_SC/BelaProjects/* ~/Bela/projects/
```
