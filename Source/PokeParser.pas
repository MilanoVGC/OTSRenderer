unit PokeParser;

interface

uses
  Classes, SysUtils,
  Graphics, Imaging.PngImage,
  CsvParser,
  PokeUtils;

const
  POKEMON_SPRITE_URL = 'https://projectpokemon.org/images/sprites-models/sv-sprites-home/';
  DATA_ITEMS: array of string = ['Pokemon', 'Moves', 'Colors', 'Items'];

type
  TUrl = type string;

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
    FEvSpread: TEvSpread;
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
    property Hp: Integer read FEvSpread.Hp;
    property Atk: Integer read FEvSpread.Atk;
    property Def: Integer read FEvSpread.Def;
    property SpA: Integer read FEvSpread.SpA;
    property SpD: Integer read FEvSpread.SpD;
    property Spe: Integer read FEvSpread.Spe;
    property Nature: string read FEvSpread.Nature;
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
    FPokemons: array of TPokemon;
    FPokemonCount: Integer;
    FAssetsPath: string;
    function GetOwnerClean: string;
    function GetPokemon(const AIndex: Integer): TPokemon;
    function GetPaste: string;
    function GetSprite(const ASpriteType: string; const AIndex: Integer): TFileName;
    function GetCustomPaste: string;

    procedure Init(const ADataFileNames: array of TFileName;
      const AAssetsPath: string);
    procedure CreatePokemons;
    function RetrieveSprite(const ASpriteName, ASpriteType: string; const AForceReload: Boolean = False): TFileName;
    procedure CheckData;
    procedure PrintPlayerOnPng(const AColor: TColor; var APng: TPngImage);
    procedure PrintPokemonOnPng(const AIndex: Integer; const AColorCSSName: string; var APng: TPngImage);
  public
    property Link: string read FLink;
    property Owner: string read FOwner write FOwner;
    property OwnerClean: string read GetOwnerClean;
    property Pokemon[const AIndex: Integer]: TPokemon read GetPokemon;
    property Count: Integer read FPokemonCount;
    property Paste: string read GetPaste;
    property CustomPaste: string read GetCustomPaste;
    property Sprite[const ASpriteType: string; const AIndex: Integer]: TFileName read GetSprite;

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

    procedure AfterConstruction; override;

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
    ///  Returns the printed output's full name.
    /// </summary>
    function PrintPng(const AColorCSSName: string; const AOutputPath: string = ''): string;

    destructor Destroy; override;
  end;

implementation

uses
  Math, StrUtils, Json, IOUtils, Types, UITypes,
  IdHttp, IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Skia, Skia.Vcl,
  AKUtils;

{ TPokepaste }

procedure TPokepaste.AfterConstruction;
begin
  inherited;

  CheckData;
  CreatePokemons;
end;

procedure TPokepaste.CheckData;
var
  I: Integer;
begin
  for I := 0 to Length(DATA_ITEMS) - 1 do
    Assert(Assigned(FData[DATA_ITEMS[I]]), Format('%s data missing.', [DATA_ITEMS[I]]));

  Assert((FList.Text <> '') and Assigned(FList), 'Pokepaste missing/empty.');
end;

constructor TPokepaste.Create(const AUrl: TUrl; const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
var
  LIdHttp: TIdHttp;
  LJsonResponse: string;
  LJson: TJsonValue;
begin
  Init(ADataFileNames, AAssetsPath);
  FLink := AUrl;
  if not SameText(FLink.Substring(Length(FLink) - 4), 'json') then
    FLink := FLink + '/json';

  LIdHttp := TIdHttp.Create(nil);
  try
    LJsonResponse := LIdHttp.Get(FLink);
  finally
    FreeAndNil(LIdHttp);
  end;
  LJson := TJsonObject.ParseJSONValue(LJsonResponse);
  FList.Text := LJson.GetValue<string>('paste');
end;

constructor TPokepaste.Create(const AText: string; const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
begin
  Init(ADataFileNames, AAssetsPath);
  FList.Text := AText;
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
    FreeAndNil(FData);
  inherited;
end;

function TPokepaste.GetCustomPaste: string;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Result := Result + sLineBreak + Pokemon[I].Text;
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
  if not DirectoryExists(FAssetsPath) then
    raise Exception.CreateFmt('Assets directory "%s" not found.', [AAssetsPath]);
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
  LOutputPath := AOutputPath;
  if LOutputPath = '' then
    LOutputPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) + 'Output');
  if not MakeDir(LOutputPath) then
    raise Exception.CreateFmt('Could not create directory "%s", try creating it manually.', [LOutputPath]);
  LOutputPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(LOutputPath) + 'HTML');
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
  Result := LOutputPath + OwnerClean + '_' + FormatDateTime('yyyymmdd', Now) + '.html';
  TFile.WriteAllText(Result, LHtml);
end;

procedure TPokepaste.PrintPlayerOnPng(const AColor: TColor; var APng: TPngImage);
var
  LWidth: Integer;
  LHeight: Integer;
  LOffsetX: Integer;
  LRect: TRect;
begin
  APng.Canvas.Font.Size := 28;
  LWidth := APng.Canvas.TextWidth(Owner) + 30;
  LHeight := APng.Canvas.TextHeight(Owner);
  APng.Canvas.Brush.Color := AColor;
  APng.Canvas.Pen.Color := AColor;
  LOffsetX := Round((APng.Width / 2) - (LWidth / 2));
  LRect := Rect(LOffsetX, 38, LOffsetX + LWidth, 75);
  APng.Canvas.RoundRect(LOffsetX, 15, LOffsetX + LWidth, 75, 46, 46);
  APng.Canvas.FillRect(LRect);
  APng.Canvas.TextOut(LOffsetX + 15, 45 - Round(LHeight / 2), Owner);
end;

function TPokepaste.PrintPng(const AColorCSSName,
  AOutputPath: string): string;
var
  LResourcePath: string;
  LOutputPath: string;
  LColorCss: TStringList;
  LHeaderColor: string;
  LBaseColor: string;
  LPng: TPngImage;
  I: Integer;

  function FgColor(const AColorHex: string): TColor;
  var
    LColorHex: string;
    LHex: string;
    LValue: Integer;
  begin
    LColorHex := AColorHex;
    SetLength(LHex, 2);
    LHex[1] := AColorHex[Length(AColorHex) - 1];
    LHex[2] := AColorHex[Length(AColorHex)];
    LValue := HexToInt(LHex);
    if LValue = 255 then
      LValue := 254
    else
      Inc(LValue);
    LHex := IntToHex(LValue);
    LColorHex[Length(LColorHex) - 1] := LHex[Length(LHex) - 1];
    LColorHex[Length(LColorHex)] := LHex[Length(LHex)];

    Result := HexToColor(LColorHex);
  end;

  procedure CreateEmptyPng;
  var
    LTraspBmp: TBitmap;
    LTraspPng: TPngImage;
    LFgColor: TColor;
  begin
    LFgColor := FgColor(LBaseColor);
    LTraspBmp := TBitmap.Create;
    LTraspPng := TPngImage.Create;
    try
      LTraspBmp.SetSize(960, 1080);
      LTraspBmp.TransparentColor := LFgColor;
      LTraspBmp.Transparent := True;
      LTraspBmp.Canvas.Brush.Color := LFgColor;
      LTraspBmp.Canvas.FillRect(Rect(0, 0, 960, 1080));
      LTraspPng.Assign(LTraspBmp);
      LTraspPng.SaveToFile(LResourcePath + 'empty_pokepaste.png');
    finally
      FreeAndNil(LTraspBmp);
      FreeAndNil(LTraspPng);
    end;
  end;
begin
  LResourcePath := IncludeTrailingPathDelimiter(FAssetsPath + '..');
  LOutputPath := AOutputPath;
  if LOutputPath = '' then
    LOutputPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) + 'Output');
  if not MakeDir(LOutputPath) then
    raise Exception.CreateFmt('Could not create directory "%s", try creating it manually.', [LOutputPath]);

  LOutputPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(LOutputPath) + 'PNG');
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

  CreateEmptyPng;

  LPng := TPngImage.Create;
  try
    LPng.LoadFromFile(LResourcePath + 'empty_pokepaste.png');
    LPng.Canvas.Brush.Style := bsClear;
    LPng.Canvas.Font.Name := 'Source Sans Pro Semibold';
    LPng.Canvas.Font.Color := clWhite;
    LPng.Canvas.Font.Style := [fsBold];
    for I := 0 to Count - 1 do
      PrintPokemonOnPng(I, AColorCSSName, LPng);
    PrintPlayerOnPng(HexToColor(LHeaderColor), LPng);
    Result := LOutputPath + OwnerClean + '_' + FormatDateTime('yyyymmdd', Now) + '.png';
    LPng.SaveToFile(Result);
  finally
    FreeAndNil(LPng);
  end;

  DeleteFile(LResourcePath + 'empty_pokepaste.png');
end;

procedure TPokepaste.PrintPokemonOnPng(const AIndex: Integer; const AColorCSSName: string;
  var APng: TPngImage);
var
  LOffsetX: Integer;
  LOffsetY: Integer;
  LPng: TPngImage;

  procedure SetOffsets;
    procedure SetOffset(const AX, AY: Integer);
    begin
      LOffsetX := AX;
      LOffsetY := AY;
    end;
  begin
    case AIndex of
      0: SetOffset(10, 75);
      1: SetOffset(480, 75);
      2: SetOffset(10, 405);
      3: SetOffset(480, 405);
      4: SetOffset(10, 735);
      5: SetOffset(480, 735);
    end;
  end;

  function SpritePath(const ASpriteType: string; const ADimension: Integer): string;
  begin
    Result := IncludeTrailingPathDelimiter(FAssetsPath + ASpriteType) + IntToStr(ADimension) + 'x' + IntToStr(ADimension);
    if DirectoryExists(Result) then
      Result := IncludeTrailingPathDelimiter(Result)
    else
      Result := IncludeTrailingPathDelimiter(FAssetsPath + ASpriteType);
  end;

  procedure Write(const AX, AY: Integer; const AText: string);
  begin
    APng.Canvas.TextOut(LOffsetX + AX, LOffsetY + AY, AText);
  end;
  procedure Draw(const AX, AY: Integer; const AImage: TPngImage);
  begin
    APng.Canvas.Draw(LOffsetX + AX, LOffsetY + AY, AImage);
  end;

  procedure WriteName;
  begin
    APng.Canvas.Font.Size := 22;
    Write(26, 16, Pokemon[AIndex].Name);
  end;
  procedure WriteAbility;
  begin
    APng.Canvas.Font.Size := 18;
    Write(26, 94, Pokemon[AIndex].Ability);
  end;
  procedure WriteItem;
  var
    LWidth: Integer;
  begin
    APng.Canvas.Font.Size := 12;
    LWidth := APng.Canvas.TextWidth(Pokemon[AIndex].Item);
    Write(361 - Round(LWidth / 2), 272, Pokemon[AIndex].Item);
  end;
  procedure WriteAndDrawMoves;
  var
    LSprite: TPngImage;
    I: Integer;
  begin
    APng.Canvas.Font.Size := 18;
    for I := 0 to 3 do
    begin
      Write(63, 139 + (40 * I), Pokemon[AIndex].MoveName[I]);
      LSprite := TPngImage.Create;
      try
        LSprite.LoadFromFile(SpritePath('Types', 32) + Pokemon[AIndex].MoveTypingSpriteName[I]);
        if (LSprite.Width > 32) or (LSprite.Height > 32) then
          SmoothResize(LSprite, 32, 32);
        Draw(25, 140 + (40 * I), LSprite);
      finally
        FreeAndNil(LSprite);
      end;
    end;
  end;
  procedure DrawTyping;
  var
    LFirstSprite: TPngImage;
    LSecondSprite: TPngImage;
  begin
    LFirstSprite := TPngImage.Create;
    LSecondSprite := TPngImage.Create;
    try
      if Pokemon[AIndex].FirstTypingSpriteName <> '' then
      begin
        LFirstSprite.LoadFromFile(SpritePath('Types', 32) + Pokemon[AIndex].FirstTypingSpriteName);
        if (LFirstSprite.Width > 32) or (LFirstSprite.Height > 32) then
          SmoothResize(LFirstSprite, 32, 32);
        Draw(325, 19, LFirstSprite);
      end;
      LSecondSprite.LoadFromFile(SpritePath('Types', 32) + Pokemon[AIndex].SecondTypingSpriteName);
      if (LSecondSprite.Width > 32) or (LSecondSprite.Height > 32) then
        SmoothResize(LSecondSprite, 32, 32);
      Draw(362, 19, LSecondSprite);
    finally
      FreeAndNil(LFirstSprite);
      FreeAndNil(LSecondSprite);
    end;
  end;
  procedure DrawTera;
  var
    LSprite: TBitmap;
    LSpritePng: TPngImage;
    LSpriteBgFileName: string;
    LSpriteFgFileName: string;
  begin
    LSpriteBgFileName := RetrieveSprite(Pokemon[AIndex].TeraTypingSpriteName, 'Types');
    LSpriteFgFileName := RetrieveSprite(Pokemon[AIndex].TeraTyping + '.svg', 'Types');
    LSprite := TBitmap.Create;
    LSpritePng := TPngImage.Create;
    try
      LSprite.SetSize(39, 46);
      // draw background
      LSprite.SkiaDraw(
        procedure(const ACanvas: ISKCanvas)
        var
          LSVGBrush: TSkSVGBrush;
        begin
          LSVGBrush := TSkSVGBrush.Create;
          try
            LSVGBrush.Source := TFile.ReadAllText(LSpriteBgFileName);
            LSVGBrush.Render(ACanvas, RectF(0, 0, LSprite.Width, LSprite.Height), 1);
          finally
            LSVGBrush.Free;
          end;
        end
      );
      // draw foreground
      LSprite.SkiaDraw(
        procedure(const ACanvas: ISKCanvas)
        var
          LSVGBrush: TSkSVGBrush;
        begin
          LSVGBrush := TSkSVGBrush.Create;
          try
            LSVGBrush.Source := TFile.ReadAllText(LSpriteFgFileName);
            LSVGBrush.OverrideColor := TAlphaColorRec.White;
            LSVGBrush.Render(ACanvas, RectF(-2, 5, 40, 40), 1);
          finally
            LSVGBrush.Free;
          end;
        end
      , False);
      // transform bitmap to png (a temporary file is needed because
      // ToSkImage.EncodeToStream does not produce a TStream accepted by
      // TPngImage...should I report it to skia4delphi?
      LSprite.ToSkImage.EncodeToFile('tmp_tera.png');
      // load it into png
      LSpritePng.LoadFromFile('tmp_tera.png');
      // delete temporary file
      DeleteFile('tmp_tera.png');
      // draw the png on the main one
      Draw(406, 12, LSpritePng);
    finally
      FreeAndNil(LSprite);
      FreeAndNil(LSpritePng);
    end;
  end;
  procedure DrawSprite;
  var
    LSprite: TPngImage;
  begin
    LSprite := TPngImage.Create;
    try
      LSprite.LoadFromFile(RetrieveSprite(Pokemon[AIndex].PokemonSpriteName, 'Pokemon'));
      if (LSprite.Width > 128) or (LSprite.Height > 128) then
        SmoothResize(LSprite, 128, 128);
      Draw(297, 93, LSprite);
    finally
      FreeAndNil(LSprite);
    end;
  end;
  procedure DrawItem;
  var
    LSprite: TPngImage;
  begin
    LSprite := TPngImage.Create;
    try
      LSprite.LoadFromFile(SpritePath('Items', 40) +  Pokemon[AIndex].ItemSpriteName);
      if (LSprite.Width > 40) or (LSprite.Height > 40) then
        SmoothResize(LSprite, 40, 40);
      Draw(341, 231, LSprite);
    finally
      FreeAndNil(LSprite);
    end;
  end;
begin
  SetOffsets;
  LPng := TPngImage.Create;
  try
    LPng.LoadFromFile(IncludeTrailingPathDelimiter(FAssetsPath + '..') + AColorCSSName + '_template.png');
    APng.Canvas.Draw(LOffsetX, LOffsetY, LPng);
  finally
    FreeAndNil(LPng);
  end;
  WriteName;
  WriteAbility;
  WriteItem;
  WriteAndDrawMoves;
  DrawTyping;
  DrawTera;
  DrawSprite;
  DrawItem;
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
var
  I: Integer;
begin
  for I := 0 to Length(FPokemons) - 1 do
    FreeAndNil(FPokemons[I]);
  SetLength(FPokemons, 0);

  CheckData;

  CreatePokemons;
end;

function TPokepaste.RetrieveSprite(const ASpriteName, ASpriteType: string;
  const AForceReload: Boolean): TFileName;
var
  LUrl: TUrl;
  LIdHttp: TIdHttp;
  LIdSSL: TIdSSLIOHandlerSocketOpenSSL;
  LPngStream: TMemoryStream;
  LImage: TPngImage;
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

  // The only png sprites we can obtain by a http request are the ones from
  // ProjectPokemon, the pokemon ones, for the others we simply raise an error.
  if not SameText(ASpriteType, 'Pokemon') then
    raise Exception.CreateFmt('Cannot retrieve the sprite for the type "%s".', [ASpriteType]);

  // Get the pokemon sprite from ProjectPokemon
  LUrl := POKEMON_SPRITE_URL + ASpriteName;
  LIdHttp := TIdHttp.Create(nil);
  LIdSSL := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  LPngStream := TMemoryStream.Create;
  LImage := TPngImage.Create;
  try
    LIdHttp.IOHandler := LIdSSL;
    LIdSSL.SSLOptions.Method := sslvSSLv23;
    LIdSSL.SSLOptions.Mode := sslmUnassigned;
    LIdHttp.AllowCookies := True;
    LIdHttp.HandleRedirects := True;
    LIdHttp.RedirectMaximum := 10;
    LIdHttp.Get(LUrl, LPngStream);
    LPngStream.Seek(0, soFromBeginning);
    LImage.LoadFromStream(LPngStream);
    LImage.SaveToFile(Result);
  finally
    FreeAndNil(LIdHttp);
    LPngStream.Free;
    FreeAndNil(LImage);
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
    FMoveList := §('Moves');
    FEvSpread := TranslateEvs(§('Evs'));
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
    LList.Add('EVs: ' + IntToStr(Hp) + ' HP / ' + IntToStr(Atk) + ' Atk / ' + IntToStr(Def) + ' Def / ' +
      IntToStr(SpA) + ' SpA / ' + IntToStr(SpD) + ' SpD / ' + IntToStr(Spe) + ' Spe');
    LList.Add(Nature + ' Nature');
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
