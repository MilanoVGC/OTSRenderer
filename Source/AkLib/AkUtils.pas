unit AkUtils;

interface

uses
  SysUtils, Classes,
  CsvParser;

const
  NULL_DATETIME = -693594;

type
  TUrl = type string;

  /// <summary>
  ///  The record containing the language's informations: (1) the language ID,
  ///  a string usually composed of two characters (like 'en'); (2) the
  ///  description, a string usually containing the full translated name (like
  ///  'English'); (3) the resource index, a integer which often contains
  ///  the column number of the language translation (to facilitate the use with
  ///  column-based translation resources or number-based translation resources);
  ///  (4 - optional) the name of the font to use with this language.
  /// </summary>
  TLanguage = record
    Id: string;
    Description: string;
    Index: Integer;
    FontName: string;
    constructor Create(const AId, ADescription: string; const AIndex: Integer;
      const AFontName: string = '');
  end;

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
    FEncoding: TEncoding;
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
    property Encoding: TEncoding read FEncoding write FEncoding;
    property OnLog: TProc<string> write FOnLog;
    property IsInitialized: Boolean read FInitialized;
    constructor CreateAndInit(const ATitle, AFileName: string; const AInterval: Char = 'Y';
      const ADateTimeFormat: string = 'yyyymmdd_hh:nn:ss');
    constructor Create(const ATitle, AFileName: string; const AInterval: Char = #0;
      const ADateTimeFormat: string = '');
    procedure Initialize;
    procedure Log(const AString: string); overload;
    procedure Log(const AString: string; const AParams: array of const); overload;
    destructor Destroy; override;
  end;

  /// <summary>
  ///  Base language registry, used to give consistent language/translation
  ///  support to the application. Languages can be loaded into it manually (via
  ///  the Add methods) or by giving it a Config file, that has to be a ';'
  ///  separated CSV file with 4 columns for each language: Id, Description,
  ///  Index, FontName (see TLanguage documentation for further informations).
  ///  The first language added to the registry will be marked as the default
  ///  language (i.e. the language of the app without any translation): it can
  ///  be changed via the DefaultLanguage property.
  /// </summary>
  /// <remarks>
  ///  You shouldn't create instances of this class, call the Instance property
  ///  instead.
  /// </remarks>
  TAkLanguageRegistry = class
  strict private
    FLanguages: array of TLanguage;
    FDefaultLanguageIndex: Integer;
    class var FConfigFileName: TFileName;
    class var FInstance: TAkLanguageRegistry;
    function LanguageIndex(const ALanguage: TLanguage): Integer; overload;
    function LanguageIndex(const AId: string): Integer; overload;
    function LanguageIndex(const AIndex: Integer): Integer; overload;
    function FindLanguageById(const AId: string): TLanguage;
    function FindLanguageByColumn(const AIndex: Integer): TLanguage;
    function GetLanguageById(const AId: string): TLanguage;
    function GetLanguageByColumn(const AIndex: Integer): TLanguage;
    procedure SetDefaultLanguage(const ALanguage: TLanguage);
    function GetDefaultLanguage: TLanguage;
    procedure ReadFromConfig;
    class function GetConfigFileName: TFileName; static;
    class procedure SetConfigFileName(const AFileName: TFileName); static;
    class function GetInstance: TAkLanguageRegistry; static;
  public
    property LanguageById[const AId: string]: TLanguage read GetLanguageById; default;
    property LanguageByColumn[const AIndex: Integer]: TLanguage read GetLanguageByColumn;
    property DefaultLanguage: TLanguage read GetDefaultLanguage write SetDefaultLanguage;
    class property Config: TFileName read GetConfigFileName write SetConfigFileName;
    class property Instance: TAkLanguageRegistry read GetInstance;
    procedure AfterConstruction; override;
    procedure Add(const ALanguage: TLanguage); overload;
    procedure Add(const ALanguages: array of TLanguage); overload;
    procedure Clear;
    function IsIn(const ALanguage: TLanguage): Boolean; overload;
    function IsIn(const AId: string): Boolean; overload;
    function IsIn(const AIndex: Integer): Boolean; overload;
    function IsDefaultLanguage(const ALanguage: TLanguage): Boolean; overload;
    function IsDefaultLanguage(const AId: string): Boolean; overload;
    function IsDefaultLanguage(const AIndex: Integer): Boolean; overload;
    procedure ForEach(const AProc: TProc<TLanguage>);
    class procedure Iterate(const ALanguages: array of TLanguage; const AProc: TProc<TLanguage>); overload;
    class procedure Iterate(const AProc: TProc<TLanguage>); overload;
    destructor Destroy; override;
  end;


function AppTitle: string;
function AppPath: string;

/// <summary>
///  Translate function that operates reading from a CSV resource file of
///  translations: the string to be translated is used (as a "key value") to
///  find the row of the resource containing the appropriate translation. The
///  column index from which the translation is got is determined by adding the
///  offset of the resource to the one of the given language (as it is stored in
///  the registry). [e.g. if the italian language is stored as id = 'it' and
///  index = 3 and the resource file (foo.csv) has 5 columns of non-translation
///  data before the translation ones, the call to this method has to be like
///  <code>
///  Translate('something', 'it', 'foo.csv', 5)
///  </code>
///  and it will search on the 8th column of foo.csv for the italian translation].
/// </summary>
/// <param name="AString">
///  The string to be translated.
/// </param>
/// <param name="ALanguageId">
///  The language ID to translate into.
/// </param>
/// <param name="AResource">
///  The CSV resource file containing translation values.
/// </param>
/// <param name="AResourceOffset">
///  The first column (index) of the resource file containing translation.
/// </param>
/// <param name="AStringOffset">
///  The column (index) which contains the string to be translated.
/// </param>
function TranslateFromCsv(const AString, ALanguageId: string; const AResource: TCsv;
  const AResourceOffset: Integer = 0; const AStringOffset: Integer = 0): string;

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
function IsValidDateFormat(const AFormat: string): Boolean;
function StringToDate(const AString: string; const AFormat: string = 'yyyymmdd'): TDateTime;
function DateToString(const ADate: TDateTime; const AFormat: string = 'yyyymmdd'): string;
function StrContains(const AString, ASubString: string): Boolean; overload;
function StrContains(const AString: string; const ASubStrings: array of string): Boolean; overload;
function StrArrayClone(const AStringArray: array of string): TArray<string>;

implementation

uses
  StrUtils, IOUtils;

function AppTitle: string;
begin
  Result := StringReplace(ExtractFileName(ParamStr(0)), ExtractFileExt(ParamStr(0)), '', [rfReplaceAll, rfIgnoreCase]);
end;

function AppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function TranslateFromCsv(const AString, ALanguageId: string; const AResource: TCsv;
  const AResourceOffset, AStringOffset: Integer): string;
begin
  Assert(Assigned(AResource));

  Result := AString;

  if Result = '' then
    Exit;

  if TAkLanguageRegistry.Instance.IsDefaultLanguage(ALanguageId) then
    Exit;

  try
    Result := AResource.FindByValue(AString, TAkLanguageRegistry.Instance[ALanguageId].Index + AResourceOffset, AStringOffset);
  except
    Result := AString;
  end;

  if Result = '' then
    Result := AString;
end;

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
    if MatchText(Result, [' ', '']) then
      Exit;
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

function IsValidDateFormat(const AFormat: string): Boolean;
begin
  Result := MatchText(AFormat, ['yyyymmdd',
    'yyyy-mm-dd', 'yyyy/mm/dd', 'yyyy_mm_dd', 'yyyy mm dd',
    'dd-mm-yyyy', 'dd/mm/yyyy', 'dd_mm_yyyy', 'dd mm yyyy',
    'mm-dd-yyyy', 'mm/dd/yyyy', 'mm_dd_yyyy', 'mm dd yyyy',
    'yy-mm-dd', 'yy/mm/dd', 'yy_mm_dd', 'yy mm dd',
    'dd-mm-yy', 'dd/mm/yy', 'dd_mm_yy', 'dd mm yy',
    'mm-dd-yy', 'mm/dd/yy', 'mm_dd_yy', 'mm dd yy']);
end;

function StringToDate(const AString, AFormat: string): TDateTime;
var
  LYear: string;
  LMonth: string;
  LDay: string;
  LYearOffset: Integer;
  LMonthOffset: Integer;
  LDayOffset: Integer;
  LYearLength: Integer;

  procedure SetOffsets(const AYearOffset, AMonthOffset, ADayOffset: Integer;
    const AYearLength: Integer = 4);
  begin
    LYearOffset := AYearOffset;
    LMonthOffset := AMonthOffset;
    LDayOffset := ADayOffset;
    LYearLength := AYearLength;
  end;

  procedure AdjustYear;
  var
    LCurrentYearStr: string;
    LCurrentHundreds: string;
  begin
    LCurrentYearStr := IntToStr(CurrentYear);
    LCurrentHundreds := LCurrentYearStr.Substring(0, Length(LCurrentYearStr) - 2);
    if StrToInt(LCurrentHundreds + LYear) > (CurrentYear + 20) then
      LYear := IntToStr(StrToInt(LCurrentHundreds) - 1) + LYear;
  end;
begin
  if AString = '' then
  begin
    Result := NULL_DATETIME;
    Exit;
  end;

  if not IsValidDateFormat(AFormat) then
    raise Exception.CreateFmt('Unknown date format "%s"', [AFormat])
  else if SameText(AFormat, 'yyyymmdd') then
    SetOffsets(0, 4, 6)
  else if MatchText(AFormat, ['yyyy-mm-dd', 'yyyy/mm/dd', 'yyyy_mm_dd', 'yyyy mm dd']) then
    SetOffsets(0, 5, 8)
  else if MatchText(AFormat, ['dd-mm-yyyy', 'dd/mm/yyyy', 'dd_mm_yyyy', 'dd mm yyyy']) then
    SetOffsets(6, 3, 0)
  else if MatchText(AFormat, ['mm-dd-yyyy', 'mm/dd/yyyy', 'mm_dd_yyyy', 'mm dd yyyy']) then
    SetOffsets(6, 0, 3)
  else if MatchText(AFormat, ['yy-mm-dd', 'yy/mm/dd', 'yy_mm_dd', 'yy mm dd']) then
    SetOffsets(0, 3, 6, 2)
  else if MatchText(AFormat, ['dd-mm-yy', 'dd/mm/yy', 'dd_mm_yy', 'dd mm yy']) then
    SetOffsets(6, 3, 0, 2)
  else if MatchText(AFormat, ['mm-dd-yy', 'mm/dd/yy', 'mm_dd_yy', 'mm dd yy']) then
    SetOffsets(6, 0, 3, 2);

  LYear := AString.Substring(LYearOffset, LYearLength);
  LMonth := AString.Substring(LMonthOffset, 2);
  LDay := AString.Substring(LDayOffset, 2);
  if LYearLength = 2 then
    AdjustYear;
  Result := EncodeDate(StrToInt(LYear), StrToInt(LMonth), StrToInt(LDay));
end;

function DateToString(const ADate: TDateTime; const AFormat: string): string;
begin
  Result := '';
  if ADate = NULL_DATETIME then
    Exit;
  Result := FormatDateTime(AFormat, ADate);
end;

function StrContains(const AString, ASubString: string): Boolean;
begin
  Result := Pos(UpperCase(ASubString), UpperCase(AString)) > 0;
end;

function StrContains(const AString: string; const ASubStrings: array of string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(ASubStrings) - 1 do
  begin
    Result := StrContains(AString, ASubStrings[I]);
    if Result then
      Break;
  end;
end;

function StrArrayClone(const AStringArray: array of string): TArray<string>;
var
  LLength: Integer;
  I: Integer;
begin
  LLength := Length(AStringArray);
  SetLength(Result, LLength);
  for I := 0 to LLength - 1 do
    Result[I] := AStringArray[I];
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
    FOnLog(AString);

  FLog.Add(LString);

  if SaveOnLog then
    FLog.SaveToFile(FFileName, FEncoding);
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

procedure TAkLogger.Log(const AString: string; const AParams: array of const);
begin
  Log(Format(AString, AParams));
end;

constructor TAkLogger.Create(const ATitle, AFileName: string;
  const AInterval: Char; const ADateTimeFormat: string);
begin
  FId := RandomString(32);
  FTitle := ATitle;
  FFileName := AFileName;
  FSaveOnLog := True;
  FInterval := AInterval;
  FDateTimeFormat := ADateTimeFormat;
  FInitialized := False;
  FEncoding := TEncoding.UTF8;
  FOnLog := nil;
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
    FLog.SaveToFile(FFileName, FEncoding);
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

{ TLanguageRegistry }

procedure TAkLanguageRegistry.Add(const ALanguage: TLanguage);
begin
  Assert(ALanguage.Id <> '', 'Languages must have non-empty ID.');
  Assert(ALanguage.Index > -1, 'Languages must have non-negative Index.');

  Assert(not IsIn(ALanguage), Format('There is already a language with ID "%s" or index %d.', [ALanguage.Id, ALanguage.Index]));

  // if it's the first add on the registry, mark it as the default language
  // for the application, the user can always edit it later
  if Length(FLanguages) = 0 then
    FDefaultLanguageIndex := 0;

  SetLength(FLanguages, Length(FLanguages) + 1);
  FLanguages[Length(FLanguages) - 1] := ALanguage;
end;

procedure TAkLanguageRegistry.Add(const ALanguages: array of TLanguage);
var
  I: Integer;
begin
  for I := 0 to Length(ALanguages) - 1 do
    Add(ALanguages[I]);
end;

procedure TAkLanguageRegistry.AfterConstruction;
begin
  inherited;
  // avoid any access violation problem if a config file is not set.
  Add(TLanguage.Create('en', 'English', 10000));
end;

procedure TAkLanguageRegistry.Clear;
begin
  SetLength(FLanguages, 0);
end;

destructor TAkLanguageRegistry.Destroy;
begin
  SetLength(FLanguages, 0);
  FreeAndNil(FInstance);
  inherited;
end;

function TAkLanguageRegistry.FindLanguageById(const AId: string): TLanguage;
var
  LIndex: Integer;
begin
  Result := TLanguage.Create('', '', -1);
  LIndex := LanguageIndex(AId);
  if LIndex > -1 then
    Result := FLanguages[LIndex];
end;

function TAkLanguageRegistry.FindLanguageByColumn(const AIndex: Integer): TLanguage;
var
  LIndex: Integer;
begin
  Result := TLanguage.Create('', '', -1);
  LIndex := LanguageIndex(AIndex);
  if LIndex > -1 then
    Result := FLanguages[LIndex];
end;

procedure TAkLanguageRegistry.ForEach(const AProc: TProc<TLanguage>);
var
  I: Integer;
begin
  for I := 0 to Length(FLanguages) - 1 do
    AProc(FLanguages[I]);
end;

class function TAkLanguageRegistry.GetConfigFileName: TFileName;
begin
  Result := FConfigFileName;
end;

function TAkLanguageRegistry.GetDefaultLanguage: TLanguage;
begin
  Result := FLanguages[FDefaultLanguageIndex];
end;

class function TAkLanguageRegistry.GetInstance: TAkLanguageRegistry;
begin
  if FInstance = nil then
    FInstance := TAkLanguageRegistry.Create;
  Result := FInstance;
end;

function TAkLanguageRegistry.GetLanguageById(const AId: string): TLanguage;
begin
  Result := FindLanguageById(AId);
  if Result.Id = '' then
    raise Exception.CreateFmt('Language with ID "%s" not found.', [AId]);
end;

function TAkLanguageRegistry.GetLanguageByColumn(const AIndex: Integer): TLanguage;
begin
  Result := FindLanguageByColumn(AIndex);
  if Result.Id = '' then
    raise Exception.CreateFmt('Language with index %d not found.', [AIndex]);
end;

function TAkLanguageRegistry.LanguageIndex(const AIndex: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(FLanguages) - 1 do
    if FLanguages[I].Index = AIndex then
      Result := I;
end;

function TAkLanguageRegistry.LanguageIndex(const ALanguage: TLanguage): Integer;
begin
  Result := LanguageIndex(ALanguage.Id);
  if Result < 0 then
    Result := LanguageIndex(ALanguage.Index);
end;

function TAkLanguageRegistry.LanguageIndex(const AId: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(FLanguages) - 1 do
    if SameText(FLanguages[I].Id, AId) then
      Result := I;
end;

function TAkLanguageRegistry.IsDefaultLanguage(const ALanguage: TLanguage): Boolean;
begin
  Result := LanguageIndex(ALanguage) = FDefaultLanguageIndex;
end;

function TAkLanguageRegistry.IsDefaultLanguage(const AId: string): Boolean;
begin
  Result := LanguageIndex(AId) = FDefaultLanguageIndex;
end;

function TAkLanguageRegistry.IsDefaultLanguage(const AIndex: Integer): Boolean;
begin
  Result := LanguageIndex(AIndex) = FDefaultLanguageIndex;
end;

function TAkLanguageRegistry.IsIn(const AIndex: Integer): Boolean;
begin
  Result := LanguageIndex(AIndex) > -1;
end;

class procedure TAkLanguageRegistry.Iterate(const AProc: TProc<TLanguage>);
begin
  Instance.ForEach(AProc);
end;

class procedure TAkLanguageRegistry.Iterate(const ALanguages: array of TLanguage;
  const AProc: TProc<TLanguage>);
var
  I: Integer;
begin
  for I := 0 to Length(ALanguages) - 1 do
    Instance.Add(ALanguages[I]);
  Instance.ForEach(AProc);
end;

function TAkLanguageRegistry.IsIn(const AId: string): Boolean;
begin
  Result := LanguageIndex(AId) > -1;
end;

function TAkLanguageRegistry.IsIn(const ALanguage: TLanguage): Boolean;
begin
  Result := LanguageIndex(ALanguage) > -1;
end;

class procedure TAkLanguageRegistry.SetConfigFileName(const AFileName: TFileName);
begin
  Instance.FConfigFileName := AFileName;
  Instance.ReadFromConfig;
end;

procedure TAkLanguageRegistry.SetDefaultLanguage(const ALanguage: TLanguage);
begin
  if not IsIn(ALanguage) then
    raise Exception.CreateFmt('No language with ID "%s" found, cannot set it as default.', [ALanguage.Id]);
  FDefaultLanguageIndex := LanguageIndex(ALanguage);
end;

procedure TAkLanguageRegistry.ReadFromConfig;
var
  LConfigCsv: TCsv;
begin
  Assert(FileExists(FConfigFileName), Format('Dictionary file "%s" not found.', [FConfigFileName]));
  Clear;
  LConfigCsv := TCsv.Create(FConfigFilename);
  try
    Assert(LConfigCsv.ColumnCount > 2, 'Languages config file must have at least 3 columns.');
    if LConfigCsv.ColumnCount = 3 then
      LConfigCsv.ForEach([0, 1, 2],
        procedure(const AValues: TArray<string>)
        begin
          Add(TLanguage.Create(AValues[0], AValues[1], StrToInt(AValues[2])));
        end
      )
    else
      LConfigCsv.ForEach([0, 1, 2, 3],
        procedure(const AValues: TArray<string>)
        begin
          Add(TLanguage.Create(AValues[0], AValues[1], StrToInt(AValues[2]), AValues[3]));
        end
      );
  finally
    LConfigCsv.Free;
  end;
end;

{ TLanguage }

constructor TLanguage.Create(const AId, ADescription: string;
  const AIndex: Integer; const AFontName: string);
begin
  Id := AId;
  Description := ADescription;
  Index := AIndex;
  FontName := AFontName;
end;

end.
