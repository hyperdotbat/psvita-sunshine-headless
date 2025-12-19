# PSVita Sunshine Headless Setup / "Steam Deck Micro"

This is a headless setup meant for settings such as a homelab or miniPC (tested on an Intel i5-6500 without a dedicated GPU).  
It will replace any regular display manager with a barebones Xorg server with an embedded gamescope running Steam.  
This setup uses a fake 720p EDID used as a kernel param in grub allowing use without any display attached or physical plugs.  
It uses Sunshine for streaming, and also a small bunch of scripts to neatly optimize for lowest CPU usage (to not hog resources on a home server in my case, so you can obviously go ahead and remove those scripts); it will go into "idle mode" when you quit the stream limitting the usage of all associated processes, and also kill all running games, put you into Invisible mode in Steam, but leaving it open for quick bootup next time.

WARNING: as of the first initial commits this hasnt been actually tested, especially the setup script, I wrote whatever from memory I did earlier on my machine

## Automatic setup:
Run `setup.sh`

[Check the kernel parameter for grub section if necessary](#kernel-parameter)  
[Post setup section](#post-setup)  

## Manual setup:
(Open the terminal from this folder)

You're gonna wanna disable your display manager if you want a truly headless setup  
If youre unsure which one youre using and want to note down in case you would like to rollback then first run:  
`systemctl status display-manager`  

Now you can disable it:  
`sudo systemctl disable display-manager`

Enable user lingering:  
`loginctl enable-linger "$USER"`

Next copy the headless Xorg service to where it belongs and enable it:  
`sudo cp -i ./etc/systemd/system/xorg-headless.service /etc/systemd/system/`  
`sudo chown root:root /etc/systemd/system/xorg-headless.service`  
`sudo systemctl enable xorg-headless`

Copy over the EDID file:  
`sudo cp -i ./usr/lib/firmware/edid/720p.bin /usr/lib/firmware/edid/`  
`sudo chown root:root /usr/lib/firmware/edid/720p.bin`  

##### Kernel parameter
Check with `check-displays.sh` which outputs are for sure free, and take into account your actual build, and the fact that its not the actual port on the motherboard but what the GPU will use, so lets say you have only DP ports, but you use a DP-HDMI cable where HDMI is plugged into your monitor; the HDMI slot will be used instead of DP in this case.

Set it as a kernel param in `/etc/default/grub` (replace `HDMI-A-1` if needed):  
`GRUB_CMDLINE_LINUX="video=HDMI-A-1:e drm_kms_helper.edid_firmware=HDMI-A-1:edid/720p.bin"`
Update grub:  
`sudo grub-mkconfig -o /boot/grub/grub.cfg`

Copy over all needed scripts to `$HOME/.local/bin/`  
`cp -i ./scripts/* "$HOME/.local/bin"`

Enable sunshine:  
`systemctl --user enable sunshine`  
(if you want to configure it you can start it as well):  
`systemctl --user start sunshine`  
and then go to:  
[https://localhost:47990](https://localhost:47990)

Unless youve used Sunshine before or are meaning to leave some of the default config or whatever copy over the `apps.json` to your config  
`cp -i ./.config/sunshine/apps.json "$HOME/.config/sunshine/"` 

If youve skipped this previous step then to use this gamescope setup youre gonna wanna add (/edit the default "Steam Big Picture" entry) in Sunshine
For Detached Command set:  
`$(HOME)/.local/bin/gamescope-steam.sh`  
and for Undo command set:  
`$(HOME)/.local/bin/sunshine-end.sh`

Reboot

---
#### Post setup
From Vita Moonlight try automatically searching for the device and connect, launch `Steam Gamescope`, the first start will take about a minute, but after its on its gonna stay that way.  
Now every time you get stuck not being able to exit the game and even input doesnt work, or you just want to stop the stream and save on resources youre gonna wanna pause the stream (by default top-left corner of the touchscreen) and explicitly Quit the app, as mentioned earlier this will kill all Steam games and also put you into "Idle mode"

for streaming over WAN (outside of your local network) you will need to portforward all of these ports for the machine running Sunshine:  
`47984` `47989` `48010` `47998` `47999` `48000`  
or you can use Tailscale or whatever else, there are more posts and guides talking about this entire topic.

#### Specific issues I have noticed [with an Intel i5-6500]:
- Because of a [certain issue with specifically Vita Moonlight](https://github.com/xyzz/vita-moonlight/issues/273), I was forced to use software rendering (libx264) instead of VA-API which throttled the performance severely, point and click games etc were very much still playable but anything with movement like a platformer was not because of ocasional input drops, and like "frame drops" caused by encoding not keeping up.
If you dont use an Intel iGPU this probably doesnt concern you, im not sure what does AMD use, but when I used Sunshine on my PC with an RTX3070 and dkms drivers it still automatically picked software instead of NVENC
- Inside of `gamescope-steam.sh` there is an env variable for `INTEL_DEBUG=noccs`, without it I would see [very bizzare color grid glitches](https://github.com/ValveSoftware/gamescope/issues/356) just like other people reported at some point, maybe this is an issue with me running it all on Debian 12, which has older drivers and gamescope.  
You can try removing this variable if youre seeing low performance, or are just not using an Intel iGPU.
(btw this is only the case with gamescope, not raw Xorg, that would work, but youd be missing out on the most important part of the setup)

#### Troubleshooting:
Check the status of any service for errors:  
`systemctl status xorg-headless`  
`systemctl --user status sunshine`  

You can acces the Sunshine WebUI from any other machine by going to its IP and port `47990` so for eg. `https://192.168.1.10:47990`  
If youre gonna have any trouble later go through the Advanced tab of the config, try different combinations; for Streaming method if KMS is not working then switch to X11, for Encoder if VA-API is glitching like mentioned above use Software.  
If your GPU doesnt have HEVC or AV1 I guess its probably better to make Sunshine not try detecting them by selecting `Sunshine will not advertise for ...` but yeah