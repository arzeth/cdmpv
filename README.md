# cdmpv (Child Display server over MPV)
You can upscale even 800x600 to 5K.
Or crop 800x600 to 16:9 at a certain position and then upscale.


Games that grab mouse movements don't work, i.e. you can't play Quake with cdmpv.

That's because TigerVNC and UltraVNC (IIRC) don't support mouse movements, they send/receive only mouse's absolute position.

Therefore, it's recommended to play VNs with `cdmpv`.

I developed `cdmpv` because I wanted my waifus from VNs to be more beautiful as soon as possible on Linux.

After 150 hours I want everything beautiful in VNs, even background images.

I still want more FPS,

and play without nested display server,

and also want to play SC2 at 70-75 fps when the original FPS drops to 46 in big fights because my Ryzen 2600 is not enough,
therefore I am developing the overengineered ultrafast (upscaling only changed regions, changing upscaler on-the-fly to achieve target fps, potentially zero-copy) upscaler/first-in-the-world-universal-upframerater (no MPV; uses a proxy window instead of nested X11) that will probably be ready in February 2022.


I didn't test `cdmpv` on other computers, so tell me if it doesn't work.


Read everything below (especially the Hotkeys section) in order to use it.

## Requirements
Linux (or probably FreeBSD/etc.).

Ability to launch MPV using X11 (Xwayland is ok).

## Terminology
X11=xorg. It is a display server. The other one in Wayland.

Host X11

Guest X11=Child X11=Nested X11=X11 in X11/Xwayland

VNC

WM=Window Manager.

[MPV](https://github.com/mpv-player/mpv) is a video player (also audio and images), it's used here for upscaling and displaying the result.

[i3](https://github.com/i3/i3) as a WM in nested X11.

[FFmpeg](https://github.com/FFmpeg/FFmpeg) for capturing what's inside nested X11.

## How to use:
```
./cdmpv.sh {GUEST_RES} ( {GUEST_FPS = guest's x11 fps or refresh rate}( {RMPV = upscaled video fps}))
./cdmpv.sh 1280x720 60 30
./cdmpv.sh 1280x720 74.5 74.5
./cdmpv.sh 1280x720 74.5 74.5/3
./cdmpv.sh 1280x720 60 160/3 # If your monitor is 160 Hz
./cdmpv.sh 1280x720 30
./cdmpv.sh 1280x720

#Bad: ./cdmpv.sh 1280x720 29.97 29.97
#Bad: ./cdmpv.sh 1280x720 29.97002997002997003 29.97 #(because what you actually want is ~0.02997002997002997003 which is also impossible to write)
#Good: ./cdmpv.sh 1280x720 29.97002997002997003 30/1001 #(useful for displays running at 60/1001 Hz=~59.94005994005994006 Hz)
# 29.97002997002997003 is for the nested X11, 30/1001 is for FFmpeg and v4l2.


```


`GUEST_FPS` is the guest X11's virtual (fake) display's refresh rate = FPS. Rarely games are broken or play too fast when >60 Hz.

default `GUEST_X11_FPS_OR_REFRESHRATE` is 60

default `UPSCALED_VIDEO_FPS`=30

For ultra low-latency, change `--interpolation` from `yes` to `no` in `x11wid.sh` (command arguments override all file configs),


By default MPV uses the config provided here, not yours in ~/.config/mpv/

because there is at least 20% chance that your config is bad.

You can change that by removing the option in mpv.sh.


i3 WM launched in the guest X11 uses the `i3-child-config` file here.


## Install
#### 1) Install VNC server and client
Arch Linux:
```
sudo pacman -S tigervnc gtk-vnc
```
Debian, Ubuntu, Mint, etc.:
```
sudo apt install tigervnc-viewer tigervnc-standalone-server gvncviewer
```
Fedora:
```
sudo dnf install tigervnc tigervnc-server
```
OpenSUSE:
```
sudo dnf install tigervnc xorg-x11-Xvnc
```
Arch Linux's tigervnc package has both Xvnc (that's VNC server with startx) and vncviewer.

TigerVNC's vncviewer is not used because its vncviewer either

1) aggressively tries to resize the guest X11 to the host resolution
2) shows unscaled 1280x720 guest in the center of the screen on 1920x1080 host. We need the same *mouse* area as the MPV window.

*If you don't need low FPS and playing backwards every 1000ms, then compile TigerVNC with my one-line patch*
Currently the only *easy* way to do that is if you use Arch Linux (or other distro that can create packages from PKGBUILD).

(the PKGBUILD is in this repo)
```
cd PKGBUILDS/tigervnc
makepkg -si
```
Now it is installed. It was patched with `dontpaint.patch` (1-2 lines) from the same folder.

With this patch, the VNC server will send only the very first frame to the VNC client. So if you `killall mpv`, then you would still see the `xfce4-terminal`.


According to my experience,
every time you upgrade xorg-server (even if it is a minor version),
you should recompile this package.

#### 2) Install all other needed packages
Arch Linux:
```
sudo pacman -S mpv i3-wm ffmpeg perl gcc dmenu bemenu bemenu-x11 dunst xfce4-terminal xorg-setxkbmap xorg-xset xorg-xrandr xdotool xorg-xdpyinfo scrot libwebp terminus-font wmctrl calc
```
Debian, Ubuntu, Mint, etc.:
```
sudo apt install mpv i3 ffmpeg perl gcc libx11-dev suckless-tools dunst xfce4-terminal x11-xkb-utils x11-xserver-utils x11-utils xdotool scrot webp xfonts-terminus wmctrl apcalc
```
Common packages for OpenSUSE and Fedora:
```
sudo dnf install mpv i3 ffmpeg perl gcc dmenu bemenu dunst xfce4-terminal setxkbmap xset xrandr xdotool xdpyinfo scrot libwebp-tools wmctrl calc
```
Only Fedora:
```
sudo dnf install terminus-fonts-console
```
Only OpenSUSE:
```
sudo dnf install terminus-bitmap-fonts
```

I am not sure if I specified enough packages needed to compile `autocutsel` in all distros.


## Environment variable: MP
Since in most VNs nothing moves,
we don't need to upscale the 99.9-100% similar frame 10000 times.

By default MP=2
MP=0 disables mpdecimate.
The higher MP, the more aggressive params are supplied to mpdecimate filter.
Maximum MP can be 8
`MP=4 ./cdmpv 1280x720 60 30`
or if you don't want to restart your already game
```
killall mpv
MP=4 ./x11wid.sh
```

Actually no, in many VNs there is an animated icon in the dialog,
which causes to rerender everything (BTW, my future upscaler upscales only changed regions),
so if you don't want your GPU's fan to be 100%, then increase `MP`.


Also see `max=` line in `x11wid.sh` which forces to render the frame every N second.
Without it what happens is that if you switch to another desktop, then back,
then you would have black screen until FFmpeg supplies a new frame.

## Environment variable: C
See the code in x11wid.sh, there is code only for 800x600
By default `C=0`
`C` can also be `1` or `2` or `3`
If `C==1` then crop resolution 800x550, crop top=25px
If `C==2` then crop resolution 800x460, crop top=60px
If `C==3` then crop resolution 800x450, crop top=70px
FFmpeg crops, not mpv (although mpv can too, with vf, but then I would need `sed` copied `input.conf`...)

Why crop? Because in old games there's unused space in the bottom.

BTW, you can also Ctrl+Up/Down/Left/Light; zoom is ctrl+u, ctrl+shift+u.
Note that if you zoom with MPV, MPV will still upscale the whole image and the output resolution won't change (exception: SSimSuperRes, which is a POSTKERNEL shader).

```
MP=4 C=2 ./x11wid.sh
```

So when you need the bottom part (e.g. to save the game; the Log button),
then either
1) Ctrl+Up/Down (but remember how many times you pressed)
2) Close x11wid.sh (or `killall mpv` if you still haven't launched it separately outside of cdmpv.sh) and start ./x11wid.sh with different `C`.



## MPV's hotkeys (read it!!!)
I am probably the only one in the world that benchmarked all possible shaders chains
(I blacklisted some of patterns, so that it would not take years)
on 2 images and 2 resolutions (800x450→1920x1080, 1280x720→1920x1080),
I'll publish my script and results in .json later,
my script primarily uses ssim (https://github.com/Alexkral/AviSynthAiUpscale/issues/3, code by igv),
but also dssim (AUR: dssim-git).

Most shader chains that are in `input.conf` are for 1920x1080 screen because my monitor is 1920x1080.
All shaders upscale images 2x times (1280x720→2560x1440) except when it is explicitly written 3x or 4x in the file name.
So they need to be downscaled afterwards if the result is higher than your screen resolution.
Only MPV's built-in upscalers (`scale=` in `mpv.conf`) can upscale to any arbitrary resolution (1.223x, etc.)
If the upscaled result image is the same size as your screen, then the sharpener is needed (`~~/shaders/igv/SSimDownscaler.glsl`) or Light_Soft shader `~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY-half.glsl` (or not -half), test yourself. Sometimes they are already included (especially in case of Anime4K *CNN* Upscalers that produces lines that are thicker than needed).
So if you have 4k/5k display, then add either Anime4K -UL or -UL-RGB or -L variant or ~~/shaders/superxbr.glsl (it's like lanczos but lines are much smoother) at the end of string in `input.conf` if your GPU allows it.

If you are at the same tab where you launched `cdmpv.sh`,
then that means if you press any key it will be sent to MPV (because cdmpv.sh launches cdmpvTempBgTasks.sh in bg which launches x11wid.sh in bg).
Or you can `killall mpv`, create a new tab in host X11/Wayland and `./x11wid.sh`.

Every hotkey in `input.conf` cycles through 1-5 shaders.
If it says press `2` three times, but you accidentally press it four times, press `0`, then repeat what you wanted.

When you switch a shader chain, you'll see so in the MPV's log.
To switch a shader you should press a key, *then wait while it renders a new frame with it*,
then go back to the terminal to look if you got the correct "glsl-shaders"

Shader cache is stored in `~/.config/mpv/shader_cache` (you can change that in config.sh)
Shaders are compiled by CPU of course.
Heavy shaders are compiled 20 seconds.
You get blue screen when not enough VRAM or shader compilation failed.

Hotkeys are specified in `input.conf`.
Every time you launch `x11wid.sh` it copies `input.conf` and removes all `ctrl+`.

Press one time `a` if you want 2x and very high FPS and no ringing and smooth lines and no small details and blurred BG.
```
~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_ULF-KrigBilateral.glsl:~~/shaders/igv/SSimDownscaler_oct8.glsl
```

Press one time `e` if you want 4x and very high FPS and no ringing and smooth lines and no small details and blurred BG.
```
~~/shaders/igv/KrigBilateral.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-first-init.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_UL-LUMA.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-apply.glsl:~~/shaders/Anime4K_Restore_CNN_Light_Soft_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl
```

`e`+`e` is better than `e` but slower.
`e` has significantly less details than `a`.
`e`+`e` has less details than `a`.
`e`+`e` is for 4K.

Anime4K CNN Upscaler is the best for Kimagure Temptation because it fixes the badly downscaled animated hair.


Press one time `shift+o` if the original has noise (Sakura no Mori Dreamers 1/2 and Honoguraki Toki no Hate Yori — they are from the same dev)
Note that the noise in hair in Daitoshokan no Hitsujikai seems to be artistical.
Therefore, for Daitoshokan no Hitsujikai don't use Anime4K because it damages hair.



Press one time `2` if you play Vampire's Melody (original is 1920x1080) because the animated sprite seems to be a lossy video (I also tried downscaling before upscaling but the result is worse).
```
~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY.glsl
```

Press two times `2` if you play the 1920x1080 game at 1920x1080 screen, and when a character's face is near, you see sprites are low-resolution,
in this case you need this:
```
~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY-half.glsl
```
or in some cases just `./cdmpv 1280x720 60 60` for this game, although somes VNs use very bad cheap downscaling when the output resolution is lower than original (Kinkoi on Unity, at least the early version)... or less likely it's a bug in Wine.

Press three times `2` if you play Monkey!¡ because the original has mega aliasing.
```
~~/shaders/Anime4K_Restore_CNN_Moderate_Soft_VL-YYY.glsl
```

For Wanko to Kurasou (800x600->4K) press three or four times `shift+q` (depending on FPS and tastes).
If that's too slow, then press two times `e`.


Press
`y` (less details but less pixelated)
or `shift+y` (less details but less pixelated and almost no color noise)
or `f` (no pixelation)
if you play the old version of YU-NO.

Press one time `shift+q` (good for 800x600 → 1920x/2560x; the best for Sugar * Style 1280x720→1920x1080)
```
~~/shaders/Anime4K_Clamp_Highlights-LUMA-first-init.glsl:~~/shaders/Anime4K_Upscale_GAN_x3_VL-LUMA.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-apply.glsl:~~/shaders/igv/KrigBilateral.glsl
```

Sometimes `w` is the best (e.g. Koikari Love for Hire), but sometimes it has ringing especially in fonts.
```
~~/shaders/igv/KrigBilateral.glsl::~~/shaders/avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.glsl:~~/shaders/Anime4K_Restore_CNN_Light_VL-YYY.glsl
```
Or rarely `n` is better (same as `w` but without Restore). The `Restore` shaders fix some ringing for AiUpscale.
Also lines are aliased (in other words, ladder) for some VNs with AiUpscale, which doesn't show up on SSIM test, but we humans see it.


## About new shaders
Anime4K shaders are optimized for x264 videos, i.e. videos with all kinds of artifacts.
Also they are trained on JPEG q=95
But in most VNs sprites are lossless and backgrounds are like JPEG q≈95.
Anime4K Upscale shaders are very bad for background, they think all details are noise so just blur everything.
But Anime4K Restore shaders barely do so.

When input is lossless, `Anime4K_Restore_CNN_*-YYY.glsl` (MAIN shaders) is better, than non-`-YYY` because black lines don't become red. It takes RGB input, but changes only the Y channel.
Generated by
```
u=YYY ./resluma.sh Anime4K_Restore_CNN_*
```

Anime4K_Clamp_Highlights-LUMA-first-init.glsl
Anime4K_Clamp_Highlights-LUMA-apply.glsl


`Anime4K_*-LUMA.glsl` are for use before LUMA shaders. But because they originally supposed to also take non-black-and-white input (i.e. U and V channels = chroma), results are a little bit worse. The exception is GAN_x3_VL.
Generated by
```
./upluma.sh Anime4K_Upscale*
```


Because everything was a little more red (unless -L variant is used), I created
Anime4K_Upscale_CNN_x2_ULF-KrigBilateral.glsl
Although the input is still RGB, only Y channel and U channel are upscaled by Anime4K, while V is upscaled by KrigBilateral embedded in the same file.
The disadvantage (compared to the original shader) is thin pink lines are darker.
It requires a little more VRAM (to store both the upscaled image and also the original image).
V channel only is because there's something wrong with upscaling U channel. FIXME!


If a shader file has `F` at the end, then that means that this shader will be *f*orcefully (no `//!WHEN`) used even the input resolution is bigger than display resolution.
If a shader file has `Cla` at the end, then that means Anime4K_Clamp_Highlights.glsl is embedded.
`FCla` = `F` + `Cla`

`avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.glsl` has many additional changes to fight ringing.
`avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.orig.glsl` is without those changes (`n` two times or `w` four times)

AiUpscale_HQ_4x_LineArt is worse than _3x, at least for 2D, althought a few details are better.

## Screenshots
`DISPLAY=:99 scrot` to save original unupscaled image as .png.
Press `s` to save *un*upscaled image as .png to `/tmp/`
Press `shift+s` to save upscaled image as .png to `/tmp/`


## About shaders
When 1280x720→1920x1080, then AiUpscale_HQ_3x_LineArt has much better SSIM than AiUpscale_HQ_2x_LineArt for 2D sprites, but the overall SSIM is worse (~0.00234 vs ~0.00263) because background images are not very anime.
`Anime4K_Clamp_Highlights.glsl` is needed because upscalers accidentally create very bright micro areas.
Anime4K_Upscale_*CNN*_ hates small details. I tried to fix it: `Anime4K_Upscale_CNN_x2_ULF-RGB-noise.glsl` but it's not always good.
TsubaUP is good for everything except 2D (especially hair is bad).
FSRCNNX is kinda like TsubaUP but slower but better hair.
I tested only VNs, but FSRCNNX_x2_56-16-4-1.glsl is always worse than _16.
The latest revision of SSimDownscaler.glsl does something bad to eyes,
so the previous October 8 revision is used that I named `SSimDownscaler_oct8.glsl`
`nnedi3-nns128-win8x6.hook` is very bad, so not even included.
`Anime4K_Upscale_GAN_x4_UUL.glsl` (two `U`) thins lines too much. Probably it was created for ancient anime videos.
`Anime4K_Upscale_GAN_x4_UL.glsl` is not worth if I remember correctly.

`ravu-zoom-*` damages geometry, so not included. And FSRCNNX is simply better.

`Anime4K*Restore*UL` work only on Vulkan.

(POSTKERNEL stage is used right before MPV downscales the image with the algo chose in `dscale`. MPV doesn't always downscale, only when needed.

SSimDownscaler (POSTKERNEL stage shader) is a sharpener. If the image is not going to be downscaled afterwards by MPV, then this shader is not used because it would introduce many artifacts.
SSimSuperRes.glsl (POSTKERNEL stage shader) is upscaler


## Tips
1) Disable auto cursor move (i.e. you click "Save game", and your mouse moves to the "Yes" button) in the game menu
because the game runs in guest X11
and it sends the mouse move command only to the guest X11,
so the next time you move your mouse,
your guest X11's mouse position reverts to the host's one.

2)
`wine explorer /desktop=cdmpv,$YOURGUESTRESOLUTION`
or
`wine explorer /desktop=cdmpv,$YOURGUESTRESOLUTION game.exe`
enables wine's own virtual desktop just for current session (doesn't add nor overwrite `[Software\\Wine\\Explorer\\Desktops]` in your `$WINEPREFIX/user.reg`), which is sometimes needed because `i3` is a *tiling* window manager, i.e. when you have one window, its size is fullscreen, but if you open a second window, both windows would get automatically the same size—half of the screen each. You can press Win+W or Win+Space or Win+Shift+Space to control that.
One wineprefix can have multiple of them.

3) If you want Steam to be in host X11/Wayland but you want the game be in nested X11, then go into game's options -> command arguments -> env DISLPAY=:99 %command%

4) Black screen in Saku Saku Cherry Blossoms and flickering in Grisaia, Himawari, Ikinari Anata ni Koishiteiru
If an .exe tells a strange error as soon as you launch it, then that's because you set STAGING_WRITECOPY=1 somewhere.
If you still have graphical glitches, then use both dgVoodoo2 (you can read about it in the "Alternative to cdmpv" section) AND software rendering AND *un*installed DXVK, which is 100% performance-wise enough for VNs:
```
__GLX_VENDOR_LIBRARY_NAME=mesa LIBGL_ALWAYS_SOFTWARE=1 VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json  MESA_LOADER_DRIVER_OVERRIDE=zink
```

BTW, when using NVIDIA GPU (I don't know about other GPUs) inside *nested* X11 there is a problem with `glxinfo` and videos in some VNs:
E.g. Akeiro Kaikitan as soon as it tries to play a video, the wine process finishes with X11 error.
Also I found out that Akeiro Kaikitan saves the read messages only after manually exiting the whole game, not when returning to main menu.
Offending videos are open in a new window. Maybe it tries to create a too large window?


Uninstall DXVK:
```
/usr/share/dxvk/setup_dxvk.sh uninstall
```
Install DXVK:
```
/usr/share/dxvk/setup_dxvk.sh install --with-d3d10 --symlink
```
Don't forget about `WINEPREFIX=`

5) In one case (Schatten) as soon as you start it, there's a unskippable video which is displayed black and played for 1 minute.

6) Use [wine-tkg](https://github.com/Frogging-Family/wine-tkg-git)


## Current Algorithm of ./cdmpv.sh
1) If PREFER_AUTOCUTSEL=1 (default) in `config.sh`, then for reliable copy clipboard from nested X11 to host X11 (didn't test this feautre on Wayland), patched `autocutsel` is automatically compiled if it wasn't compiled yet.
It is needed because the VNC protocol by default supports only ASCII. There are some hacks in TigerVNC (both server and client) but sometimes it forgets to send update to the host.
2) Cache all executable files into RAM (useful for HDD).
3) Launch `./cdmpvTempBgTasks.sh` in background
4) Launch TigerVNC's `Xvnc` which provides a guest (child) X11 server (X11 in X11/Wayland) and a VNC server.
4..) After launcing Xvnc there is no more code to execute in `./cdmpv.sh` but `cdmpv.sh` is still active because it executes `Xvnc`
5) `cdmpvTempBgTasks.sh`: Launch `i3` in the guest X11, the i3 uses `i3-child-config` file from the same folder as `cdmpv.sh`. I chose to use i3 as a WM for a guest X11 because it allows to easily remove any borders and panels, uses little RAM, easily configurable.
6) `cdmpvTempBgTasks.sh`: Launch TigerVNC's `vncviewer`. Don't forget that it should be patched.
7) `cdmpvTempBgTasks.sh`: Execute `./x11wid.sh`. It launches `ffmpeg` that grabs guest X11's screen which it pipes to `mpv`.
`mpv` is launched with `--wid={vncviewer's window id}` which makes `mpv` a child window of the VNC client.
You look at `mpv` but all keyboard & mouse control goes to `vncviewer`.
So if `mpv` crashes or you updated one of `.glsl` or `.conf`, then `killall mpv`, then `./x11wid.sh`.
You can 100% safely Ctrl+c `x11wid.sh`.
If you decide to change FPS, then `./x11wid.sh 1280x720 60 30` or edit `.env-of-current-process`
If you specify too high FPS for your GPU then you would get high latency for unknown reason.

If you want to close `cdmpv.sh`, then Ctrl+c it and it will automatically kill all the processes it spawned.

## Former Deprecated Algorithm (read this only if you are curious)
0) Host must be X11, preferably i3 WM. If you have a login screen, and there is a button that says "Wayland session", then you have Wayland instead of X11.
0) No compositor (i.e., no `xfwm`, `metacity`, `compiz`, `KWin`). Or, if you already use `picom` (`compton`),
then see what you need to change in your config.
0) After launching need to wait 20 seconds (because that's how many `sleep`s are in the scripts).
1) if no i3 or if AUTOSWITCH is unset or 0, then print the instruction, then sleep for 3 seconds.
2) Launch TigerVNC's `Xvnc` which provides a guest (child) X11 server (X11 in X11) and a VNC server.
BTW, `killall Xvnc` kills the guest X11 just like `killall i3` kills all browsers and etc.
3) Launch `i3` in the guest X11, the i3 uses `i3-child-config` file from the same folder as `cdmpv.sh`. I chose to use i3 as a WM for a guest X11 because it allows to easily remove any borders and panels, uses little RAM, easily configurable.
4) Launch `ffmpeg` that grabs guest X11's screen and redirects it to `/dev/video8` (rawvideo->rawvideo, no videocodecs) with the help of V4L2. By the way, you can change `/dev/video8` in the `config.sh` file.
5) if i3 and AUTOSWITCH={non-zero number}, then switch to the virtual desktop {number} (counting from 1).
6) Spawn the `gtkvncviewer`. `gtkvncviewer` launches in fullscreen and changes the guest X11 resolution to the maximum it can fit (`gtkvncviewer` has no whatsoever options, so this behavior cannot be disabled).
7) Spawn `mpv` using the config from dir here (not yours) whose input is a fake web camera `/dev/video8`.
8) Switch `mpv` into a window mode, and set the window size to the largest available.
9) Switch `gtkvncviewer` into a window mode, and resize it to a resolution larger than the real monitor's resolution. Otherwise `gtkvncviewer` would resize (xrandr) the guest X11 resolution every time, which would also break `ffmpeg -f x11grab`.
10) Move `gtkvncviewer` to the position where only one row of pixels (e.g. w=1920px, h=1px) of its menu can be seen and clicked.
That 1 pixel row is useful, because sometimes you'll *need* to ungrab the keyboard: move your mouse to the very top and then use your keyboard. Only 1 pixel row because otherwise the displayed-by-mpv cursor and the actual cursor should be in one position.
11) Launch `picom` (former `compton`. Arch Linux's `picom` package provides a symlink compton->picom).
We need it to make `gtkvncviewer` 100% transparent.
12) Focus on `gtkvncviewer`.
In the end you actually see `mpv` but control `gtkvncviewer`.
Step 11 is needed because I couldn't find a way to display `mpv` always above `gtkvncviewer` AND ban focus grabbing for `mpv`.



## My failed attempts with VMs, the guest is Windows 10 x64, the host is Linux
I couldn't run Magpie in VirtualBox. Maybe because VirtualBox GPU Driver supports only DirectX 9.
I could run Magpie in VMware Workstation 16.1.2, but in most games FPS is very low with Anime4K and ACNet.
The FPS is low (8), but for some reason my CPU Load is only 33% and GPU load is very low. I tried experimenting with number of cores, nice level, etc.
Of course I installed the VM guest drivers.
Virtualization is enabled in UEFI and VMware. Motherboard: MSI B450M PRO-M2 MAX (MS-7B84).
On the other hand some software can cause 100% load (`nvtop`) to GTX 1660 Super in VMware, so it's not software acceleration.
If I force CPU powersave mode (max clock rate decrease from 3550 to 1550 MHz), then FPS in VMware is 3 or 4, not 8.
Note that I have only one RAM module (16 GB@3000MHz).
And when FPS is low, sound stutters every ~200 ms. And when I just play the game in VMware without Magpie, FPS is good, but every ~40 secs, sound stutters for 2-3 seconds.
Maybe problems with VMware are because I use the NVIDIA proprietary driver.


## Alternatives with far worse upscaling
### Alternative to this method for proprietary NVIDIA Linux users
Before I started using this hacky VNC approach, I had been using everywhere DXVK +
```
__GL_SHARPEN_VALUE=90 __GL_SHARPEN_IGNORE_FILM_GRAIN=90
```
Although the prefix is `__GL_`, they apply to Vulkan too.
Some VNs like `Shinigami no Kiss Wa Wakare no Aji` and `Wanko to Kurasou` somehow don't use DirectX (they use DirectDraw I think), so no sharpening there (and dgVoodoo 2 doesn't work too).
### Alternative to cdmpv
dgVoodoo 2 (Freeware, not Open Source).
http://dege.freeweb.hu/dgVoodoo2/dgVoodoo2/#latest-stable-version (no https)

This alternative produces better output than the NVIDIA-only sharpening.
The dgVoodoo 2's .exe is a GUI for creating `dgVoodoo.conf`. You don't need to use it.
Copy `D3D8.dll`, `D3D9.dll` and `dgVoodoo.conf` (maybe also `D3DImm.dll`, `DDraw.dll`) from `%dgVoodoo2UnpackedPath%/MS/x86/` into the folder containing game's .exe.
The game will automatically use the files.
BTW, you can replace all `.dll`s in `$WINEPREFIX/.wine/drive_c/windows/syswow64/` (but pay attention to upper/lower case, so that you would not have `d3d9.dll` AND `D3D9.dll`), but I don't know what Valve's VAC would think about that. I had to do that for `The Fruit of Grisaia` (though I still needed `dgVoodoo.conf`).

*!!!*
Use `dgVoodoo-ini/createDgVoodooConf.sh` to create your `dgVoodoo.conf`.
*!!!*

#### Changes from the original the dgVoodoo.conf:
`Resampling` from `bilinear` to `lanzcos-3`
`FullscreenAttributes =` to `FullscreenAttributes = Fake`
`FPSLimit = 0` to `FPSLimit = 144` (if your monitor is 144 Hz)
`AppControlledScreenMode` to `false`
`DisableAltEnterToToggleScreenMode` to `false`
In `[DirectX]`: `Resolution = unforced` to `Resolution = 1920x1080@144` (*NOTE*: it should remain `unforced` if you don't use dgVoodoo's upscaling)
In `[DirectX]`: `VRAM = 256` to `VRAM = 512`
`dgVoodooWatermark` to `true` to check if the dgVoodoo 2 is used.
Then change it back to `false` if all is OK.
Detailed info on all options: https://www.pcgamingwiki.com/wiki/DgVoodoo_2

## TODO: Sway as nested display server instead of i3 WM
### Problem 1
[Sway](https://github.com/swaywm/sway) is compatible with i3 WM, but how to check if we run Wayland?
If I go here, https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used
all commands' result is `tty` for me (I use `startx` to start i3).
One answer says to check `WAYLAND_DISPLAY` and `DISPLAY` variables... hm...

### Problem 2
`xdotool`'s replacements `wtype` and https://github.com/ReimuNotMoe/ydotool
don't seem to support commands: `windowstate`, `windowsize`, `windowmove`, `get_desktop`.
One of Wayland's (security) features is nobody has right to know what is in other windows.

But maybe `i3-msg`/`swaymsg` have commands similar to `xdotool`'s? Need to check.

### Problem 3
If the host is Wayland, can a guest be X11? I don't know, but I guess 99%.
But if a guest would be Wayland-based, then we need to replace Xvnc with something (wayvnc?).

### Problem 4
`ffmpeg -f x11grab` doesn't work.
I guess `-f kmsgrab` probably just grabs the screen that is displayed on the real monitor, not tested.
Maybe somehow use `ffmpeg` with `pipewire`?
The only way to grab a window's contents on Wayland I know is to use OBS (but I didn't test):

## Lessons learned
Downscaling algorithm is very important.
catmull_rom (short: catrom) and lanczos are the best.
(I'll compare lanczos vs ginseng later).
catmull_rom also somehow hides AiUpscale's ringing.
There are very different emotions from a picture depending
on which dscaler was used: mitchell, catmull_rom, lanczos, etc.
Bicubic is trash, by the way.
ewa_lanczos* give too blurry picture.
I use `feh` to look at how much info is lost and how smooth are lines.

Also I made an experiment:
I downscaled 1920x1080 original to 1280x720 with every dscaler, then upscaled it back with one upscaler.
I am lazy to search my result file, but lanczos and catmull_rom are the best (or it was spline16/36/64 with almost the same score, I forgot).

At least for 2D.

## License
Everything that **I** did in `cdmpv` is under CC0 (Public Domain).
Everything that was not done by me is obviously under other licenses.

If you use `cdmpv` and like it very much, you can donate:
1) Binance
https://www.binance.com/en/my/wallet/account/payment/send
Pay ID = 221728070, nickname = arzeth, any cryptocurrency.
2) If you don't use Binance, then
BTC: 1CjSZ8MWYEs9QVnbbMsLWgm9F7MXjvkxfK
ETH: 0xe55DB49bD551Fd805c231f71f8A4f1eAD6349EB8
3) No Patreon because I assume I would need to provide private/beta builds to patrons. Therefore, maybe later, because my upcoming upscaler is too unready for now.

## My other related projects
[sugoi-web](https://github.com/arzeth/sugoi-web) Web Frontend for Sugoi Translator


