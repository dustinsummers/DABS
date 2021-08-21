# DABS

Download Android Binaries based on Search Term (DABS for short)

![889-8897411_dabbing-android-android-gingerbread-logo](https://user-images.githubusercontent.com/25121655/130323697-e8ce30d5-9d17-42d5-8541-632600a7ac1b.png)

## Description
Ever need to download a binary file from your Android device/emulator, but don't know the package name or the path?

Well, you could use the following, which I have been doing for years...

```shell
adb shell pm list packages | grep <search term for app>
adb shell pm path <package from above>
adb pull <path>
```
Easy, right?  But these days with App Bundles, binaries don't come nicely packaged up like they use to in a single `.apk` file.  

Instead strings, images, assets, and code files can all come scattered into separate `.apk` files that all need to be installed together for the app to function, which requires people like me to download each individually.

Still not bad, but in general, it's a waste of time.

And no one has time to waste.

Enter **DABS**.  

With DABS, you can simply enter the following in, and it will download all paths associated with your search term.

```shell
dabs -s "google"
```

This will output a list of packages associated with that search term:

```shell
[0] com.google.android.apps.nbu.paisa.user
[1] com.google.android.apps.pixelmigrate
[2] com.google.android.projection.gearhead
[3] com.google.android.wifi.resources
[4] com.google.android.apps.wallpaper
[5] com.google.android.apps.youtube.music
[6] com.google.android.apps.nexuslauncher.auto_generated_rro_product__
[7] com.google.android.cellbroadcastreceiver
[8] com.google.android.inputmethod.latin
[9] com.google.android.apps.restore
-=-=-=-=-=-=-=-=-=-=-=-=-
[#] to download a specific package.
[a] or [all] to download all packages listed.
[c] or leave blank to exit.
```

From here, you can choose to download all of them, or pick and choose your adventure.

This will create a directory based on the package, and download all necessary files into that directory for you.

## Dependencies

Since DABS is a fish function, it requires the following:
- [Fish Shell](https://fishshell.com/) 
  - `brew install fish`
- [Android Debug Bridge](https://developer.android.com/studio/releases/platform-tools?authuser=4)
  - You probably already have this if you have [Android Studio](https://developer.android.com/studio/releases?authuser=4) installed

## Configuration
Configuring is easy.

With Fish Shell already installed, go into your fish functions directory, usually located at the below:
```shell
cd ~/.config/fish/functions/
```

Inside of this folder, you can clone the repo:
```
git clone git@github.com:dustinsummers/dabs.git
```

After that, open up a shell and quickly run a `source` on the new `.fish` we just downloaded:
```shell
source ~/.config/fish/functions/dabs/download_app_based_on_search_term.fish`
```
<Note: You shouldn't need to source everytime you open up a new shell/terminal, but if you find yourself in that situation, add this line to the alias below or just add this line at the top of your `config.fish` file and you should be good :)>

From here, it is just a matter of pointing your `config.fish` file to this new function with an alias.

Inside of `~/.config/fish/config.fish`, add the following line wherever you keep your `alias`:
```fish
alias dabs="download_app_based_on_search_term"
```

## Use

At the time of this writing, only two options exist:
```shell
dabs -d <device to point to if you have multiple> -s <search term>
```

Example:
```shell
dabs -d emulator-5554 -s "google"
```

From here, the terminal will prompt for input in regards to which packages to download/directories to store, etc.

# Enjoy!
