[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPL License][license-shield]][license-url]

<br />
<p align="center">
  <h3 align="center">Lua Tiled Map Converter</h3>

  <p align="center">
    A modding tool that converts Lua tables back into <a href="https://www.mapeditor.org/">Tiled</a> readable JSON files.
    <br />
    <a href="https://github.com/Rydrako/LuaTiledMapConverter/issues">Report Bug</a>
    ·
    <a href="https://github.com/Rydrako/LuaTiledMapConverter/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
    <li>
      <a href="#set-up">Set Up</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

This is an open-source modding tool for lua based games that use Tiled maps.
Tiled is a popular, free, open-source Map Editor used in many games, while it supports exporting for lua it does not have native support for importing lua formats. This modding tool converts lua files back into Tiled readable json files while retaining custom properties and formats. It provides a framework that supports map formats of different games and is easily modifiable.

### Dependencies

* [Lua File System](https://keplerproject.github.io/luafilesystem/)
* [IUP](https://www.tecgraf.puc-rio.br/iup/)



<!-- GETTING STARTED -->
## Set Up

### Prerequisites

* [Lua](https://www.lua.org)

### Installation

1. Download Lua 5.1 or later [source](http://www.lua.org/ftp/) and build it for your system
    - Or use an easy installer for Windows that includes the required libraries mentioned above - https://github.com/rjpcomputing/luaforwindows
2. Clone this repository or [download](https://github.com/Rydrako/LuaTiledMapConverter/archive/refs/heads/main.zip) the source code and extract it.
3. From here you may either:
    - Build the code yourself
    - Run the program from the cmd line with the following command: ``` lua luaTiledMapConverter.lua ```
    - Or simply run the included LuaTiledMapConverter.bat file

<!-- USAGE EXAMPLES -->
## Usage

<a href="https://i.imgur.com/qipf0io.png">
    <img src="https://i.imgur.com/qipf0io.png" alt="UI Layout of the Program">
</a>

*Layout of the UI. You may drag & drop files into the text fields or use the Browse buttons to select files and directories.*

#### Input

The lua or json file you want to convert

#### Output

The output path, can either be a file name or a directory. Choosing a directory is recommended

#### Tileset Settings

The directory where the image files of the map are contained, by default LTMC will try to locate files under the output path
Margin and spacing parameters can also be set in this section.

#### Lua Settings

The path used for tilesets in lua format. Make sure to check the game's original lua files to see what path they're using.

#### Convert

Here you may select to export to lua or json format. If you export to json, the program will generate two files:
```
<map_name>.json
```
A file containing the map data: tiles, objects, and custom properties. It can be opened and editted with the Tiled Map Editor.
```
<map_name>_tilesets.json
```
And a file containing properties of the map's tilesets, this data is lost when parsed by Tiled and must be kept this separate file. DO NOT rename the tileset file, when converting back into lua, the program needs to read the corresponding tileset json file with the input file name.


<!-- LICENSE -->
## License

Distributed under the GPL-3.0 License. See `LICENSE` for more information.



<!-- CONTACT -->
## Contact

Rydrako - [@Rydrako_](https://twitter.com/Rydrako_) - rydrako.art@gmail.com

Project Link: [https://github.com/Rydrako/LuaTiledMapConverter](https://github.com/Rydrako/LuaTiledMapConverter)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/Rydrako/LuaTiledMapConverter.svg?style=for-the-badge
[contributors-url]: https://github.com/Rydrako/LuaTiledMapConverter/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/Rydrako/LuaTiledMapConverter.svg?style=for-the-badge
[forks-url]: https://github.com/Rydrako/LuaTiledMapConverter/network/members
[stars-shield]: https://img.shields.io/github/stars/Rydrako/LuaTiledMapConverter.svg?style=for-the-badge
[stars-url]: https://github.com/Rydrako/LuaTiledMapConverter/stargazers
[issues-shield]: https://img.shields.io/github/issues/Rydrako/LuaTiledMapConverter.svg?style=for-the-badge
[issues-url]: https://github.com/Rydrako/LuaTiledMapConverter/issues
[license-shield]: https://img.shields.io/github/license/Rydrako/LuaTiledMapConverter.svg?style=for-the-badge
[license-url]: https://github.com/Rydrako/LuaTiledMapConverter/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/Rydrako
