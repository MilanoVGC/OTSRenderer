# Code details for OTSRenderer
In this file we go through a detailed description of the code units of the application (excluding everything under AkLib since there are only multi-purpose utility units), a more specific documentation is also available directly on the source code for many complex features.

### PokeUtils.pas
This unit defines some useful structures to use across all the application, together with some functions to translate and manipulate them into/from native types.

### PokeParser.pas
This unit defines the two main structures of the application: TPokemon and TPokepaste.
- TPokemon extract from a paste text all the features of the Pokémon (assuming defaults when needed, like 31 Ivs for the ones not specified) and integrates them with the data read off the resource files: it provides all the properties of the Pokémon, translated when needed, as well as a method to insert them in a given text replacing any macro defined like %PropertyName%.
- TPokepaste works like a "TPokemon manager", creating all the needed instances of TPokemon from a pokepaste url (or a pokepaste text) and storing on top of them the player informations; it provides the methods to render the pokepaste in the needed output. When a rendering needs the graphic units (the VCL), such as PNG or PDF rendering, the class calls some virtual methods.

### PokeParserVcl.pas
This unit defines the TPokepasteVcl class, which inherits all of TPokepaste properties and implements on top of those the afromentioned virtual methods using the VCL: to have the capability to produce the VCL-rendering, a instance of TPokepasteVcl must be created instead of a TPokepaste one.

### PokepasteProcessor.pas
This unit defines the TPokepasteProcessor class, which is the one that links inputs (both manual inputs and files) to the rendering process, adding logging and translation features. Since it works on the general TPokepaste class instead of one of it's derived children, its rendering calls depends of the single instance that it has been given to it: ideally all of the rendering should pass through this class rather than being directly called on the pokepaste ones, to avoid worrying with the type casts.

### TeamlistTemplateFrame.pas
This unit is a "hack" to create a common ancestor for the PDF class templates while keeping the possibility for the developer to design those templates using the Delphi IDE (this is achieved by calling this class TFrame), to give them some utility methods and a virtual method to paint the canvas in their own way.

### MonolingualTeamlist.pas and MonolingualTeamlist.dfm
The template frame for mono-lingual PDF teamlists (both open and closed): as a class it simply implements the PaintCanvas method.

### BilingualTeamlist.pas and BilingualTeamlist.dfm
The template frame for bi-lingual PDF teamlists (always open): as a class it simply implements the PaintCanvas method.

### MainFormUnit.pas MainFormUnit.dfm
The unit that implements the GUI.

### Application flow
This application flow can be summarized as follows:
1. Load environment settings (color palette and languages), create and open the logger, create an empty instance of the pokepaste class that matches the environment (for now is only PokepasteVcl, but could be PokepasteFmx for other platforms)
2. Collect user-defined settings (like resource path, manual inputs, file input, ...)
3. (When the user runs the renderings) Create a PokepasteProcessor instance with the Pokepaste instance and all settings, customize that instance as preferred (setting OTSLanguage and/or StopOnErrors properties)
3.1 (OPTIONAL) Add desired logics to the PokepasteProcessor before and after the renderings using the OnRender and AfterRender properties (such as confirmation dialogs for overwriting already existing files)
4. Invoke the rendering methods on PokepasteProcessor


If you have any issue, suggestion, request, curiosity regarding OTSRenderer, feel free to [DM me](https://twitter.com/reldervgc), every feedback is appreciated!