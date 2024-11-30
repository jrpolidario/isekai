# Isekai

* This is an unfinished development of a 2.5D Minecraft-clone (that I envisioned) using my `rubuild` (my owng game engine that I have not yet extracted out from this repo, located inside `lib/`)
* There was something that I got stuck and could not readily fix, and I lost motivation unfortunately.
* I got the "positioning" and "rendering" part of the game engine ready already, though as you could see below:

<img width="1792" alt="Screenshot 2024-11-30 at 03 40 03" src="https://github.com/user-attachments/assets/1035f49f-98bd-4dbd-a2af-712c512699b1">

## Technologies
* SDL
* rubuild (my own game engine)
* [super_callbacks gem (also my own gem built mainly for this)](https://github.com/jrpolidario/super_callbacks)

## Development
* Depending on your environment, but on mac you'll simply just need to install:

```bash
brew install SDL2                   
brew install SDL2_image
brew install SDL2_ttf
```

* And then run:

```bash
cd some/path-to/isekai
bundle
```

* And to run the game:

```bash
./bin/rubuild
```
