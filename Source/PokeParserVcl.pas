unit PokeParserVcl;

interface

uses
  SysUtils,
  Vcl.Graphics, Vcl.Imaging.PngImage,
  PokeParser;

type
  TPokepasteVcl = class(TPokepaste)
  private
    procedure PrintPlayerOnPng(const AColor: TColor; var APng: TPngImage); virtual;
    procedure PrintPokemonOnPng(const AIndex: Integer; const AColorCSSName: string; var APng: TPngImage);

  strict protected
    function RetrieveSprite(const ASpriteName, ASpriteType: string; const AForceReload: Boolean = False): TFileName; override;
    procedure CreateEmptyPng(const ABaseColorHex: string); override;
    function PaintPastePng(const AColorCSSName, AHeaderColorHex, AOutputPath: string): string; override;
  end;


implementation

uses
  Classes, Math, IOUtils, Types, UITypes,
  IdHttp, IdBaseComponent, IdComponent, IdIOHandler, IdIOHandlerSocket,
  IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  Skia, Skia.Vcl,
  AkUtils, AkUtilsVcl;

{ TPokepasteVcl }

procedure TPokepasteVcl.CreateEmptyPng(const ABaseColorHex: string);
var
  LTraspBmp: TBitmap;
  LTraspPng: TPngImage;
  LFgColor: TColor;

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
    if LValue = 0 then
      LValue := 1
    else
      LValue := LValue - 1;
    LHex := IntToHex(LValue);
    LColorHex[Length(LColorHex) - 1] := LHex[Length(LHex) - 1];
    LColorHex[Length(LColorHex)] := LHex[Length(LHex)];

    Result := HexToColor(LColorHex);
  end;
begin
  inherited;
  LFgColor := FgColor(ABaseColorHex);
  LTraspBmp := TBitmap.Create;
  LTraspPng := TPngImage.Create;
  try
    LTraspBmp.SetSize(960, 1080);
    LTraspBmp.TransparentColor := LFgColor;
    LTraspBmp.Transparent := True;
    LTraspBmp.Canvas.Brush.Color := LFgColor;
    LTraspBmp.Canvas.FillRect(Rect(0, 0, 960, 1080));
    LTraspPng.Assign(LTraspBmp);
    LTraspPng.SaveToFile(IncludeTrailingPathDelimiter(AssetsPath + '..') + 'empty_pokepaste.png');
  finally
    FreeAndNil(LTraspBmp);
    FreeAndNil(LTraspPng);
  end;
end;

procedure TPokepasteVcl.PrintPlayerOnPng(const AColor: TColor; var APng: TPngImage);
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

procedure TPokepasteVcl.PrintPokemonOnPng(const AIndex: Integer; const AColorCSSName: string;
  var APng: TPngImage);
var
  LOffsetX: Integer;
  LOffsetY: Integer;
  LPng: TPngImage;

  procedure SetOffsets;
  begin
    if Odd(AIndex) then
      LOffsetX := 480
    else
      LOffsetX := 10;

    LOffsetY := 75 + (330 * Floor(AIndex / 2));
  end;

  function SpritePath(const ASpriteType: string; const ADimension: Integer): string;
  begin
    Result := IncludeTrailingPathDelimiter(AssetsPath + ASpriteType) + IntToStr(ADimension) + 'x' + IntToStr(ADimension);
    if DirectoryExists(Result) then
      Result := IncludeTrailingPathDelimiter(Result)
    else
      Result := IncludeTrailingPathDelimiter(AssetsPath + ASpriteType);
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
    LPng.LoadFromFile(IncludeTrailingPathDelimiter(AssetsPath + '..') + AColorCSSName + '_template.png');
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

function TPokepasteVcl.RetrieveSprite(const ASpriteName, ASpriteType: string;
  const AForceReload: Boolean): TFileName;
var
  LUrl: TUrl;
  LIdHttp: TIdHttp;
  LIdSSL: TIdSSLIOHandlerSocketOpenSSL;
  LPngStream: TMemoryStream;
  LImage: TPngImage;
begin
  Result := inherited;
  if (FileExists(Result) and not AForceReload) or SameText(Result, '') then
    Exit;

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

function TPokepasteVcl.PaintPastePng(const AColorCSSName, AHeaderColorHex,
  AOutputPath: string): string;
var
  LPng: TPngImage;
  I: Integer;
begin
  inherited;
  LPng := TPngImage.Create;
  try
    LPng.LoadFromFile(IncludeTrailingPathDelimiter(AssetsPath + '..') + 'empty_pokepaste.png');
    LPng.Canvas.Brush.Style := bsClear;
    LPng.Canvas.Font.Name := 'Source Sans Pro Semibold';
    LPng.Canvas.Font.Color := clWhite;
    LPng.Canvas.Font.Style := [fsBold];
    for I := 0 to Count - 1 do
      PrintPokemonOnPng(I, AColorCSSName, LPng);
    PrintPlayerOnPng(HexToColor(AHeaderColorHex), LPng);
    Result := AOutputPath + OwnerClean + '_' + FormatDateTime('yyyymmdd', Now) + '.png';
    LPng.SaveToFile(Result);
  finally
    FreeAndNil(LPng);
  end;
end;

end.
