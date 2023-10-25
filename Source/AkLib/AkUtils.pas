unit AkUtils;

interface

uses
  SysUtils, Classes;

type
  TUrl = type string;

  TStringsHelper = class Helper for TStringList
  private
    function ContainsCaseSensitive(const AString: string; const AOffset: Integer): Integer;
    function ContainsCaseInsensitive(const AString: string; const AOffset: Integer): Integer;
    function GetObjectCount: Integer;
    function GetObjectText: string;
    function GetAssignedObject(const AIndex: Integer): TObject;
  public
    property ObjectCount: Integer read GetObjectCount;
    property ObjectText: string read GetObjectText;
    property AssignedObjects[const AIndex: Integer]: TObject read GetAssignedObject;
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
  end;

  TAkLogger = class
  private
    FId: string;
    FTitle: string;
    FFileName: string;
    FHeader: string;
    FInterval: Char;
    FDateTimeFormat: string;
    FSaveOnLog: Boolean;
    FOnLog: TProc<string>;
    FLog: TStringList;
    FInitialized: Boolean;
    procedure SetInterval(const AInterval: Char);
    procedure SetHeader;
    function GetFileName: string;
    function GetFilePath: string;
    function GetIntervalSuffix: string;
  public
    property Id: string read FId;
    property Title: string read FTitle;
    property FileName: string read GetFileName;
    property FilePath: string read GetFilePath;
    property Interval: Char read FInterval write SetInterval;
    property DateTimeFormat: string read FDateTimeFormat write FDateTimeFormat;
    property IntervalSuffix: string read GetIntervalSuffix;
    property SaveOnLog: Boolean read FSaveOnLog write FSaveOnLog;
    property OnLog: TProc<string> write FOnLog;
    constructor CreateAndInit(const ATitle, AFileName: string; const AInterval: Char = 'Y';
      const ADateTimeFormat: string = 'yyyymmdd_hh:nn:ss');
    constructor Create(const ATitle, AFileName: string; const AInterval: Char = #0;
      const ADateTimeFormat: string = '');
    procedure Initialize;
    procedure Log(const AString: string);
    destructor Destroy; override;
  end;

function CreateFileList(const AFolderName, AWildCard: string): TArray<TFileName>;
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

function TStringsHelper.GetAssignedObject(const AIndex: Integer): TObject;
var
  LIndex: Integer;
  I: Integer;
begin
  Result := nil;
  LIndex := 0;
  for I := 0 to Count - 1 do
    if Assigned(Objects[I]) then
    begin
      if AIndex = LIndex then
      begin
        Result := Objects[I];
        Exit;
      end;
      Inc(LIndex);
    end;
end;

function TStringsHelper.GetObjectCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    if Assigned(Objects[I]) then
      Inc(Result);
end;

function TStringsHelper.GetObjectText: string;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    if Assigned(Objects[I]) then
      Result := Result + sLineBreak + Strings[I];
  Result := StringReplace(Result, sLineBreak, '', [rfIgnoreCase]);
end;

{ TAkLogger }

procedure TAkLogger.Log(const AString: string);
var
  LString: string;
begin
  Assert(FInitialized, 'AkLogger not initialized. Initialize it first.');

  LString := '[' + FormatDateTime(DateTimeFormat, Now) + ']: ' + AString;

  if Assigned(FOnLog) then
    FOnLog(LString);

  FLog.Add(LString);

  if SaveOnLog then
    FLog.SaveToFile(FFileName);
end;

procedure TAkLogger.Initialize;
var
  LOldLogName: string;
begin
  if FInitialized then
    Exit;

  Assert(FInterval <> #0, 'Cannot initialize AkLogger: interval not set.');
  Assert(FDateTimeFormat <> '', 'Cannot initialize AkLogger: date-time format not set.');

  LOldLogName := FFileName;

  FLog := TStringList.Create;

  ///  Remove other possible extensions and add interval suffix (if not already
  ///  present in filename)
  if Pos(IntervalSuffix, FFileName) > 0 then
    FFileName := StringReplace(FFileName, ExtractFileExt(FFileName), '', [rfIgnoreCase])
  else
    FFileName := StringReplace(FFileName, ExtractFileExt(FFileName), '', [rfIgnoreCase]) + IntervalSuffix;
  FFileName := FFileName + '.log';

  SetHeader;

  if FileExists(FFileName) then
    FLog.LoadFromFile(FFileName)
  else if FileExists(LOldLogName) then
    FLog.LoadFromFile(LOldLogName)
  else
    FLog.Add(FHeader);

  FInitialized := True;

  FLog.Add('');
  Log(Format('== New session started (%s). ==', [Id]));
end;

constructor TAkLogger.Create(const ATitle, AFileName: string;
  const AInterval: Char; const ADateTimeFormat: string);
begin
  FId := RandomString(32);
  FTitle := ATitle;
  FFileName := AFileName;
  FSaveOnLog := True;
  FInterval := AInterval;
  FDateTimeFormat := FDateTimeFormat;
  FInitialized := False;
end;

constructor TAkLogger.CreateAndInit(const ATitle, AFileName: string;
  const AInterval: Char; const ADateTimeFormat: string);
begin
  Create(ATitle, AFileName);
  FInterval := UpCase(AInterval);
  FDateTimeFormat := ADateTimeFormat;
  Initialize;
end;

destructor TAkLogger.Destroy;
begin
  if FInitialized then
  begin
    Assert(Assigned(FLog), 'AkLogger error: log was not initialized.');

    Log(Format('== Session concluded (%s). ==', [Id]));
    FLog.SaveToFile(FFileName);
    FLog.Free;
  end;
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

procedure TAkLogger.SetInterval(const AInterval: Char);
begin
  FInterval := UpCase(AInterval);
end;

end.
