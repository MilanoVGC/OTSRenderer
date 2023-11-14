# OTSRenderer

OTSRenderer is a program targeted at creating Pokémon teamsheets for Pokémon Scarlet and Violet with just a [pokepast.es](http://pokepast.es).

![image](https://i.imgur.com/3JUKNtL.png)

### Features:
- CSV or manual input
- Outputs both HTML (with animations) or PNG
- Has all SV Pokémons and Items
- 5 different palette to choose from

### About the code:
OTSRenderer is written in Delphi, a low level programming language based on Object Pascal (more info [here](https://www.embarcadero.com/products/delphi)), and takes advantage of the Visual Component Library (VCL) both for the GUI and for the image rendering. For this reason the application currently targets only Windows systems.

The code is designed in a modular way: the core units are PokeParser.pas and PokepasteProcessor.pas, the former implements all the logic structures (TPokemon and TPokepaste) and the latter is the middleware which links inputs and rendering calls.
While the HTML rendering does not need VCL use and it's therefore implemented directly on PokeParser.pas, the other renderings are written in the unit PokeParserVcl.pas (which extends PokeParser.pas) to keep easy replacing and/or refactoring the graphic units (as AkUtilsVcl.pas).

### TO-DO
- Add PDF output for tournament OTS (with dual-language)
- Add PDF output for tournament CTS (the teamsheet for tournament staff)
- Add support for macOS and Linux

### Contacts
- [shairaba](https://twitter.com/shairaba) - Project leader
- [relderVGC](https://twitter.com/reldervgc) - Developer (DMs are open!)