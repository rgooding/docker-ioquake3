# ioquake3 Dedicated Server

ioquake3 dedicated server built from source with nginx auto-configured to serve maps and mods over
HTTP for fast downloads.


### Running the container

This requires pak0.pk3 from the original game and the latest patch data. The patch files can be downloaded here: https://ioquake3.org/extras/patch-data/

Create a directory layout like this:
```
data/
  baseq3/      Place pak0.pk3 from the original game here along with the patch files
  maps/        Place the .pk3 files for any additional maps in here
  missionpack/ Place the Team Arena pak0.pak here along with any patch files
  mods/        Place any mods in here
```
The default configuration runs a deathmatch server rotating through the maps in a random order.
You can override the configuration by creating a file named `deathmatch.cfg` in `data/baseq3`.

Before starting the container you should change the default server password in `run-standalone.sh`
by editing the `Q3_PASSWORD` variable.

If you are using additional maps and you want clients to be able to download them over HTTP you
will need to edit the `WAN_HOSTNAME` variable in `run-standalone.sh` so they know where to find them.

Start the container with `./run-standalone.sh`

On the first run this will download and compile the latest version of the ioquake3 dedicated server

For more advanced configuration you can adapt `run-standalone.sh` to your own needs.
