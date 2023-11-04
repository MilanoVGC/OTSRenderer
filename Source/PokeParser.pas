unit PokeParser;

interface

uses
  Classes, SysUtils,
  CsvParser,
  PokeUtils, AkUtils;

const
  POKEMON_SPRITE_URL = 'https://projectpokemon.org/images/sprites-models/sv-sprites-home/';
  DATA_ITEMS: array of string = ['Pokemon', 'Moves', 'Colors', 'Items'];

type
  TPokemon = class
  strict private
    FData: TCsvArchive;
    FName: string;
    FSpecies: string;
    FFirstTyping: TTyping;
    FSecondTyping: TTyping;
    FMoveList: string;
    FMoveset: array of TMove;
    FAbility: string;
    FItem: string;
    FNickname: string;
    FTeraTyping: TTyping;
    FLevel: Integer;
    FEvSpread: TEvSpread;
    FIvSpread: TIvSpread;
    procedure Init(const AData: TCsvArchive);
    function GetTyping: string;
    function GetMove(const AIndex: Integer): TMove;
    function GetMoveName(const AIndex: Integer): string;
    function GetMoveTyping(const AIndex: Integer): string;
    function GetTeraTyping: string;
    function GetText: string;
    function GetPokemonSpriteName: string;
    function GetItemSpriteName: string;
    function GetFirstTypingSpriteName: string;
    function GetSecondTypingSpriteName: string;
    function GetMoveTypingSpriteName(const AIndex: Integer): string;
    function GetTeraTypingSpriteName: string;
    function GetSpriteName(const ASpriteType: string): string;
    function GetQualifier(const AQualifier: string): string;
    function GetDisplayName: string;
    function GetStatIndex(const AStatName: string): Integer;
    function GetEv(const AStatName: string): Integer;
    function GetIv(const AStatName: string): Integer;
    function GetNatureFactor(const AStatName: string): Double;
    function GetStat(const AStatName: string): Integer;
    procedure SetTypes;
    procedure SetSpecies;
    procedure SetMoves;
  public
    property Name: string read FName;
    property Species: string read FSpecies;
    property Typing: string read GetTyping;
    property Move[const AIndex: Integer]: TMove read GetMove;
    property MoveName[const AIndex: Integer]: string read GetMoveName;
    property MoveTyping[const AIndex: Integer]: string read GetMoveTyping;
    property Ability: string read FAbility;
    property Item: string read FItem;
    property Nickname: string read FNickname;
    property TeraTyping: string read GetTeraTyping;
    property EvHp: Integer read FEvSpread.Hp;
    property EvAtk: Integer read FEvSpread.Atk;
    property EvDef: Integer read FEvSpread.Def;
    property EvSpA: Integer read FEvSpread.SpA;
    property EvSpD: Integer read FEvSpread.SpD;
    property EvSpe: Integer read FEvSpread.Spe;
    property Ev[const AStatName: string]: Integer read GetEv;
    property Nature: string read FEvSpread.Nature;
    property IvHp: Integer read FIvSpread.Hp;
    property IvAtk: Integer read FIvSpread.Atk;
    property IvDef: Integer read FIvSpread.Def;
    property IvSpA: Integer read FIvSpread.SpA;
    property IvSpD: Integer read FIvSpread.SpD;
    property IvSpe: Integer read FIvSpread.Spe;
    property Iv[const AStatName: string]: Integer read GetIv;
    property NatureFactor[const AStatName: string]: Double read GetNatureFactor;
    property PokemonSpriteName: string read GetPokemonSpriteName;
    property ItemSpriteName: string read GetItemSpriteName;
    property FirstTypingSpriteName: string read GetFirstTypingSpriteName;
    property SecondTypingSpriteName: string read GetSecondTypingSpriteName;
    property MoveTypingSpriteName[const AIndex: Integer]: string read GetMoveTypingSpriteName;
    property TeraTypingSpriteName: string read GetTeraTypingSpriteName;
    property SpriteName[const ASpriteType: string]: string read GetSpriteName;
    property Qualifier[const AQualifier: string]: string read GetQualifier;
    property Text: string read GetText;
    property DisplayName: string read GetDisplayName;
    property Stat[const AStatName: string]: Integer read GetStat;

    /// <summary>
    ///  Creates a pokemon from a pokepaste section of text, with the help of
    ///  the given data.
    /// </summary>
    constructor CreateFromText(const AText: string; const AData: TCsvArchive);
    procedure AfterConstruction; override;

    /// <summary>
    ///  Replaces every macro (in the form "%MacroName%") with the corrisponding
    ///  pokemon attribute obtained by the Qualifier property.
    ///  Calling this method on a text like "I love using %Item% on my teams!"
    ///  would replace %Item% with the result of the call Qualifier["Item"],
    ///  which will be the result of the call to the Item property.
    /// </summary>
    /// <remarks>
    ///  Qualifier property does not link all names to the respecting property
    ///  call: most of the not necessary ones (for this application purposes)
    ///  are yet to be implemented.
    /// </remarks>
    procedure ExpandMacros(var AText: string);
  end;

  TPokepaste = class
  strict private
    FData: TCsvArchive;
    FLink: string;
    FList: TStrings;
    FOwner: string;
    FAssetsPath: string;
    FPokemons: array of TPokemon;
    FPokemonCount: Integer;
    function GetOwnerClean: string;
    function GetPokemon(const AIndex: Integer): TPokemon;
    function GetPaste: string;
    function GetSprite(const ASpriteType: string; const AIndex: Integer): TFileName;
    function GetCustomPaste: string;
    function GetOutputName: string;
    class function GetDataItem(const AIndex: Integer): string; static;
    class function GetDataItemCount: Integer; static;

    procedure Init(const ADataFileNames: array of TFileName;
      const AAssetsPath: string);
    procedure CreatePokemons;
    procedure FreePokemons;
    procedure CheckData;
    procedure StartPokepaste;
  strict protected
    function RetrieveSprite(const ASpriteName, ASpriteType: string; const AForceReload: Boolean = False): TFileName; virtual;

    procedure CreateEmptyPng(const ABaseColorHex: string); virtual;
    function PaintPastePng(const AColorCSSName, AHeaderColorHex, AOutputPath: string): string; virtual;
  public
    property Link: string read FLink;
    property Owner: string read FOwner write FOwner;
    property OwnerClean: string read GetOwnerClean;
    property AssetsPath: string read FAssetsPath;
    property Pokemon[const AIndex: Integer]: TPokemon read GetPokemon;
    property Count: Integer read FPokemonCount;
    property Paste: string read GetPaste;
    property CustomPaste: string read GetCustomPaste;
    property Sprite[const ASpriteType: string; const AIndex: Integer]: TFileName read GetSprite;
    property OutputName: string read GetOutputName;
    class property DataItems[const AIndex: Integer]: string read GetDataItem;
    class property DataItemsCount: Integer read GetDataItemCount;

    /// <summary>
    ///  Create a Pokepaste entity directly by the "paste text", for an offline
    ///  mode. Other parameters are for data and resources.
    /// </summary>
    constructor Create(const AText: string; const ADataFileNames: array of TFileName;
      const AAssetsPath: string); overload;

    /// <summary>
    ///  Create a Pokepaste entity from the URL to pokepast.es, for the main
    ///  online mode. Other parameters are for data and resources.
    /// </summary>
    constructor Create(const AUrl: TUrl; const ADataFileNames: array of TFileName;
      const AAssetsPath: string); overload;

    procedure LoadPokepaste(const AText: string; const ADataFileNames: array of TFileName;
      const AAssetsPath: string); overload;

    procedure LoadPokepaste(const AUrl: TUrl; const ADataFileNames: array of TFileName;
      const AAssetsPath: string); overload;

    /// <summary>
    ///  Forces the pokepaste to reload from the text. If something has been
    ///  changed in the paste text (maybe granting the permission to write on
    ///  Paste/Link, eventually reloading the text from the link), it reloads
    ///  all from that.
    /// </summary>
    procedure ReloadPokemons;

    /// <summary>
    ///  Recreates teratypes background SVGs for all types from the template
    ///  file "teratype.svg".
    /// </summary>
    procedure PrintTeraTypings;

    /// <summary>
    ///  Ideally generates all PNGs or SVGs obtainable by template SVG files,
    ///  but now it's just a call to PrintTeraTypings, since the png for the
    ///  types are already given.
    /// </summary>
    procedure PrintSVGs;

    /// <summary>
    ///  Prints the HTML page containing the rendering of the pokepaste as OTS.
    ///  Returns the printed output's full name.
    /// </summary>
    function PrintHtml(const AColorCSSName: string; const AOutputPath: string = ''): string;

    /// <summary>
    ///  Prints the PNG image containing the rendering of the pokepaste as OTS.
    ///  Implementation depends on the children class used
    ///  Returns the printed output's full name.
    /// </summary>
    function PrintPng(const AColorCSSName: string; const AOutputPath: string = ''): string;

    destructor Destroy; override;
  end;

implementation

uses
  Math, StrUtils, Json, IOUtils, Types, UITypes,
  IdHttp, IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL;

{ TPokepaste }

procedure TPokepaste.CheckData;
var
  I: Integer;
begin
  for I := 0 to DataItemsCount - 1 do
    Assert(Assigned(FData[DataItems[I]]), Format('%s data missing.', [DataItems[I]]));

  Assert(Assigned(FList) and (FList.Text <> ''), 'Pokepaste missing/empty.');
end;

constructor TPokepaste.Create(const AUrl: TUrl; const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
begin
  LoadPokepaste(AUrl, ADataFileNames, AAssetsPath);
end;

constructor TPokepaste.Create(const AText: string; const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
begin
  LoadPokepaste(AText, ADataFileNames, AAssetsPath);
end;

procedure TPokepaste.CreateEmptyPng(const ABaseColorHex: string);
begin

end;

procedure TPokepaste.CreatePokemons;
var
  LPokemonText: TStringList;
  LPokemonIndex: Integer;
  I: Integer;
begin
  LPokemonIndex := -1;
  LPokemonText := TStringList.Create;
  try
    for I := 0 to FList.Count - 1 do
    begin
      if FList[I] = '' then
      begin
        Inc(LPokemonIndex);
        SetLength(FPokemons, Length(FPokemons) + 1);
        FPokemons[LPokemonIndex] := TPokemon.CreateFromText(LPokemonText.Text, FData);
        LPokemonText.Text := '';
      end
      else
        LPokemonText.Add(FList[I]);
    end;
    if LPokemonText.Text <> '' then
    begin
      Inc(LPokemonIndex);
      SetLength(FPokemons, Length(FPokemons) + 1);
      FPokemons[LPokemonIndex] := TPokemon.CreateFromText(LPokemonText.Text, FData);
      LPokemonText.Text := '';
    end;

  finally
    LPokemonText.Free;
  end;
  FPokemonCount := Length(FPokemons);
end;

destructor TPokepaste.Destroy;
begin
  if Assigned(FList) then
    FList.Free;
  if Assigned(FData) then
    FData.Free;
  inherited;
end;

procedure TPokepaste.FreePokemons;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    FreeAndNil(FPokemons[I]);
  SetLength(FPokemons, 0);
  FPokemonCount := 0;
end;

function TPokepaste.GetCustomPaste: string;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Result := Result + sLineBreak + Pokemon[I].Text;
end;

class function TPokepaste.GetDataItem(const AIndex: Integer): string;
begin
  Result := DATA_ITEMS[AIndex];
end;

class function TPokepaste.GetDataItemCount: Integer;
begin
  Result := Length(DATA_ITEMS);
end;

function TPokepaste.GetOutputName: string;
begin
  Result := OwnerClean + '_' + FormatDateTime('yyyymmdd', Now);
end;

function TPokepaste.GetOwnerClean: string;
begin
  Result := AnsiLowerCase(StringReplace(Owner, ' ', '_', [rfReplaceAll, rfIgnoreCase]));
end;

function TPokepaste.GetPaste: string;
begin
  Result := FList.Text;
end;

function TPokepaste.GetPokemon(const AIndex: Integer): TPokemon;
begin
  Assert(Length(FPokemons) > AIndex);

  Result := FPokemons[AIndex];
end;

function TPokepaste.GetSprite(const ASpriteType: string;
  const AIndex: Integer): TFileName;
var
  LSpriteFolderName: string;
begin
  LSpriteFolderName := ASpriteType;
  if Pos('TYPING', AnsiUpperCase(ASpriteType)) > 0 then
    LSpriteFolderName := 'Types';
  Result := RetrieveSprite(Pokemon[AIndex].SpriteName[ASpriteType], LSpriteFolderName);
end;

procedure TPokepaste.Init(const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
begin
  FData := TCsvArchive.Create;
  FData.Add(ADataFileNames);
  FList := TStringList.Create;
  FAssetsPath := AAssetsPath;
  FPokemonCount := 0;
  if not DirectoryExists(FAssetsPath) then
    raise Exception.CreateFmt('Assets directory "%s" not found.', [AAssetsPath]);
end;

procedure TPokepaste.LoadPokepaste(const AUrl: TUrl;
  const ADataFileNames: array of TFileName; const AAssetsPath: string);
var
  LIdHttp: TIdHttp;
  LJsonResponse: string;
  LJson: TJsonValue;
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  if Assigned(FList) then
    FreeAndNil(FList);

  Init(ADataFileNames, AAssetsPath);

  FLink := Trim(AUrl);
  if not SameText(FLink.Substring(Length(FLink) - 4), 'json') then
    FLink := FLink + '/json';

  LIdHttp := TIdHttp.Create(nil);
  try
    LJsonResponse := LIdHttp.Get(FLink);
  finally
    LIdHttp.Free;
  end;
  LJson := TJsonObject.ParseJSONValue(LJsonResponse);
  FList.Text := LJson.GetValue<string>('paste');

  StartPokepaste;
end;

procedure TPokepaste.LoadPokepaste(const AText: string;
  const ADataFileNames: array of TFileName; const AAssetsPath: string);
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  if Assigned(FList) then
    FreeAndNil(FList);

  Init(ADataFileNames, AAssetsPath);
  FList.Text := AText;

  StartPokepaste;
end;

procedure TPokepaste.StartPokepaste;
begin
  FreePokemons;
  CheckData;
  CreatePokemons;
end;

function TPokepaste.PaintPastePng(const AColorCSSName, AHeaderColorHex, AOutputPath: string): string;
begin

end;

function TPokepaste.PrintHtml(const AColorCSSName, AOutputPath: string): string;
var
  LOutputPath: string;
  LHtml: string;
  LSplit: string;
  I: Integer;
  LTyping: TTyping;
  LSvgName: string;

begin
  LOutputPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AOutputPath) + 'HTML');
  if not MakeDir(LOutputPath) then
    raise Exception.CreateFmt('Could not create directory "%s", try creating it manually.', [LOutputPath]);

  LHtml := TFile.ReadAllText(IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'header.html');
  ExpandPathMacros(LHtml, [IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'main.css'], '%');
  ExpandPathMacros(LHtml, [IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'animations.css'], '%');
  ExpandValue(LHtml, 'colors.css', ExpandFileName(IncludeTrailingPathDelimiter(FAssetsPath + '..') + AColorCSSName + '_palette.css'));
  ExpandValue(LHtml, 'Owner', Owner);

  for I := 0 to Count - 1 do
  begin
    LSplit := TFile.ReadAllText(IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'template.html');
    LSplit := StringReplace(LSplit, '%n%', IntToStr(I + 1), [rfReplaceAll, rfIgnoreCase]);
    Pokemon[I].ExpandMacros(LSplit);
    LHtml := LHtml + sLineBreak + LSplit;
  end;

  LHtml := LHtml + sLineBreak + TFile.ReadAllText(IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'footer.html');
  ExpandPathMacros(LHtml, [
    FAssetsPath + 'Types',
    FAssetsPath + 'Pokemon',
    FAssetsPath + 'Items'
  ]);

  for LTyping := Low(TTyping) to High(TTyping) do
    if LTyping <> tNone then
    begin
      LSvgName := 'teratype_' + TypingToStr(LTyping) + '.svg';
      ExpandFileMacros(LHtml, [RetrieveSprite(LSvgName, 'Types')], '@svg@');
      ExpandFileMacros(LHtml, [RetrieveSprite(TypingToStr(LTyping) + '.svg', 'Types')], '@svg@');
    end;
  Result := LOutputPath + OutputName + '.html';
  TFile.WriteAllText(Result, LHtml);
end;

function TPokepaste.PrintPng(const AColorCSSName,
  AOutputPath: string): string;
var
  LOutputPath: string;
  LColorCss: TStringList;
  LHeaderColor: string;
  LBaseColor: string;
begin
  LOutputPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(AOutputPath) + 'PNG');
  if not MakeDir(LOutputPath) then
    raise Exception.CreateFmt('Could not create directory "%s", try creating it manually.', [LOutputPath]);

  LColorCSS := TStringList.Create;
  try
    LColorCSS.LoadFromFile(IncludeTrailingPathDelimiter(FAssetsPath + '..') + AColorCSSName + '_palette.css');
    LHeaderColor := Trim(RemoveStrings(LColorCSS[LColorCSS.Contains('--headerColor')], ['--headerColor:', ';']));
    LBaseColor := Trim(RemoveStrings(LColorCSS[LColorCSS.Contains('--baseColor')], ['--baseColor:', ';']));
  finally
    LColorCSS.Free;
  end;

  CreateEmptyPng(LBaseColor);

  Result := PaintPastePng(AColorCSSName, LHeaderColor, LOutputPath);

  if FileExists(IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'empty_pokepaste.png') then
    DeleteFile(IncludeTrailingPathDelimiter(FAssetsPath + '..') + 'empty_pokepaste.png');
end;

procedure TPokepaste.PrintSVGs;
begin
  PrintTeraTypings;
end;

procedure TPokepaste.PrintTeraTypings;
var
  LSvg: TStringList;
  LTyping: TTyping;
  LTypingStr: string;
begin
  LSvg := TStringList.Create;
  try
    for LTyping := Low(TTyping) to High(TTyping) do
    begin
      if LTyping = tNone then
        Continue;
      LTypingStr := TypingToStr(LTyping);
      LSvg.LoadFromFile(FAssetsPath + 'teratype.svg');
      LSvg[0] := '<svg class="svg-teratype" xmlns="http://www.w3.org/2000/svg" width="813" height="958.3" viewBox="0 0 812.864 958.0729" fill="url(#gradient-' + AnsiLowerCase(LTypingStr) + ')">';
      LSvg[1] := '  <linearGradient id="gradient-' + AnsiLowerCase(LTypingStr) + '" gradientTransform="rotate(90)">';
      LSvg[2] := '    <stop class="first" offset="0%" style="stop-color: #' + FData['Colors'].FindByValue(LTypingStr, 1) + '" ></stop>';
      LSvg[3] := '    <stop class="second" offset="100%" style="stop-color: #' + FData['Colors'].FindByValue(LTypingStr, 2) + '" ></stop>';
      LSvg.SaveToFile(IncludeTrailingPathDelimiter(FAssetsPath + 'Types') + 'teratype_' + AnsiLowerCase(LTypingStr) + '.svg');
      LSvg.Clear;
    end;
  finally
    LSvg.Free;
  end;
end;

procedure TPokepaste.ReloadPokemons;
begin
  StartPokepaste;
end;

function TPokepaste.RetrieveSprite(const ASpriteName, ASpriteType: string;
  const AForceReload: Boolean): TFileName;
begin
  if ASpriteName = '' then
  begin
    Result := '';
    Exit;
  end;

  Result := IncludeTrailingPathDelimiter(FAssetsPath + ASpriteType) + ASpriteName;

  if FileExists(Result) and not AForceReload then
    Exit;

  // Handle SVG sprites
  if SameText(ExtractFileExt(Result), '.svg') then
  begin
    PrintSVGs;
    Exit;
  end;
end;

{ TPokemon }

procedure TPokemon.AfterConstruction;
begin
  inherited;
  SetSpecies;
  SetTypes;
  SetMoves;
end;

constructor TPokemon.CreateFromText(const AText: string; const AData: TCsvArchive);
var
  LList: TStringList;
  LNameRowClean: string;
  LIsNicknamed: Boolean;
  LSkipLevel: Integer;
  LSkipShiny: Integer;
  LSkipEvs: Integer;
  LSkipNature: Integer;
  LSkipIvs: Integer;

  function I(const AAttribute: string): Integer;
  begin
    if SameText(AAttribute, 'Nickname') then
      if LIsNicknamed then
        Result := 0
      else
        Result := -1
    else if MatchText(AAttribute, ['Name', 'Item']) then
      Result := 0
    else if SameText(AAttribute, 'Ability') then
      Result := 1
    else if SameText(AAttribute, 'Level') then
      if LSkipLevel = 0 then
        Result := -1
      else
        Result := 2
    else if SameText(AAttribute, 'Tera type') then
      Result := 2 + LSkipLevel + LSkipShiny
    else if SameText(AAttribute, 'Evs') then
      if LSkipEvs = 0 then
        Result := -1
      else
        Result := 3 + LSkipLevel + LSkipShiny
    else if SameText(AAttribute, 'Nature') then
      if LSkipNature = 0 then
        Result := -1
      else
        Result := 3 + LSkipLevel + LSkipShiny + LSkipEvs
    else if SameText(AAttribute, 'Ivs') then
      if LSkipIvs = 0 then
        Result := -1
      else
        Result := 3 + LSkipLevel + LSkipShiny + LSkipEvs + LSkipNature
    else if SameText(AAttribute, 'Moves') then
      Result := 3 + LSkipLevel + LSkipShiny + LSkipEvs + LSkipNature + LSkipIvs
    else
      raise Exception.CreateFmt('Attribute "%s" not recognized.', [AAttribute])
  end;

  function SplitNameRow(const AAttribute, ARow: string): string;
  var
    LStart: Integer;
    LCount: Integer;
  begin
    LStart := 0;
    LCount := Length(ARow);
    if SameText(AAttribute, 'Nickname') then
      LCount := Pos('(', ARow) - 1
    else if SameText(AAttribute, 'Name') then
      if LIsNicknamed then
      begin
        LStart := Pos('(', ARow);
        LCount := Pos(')', ARow) - Pos('(', ARow) - 1;
      end
      else
        if Pos('(', ARow) > 0 then
          LCount := Pos('(', ARow) - 1
        else
          LCount := Pos('@', ARow) - 1
    else if SameText(AAttribute, 'Item') then
      LStart := Pos('@', ARow)
    else
      raise Exception.CreateFmt('Unknown attribute "%s"', [AAttribute]);

    Result := Trim(ARow.Substring(LStart, LCount));
  end;

  function §(const AAttribute: string): string;
  var
    J: Integer;
  begin
    if I(AAttribute) = -1 then
      Exit;

    if MatchText(AAttribute, ['Nickname', 'Name', 'Item']) then
      Result := SplitNameRow(AAttribute, LList[I(AAttribute)])
    else if SameText(AAttribute, 'Moves') then
    begin
      Result := Trim(StringReplace(LList[I(AAttribute)], '-', '', []));
      for J := I(AAttribute) + 1 to LList.Count - 1 do
        Result := Result + sLineBreak + Trim(StringReplace(LList[J], '-', '', []));
    end
    else
      Result := Trim(StringReplace(
        StringReplace(LList[I(AAttribute)], AAttribute, '', [rfIgnoreCase, rfReplaceAll])
        , ':', '', []));

    if SameText(AAttribute, 'Evs') then
      Result := Result + sLineBreak + §('Nature');
  end;
begin
  Init(AData);
  LList := TStringList.Create;
  try
    LList.Text := AText;
    LNameRowClean := StringReplace(StringReplace(LList[0], '(M) @', ' @', [rfIgnoreCase]), '(F) @', ' @', [rfIgnoreCase]);
    if Pos('(', LNameRowClean) > 0 then
      LIsNicknamed := True;
    if Pos('LEVEL', AnsiUpperCase(LList[2])) > 0 then
      LSkipLevel := 1
    else
      LSkipLevel := 0;
    if Pos('SHINY', AnsiUpperCase(LList[2 + LSkipLevel])) > 0 then
      LSkipShiny := 1
    else
      LSkipShiny := 0;
    if Pos('EVS', AnsiUpperCase(LList[3 + LSkipLevel + LSkipShiny])) > 0 then
      LSkipEvs := 1
    else
      LSkipEvs := 0;
    if Pos('NATURE', AnsiUpperCase(LList[3 + LSkipLevel + LSkipShiny + LSkipEvs])) > 0 then
      LSkipNature := 1
    else
      LSkipNature := 0;
    if Pos('IVS', AnsiUpperCase(LList[3 + LSkipLevel + LSkipShiny + LSkipEvs + LSkipNature])) > 0 then
      LSkipIvs := 1
    else
      LSkipIvs := 0;


    FNickName := §('Nickname');
    FName := §('Name');
    FItem := §('Item');
    FAbility := §('Ability');
    FTeraTyping := StrToTyping(§('Tera type'));
    FLevel := StrToInt(IfThen(§('Level') = '', '100', §('Level')));
    FMoveList := §('Moves');
    FEvSpread := TranslateEvs(§('Evs'));
    FIvSpread := TranslateIvs(§('Ivs'));
  finally
    LList.Free;
  end;
end;

procedure TPokemon.ExpandMacros(var AText: string);
var
  LTextList: TStringList;
  I: Integer;

  function ExtractMacro(const ALine: string; const ADelimiter: string): string;
  begin
    Result := ALine.Substring(Pos(ADelimiter, ALine),
      Pos(ADelimiter, ALine, Pos(ADelimiter, ALine) + 1) - Pos(ADelimiter, ALine) - 1);
  end;
  function ContainsMacro(const ALine: string; const ADelimiter: string = '%'): Boolean;
  var
    LPos: Integer;
  begin
    LPos := Pos(ADelimiter, ALine);
    Result := LPos > 0;
    if Result then
      Result := Pos(ADelimiter, ALine, LPos + 1) > 0;
    if Result then
    begin
      try
        // if there is a non-macro included in two delimiters, it will not have
        // a corresponding qualifier: in that case we catch the error and we
        // remove temporarily the false macro and perform the check again.
        Qualifier[ExtractMacro(ALine, ADelimiter)];
      except
        Result := ContainsMacro(
          StringReplace(ALine, ADelimiter + ExtractMacro(ALine, ADelimiter) + ADelimiter, '', [rfReplaceAll, rfIgnoreCase]),
          ADelimiter);
      end;
    end;
  end;
  function ReplaceMacro(const ALine: string; const ADelimiter: string = '%'): string;
  var
    LMacroName: string;
  begin
    LMacroName := StringReplace(ExtractMacro(ALine, ADelimiter), ADelimiter, '', [rfReplaceAll]);
    Result := StringReplace(ALine, ADelimiter + LMacroName + ADelimiter, Qualifier[LMacroName], [rfReplaceAll, rfIgnoreCase]);
  end;
begin
  LTextList := TStringList.Create;
  try
    LTextList.Text := AText;
    for I := 0 to LTextList.Count - 1 do
      while ContainsMacro(LTextList[I]) do
        LTextList[I] := ReplaceMacro(LTextList[I]);

    AText := LTextList.Text;
  finally
    LTextList.Free;
  end;
end;

function TPokemon.GetDisplayName: string;
begin
  Result := FData['Pokemon'].FindByValue(Name, 4);
  if Result = '' then
    Result := Name;
end;

function TPokemon.GetEv(const AStatName: string): Integer;
begin
  Result := 0;
  case GetStatIndex(AStatName) of
    0: Result := IvHp;
    1: Result := IvAtk;
    2: Result := IvDef;
    3: Result := IvSpA;
    4: Result := IvSpD;
    5: Result := IvSpe;
  end;
end;

function TPokemon.GetFirstTypingSpriteName: string;
begin
  Result := '';
  if (FSecondTyping <> tNone) and (FFirstTyping <> FSecondTyping) then
    Result := TypingToStr(FFirstTyping) + '.png';
end;

function TPokemon.GetItemSpriteName: string;
begin
  Result := 'item_' + FData['Items'].FindByValue(Item, 0, 1) + '.png';
end;

function TPokemon.GetIv(const AStatName: string): Integer;
begin
  Result := 31;
  case GetStatIndex(AStatName) of
    0: Result := IvHp;
    1: Result := IvAtk;
    2: Result := IvDef;
    3: Result := IvSpA;
    4: Result := IvSpD;
    5: Result := IvSpe;
  end;
end;

function TPokemon.GetMove(const AIndex: Integer): TMove;
begin
  Assert(Length(FMoveset) > AIndex);

  Result := FMoveset[AIndex];
end;

function TPokemon.GetMoveName(const AIndex: Integer): string;
begin
  Result := '';
  if AIndex < Length(FMoveset) then
    Result := Move[AIndex].Name;
end;

function TPokemon.GetMoveTyping(const AIndex: Integer): string;
begin
  Result := TypingToStr(Move[AIndex].Typing);
end;

function TPokemon.GetMoveTypingSpriteName(const AIndex: Integer): string;
begin
  Result := '';
  if AIndex < Length(FMoveset) then
    Result := MoveTyping[AIndex] + '.png';
end;

function TPokemon.GetNatureFactor(const AStatName: string): Double;
begin
  Result := 1.0;
  case GetStatIndex(AStatName) of
    0: Exit;
    1:
    begin
      if MatchText(Nature, ['Adamant', 'Brave', 'Lonely', 'Naughty']) then
        Result := 1.1
      else if MatchText(Nature, ['Bold', 'Calm', 'Modest', 'Timid']) then
        Result := 0.9;
    end;
    2:
    begin
      if MatchText(Nature, ['Bold', 'Impish', 'Lax', 'Relaxed']) then
        Result := 1.1
      else if MatchText(Nature, ['Gentle', 'Hasty', 'Lonely', 'Mild']) then
        Result := 0.9;
    end;
    3:
    begin
      if MatchText(Nature, ['Mild', 'Modest', 'Quiet', 'Rash']) then
        Result := 1.1
      else if MatchText(Nature, ['Adamant', 'Careful', 'Impish', 'Jolly']) then
        Result := 0.9;
    end;
    4:
    begin
      if MatchText(Nature, ['Calm', 'Careful', 'Gentle', 'Sassy']) then
        Result := 1.1
      else if MatchText(Nature, ['Lax', 'Naive', 'Naughty', 'Rash']) then
        Result := 0.9;
    end;
    5:
    begin
      if MatchText(Nature, ['Hasty', 'Jolly', 'Naive', 'Timid']) then
        Result := 1.1
      else if MatchText(Nature, ['Brave', 'Quiet', 'Relaxed', 'Sassy']) then
        Result := 0.9;
    end;
  end;
end;

function TPokemon.GetPokemonSpriteName: string;
begin
  Result := Species + '.png';
end;

function TPokemon.GetQualifier(const AQualifier: string): string;
begin
  if MatchText(AQualifier, ['Pokemon', 'Name', 'DisplayName']) then
    Result := DisplayName
  else if Pos('SPRITENAME', AnsiUpperCase(AQualifier)) > 0 then
  begin
    Result := SpriteName[StringReplace(AQualifier, 'SpriteName', '', [rfReplaceAll, rfIgnoreCase])];
    if Result = '' then
      Result := 'empty.png';
  end
  else if SameText(AQualifier, 'Nickname') then
    Result := Nickname
  else if SameText(AQualifier, 'Item') then
    Result := Item
  else if SameText(AQualifier, 'FirstTyping') then
    Result := StringReplace(FirstTypingSpriteName, ExtractFileExt(FirstTypingSpriteName), '', [rfReplaceAll, rfIgnoreCase])
  else if SameText(AQualifier, 'SecondTyping') then
    Result := StringReplace(SecondTypingSpriteName, ExtractFileExt(SecondTypingSpriteName), '', [rfReplaceAll, rfIgnoreCase])
  else if SameText(AQualifier, 'TeraTyping') then
    Result := TeraTyping
  else if SameText(AQualifier, 'Ability') then
    Result := Ability
  else if Pos('MOVETYPING', AnsiUpperCase(AQualifier)) > 0 then
    Result := MoveTypingSpriteName[StrToInt(StringReplace(AQualifier, 'MoveTyping', '', [rfReplaceAll, rfIgnoreCase])) - 1]
  else if Pos('MOVE', AnsiUpperCase(AQualifier)) > 0 then
    Result := MoveName[StrToInt(StringReplace(AQualifier, 'Move', '', [rfReplaceAll, rfIgnoreCase])) - 1]
  else
    raise Exception.CreateFmt('Unknown qualifier type "%s".', [AQualifier]);
end;

function TPokemon.GetSecondTypingSpriteName: string;
begin
  Result := TypingToStr(FFirstTyping);
  if (FSecondTyping <> tNone) and (FFirstTyping <> FSecondTyping) then
    Result := TypingToStr(FSecondTyping);
  Result := Result + '.png';
end;

function TPokemon.GetSpriteName(const ASpriteType: string): string;
begin
  if SameText(ASpriteType, 'Pokemon') then
    Result := PokemonSpriteName
  else if SameText(ASpriteType, 'Items') then
    Result := ItemSpriteName
  else if SameText(ASpriteType, 'TeraTyping') then
    Result := TeraTypingSpriteName
  else if SameText(ASpriteType, 'FirstTyping') then
    Result := FirstTypingSpriteName
  else if SameText(ASpriteType, 'SecondTyping') then
    Result := SecondTypingSpriteName
  else
    raise Exception.CreateFmt('Unknown sprite type "%s".', [ASpriteType]);
end;

function TPokemon.GetStat(const AStatName: string): Integer;
var
  LStatIndex: Integer;
  LBaseStat: Integer;
begin
  LStatIndex := GetStatIndex(AStatName);
  LBaseStat := StrToInt(FData['Pokemon'].FindByValue(Name, LStatIndex + 5));
  Result := (Floor(0.01 * (2 * LBaseStat + Iv[AStatName] + Floor(0.25 * Ev[AStatName])) * FLevel) + 5);
  if LStatIndex = 0 then
    Result := Result + 5 + FLevel
  else
    Result := Floor(Result * NatureFactor[AStatName]);
end;

function TPokemon.GetStatIndex(const AStatName: string): Integer;
begin
  if MatchText(AStatName, ['Hp', 'Health points', 'HealthPoints', 'Health']) then
    Result := 0
  else if MatchText(AStatName, ['Atk', 'Attack']) then
    Result := 1
  else if MatchText(AStatName, ['Def', 'Defense']) then
    Result := 2
  else if MatchText(AStatName, ['SpA', 'Special Attack', 'SpecialAttack']) then
    Result := 3
  else if MatchText(AStatName, ['SpD', 'Special Defense', 'SpecialDefense']) then
    Result := 4
  else if MatchText(AStatName, ['Spe', 'Speed']) then
    Result := 5
  else
    raise Exception.CreateFmt('Unknown stat name "%s".', [AStatName]);
end;

function TPokemon.GetTeraTyping: string;
begin
  Result := TypingToStr(FTeraTyping);
end;

function TPokemon.GetTeraTypingSpriteName: string;
begin
  Result := 'teratype_' + AnsiLowerCase(TypingToStr(FTeraTyping)) + '.svg';
end;

function TPokemon.GetText: string;
var
  LList: TStringList;
  I: Integer;
begin
  LList := TStringList.Create;
  try
    if Nickname = '' then
      LList.Add(Name + ' @ ' + Item)
    else
      LList.Add(Nickname + ' (' + Name + ') @ ' + Item);
    LList.Add('Ability: ' + Ability);
    LList.Add('Tera type: ' + TeraTyping);
    LList.Add('EVs: ' + IntToStr(EvHp) + ' HP / ' + IntToStr(EvAtk) + ' Atk / ' + IntToStr(EvDef) + ' Def / ' +
      IntToStr(EvSpA) + ' SpA / ' + IntToStr(EvSpD) + ' SpD / ' + IntToStr(EvSpe) + ' Spe');
    LList.Add(Nature + ' Nature');
    LList.Add('IVs: ' + IntToStr(IvHp) + ' HP / ' + IntToStr(IvAtk) + ' Atk / ' + IntToStr(IvDef) + ' Def / ' +
      IntToStr(IvSpA) + ' SpA / ' + IntToStr(IvSpD) + ' SpD / ' + IntToStr(IvSpe) + ' Spe');
    for I := 0 to Length(FMoveset) - 1 do
      LList.Add('- ' + Move[I].Name);
    LList.Add('');
    Result := LList.Text;
  finally
    LList.Free;
  end;
end;

function TPokemon.GetTyping: string;
begin
  Result := TypingToStr(FFirstTyping) +
    IfThen((FSecondTyping <> tNone) and (FSecondTyping <> FFirstTyping), '/' + TypingToStr(FSecondTyping));
end;

procedure TPokemon.Init(const AData: TCsvArchive);
begin
  FData := AData;
end;

procedure TPokemon.SetMoves;
var
  LMoveList: TStringList;
  I: Integer;
begin
  LMoveList := TStringList.Create;
  try
    LMoveList.Text := FMoveList;
    SetLength(FMoveset, LMoveList.Count);
    for I := 0 to LMoveList.Count - 1 do
      FMoveset[I] := GetMoveInfo(Trim(LMoveList[I]), FData['Moves']);
  finally
    LMoveList.Free;
  end;
end;

procedure TPokemon.SetSpecies;
begin
  FSpecies := StringReplace(FData['Pokemon'].FindByValue(Name, 1), '_00', '', [rfReplaceAll, rfIgnoreCase]);
end;

procedure TPokemon.SetTypes;
begin
  FFirstTyping := StrToTyping(Trim(FData['Pokemon'].FindByValue(Name, 2)));
  FSecondTyping := StrToTyping(Trim(FData['Pokemon'].FindByValue(Name, 3)));
end;

end.
