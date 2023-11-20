unit RendererConsole;

interface

uses
  SysUtils, Classes,
  AkUtils, CsvParser, PokeParser, PokepasteProcessor;

const
  amSingle = 'S';
  amFile = 'F';

type
  TRendererConsole = class
  strict private
    FAppMode: Char;
    FDataFileNames: array of TFileName;
    FResourcesPath: string;
    FAssetsPath: string;
    FDataPath: string;
    FColorPaletteName: string;
    FOTSLanguageId: string;
    FCsvColumnNames: array of string;
    FCsvColumnDefinitions: array of string;
    FCsvDelimiter: Char;
    FCsvDateFormat: string;
    FOutputPath: string;
    FOutputTypes: TStringList;
    FOutputs: string;
    FErrors: string;
    FPokepaste: TPokepaste;
    FLogger: TAkLogger;
    FLogOwner: Boolean;
    FInputFileName: TFileName;
    FSingleInput: TInput;
    FOnRender: TFunc<TPokepaste, TInput, string, Boolean>;
    FAfterRender: TProc<TPokepaste, TInput, string, TFileName>;
    FOnInput: TFunc<TPokepaste, TInput, Boolean>;
    FAfterInput: TProc<TPokepaste, TInput, string>;
    FOnError: TProc<TPokepaste, TInput, Exception>;
    procedure CheckAndFormatOutputTypes;
    procedure SetOTSLanguage(const ALanguage: TLanguage);
    function GetOTSLanguage: TLanguage;
    function GetSettings: string;
    procedure RunByFile(const AProcessor: TPokepasteProcessor);
    procedure RunByInput(const AProcessor: TPokepasteProcessor);
  public
    property ResourcesPath: string read FResourcesPath;
    property AppMode: Char read FAppMode write FAppMode;
    property ColorPaletteName: string read FColorPaletteName write FColorPaletteName;
    property OTSLanguage: TLanguage read GetOTSLanguage write SetOTSLanguage;
    property OutputPath: string read FOutputPath write FOutputPath;
    property InputFileName: TFileName read FInputFileName write FInputFileName;
    property SingleInput: TInput read FSingleInput write FSingleInput;
    property Settings: string read GetSettings;

    /// <summary>
    ///  This function will be set as the OnRender property of the
    ///  PokepasteProcessor instance used to perform rendering (see documentation
    ///  on the PokepasteProcessor unit).
    /// </summary>
    property OnRender: TFunc<TPokepaste, TInput, string, Boolean> write FOnRender;

    /// <summary>
    ///  This function will be set as the AfterRender property of the
    ///  PokepasteProcessor instance used to perform rendering (see documentation
    ///  on the PokepasteProcessor unit).
    /// </summary>
    property AfterRender: TProc<TPokepaste, TInput, string, TFileName> write FAfterRender;

    /// <summary>
    ///  This function will be set as the OnInput property of the
    ///  PokepasteProcessor instance used to perform rendering (see documentation
    ///  on the PokepasteProcessor unit).
    /// </summary>
    property OnInput: TFunc<TPokepaste, TInput, Boolean> write FOnInput;

    /// <summary>
    ///  This function will be set as the AfterInput property of the
    ///  PokepasteProcessor instance used to perform rendering (see documentation
    ///  on the PokepasteProcessor unit).
    /// </summary>
    property AfterInput: TProc<TPokepaste, TInput, string> write FAfterInput;

    /// <summary>
    ///  This function will be set as the OnError property of the
    ///  PokepasteProcessor instance used to perform rendering (see documentation
    ///  on the PokepasteProcessor unit).
    /// </summary>
    property OnError: TProc<TPokepaste, TInput, Exception> write FOnError;

    constructor Create(const AConfigFileName: TFileName;
      const APokepaste: TPokepaste; const ALogger: TAkLogger = nil);
    procedure Run;
  end;

implementation

uses
  IniFiles;

{ TRendererConsole }

procedure TRendererConsole.CheckAndFormatOutputTypes;
var
  LSupportedOutputs: TStringList;
  I: Integer;
begin
  LSupportedOutputs := TStringList.Create;
  try
    LSupportedOutputs.Text := SUPPORTED_OUTPUTS;
    for I := FOutputTypes.Count - 1 downto 0 do
      if LSupportedOutputs.Contains(FOutputTypes[I]) < 0 then
        if SameText(FOutputTypes[I], 'pdf') then
          FOutputTypes[I] := 'PDF_OTS'
        else
          FOutputTypes.Delete(I);
  finally
    LSupportedOutputs.Free;
  end;
end;

constructor TRendererConsole.Create(const AConfigFileName: TFileName;
  const APokepaste: TPokepaste; const ALogger: TAkLogger);
var
  LConfig: TMemIniFile;
  I: Integer;

  function Read(const ASection, AIdent: string; ADefault: string = ''): string;
  begin
    Result := LConfig.ReadString(ASection, AIdent, ADefault);
  end;

  function ReadExpanded(const ASection, AIdent, ADefault: string; const IsPath: Boolean = True): string;
  var
    LValue: string;
  begin
    LValue := Read(ASection, AIdent, ADefault);
    Result := StringReplace(LValue, '%app%', AppPath, [rfReplaceAll, rfIgnoreCase]);
    if IsPath then
      Result := IncludeTrailingPathDelimiter(Result);
  end;

  procedure ReadCsvColumnList;
  var
    LList: TStringList;
    LDeleteIndex: Integer;
    J: Integer;
  begin
    LList := TStringList.Create;
    try
      LConfig.ReadSection('InputCSV', LList);

      // remove non-column infos
      LDeleteIndex := LList.IndexOf('Delimiter');
      if LDeleteIndex > -1 then
        LList.Delete(LDeleteIndex);
      LDeleteIndex := LList.IndexOf('DateFormat');
      if LDeleteIndex > -1 then
        LList.Delete(LDeleteIndex);

      SetLength(FCsvColumnNames, LList.Count);
      SetLength(FCsvColumnDefinitions, LList.Count);
      for J := 0 to LList.Count - 1 do
      begin
        FCsvColumnDefinitions[J] := LList[J];
        FCsvColumnNames[J] := Read('InputCSV', LList[J]);
      end;
    finally
      LList.Free;
    end;
  end;

begin
  Assert(FileExists(AConfigFileName), Format('Config file "%s" does not exists.', [AConfigFileName]));
  Assert(Assigned(APokepaste), 'Pokepaste is not assigned.');

  FPokepaste := APokepaste;
  SetLength(FDataFileNames, Length(DATA_ITEMS));
  FOutputTypes := TStringList.Create;
  FLogger := ALogger;
  if not Assigned(FLogger) then
  begin
    FLogger := TAkLogger.CreateAndInit('ConsoleRun', IncludeTrailingPathDelimiter(AppPath + 'Log') + AppTitle + 'Log');
    FLogOwner := True;
  end
  else
    FLogOwner := False;

  FLogger.Log('Reading configuration file "%s".', [AConfigFileName]);
  LConfig := TMemIniFile.Create(AConfigFileName);
  try
    LConfig.CaseSensitive := False;
    // Load resources
    FResourcesPath := ReadExpanded('Resources', 'Path', '%app%Resources');
    FAssetsPath := ReadExpanded('Resources', 'Assets', FResourcesPath + 'Assets');
    FDataPath := ReadExpanded('Resources', 'Data', FResourcesPath + 'Data');
    for I := 0 to Length(FDataFileNames) - 1 do
      FDataFileNames[I] := FDataPath + Read('Resources', DATA_ITEMS[I] + 'FileName', DATA_ITEMS[I] + '.csv');

    // Load settings
    FColorPaletteName := Read('Settings', 'ColorPalette', 'blue');
    FOTSLanguageId := Read('Settings', 'OTSLanguage', 'en');

    // Load input CSV infos
    ReadCsvColumnList;
    FCsvDelimiter := Read('InputCSV', 'Delimiter', ',')[1];
    FCsvDateFormat := Read('InputCSV', 'DateFormat', 'yyyymmdd');

    // Load output
    FOutputPath := ReadExpanded('Output', 'Path', '%app%Output');
    FOutputTypes.Delimiter := ',';
    FOutputTypes.StrictDelimiter := False;
    FOutputTypes.DelimitedText := Read('Output', 'Formats', 'HTML PNG PDF_OTS PDF_CTS');
    CheckAndFormatOutputTypes;
  finally
    LConfig.Free;
  end;
  FAppMode := #0;
  FOnRender := nil;
  FAfterRender := nil;
  FLogger.Log('Configuration correctly loaded:' + sLineBreak + Settings);
end;

function TRendererConsole.GetOTSLanguage: TLanguage;
begin
  TAkLanguageRegistry.Instance[FOTSLanguageId];
end;

function TRendererConsole.GetSettings: string;
var
  LConfigList: string;

  function StrConcat(const ANames, AValues: array of string; const AIndent: Integer = 0): string;
  var
    I: Integer;
  begin
    Assert(Length(ANames) = Length(AValues), 'Names and values have different lengths.');
    for I := 0 to Length(ANames) - 1 do
      Result := Result + StringOfChar(' ', AIndent) + ANames[I] + ': ' + AValues[I] + sLineBreak;
  end;

begin
  LConfigList := StrConcat(['Resources path', 'Assets path', 'Data path',
    'Color palette', 'OTS Language', 'Output path', 'Output types',
    'Input CSV delimiter', 'Input CSV date format', 'Input CSV columns'],
    [FResourcesPath, FAssetsPath, FDataPath,
    FColorPaletteName, FOTSLanguageId, FOutputPath, FOutputTypes.DelimitedText,
    FCsvDelimiter, FCsvDateFormat, '']);
  LConfigList := LConfigList + StrConcat(FCsvColumnDefinitions, FCsvColumnNames, 2);
  case AppMode of
    amSingle: Result := StrConcat(
      ['Manual input mode', 'Name', 'Surname', 'Paste',
      'Trainer name in game', 'Battle team name', 'Switch profile',
      'Player ID', 'Birth date',
      'Game language ID'],
      ['given data', SingleInput.Name, SingleInput.Surname, SingleInput.Link,
      SingleInput.TrainerName, SingleInput.BattleTeam, SingleInput.Profile,
      SingleInput.PlayerId, FormatDateTime('yyyymmdd', SingleInput.BirthDate),
      SingleInput.GameLanguageId]);
    amFile: Result := StrConcat(['File input mode, given file'], [InputFileName]);
  end;
  Result := Result + LConfigList;
end;

procedure TRendererConsole.Run;
var
  LProcessor: TPokepasteProcessor;
begin
  Assert(FAppMode <> #0, 'Application input mode has not been set.');

  LProcessor := TPokepasteProcessor.Create(FDataFileNames, FAssetsPath,
    ColorPaletteName, OutputPath, FPokepaste, FOutputTypes.Text, FLogger);
  try
    LProcessor.OTSLanguage := FOTSLanguageId;
    LProcessor.StopOnErrors := False;
    LProcessor.OnRender := FOnRender;
    LProcessor.AfterRender := FAfterRender;
    LProcessor.OnError := FOnError;
    case AppMode of
      amSingle: RunByInput(LProcessor);
      amFile: RunByFile(LProcessor);
      else
        raise Exception.CreateFmt('Unrecognized application input mode "%s"', [FAppMode]);
    end;
  finally
    LProcessor.Free;
  end;
end;

procedure TRendererConsole.RunByFile(const AProcessor: TPokepasteProcessor);
var
  LInputFile: TCsv;
  LNameList: string;
begin
  Assert(Assigned(AProcessor));
  Assert(FileExists(InputFileName));

  LInputFile := TCsv.Create(InputFileName, FCsvDelimiter, True);
  try
    FOutputs := AProcessor.CreateFromFile(LInputFile, FCsvColumnDefinitions,
      FCsvColumnNames, LNameList, FErrors);
  finally
    LInputFile.Free;
  end;
end;

procedure TRendererConsole.RunByInput(const AProcessor: TPokepasteProcessor);
begin
  Assert(Assigned(AProcessor));
  Assert(SingleInput.Valid);

  FOutputs := AProcessor.CreateFromSingleInput(SingleInput, FErrors);
end;

procedure TRendererConsole.SetOTSLanguage(const ALanguage: TLanguage);
begin
  FOTSLanguageId := ALanguage.Id;
end;

end.
