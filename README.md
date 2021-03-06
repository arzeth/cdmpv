# cdmpv (Nested Display server over MPV)
Image quality is much better than Magpie.
<br/>"c" in "cdmpv" is because I used to think that "**C**hild display server" is the more appropriate term.
<br/>But now I am very accustomed to "cdmpv" (and it's easier to enter), so I keep it so.
<br/>You can upscale even 800x600 to 5K.
<br/>Or crop 800x600 to 16:9 at a certain position and then upscale.
<br/>
<br/>Games that grab mouse movements don't work, i.e. you can't play Quake with cdmpv.
<br/>That's because TigerVNC and UltraVNC (IIRC) don't support mouse movements, they send/receive only mouse's absolute position.
<br/>Therefore, it's recommended to play VNs with `cdmpv`.
<br/>
<br/>I developed `cdmpv` because [Magpie](https://github.com/Blinue/Magpie) doesn't work with Wine.
<br/>
<br/>And since I want more FPS,
<br/>and play without a nested display server,
<br/>and also want to play SC2 at 70-75 fps when the original FPS drops to 46 in big fights because my Ryzen 2600 is not enough,
<br/>now I am developing the overengineered ultrafast (upscaling only changed regions, switching upscalers on-the-fly to achieve target fps, potentially zero-copy) upscaler/first-in-the-world-universal-upframerater without using MPV and with using a proxy window instead of nested X11. It will probably be ready in February 2022.
<br/>In other words, `cdmpv` is a temporary measure.
<br/>
<br/>I didn't test `cdmpv` on other computers, so tell me if it doesn't work.
<br/>
<br/>Read everything below (especially the Hotkeys section) in order to use it.

## How good can it upscale?
### Example 1
Original (800x600, lossless .webp)
<br/>https://arzet.cf/scr/wanko_origHeight600.webp

Upscaled (2880x2160, 5.6MB lossless .webp) (Hotkey: w+w+w, low FPS on GTX 1660 Super)
<br/>https://arzet.cf/scr/wanko_upscaledHeight2160.webp

## Requirements
Linux (or probably FreeBSD/etc.).
<br/>Ability to launch MPV using X11 (Xwayland is ok).

## Terminology
X11=xorg. It is a display server. The other one in Wayland.
<br/>Host X11
<br/>Guest X11=Child X11=Nested X11=X11 in X11/Xwayland
<br/>VNC
<br/>WM=Window Manager.
<br/>[MPV](https://github.com/mpv-player/mpv) is a video player (also audio and images), it's used here for upscaling and displaying the result.
<br/>[i3](https://github.com/i3/i3) as a WM in nested X11.
<br/>[FFmpeg](https://github.com/FFmpeg/FFmpeg) for capturing what's inside nested X11.

## Don't forget to calibrate your monitor
http://www.lagom.nl/lcd-test/contrast.php
<br/>http://www.lagom.nl/lcd-test/black.php
<br/>http://www.lagom.nl/lcd-test/white.php
<br/>And especially sharpness (make sure that browser zoom is 100%): http://www.lagom.nl/lcd-test/sharpness.php

## How to use:
Go to vndb.org, see the resolution of a screenshot of the game (e.g. [The Fruit of Grisaia](https://vndb.org/v5154) uses [1024x576](https://s2.vndb.org/sf/26/127126.jpg)).
```
./cdmpv.sh {GUEST_RES} ( {GUEST_REFRESH_RATE = nested x11's fps = emulated display refresh rate} ({UPSCALED_FPS = how many frames per second should MPV upscale}))
./cdmpv.sh 1024x576 60 30
./cdmpv.sh 1024x576 74.5 74.5
./cdmpv.sh 1024x576 160 160/3??# If your monitor is 160 Hz
./cdmpv.sh 1024x576 30
./cdmpv.sh 1024x576

#Bad: ./cdmpv.sh 1280x720 29.97 29.97
#Bad: ./cdmpv.sh 1280x720 29.97002997002997003 29.97 #(because what you actually want is ~0.02997002997002997003 which is also impossible to write)
#Good: ./cdmpv.sh 1280x720 29.97002997002997003 30/1001 #(useful for displays running at 60/1001 Hz=~59.94005994005994006 Hz)
# 29.97002997002997003 here is for the nested X11, 30/1001 is for FFmpeg.


```
If you accidentally specify even 1px more, the upscaled result is far worse. If you specify 30px more than needed, then almost nothing will be upscaled because neural networks are not trained to upscale already upscaled images.
<br/>Inside nested X11, play games in fullscreen. The VNC Viewer itself could be even a window.
<br/>
<br/>If the VNC viewer has fully grabbed your input, then press F11 to show the context menu, then disable "Full screen".
<br/>`GUEST_REFRESH_RATE` is the guest X11's virtual (fake) display's refresh rate. Rarely gameplay in VNs is broken or becomes too fast when >60 Hz.
<br/>default `GUEST_REFRESH_RATE` is 60
<br/>default `UPSCALED_FPS` is 30
<br/>For ultra low-latency, change `--interpolation` from `yes` to `no` in `x11wid.sh` (command arguments override all file configs).
<br/>Although I suspect that interpolation is already (forcefully) disabled because no <code>--video-sync=display-resample</code>
<br/>which I didn't specify because it stops rendering.
<br/>
<br/>By default MPV uses the config provided here in `./mpvcfg/` instead of yours in `$HOME/.config/mpv/`
<br/>because there is at least 20% chance that your config is bad for this use case.
<br/>You can change that by setting `MPV__CONFIG_DIR` to `$HOME/.config/mpv` (use `$HOME` instead of `~` just in case) in `config.sh`
<br/>
<br/>i3 WM launched in the nested X11 uses the `i3-child-config` file from here.

## Why is VNC needed?
It is the only way to control a nested X11.
<br/>By the way, I'll probably soon add an alternative script that uses `kwin_wayland` instead of X11/Xvnc.

## Dependencies to use cdmpv
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
<br/>TigerVNC's vncviewer is not used because its vncviewer either
1) aggressively tries to resize the guest X11 to the host resolution
2) shows unscaled 1280x720 guest in the center of the screen on 1920x1080 host. We need the same *mouse* area as the MPV window.
<br/>
<br/>*If you don't need low FPS and playing backwards every 1000ms, then compile TigerVNC with my one-line patch*
<br/>Currently the only *easy* way to do that is if you use Arch Linux (or other distro that can create packages from PKGBUILD).
<br/>(the PKGBUILD is in this repo)

```
cd PKGBUILDS/tigervnc
makepkg -si
```

Now it is installed. It was patched with `dontpaint.patch` (1-2 lines) from the same folder.
<br/>With this patch, the VNC server will send only the very first frame to the VNC client. So if you `killall mpv`, then you would still see the `xfce4-terminal`.
<br/>
<br/>According to my experience,
<br/>every time you upgrade xorg-server (even if it is a minor version),
<br/>you should recompile this package.

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
<br/>we don't need to upscale the 99.9-100% similar frame 10000 times.

By default MP=2
<br/>MP=0 disables mpdecimate.
<br/>The higher MP, the more aggressive params are supplied to mpdecimate filter.
<br/>Maximum MP can be 8
`MP=4 ./cdmpv 1280x720 60 30`
or if you don't want to restart your already game
```
killall mpv
MP=4 ./x11wid.sh
```

Actually no, in many VNs there is an animated icon in the dialog window,
<br/>which causes to rerender everything (BTW, my future upscaler upscales only changed regions),
<br/>so if you don't want your GPU's fan to be 100%, then increase `MP`.

## Environment variable: C
See the code in x11wid.sh, there is code only for 800x600
<br/>By default `C=0`
<br/>`C` can also be `1` or `2` or `3`
<br/>If `C==1` then crop resolution 800x550, crop top=25px
<br/>If `C==2` then crop resolution 800x460, crop top=30px
<br/>If `C==3` then crop resolution 800x450, crop top=70px
<br/>FFmpeg crops, not mpv (although mpv can too, with vf, but then I would need `sed` copied `input.conf`...)
<br/>
<br/>Why crop? Because in old games there's unused space in the bottom.
<br/>
<br/>BTW, you can also Ctrl+Up/Down/Left/Light; zoom is ctrl+u, ctrl+shift+u.
<br/>Note that if you zoom with MPV, MPV will still upscale the whole image and the output resolution won't change (exception: SSimSuperRes, which is a POSTKERNEL shader).

```
MP=4 C=2 ./x11wid.sh
```

So when you need the bottom part (e.g. to save the game; the Log button),
<br/>then either
1) Ctrl+Up/Down (but remember how many times you pressed)
2) Close x11wid.sh (or `killall mpv` if you still haven't launched it separately outside of cdmpv.sh) and start ./x11wid.sh with different `C`.



## MPV's hotkeys (read it!!!)
I am probably the only one in the world that benchmarked all possible shaders chains
<br/>(I blacklisted some of low-quality patterns, so that it would not take years)
<br/>on 2 images and 2 resolutions (800x450???1920x1080, 1280x720???1920x1080),
<br/>I'll publish my script and results in .json later,
<br/>my benchmark script primarily uses ssim (https://github.com/Alexkral/AviSynthAiUpscale/issues/3, code by igv),
<br/>but also dssim (AUR: dssim-git).
<br/>
<br/>Most shader chains that are in `input.conf` are optimized for 1920x1080 (or probably 2560x1440) screen because my monitor is 1920x1080.
<br/>All shaders upscale images 2x times (1280x720???2560x1440) except when it is explicitly written 3x or 4x in their file name.
<br/>So their results need to be downscaled afterwards at the final stage if the result has higher resolution than your screen's.
<br/>Only SSimSuperRes (by igv) and MPV's built-in upscalers (`scale=` in `mpv.conf`) can upscale to any arbitrary resolution (1.223x, etc.).
<br/>If the upscaled result image is the same size as your screen, then the sharpener is needed (`~~/shaders/igv/SSimDownscaler.glsl`) or Light_Soft shader `~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY-half.glsl` (or not -half), test yourself. Sometimes they are already included (especially in case of Anime4K *CNN* Upscalers that produces lines that are thicker than needed).
<br/>So if you have 4k/5k display, then add additional Anime4K -UL or -UL-YYY or -L variant or ~~/shaders/superxbr.glsl (it's like lanczos but lines are much smoother) at the end of string in `input.conf` if your GPU allows it and it isn't there already.
<br/>
<br/>If you are at the same terminal's tab where you launched `cdmpv.sh`,
<br/>then that means you can control MPV with your keyboard (because cdmpv.sh launches cdmpvTempBgTasks.sh in bg which launches x11wid.sh in bg).
<br/>Or you can `killall mpv`, create a new tab in host X11/Wayland and `./x11wid.sh`.
<br/>
<br/>Every hotkey in `input.conf` cycles through 1-5 shaders.
<br/>If it is written "press `2` three times", but you accidentally press it four times, press `0` (uses either SSimSuperRes or SSimDownscaler) or `shift+0` (uses nothing), then repeat what you wanted.
<br/>
<br/>When you switch a shader chain, you'll see a message in the MPV's log (it is written to stdout, it is not written to a file).
<br/>To switch a shader chain, you should press a key, *then wait while it renders a new frame with it* (up to 2 seconds unless they aren't in your shader cache because you never used them),
<br/>then go back to the terminal to look if you got the correct "glsl-shaders"
<br/>
<br/>Shader cache is stored in `~/.config/mpv/shader_cache` (you can change that in config.sh)
<br/>Shaders are compiled by CPU of course.
<br/>The heaviest shaders are compiled ~20 seconds on Ryzen 2600.
<br/>You get blue screen when shader compilation failed or not enough VRAM to use a shader chain.
<br/>
<br/>Hotkeys are specified in `input.conf`.
<br/>Every time you launch `x11wid.sh`, it copies `input.conf` and removes all `ctrl+` (because `ctrl+` hotkeys conflict with the terminal's).
<br/>
<br/>This shader chain is used by default at every launch for all resolutions.
2x upscaling (e.g. 1280x720???2560x1440) and very high FPS, smooth lines, no ringing. Disadvantages: blurred BG, very similar colors are blended, no small details (e.g. grain disappears from hair in Daitoshokan no Hitsujikai); lines are thicker (than the original) without Anime4K_Restore.
The hotkey: press one time <code>a</code>.
```
~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_ULF-KrigBilateral.glsl:~~/shaders/Anime4K_Restore_CNN_Light_S-YYY-half.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

For (<code>a</code> + 1% better colors) use <code>o</code>.

The faster shader chain is <code>o+o</code>
```
~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_ULF-KrigBilateral.glsl:~~/shaders/igv/SSimSuperRes.glsl
```
It is used by default when
<br/>input resolution is > 1579 but (output resolution / input resolution) ??? 1.23.
<br/>E.g. for 1600x900 ??? 1920x1080.

The even faster shader chain is <code>o+o+o</code> (the only one here with color distortions):
```
~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_ULF.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

The fastest shader chain is <code>0</code> which is just:
```
~~/shaders/igv/SSimSuperRes.glsl
```

BTW, SSimSuperRes gets used only when previous upscalers didn't upscale the image big enough.

No shader chain is <code>shift+0</code> (MPV's built-in lanczos shader will be used for upscaling).



Press one time <code>e</code> if you want the same as <code>a</code>, but 4x upscaling.
```
~~/shaders/igv/KrigBilateral.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-first-init.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_UL-LUMA.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-apply.glsl:~~/shaders/Anime4K_Restore_CNN_Light_Soft_S.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

<code>e</code>+<code>e</code> is better than <code>e</code> but slower.
<br/><code>e</code> has significantly less details than <code>a</code>.
<br/><code>e</code>+<code>e</code> has less details than <code>a</code>.
<br/>
<br/>Anime4K CNN Upscaler (<code>+a</code>, <code>+e/+e+e</code>) is the best for Kimagure Temptation because it fixes aliasing which is caused by the VN itself badly downscaling the animated hair.
<br/>
<br/>
<br/>
<br/>
<br/>Press one time <code>2</code> if you play Vampire's Melody (original is 1920x1080) because the animated sprite seems to be a lossy video (I also tried downscaling before upscaling but the result is worse).
```
~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY.glsl:~~/shaders/igv/SSimSuperRes.glsl
```
<br/>
<br/>Press two times <code>2</code> if you play the 1920x1080 game at 1920x1080 screen, and when a character's face is near, you see sprites are low-resolution,
in this case you need this:

```
~~/shaders/Anime4K_Restore_CNN_Light_Soft_VL-YYY-half.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

or in some cases just <code>./cdmpv 1280x720 60 60</code> for this game, although somes VNs use very bad cheap downscaling when the output resolution is lower than original (Kinkoi on Unity, at least the early version)... or less likely it's a bug in Wine.
<br/>
<br/>Press three times <code>2</code> if you play Monkey!?? because the original has mega aliasing.

```
~~/shaders/Anime4K_Restore_CNN_Moderate_Soft_VL-YYY.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

<br/>For Wanko to Kurasou (800x600->4K) press three or four times <code>shift+q</code> (depending on FPS and tastes).
<br/>If that's too slow, then press two times <code>e</code> (or <code>a</code> for a 1920x1080 monitor).
<br/>
<br/>
Press
<br/><code>y</code> (less details but less pixelated)
<br/>or <code>shift+y</code> (less details but less pixelated and almost no color noise)
<br/>or <code>f</code> (no pixelation)
<br/>if you play the old version of YU-NO.
<br/>
<br/>Press one time <code>shift+q</code> (good for 800x600 ??? 1920x/2560x; the best for Sugar * Style 1280x720???1920x1080)
```
~~/shaders/igv/KrigBilateral.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-first-init.glsl:~~/shaders/Anime4K_Upscale_GAN_x3_VL-LUMA.glsl:~~/shaders/Anime4K_Clamp_Highlights-LUMA-apply.glsl:~~/shaders/igv/SSimSuperRes.glsl
```

Sometimes `w` is the best (e.g. Koikari Love for Hire), but sometimes it has ringing especially in fonts.
```
~~/shaders/igv/KrigBilateral.glsl::~~/shaders/avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.glsl:~~/shaders/Anime4K_Restore_CNN_Light_VL-YYY.glsl:~~/shaders/igv/SSimSuperRes.glsl
```
Or rarely `n` is better (same as `w` but without Restore). The `Restore` shaders fix some ringing for AiUpscale.
<br/>Also lines are aliased (in other words, ladder) for some VNs with AiUpscale, which doesn't show up on SSIM test, but we humans see it.

### MPV's hotkeys for reparing the image BEFORE upscaling (read it too!!!)
Many VNs used very bad/cheap downscaling algos (i.e. bicubic, bilinear or even nearest-neighbor) instead of good algos like lanczos (there are probably variations of lanczos DS, at least the MPV/libplacebo's one is good) or ginseng (both lanczos and ginseng are very similar), catmull_rom or spline16 (both are very similar).
<br/>In Palette's Saku Saku you can see aliasing (lines are ladders), especially for far away chars.
<br/>Maybe all Kirikiri games (files are .xp3) suffer from having a bad DS algo, I don't know.
<br/>
<br/>Other VNs use low-res character sprites, which is not noticable only when a character is far.
<br/>Even 2022's VNs still have this issue, like the 1920x1080 3-lang edition (released in 2022-01 by NekoNyan) of Hello Lady.
<br/>*NOTE*: all of the following hotkeys in this list work only for those upscalers whose hotkey is either <code>a</code> (2x), <code>e+e</code> (4x), <code>o</code> (2x+more details but noise), <code>o+o</code> (same as <code>a</code> but 3% better colors), <code>o+o+o</code> (same as <code>a</code> but sacrifices colors for speed), <code>J</code> (slow 3x). If you try to use it with other upscalers (LUMA upscalers), then it would be reparing *after* upscaling which is already is in shader chains.
<br/>Hotkeys (you can have only one type of repairing):
<br/><code>2</code> Disable repairing
<br/><code>@</code> Heavy repairing (Anime4K_Restore_CNN_**Moderate_Soft_M**-YYY.glsl). Not always recommended.
<br/><code>3</code> Heavy repairing (Anime4K_Restore_CNN_**Moderate_Soft_M**-YYY-percent75.glsl). Not always recommended (but recommended for A Clockwork Ley-Line).
<br/><code>#</code> Medium repairing (Anime4K_Restore_CNN_**Moderate_Soft_M**-YYY-**half**.glsl).
<br/><code>4</code> Low repairing (Anime4K_Restore_CNN_**Light_Soft_M**-YYY-**percent70**.glsl).
<br/><code>$</code> Very low repairing (Anime4K_Restore_CNN_**Light_Soft_M**-YYY-**half**.glsl).
<br/><code>5</code> (rare) If the input has very heavy aliasing and you need a high FPS (Anime4K_Restore_CNN_**Light_Soft_S**-YYY.glsl).
<br/><code>%</code> low FPS, sometimes less details (Anime4K_Restore_CNN_**Light_Soft_VL**-YYY.glsl). (5 and % are recommended for HARUKAZE's Monkeys!??, A Clockwork Ley-Line)
<br/>Use the above hotkeys AFTER pressing a hotkey for upscaling algos (btw, if you prefer the default upscale algo, then, obviously, don't press); otherwise, if you press "3" then "a", then you would get no repairing, because "a" clears all previous shaders.

## About new shaders
Anime4K shaders are optimized for x264 videos, i.e. videos with all kinds of artifacts.
<br/>Also I think they are trained on JPEG q=95 (`jpeg_factor=95` in https://github.com/bloc97/Anime4K/blob/master/tensorflow/Train_Model.ipynb)
<br/>But in most VNs sprites are lossless and backgrounds are like JPEG q???95.
<br/>Anime4K Upscale shaders are very bad for background, they think all details are noise so just blur everything.
<br/>But Anime4K Restore shaders barely do so.

When input is lossless, `Anime4K_Restore_CNN_*-YYY.glsl` (MAIN shaders) is better, than non-`-YYY` because black lines don't become red. It takes RGB input, but changes only the Y channel.
<br/>Generated by
```
u=YYY ./resluma.sh Anime4K_Restore_CNN_*
```

Anime4K_Clamp_Highlights-LUMA-first-init.glsl
<br/>Anime4K_Clamp_Highlights-LUMA-apply.glsl
<br/>Usage for these two see in `input.conf`


`Anime4K_*-LUMA.glsl` are for use before LUMA shaders. But because they originally supposed to also take non-black-and-white input (i.e. U and V channels = chroma), results are a little bit worse. The exception is GAN_x3_VL.
<br/>Generated by
```
./upluma.sh Anime4K_Upscale*
```


Because with Anime4K_Upscale_CNN_x2_* everything was a little (e.g. Red 40/255 ??? 54/255) more red (unless `Anime4K_Upscale_CNN_x2_L` is used), I created
<br/>Anime4K_Upscale_CNN_x2_ULF-KrigBilateral.glsl
<br/>Although the input is still RGB, only Y channel and U channel are upscaled by Anime4K, while V is upscaled by KrigBilateral embedded in the same file.
<br/>It requires a little more VRAM (to store both the upscaled image and also the original image).
<br/>V channel only is because there's something wrong with upscaling U channel. FIXME!
<br/><code>+o</code> uses a little bit slower <code>Anime4K_Upscale_CNN_x2_ULF-slowerKrigBilateral-noise.glsl</code> that doesn't damage background images. <code>+o</code> has the best SSIM possible for Anime4K CNN upscale shaders.


If a shader file has `F` at the end, then that means that this shader will be *f*orcefully (no `//!WHEN`) used even the input resolution is bigger than display resolution.
<br/>If a shader file has `Cla` at the end, then that means Anime4K_Clamp_Highlights.glsl is embedded.
<br/>`FCla` = `F` + `Cla`
<br/>
<br/>`avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.glsl` has many additional changes to fight ringing.
<br/>`avisynth/mpv user shaders/LineArt/3x/AiUpscale_HQ_3x_LineArtFCla.orig.glsl` is without those changes (`n` two times or `w` four times)

AiUpscale_HQ_4x_LineArt is worse than _3x, at least for 2D,
<br/>althought a few details are better, so I didn't include int

## Screenshots
`DISPLAY=:44 scrot` to save original unupscaled image as .png.
<br/>Press `s` in MPV's CLI to save *un*upscaled image as .png to `/tmp/`
<br/>Press `shift+s` in MPV's CLI to save upscaled image as .png to `/tmp/`


## About shaders
When 1280x720???1920x1080, then AiUpscale_HQ_3x_LineArt has much better SSIM than AiUpscale_HQ_2x_LineArt for 2D sprites, but the overall SSIM is worse (~0.00234 vs ~0.00263) because background images are not very anime.
<br/>`Anime4K_Clamp_Highlights.glsl` is needed because upscalers accidentally create very bright micro areas.
<br/>Anime4K_Upscale_*CNN*_ hates small details, so I fixed this by prenoising the chroma and then replacing the Anime4K CNN's chroma with KrigBilateral's (both U and V) that is supplied the original chroma. The file is <code>Anime4K_Upscale_CNN_x2_ULF-slowerKrigBilateral-noise.glsl</code>
<br/>TsubaUP is good for everything except 2D (especially hair is bad).
<br/>FSRCNNX is kinda like TsubaUP but slower but upscales hair better.
<br/>I tested only VNs, but FSRCNNX_x2_56-16-4-1.glsl is always worse than _16, so I didn't include it.
<br/>The latest revision of SSimDownscaler.glsl does something bad to eyes,
<br/>so the previous 2021-10-08 revision is used that I named `SSimDownscaler_oct8.glsl`
<br/>`nnedi3-nns128-win8x6.hook` is very bad, so not even included.
<br/>`Anime4K_Upscale_GAN_x4_UUL.glsl` (two `U`) thins lines too much. Probably it was created for ancient anime videos.
<br/>`Anime4K_Upscale_GAN_x4_UL.glsl` is not worth if I remember correctly.
<br/>
<br/>`ravu-zoom-*` damages geometry, so not included. And FSRCNNX is simply better.
<br/>
<br/>`Anime4K*Restore*UL` work only on Vulkan, and is not used because too slow and sometimes worse than VL.
<br/>
<br/>(<code>POSTKERNEL</code> stage is used right before MPV downscales the image with the algo chosen in `dscale`. MPV downscales only when needed.
<br/>
<br/>SSimDownscaler (POSTKERNEL stage shader) is a sharpener. If the image is not going to be downscaled afterwards by MPV, then this shader is not used because it would introduce many artifacts.
<br/><code>SSimSuperRes.glsl</code> (POSTKERNEL stage shader) is a fast upscaler without neural networks.


## Tips
1) https://www.reddit.com/r/visualnovels/comments/lh10yb/getting_movies_to_work_in_visual_novels_on_linux/ (also read all comments)

2) Disable auto cursor move (i.e. you click "Save game", and your mouse moves to the "Yes" button) in the game menu
<br/>because the game runs in nested X11
<br/>and it sends the mouse move command only to the nested X11,
<br/>so the next time you move your mouse,
<br/>your nested X11's mouse position reverts to the host's one.

3)
`wine explorer /desktop=cdmpv,$YOURGUESTRESOLUTION`
or
`wine explorer /desktop=cdmpv,$YOURGUESTRESOLUTION game.exe`
<br/>enables wine's own virtual desktop just for current session (doesn't add nor overwrite `[Software\\Wine\\Explorer\\Desktops]` in your `$WINEPREFIX/user.reg`), which is sometimes needed because `i3` is a *tiling* window manager, i.e. when you have one window, its size is fullscreen, but if you open a second window, both windows would get automatically the same size???half of the screen each. You can press Win+W or Win+Space or Win+Shift+Space to control that.
<br/>One wineprefix can have multiple of them.

4) If you want Steam to be in host X11/Wayland but you want the game to be in nested X11, then go into game's options -> command arguments -> env DISLPAY=:44 %command%

5) Black screen in Saku Saku Cherry Blossoms and flickering in Grisaia, Himawari, Ikinari Anata ni Koishiteiru
<br/>If you have graphical glitches, then use dgVoodoo2 (see the below section).
<br/>If you still have graphical glitches or crashes when a video starts to play, then use dgVoodoo2 (you can read about it in the "Alternative to cdmpv" section) AND software rendering AND *un*installed DXVK, which is 100% performance-wise enough for VNs:
```
__GLX_VENDOR_LIBRARY_NAME=mesa LIBGL_ALWAYS_SOFTWARE=1 VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json MESA_LOADER_DRIVER_OVERRIDE=zink
```
<br/>
<br/>If an .exe file says a strange error as soon as you launch it, then that's because you set <code>STAGING_WRITECOPY=1</code> somewhere (<code>env|grep STAGING</code> or <code>.bashrc</code>/<code>.zshrc</code>).
<br/>
<br/>BTW, when using NVIDIA GPU (I don't know about other GPUs) inside *nested* X11 there is a problem with <code>glxinfo</code> (fails to start every 5th time) and videos (they either always fail or never) in some VNs:
<br/>E.g. Akeiro Kaikitan as soon as it tries to play a video, the wine process finishes with X11 error (`BadAlloc (insufficient resources for operation)`, opcodes: `150 (GLX), 5 (X_GLXMakeCurrent), 0, 42`)
<br/>Also I found out that Akeiro Kaikitan saves the read messages only after manually exiting the whole game, not when returning to main menu.
<br/>The workaround for this is the same as above but probably only __GLX_VENDOR_LIBRARY_NAME=mesa is enough, i.e. using software rendering, but dgVoodoo2 is not necessary.
<br/><code>__GLX_VENDOR_LIBRARY_NAME=mesa</code> applies only to OpenGL; so if you see the DXVK log, then your GPU is used.
<br/>Also you can use that env variable for the entire X11:
```
__GLX_VENDOR_LIBRARY_NAME=mesa ./cdmpv.sh 1280x720 60 25
```

<br/>

Uninstall DXVK:

```
/usr/share/dxvk/setup_dxvk.sh uninstall
```

Install DXVK:
```
/usr/share/dxvk/setup_dxvk.sh install --with-d3d10 --symlink
```

Don't forget about `WINEPREFIX=`

6) In one case (Schatten) as soon as you start it, there's a unskippable video which is displayed black and played for 1 minute.

7) Use [wine-tkg](https://github.com/Frogging-Family/wine-tkg-git). If you use Arch Linux, then add chaotic-aur repo.

## dgVoodoo 2 (Freeware, not Open Source)
http://dege.freeweb.hu/dgVoodoo2/dgVoodoo2/#latest-stable-version (no https)
<br/>
<br/>The dgVoodoo 2's .exe is a GUI for creating `dgVoodoo.conf`. You don't need to use it.
<br/>Copy `D3D8.dll`, `D3D9.dll` (maybe also `D3DImm.dll`, `DDraw.dll`) from `%dgVoodoo2UnpackedPath%/MS/x86/` into the folder containing game's .exe.
<br/>The game will automatically use the files.
<br/>BTW, you can replace all `.dll`s in `$WINEPREFIX/.wine/drive_c/windows/syswow64/` (but pay attention to upper/lower case, so that you would not have `d3d9.dll` AND `D3D9.dll`), but I don't know what Valve's VAC would think about that. I had to do that for `The Fruit of Grisaia` (though I still needed `dgVoodoo.conf`).

*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*
<br/>Use `dgVoodoo-ini/createDgVoodooConf.sh VN_origWidth_in_px VN_origHeight_in_px 60 60` to create your own `dgVoodoo.conf`.
<br/>*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*


## Current Algorithm of ./cdmpv.sh
1) If PREFER_AUTOCUTSEL=1 (default) in `config.sh`, then for reliable copy clipboard from nested X11 to host X11 (didn't test this feautre on Wayland), patched `autocutsel` is automatically compiled if it wasn't compiled yet.
<br/>It is needed because the VNC protocol by default supports only ASCII. There are some hacks in TigerVNC (both server and client) but sometimes it forgets to send update to the host.
2) Cache all executable files into RAM (useful for HDD).
3) Launch `./cdmpvTempBgTasks.sh` in background
4) Launch TigerVNC's `Xvnc` which provides a guest (child) X11 server (X11 in X11/Wayland) and a VNC server.
4..) After launcing Xvnc there is no more code to execute in `./cdmpv.sh` but `cdmpv.sh` is still active because it executes `Xvnc`
5) `cdmpvTempBgTasks.sh`: Launch `i3` in the guest X11, the i3 uses `i3-child-config` file from the same folder as `cdmpv.sh`. I chose to use i3 as a WM for a guest X11 because it allows to easily remove any borders and panels, uses little RAM, easily configurable.
6) `cdmpvTempBgTasks.sh`: Launch TigerVNC's `vncviewer`. Don't forget that it should be patched.
7) `cdmpvTempBgTasks.sh`: Execute `./x11wid.sh`. It launches `ffmpeg` that grabs guest X11's screen which it pipes to `mpv`.
<br/>`mpv` is launched with `--wid={vncviewer's window id}` which makes `mpv` a child window of the VNC client.
<br/>You look at `mpv` but all keyboard & mouse control goes to `vncviewer`.
<br/>So if `mpv` crashes or you updated one of `.glsl` or `.conf`, then `killall mpv`, then `./x11wid.sh`.
<br/>You can 100% safely Ctrl+c `x11wid.sh`.
<br/>If you decide to change FPS without restarting `cdmpv.sh`, then `./x11wid.sh 30` or edit `.env-of-current-process` and then `./x11wid.sh`
<br/>If you specify too high FPS for your GPU then you would get high latency for unknown reason.

If you want to close `cdmpv.sh`, then Ctrl+c it and it will automatically kill all the processes it spawned.

## Former Deprecated Algorithm (read this only if you are curious)
0) Host must be X11, preferably i3 WM. If you have a login screen, and there is a button that says "Wayland session", then you have Wayland instead of X11.
0) No compositor (i.e., no `xfwm`, `metacity`, `compiz`, `KWin`). Or, if you already use `picom` (`compton`),
then see what you need to change in your config.
0) After launching need to wait 20 seconds (because that's how many `sleep`s are in the scripts).
1) if no i3 or if AUTOSWITCH is unset or 0, then print the instruction, then sleep for 3 seconds.
2) Launch TigerVNC's `Xvnc` which provides a guest (child) X11 server (X11 in X11) and a VNC server.
<br/>BTW, <code>killall Xvnc</code> kills the guest X11 just like <code>killall i3</code> kills all browsers and etc.
3) Launch `i3` in the guest X11, the i3 uses `i3-child-config` file from the same folder as `cdmpv.sh`. I chose to use i3 as a WM for a guest X11 because it allows to easily remove any borders and panels, uses little RAM, easily configurable.
4) Launch `ffmpeg` that grabs guest X11's screen and redirects it to `/dev/video8` (rawvideo->rawvideo, no videocodecs) with the help of V4L2. By the way, you can change `/dev/video8` in the `config.sh` file.
5) if i3 and AUTOSWITCH={non-zero number}, then switch to the virtual desktop {number} (counting from 1).
6) Spawn the `gtkvncviewer`. `gtkvncviewer` launches in fullscreen and changes the guest X11 resolution to the maximum it can fit (`gtkvncviewer` has no whatsoever options, so this behavior cannot be disabled).
7) Spawn `mpv` using the config from dir here (not yours) whose input is a fake web camera `/dev/video8`.
8) Switch `mpv` into a window mode, and set the window size to the largest available.
9) Switch `gtkvncviewer` into a window mode, and resize it to a resolution larger than the real monitor's resolution. Otherwise `gtkvncviewer` would resize (xrandr) the guest X11 resolution every time, which would also break `ffmpeg -f x11grab`.
10) Move `gtkvncviewer` to the position where only one row of pixels (e.g. w=1920px, h=1px) of its menu can be seen and clicked.
<br/>That 1 pixel row is useful, because sometimes you'll *need* to ungrab the keyboard: move your mouse to the very top and then use your keyboard. Only 1 pixel row because otherwise the displayed-by-mpv cursor and the actual cursor should be in one position.
11) Launch `picom` (former `compton`. Arch Linux's `picom` package provides a symlink compton->picom).
<br/>We need it to make `gtkvncviewer` 100% transparent.
12) Focus on `gtkvncviewer`.
<br/>In the end you actually see `mpv` but control `gtkvncviewer`.
<br/>Step 11 is needed because I couldn't find a way to display `mpv` always above `gtkvncviewer` AND ban focus grabbing for `mpv`.



## My failed attempts with VMs, the guest is Windows 10 x64, the host is Linux
I couldn't run Magpie in VirtualBox. Maybe because VirtualBox GPU Driver supports only DirectX 9.
<br/>I could run Magpie in VMware Workstation 16.1.2, but in most games FPS is very low with Anime4K and ACNet.
<br/>The FPS is low (8), but for some reason my CPU Load is only 33% and GPU load is very low. I tried experimenting with number of cores, nice level, etc.
<br/>Of course I installed the VM guest drivers.
<br/>Virtualization is enabled in UEFI and VMware. Motherboard: MSI B450M PRO-M2 MAX (MS-7B84).
<br/>On the other hand some software can cause 100% load (`nvtop`) to GTX 1660 Super in VMware, so it's not software acceleration.
<br/>If I force CPU powersave mode (max clock rate decrease from 3550 to 1550 MHz), then FPS in VMware is 3 or 4, not 8.
<br/>Note that I have only one RAM module (16 GB@3000MHz).
<br/>And when FPS is low, sound stutters every ~200 ms. And when I just play the game in VMware without Magpie, FPS is good, but every ~40 secs, sound stutters for 2-3 seconds.
<br/>Maybe problems with VMware are because I use the evil NVIDIA proprietary driver.


## Alternatives with far worse upscaling
### lanczos-3 by dgVoodoo 2
Use the above "dgVoodoo2" section but change <code>Resolution</code> to e.g. <code>1920x1080@144</code>.
<br/>Then just launch the game with Wine without any cdmpv's scripts.

### Alternative to this method for proprietary NVIDIA Linux users
Before I started using this hacky VNC approach, I had been using everywhere DXVK +
```
__GL_SHARPEN_VALUE=90 __GL_SHARPEN_IGNORE_FILM_GRAIN=90
```
Although the prefix is `__GL_`, they apply to Vulkan too.
<br/>Some VNs like `Shinigami no Kiss Wa Wakare no Aji` and `Wanko to Kurasou` somehow don't use DirectX (they use DirectDraw I think), so no sharpening is there (and dgVoodoo 2 doesn't work too).

#### How dgVoodoo.conf differs from the original default file:
`Resampling` from `bilinear` to `lanzcos-3`
<br/>`FullscreenAttributes =` to `FullscreenAttributes = Fake`
<br/>`FPSLimit = 0` to `FPSLimit = 144` (if your monitor is 144 Hz)
<br/>`AppControlledScreenMode` to `false`
<br/>`DisableAltEnterToToggleScreenMode` to `false`
<br/>In `[DirectX]`: `Resolution = unforced` to `Resolution = 1920x1080@144` (*NOTE*: it should remain `unforced` if you don't use dgVoodoo's upscaling)
<br/>In `[DirectX]`: `VRAM = 256` to `VRAM = 512`
<br/>`dgVoodooWatermark` to `true` to check if dgVoodoo 2 is being used.
<br/>Then change it back to `false` if all is OK.
<br/>Detailed info on all options: https://www.pcgamingwiki.com/wiki/DgVoodoo_2

## TODO: Sway as nested display server instead of i3 WM
### Problem 1
[Sway](https://github.com/swaywm/sway) is compatible with i3 WM, but how to check if we run Wayland?
<br/>If I go here, https://unix.stackexchange.com/questions/202891/how-to-know-whether-wayland-or-x11-is-being-used
<br/>all commands' result is `tty` for me (I use `startx` to start i3).
<br/>One answer says to check `WAYLAND_DISPLAY` and `DISPLAY` variables... hm...

### Problem 2
`xdotool`'s replacements `wtype` and https://github.com/ReimuNotMoe/ydotool
<br/>don't seem to support commands: `windowstate`, `windowsize`, `windowmove`, `get_desktop`.
<br/>One of Wayland's (security) features is nobody has right to know what is in other windows.
<br/>
<br/>But maybe `i3-msg`/`swaymsg` have commands similar to `xdotool`'s? Need to check.

### Problem 3
If the host is Wayland, can a guest be X11? I don't know, but I guess 99%.
<br/>But if a guest would be Wayland-based, then we need to replace Xvnc with something (wayvnc?).

### Problem 4
`ffmpeg -f x11grab` doesn't work.
<br/>I guess `-f kmsgrab` probably just grabs the screen that is displayed on the real monitor, not tested.
<br/>Maybe somehow use `ffmpeg` with `pipewire`?
<br/>The only way to grab a window's contents on Wayland I know is to use OBS (but I didn't test):

## Lessons learned
Which downscaling algorithm is used is very important.
<br/>There are very different emotions from a picture depending
<br/>on which dscaler was used: mitchell, catmull_rom, lanczos, etc.
<br/>catmull_rom (short: catrom) and lanczos are the best.
<br/>(though I didn't compare lanczos vs ginseng which are very similar to each other).
<br/>Bicubic is trash, by the way.
<br/>catmull_rom also somehow hides AiUpscale's ringing.
<br/>ewa_lanczos* give too blurry picture.
<br/>I use `feh` to look at how much info is lost and how smooth are lines.
<br/>
<br/>Also I made an experiment:
<br/>I downscaled an 1920x1080 original image to 1280x720 with every dscaler, then upscaled them back with one upscaler.
<br/>I am lazy to find my result file, but lanczos and catmull_rom are the best (or it was spline16/36/64 with almost the same score, I forgot).
<br/>
<br/>At least for 2D.

## License
Everything that **\*I\*** did in `cdmpv` is under CC0 (Public Domain).
<br/>Everything that was not done by me is obviously under other licenses.

## My other related projects
[sugoi-web](https://arzeth.github.io/sugoi-web/) Web Frontend for Sugoi-Japanese-Translator (offline & better than DeepL).


