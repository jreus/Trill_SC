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
bela> ln -s ~/Trill_SC/ext/Trill /usr/local/share/SuperCollider/Extensions/TrillUGens
```

4. ***(Not required)*** Make symbolic links to all the example projects.

```
bela> ln -s ~/Trill_SC/BelaProjects/* ~/Bela/projects/
```

# Troubleshooting

## Trill Not Detected

Errors like these:
```
Unexpected or no response.
No valid device connected.
1
Unable to identify device
```

and

```
Failed to prepare Trill data collection
Failure to read Byte Stream
```

Check your I2C devices on the Bela:

```
root@bela:~# i2cdetect -r 1
WARNING! This program can confuse your I2C bus, cause data loss and worse!
I will probe file /dev/i2c-1 using read byte commands.
I will probe address range 0x03-0x77.
Continue? [Y/n] y
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- 18 -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --        
```

This indicates an I2C device on address 0x18

```
root@bela:~# i2cdetect -r 1
WARNING! This program can confuse your I2C bus, cause data loss and worse!
I will probe file /dev/i2c-1 using read byte commands.
I will probe address range 0x03-0x77.
Continue? [Y/n] Y
     0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
00:          -- -- -- -- -- -- -- -- -- -- -- -- --
10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
30: -- -- -- -- -- -- -- -- 38 -- -- -- -- -- -- --
40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
60: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
70: -- -- -- -- -- -- -- --                         
```

This indicates an I2C device on address 0x38
