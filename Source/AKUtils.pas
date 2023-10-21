unit AKUtils;

interface

uses
  SysUtils, Classes,
  Vcl.Graphics, Vcl.Imaging.pngimage,
  Winapi.Windows;

type
  TStringsHelper = class Helper for TStringList
    /// <summary>
    ///  Returns the index of the line which contains the first appearance of
    ///  the given string, starting from the specified offset. If none is found
    ///  -1 is returned.
    /// </summary>
    /// <param name="AString">
    ///  The string to search.
    /// </param>
    /// <param name="AOffset">
    ///  The index of the first line searched.
    /// </param>
    function Contains(const AString: string; const AOffset: Integer = 0): Integer;
  private
    function ContainsCaseSensitive(const AString: string; const AOffset: Integer): Integer;
    function ContainsCaseInsensitive(const AString: string; const AOffset: Integer): Integer;
  end;

  TAkLogger = class
  private
    FId: string;
    FTitle: string;
    FFileName: string;
    FHeader: string;
    FInterval: Char;
    FSaveOnLog: Boolean;
    FOnLog: TProc<string>;
    FLog: TStringList;
    procedure SetHeader;
    function GetFileName: string;
    function GetFilePath: string;
    function GetIntervalSuffix: string;
  public
    property Id: string read FId;
    property Title: string read FTitle;
    property FileName: string read GetFileName;
    property FilePath: string read GetFilePath;
    property Interval: Char read FInterval write FInterval;
    property IntervalSuffix: string read GetIntervalSuffix;
    property SaveOnLog: Boolean read FSaveOnLog write FSaveOnLog;
    property OnLog: TProc<string> write FOnLog;
    constructor Create(const ATitle, AFileName: string; const AInterval: Char = 'Y');
    procedure AfterConstruction; override;
    procedure Log(const AString: string);
    destructor Destroy; override;
  end;

function CreateFileList(const AFolderName, AWildCard: string): TArray<TFileName>;
function ColorToHex(const AColor: TColor): string;
function HexToColor(const AHex: string): TColor;
procedure ExpandValue(var AText: string; const AMacro, AValue: string; const ADelimiter: string  = '%');
procedure ExpandValues(var AText: string; const AMacros, AValues: array of string; const ADelimiter: string = '%');
procedure ExpandFileMacros(var AText: string; const AFileNames: array of TFileName; const ADelimiter: string = '%');
procedure ExpandPathMacros(var AText: string; const APaths: array of string; const ADelimiter: string = '#');
function Occurrences(const ASubString, AText: string): Integer;
function CapitalFirst(const AString: string): string;
function RemoveStrings(const AString: string; APatterns: array of string): string;
function MakeDir(const APath: string): Boolean;
function RandomString(const ALength: Integer; const ACharSet: string = ''): string;
function HexToInt(const AHex: string): Integer;
procedure SmoothResize(apng:tpngimage; NuWidth,NuHeight:integer);

implementation

uses
  StrUtils, IOUtils;

function CreateFileList(const AFolderName, AWildCard: string): TArray<TFileName>;
var
  LSearch: TSearchRec;
  LFolderName: string;
  LFileName: TFileName;
begin
  LFolderName := IncludeTrailingPathDelimiter(AFolderName);

  if FindFirst(LFolderName + AWildCard, faAnyFile, LSearch) = 0 then
  begin
    SetLength(Result, Length(Result) + 1);
    LFileName := LFolderName + LSearch.Name;
    Result[Length(Result) - 1] := LFileName;
    while FindNext(LSearch) = 0 do
    begin
      SetLength(Result, Length(Result) + 1);
      LFileName := LFolderName + LSearch.Name;
      Result[Length(Result) - 1] := LFileName;
    end;
    SysUtils.FindClose(LSearch);
  end;
end;

function ColorToHex(const AColor: TColor): string;
var
  LRValue: Word;
  LGValue: Word;
  LBValue: Word;
begin
  LRValue := GetRValue(AColor);
  LGValue := GetGValue(AColor);
  LBValue := GetBValue(AColor);
  Result := '#' + IntToHex(LRValue, 2) + IntToHex(LGValue, 2) + IntToHex(LBValue, 2);
end;

function HexToColor(const AHex: string): TColor;
var
  LHexStr: string;
begin
  LHexStr := AHex;
  if not Pos('#', LHexStr) = 1 then
    LHexStr := '#' + LHexStr;

  Result := StrToInt64('$00' +
    Copy(LHexStr, Pos('#', LHexStr) + 5, 2) +
    Copy(LHexStr, Pos('#', LHexStr) + 3, 2) +
    Copy(LHexStr, Pos('#', LHexStr) + 1, 2));
end;

procedure ExpandValue(var AText: string; const AMacro, AValue: string; const ADelimiter: string);
begin
  AText := StringReplace(AText, ADelimiter + AMacro + ADelimiter, AValue, [rfReplaceAll, rfIgnoreCase]);
end;

procedure ExpandValues(var AText: string; const AMacros, AValues: array of string; const ADelimiter: string);
var
  I: Integer;
begin
  for I := 0 to Length(AMacros) - 1 do
    ExpandValue(AText, AMacros[I], AValues[I], ADelimiter);
end;

procedure ExpandFileMacros(var AText: string; const AFileNames: array of TFileName; const ADelimiter: string);
var
  LFileText: string;
  I: Integer;
begin
  for I := 0 to Length(AFileNames) - 1 do
  begin
    LFileText := TFile.ReadAllText(AFileNames[I]);
    ExpandValue(AText, ExtractFileName(AFileNames[I]), LFileText, ADelimiter);
  end;
end;

procedure ExpandPathMacros(var AText: string; const APaths: array of string; const ADelimiter: string);
var
  I: Integer;
begin

  for I := 0 to Length(APaths) - 1 do
  begin
    if not FileExists(APaths[I]) and not DirectoryExists(APaths[I]) then
      Continue;
    if ExtractFileExt(APaths[I]) = '' then // it's a folder
      ExpandValue(AText, ExtractFileName(APaths[I]), ExpandFileName(IncludeTrailingPathDelimiter(APaths[I])), ADelimiter)
    else // it's a file
      ExpandValue(AText, ExtractFileName(APaths[I]), ExpandFileName(APaths[I]), ADelimiter);
  end;
end;

function Occurrences(const ASubString, AText: string): Integer;
var
  LOffset: Integer;
begin
  Result := 0;
  LOffset := PosEx(ASubString, AText, 1);
  while LOffset <> 0 do
  begin
    Inc(Result);
    LOffset := PosEx(ASubString, AText, LOffset + Length(ASubString));
  end;
end;

function CapitalFirst(const AString: string): string;
var
  LMultiName: TStringList;
  I: Integer;

  function CapitalFirstItem(const AString: string): string;
  begin
    Result := AnsiLowerCase(AString);
    Delete(Result, 1, 1);
    Result := AnsiUpperCase(AString)[1] + Result;
  end;

  begin
  LMultiName := TStringList.Create;
  try
    LMultiName.Delimiter := ' ';
    LMultiName.StrictDelimiter := True;
    LMultiName.DelimitedText := AString;
    for I := 0 to LMultiName.Count - 1 do
      Result := Result + ' ' + CapitalFirstItem(LMultiName[I]);
    Result := Trim(Result);
  finally
    LMultiName.Free;
  end;
end;

function RemoveStrings(const AString: string; APatterns: array of string): string;
var
  I: Integer;
begin
  Result := AString;
  for I := 0 to Length(APatterns) - 1 do
    Result := StringReplace(Result, APatterns[I], '', [rfReplaceAll, rfIgnoreCase]);
end;

function MakeDir(const APath: string): Boolean;
begin
  Result := DirectoryExists(APath);
  if not Result then
    Result := CreateDir(APath);
end;

function RandomString(const ALength: Integer; const ACharSet: string): string;
const
  CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
var
  LCharSet: string;
  I: Integer;
begin
  LCharSet := ACharSet;
  if LCharSet = '' then
    LCharSet := CHARS;

  SetLength(Result, ALength);
  Randomize;
  for I := 1 to ALength do
    Result[I] := LCharSet[Random(Length(LCharSet)) + 1];
end;

function HexToInt(const AHex: string): Integer;
begin
  Result := StrToInt('$' + AHex);
end;

/// taken from http://cc.embarcadero.com/Item/25631
procedure SmoothResize(apng:tpngimage; NuWidth,NuHeight:integer);
var
  xscale, yscale         : Single;
  sfrom_y, sfrom_x       : Single;
  ifrom_y, ifrom_x       : Integer;
  to_y, to_x             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue, new_alpha    : Integer;
  new_colortype          : Integer;
  total_red, total_green : Single;
  total_blue, total_alpha: Single;
  IsAlpha                : Boolean;
  ix, iy                 : Integer;
  bTmp : TPngImage;
  sli, slo : pRGBLine;
  ali, alo: pbytearray;
begin
  if not (apng.Header.ColorType in [COLOR_RGBALPHA, COLOR_RGB]) then
    raise Exception.Create('Only COLOR_RGBALPHA and COLOR_RGB formats' +
    ' are supported');
  IsAlpha := apng.Header.ColorType in [COLOR_RGBALPHA];
  if IsAlpha then new_colortype := COLOR_RGBALPHA else
    new_colortype := COLOR_RGB;
  bTmp := TPngImage.CreateBlank(new_colortype, 8, NuWidth, NuHeight);
  xscale := bTmp.Width / (apng.Width-1);
  yscale := bTmp.Height / (apng.Height-1);
  for to_y := 0 to bTmp.Height-1 do begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];
    for to_x := 0 to bTmp.Width-1 do begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      total_alpha  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          sli := apng.Scanline[ifrom_y + iy];

          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
          if IsAlpha then
          begin
            ali := apng.AlphaScanline[ifrom_y + iy];
            new_alpha := ali[ifrom_x + ix];
            total_alpha := total_alpha + new_alpha * weight;
          end;
        end;
      end;
      slo := bTmp.ScanLine[to_y];
      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);
      if isAlpha then
      begin
        alo := bTmp.AlphaScanLine[to_y];
        alo[to_x] := Round(total_alpha);
      end;
    end;
  end;
  apng.Assign(bTmp);
  bTmp.Free;
end;

{ TStringsHelper }

function TStringsHelper.Contains(const AString: string; const AOffset: Integer): Integer;
begin
  Result := -1;

  if AOffset >= Count then
    Exit;

  if CaseSensitive then
    Result := ContainsCaseSensitive(AString, AOffset)
  else
    Result := ContainsCaseInsensitive(AString, AOffset);
end;

function TStringsHelper.ContainsCaseInsensitive(const AString: string; const AOffset: Integer): Integer;
var
  LString: string;
  I: Integer;
begin
  Result := -1;
  LString := AnsiUpperCase(AString);
  for I := AOffset to Count - 1 do
    if Pos(LString, AnsiUpperCase(Self[I])) > 0 then
    begin
      Result := I;
      Exit;
    end;
end;

function TStringsHelper.ContainsCaseSensitive(const AString: string; const AOffset: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := AOffset to Count - 1 do
    if Pos(AString, Self[I]) > 0 then
    begin
      Result := I;
      Exit;
    end;
end;

{ TAkLogger }

procedure TAkLogger.Log(const AString: string);
var
  LString: string;
begin
  LString := '[' + FormatDateTime('dd-mm-yy_hh:nn:ss', Now) + ']: ' + AString;

  if Assigned(FOnLog) then
    FOnLog(LString);

  FLog.Add(LString);

  if SaveOnLog then
    FLog.SaveToFile(FFileName);
end;

procedure TAkLogger.AfterConstruction;
begin
  inherited;

  if FLog.Count < 1 then
    FLog.Add(FHeader)
  else
    FLog.Add('');

  Log(Format('== New session started (%s). ==', [Id]));
end;

constructor TAkLogger.Create(const ATitle, AFileName: string; const AInterval: Char);
begin
  FId := RandomString(32);
  FTitle := ATitle;
  FInterval := UpCase(AInterval);
  FSaveOnLog := True;

  if Pos(IntervalSuffix, AFileName) > 0 then
    FFileName := StringReplace(AFileName, ExtractFileExt(AFileName), '', [rfIgnoreCase])
  else
    FFileName := StringReplace(AFileName, ExtractFileExt(AFileName), '', [rfIgnoreCase]) + IntervalSuffix;

  FFileName := FFileName + '.log';

  SetHeader;

  FLog := TStringList.Create;
  if FileExists(FFileName) then
    FLog.LoadFromFile(FFileName)
  else if FileExists(AFileName) then
    FLog.LoadFromFile(AFileName);
end;

destructor TAkLogger.Destroy;
begin
  Assert(Assigned(FLog), 'AkLogger error: log was not initialized.');

  Log(Format('== Session concluded (%s). ==', [Id]));
  FLog.SaveToFile(FFileName);
  FLog.Free;
  inherited;
end;

function TAkLogger.GetFileName: string;
begin
  Result := ExtractFileName(FFileName);
end;

function TAkLogger.GetFilePath: string;
begin
  Result := ExtractFilePath(FFileName);
end;

function TAkLogger.GetIntervalSuffix: string;
begin
  case Interval of
    'Y': Result := '_' + FormatDateTime('yyyy', Now);
    'M': Result := '_' + FormatDateTime('yyyymm', Now);
    'D': Result := '_' + FormatDateTime('yyyymmdd', Now);
  else
    Result := '';
  end;
end;

procedure TAkLogger.SetHeader;
begin
  FHeader := Format('========== %s log ==========', [FTitle]);
end;

end.
