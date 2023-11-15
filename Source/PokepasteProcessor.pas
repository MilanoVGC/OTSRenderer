unit PokepasteProcessor;

interface

uses
  SysUtils, Classes,
  PokeParser, AkUtils, CsvParser;

const
  SUPPORTED_OUTPUTS = 'HTML' + sLineBreak +
    'PNG' + sLineBreak +
    'PDF_OTS' + sLineBreak +
    'PDF_CTS';
type
  TInput = record
    Name: string;
    Surname: string;
    Link: TUrl;
    TrainerName: string;
    BattleTeam: string;
    Profile: string;
    PlayerId: string;
    BirthDate: TDateTime;
    GameLanguageId: string;
    function FullName: string;
    constructor Create(const AName, ASurname, ALink: string;
      const ATrainerName: string = ''; const ABattleTeam: string = '';
      const AProfile: string = ''; const APlayerId: string = '';
      const AGameLanguageId: string = '';
      const ABirthDate: TDateTime = NULL_DATETIME);
    constructor CreateFromOrderedValues(const AValues: array of string;
      const ADateFormat: string);
    constructor CreateFromNamedValues(const ANames, AValues: array of string;
      const ADateFormat: string);
  end;

  TPokepasteProcessor = class
  strict private
    FDataFiles: array of TFileName;
    FAssetsPath: string;
    FColorPaletteName: string;
    FOTSLanguageId: string;
    FGameLanguageId: string;
    FOutputPath: string;
    FPokepaste: TPokepaste;
    FOutputList: string;
    FOutputs: TStringList;
    FLog: TAkLogger;
    FLogOwner: Boolean;
    FOnRender: TFunc<TPokepaste, TInput, Boolean>;
    FAfterRender: TProc<TPokepaste, TInput, string>;
    FStopOnErrors: Boolean;
    procedure CreateFromInput(const AInput: TInput; var AErrors: string;
      const AOutputs: TStringList = nil);
    procedure ResetOutputs;
    procedure SetOutputs(const AOutputList: string);
    function GetOutput(const AOutputName: string): Boolean;
    function Print(const AOutputType: string): string;
  public
    property OTSLanguage: string read FOTSLanguageId write FOTSLanguageId;
    property GameLanguage: string read FGameLanguageId write FGameLanguageId;
    property OutputPath: string read FOutputPath;
    property Output[const AOutputName: string]: Boolean read GetOutput;
    property Outputs: string read FOutputList write SetOutputs;

    /// <summary>
    ///  The function that will be called before rendering but after having
    ///  loaded the pokepaste (which is given to the function).
    ///  The rendering will be affected by any edit done either on the pokepaste
    ///  or the input in this function.
    ///  If the result of the function is False, the rendering of the pokepaste
    ///  will be skipped.
    /// </summary>
    property OnRender: TFunc<TPokepaste, TInput, Boolean> write FOnRender;

    /// <summary>
    ///  The function that will be called after rendering occurs.
    ///  The pokepaste and the input are editable without affecting the rendering.
    ///  The output file names (without the path) are given as a list separed
    ///  by line breaks.
    /// </summary>
    property AfterRender: TProc<TPokepaste, TInput, string> write FAfterRender;

    /// <summary>
    ///  Determines if exceptions catched during the rendering process are
    ///  to be logged and raised or just logged.
    /// </summary>
    property StopOnErrors: Boolean read FStopOnErrors write FStopOnErrors;

    /// <summary>
    ///  The basic constructor with the needed resources. The pokepaste must
    ///  have previously been initialized: this is because this class is a general
    ///  utility tool, while there may be multiple different pokepaste class
    ///  implementations (using VCL or FMX, for example).
    ///  The idea is to use this unit across multiple children types of pokepaste
    ///  without having to worry casting.
    /// </summary>
    constructor Create(const ADataFiles: array of TFileName;
      const AAssetsPath, AColorPaletteName, AOutputPath: string; const APokepaste: TPokepaste;
      const AOutputList: string = SUPPORTED_OUTPUTS; const ALog: TAkLogger = nil);

    /// <summary>
    ///  Renders the outputs (specified on Create) reading and loading the pokepaste
    ///  from a given CSV file. If a list of full names is given, it appends a
    ///  index on every full name already present on the list.
    ///  Returns the list of outputted files and fills AErrors with the list of
    ///  exception that are raised, both lists are separated by a line break.
    /// </summary>
    function CreateFromFile(const ACsvFile: TCsv; const AColumnDefinitions, AColumnNames: array of string;
      var AFullNameList: string; var AErrors: string): string;

    /// <summary>
    ///  Renders the outputs (specified on Create) reading and loading the pokepaste
    ///  from a given TInput array. If a list of full names is given, it appends a
    ///  index on every full name already present on the list.
    ///  Returns the list of outputted files and fills AErrors with the list of
    ///  exception that are raised, both lists are separated by a line break.
    /// </summary>
    function CreateFromInputList(var AInputList: array of TInput;
      var AFullNameList: string; var AErrors: string): string;

    /// <summary>
    ///  Renders the outputs (specified on Create) reading and loading the pokepaste
    ///  from a given TInput.
    ///  Returns the list of outputted files and fills AErrors with the list of
    ///  exception that are raised, both lists are separated by a line break.
    /// </summary>
    function CreateFromSingleInput(const AInput: TInput; var AErrors: string): string;

    destructor Destroy; override;
  end;


function OutputExt(const AOutputType: string): string;

implementation

function OutputExt(const AOutputType: string): string;
begin
  Result := '.' + AnsiLowerCase(AOutputType);
  if Pos('PDF', AnsiUpperCase(AOutputType)) > 0 then
    Result := '.pdf';
end;

{ TInput }

constructor TInput.Create(const AName, ASurname, ALink: string;
  const ATrainerName, ABattleTeam, AProfile, APlayerId, AGameLanguageId: string;
  const ABirthDate: TDateTime);
begin
  Name := AName;
  Surname := ASurname;
  Link := ALink;
  TrainerName := ATrainerName;
  BattleTeam := ABattleTeam;
  Profile := AProfile;
  PlayerId := APlayerId;
  BirthDate := ABirthDate;
  if TAkLanguageRegistry.Instance.IsIn(AGameLanguageId) then
    GameLanguageId := AGameLanguageId
  else
    GameLanguageId := TAkLanguageRegistry.Instance.DefaultLanguage.Id;
end;

constructor TInput.CreateFromNamedValues(const ANames, AValues: array of string;
  const ADateFormat: string);

  function EvalValue(const AName: string): string;
  var
    I: Integer;
  begin
    Result := '';
    for I := 0 to Length(ANames) - 1 do
    begin
      if SameText(Trim(ANames[I]), Trim(AName)) then
        Result := AValues[I];
    end;
  end;
begin
  Name := EvalValue('Name');
  Surname := EvalValue('Surname');
  Link := EvalValue('Paste');
  TrainerName := EvalValue('TrainerName');
  BattleTeam := EvalValue('BattleTeam');
  Profile := EvalValue('Profile');
  PlayerId := EvalValue('PlayerId');
  BirthDate := StringToDate(EvalValue('BirthDate'), ADateFormat);
  GameLanguageId := EvalValue('GameLanguage');
end;

constructor TInput.CreateFromOrderedValues(const AValues: array of string;
  const ADateFormat: string);

  function EvalValue(const AIndex: Integer): string;
  begin
    Result := '';
    if AIndex < Length(AValues) then
      Result := AValues[AIndex];
  end;
begin
  Name := AValues[0];
  Surname := AValues[1];
  Link := AValues[2];
  TrainerName := EvalValue(3);
  BattleTeam := EvalValue(4);
  Profile := EvalValue(5);
  PlayerId := EvalValue(6);
  BirthDate := StringToDate(EvalValue(7), ADateFormat);
  GameLanguageId := EvalValue(8);
end;

function TInput.FullName: string;
begin
  Result := CapitalFirst(Name) + ' ' + CapitalFirst(Surname);
end;

{ TPokepasteProcessor }

constructor TPokepasteProcessor.Create(const ADataFiles: array of TFileName;
  const AAssetsPath, AColorPaletteName, AOutputPath: string; const APokepaste: TPokepaste;
  const AOutputList: string; const ALog: TAkLogger);
var
  I: Integer;
begin
  Assert(Assigned(APokepaste));
  SetLength(FDataFiles, Length(ADataFiles));
  for I := 0 to Length(ADataFiles) - 1 do
    FDataFiles[I] := ADataFiles[I];

  FAssetsPath := AAssetsPath;
  FColorPaletteName := AColorPaletteName;
  FOutputPath := AOutputPath;
  FPokepaste := APokepaste;
  Outputs := AOutputList;
  FStopOnErrors := True;
  FLog := ALog;
  FLogOwner := False;
  if FOutputPath = '' then
    FOutputPath := IncludeTrailingPathDelimiter(AppPath + 'Output');
  if not MakeDir(FOutputPath) then
    raise Exception.CreateFmt('Could not create directory "%s", try creating it manually.', [FOutputPath]);
  if not Assigned(FLog) then
  begin
    FLog := TAkLogger.CreateAndInit(AppTitle, IncludeTrailingPathDelimiter(AppPath + 'Log') + AppTitle,
      'Y', 'dd-mm-yy_hh:nn:ss');
    FLogOwner := True;
  end;
end;

function TPokepasteProcessor.CreateFromFile(const ACsvFile: TCsv;
  const AColumnDefinitions, AColumnNames: array of string;
  var AFullNameList: string; var AErrors: string): string;
var
  LOutputs: TStringList;
  LFullNames: TStringList;
  LColumnDefinitions: TArray<string>;
  LDuplicateIndex: Integer;
  LErrors: string;
begin
  Assert(Assigned(ACsvFile), 'Input file has not been initialized.');
  LColumnDefinitions := StrArrayClone(AColumnDefinitions);
  LErrors := AErrors;
  LOutputs := TStringList.Create;
  LFullNames := TStringList.Create;
  try
    LFullNames.Text := AFullNameList;
    ACsvFile.ForEach(AColumnNames,
      procedure(const AValues: TArray<string>)
      var
        LInput: TInput;
      begin
        LInput := TInput.CreateFromNamedValues(LColumnDefinitions, AValues, ACsvFile.DateFormat);
        LDuplicateIndex := 1;
        while LFullNames.IndexOf(LInput.FullName) >= 0 do
        begin
          Inc(LDuplicateIndex);
          if LDuplicateIndex = 2 then
            LInput.Surname := LInput.Surname + '_2'
          else
            LInput.Surname := StringReplace(LInput.Surname,
              '_' + IntToStr(LDuplicateIndex - 1),  '_' + IntToStr(LDuplicateIndex), [rfIgnoreCase]);
        end;
        LFullNames.Add(LInput.FullName);
        FLog.Log('Processing file entry ' + LInput.FullName + ' - ' + LInput.Link);
        CreateFromInput(LInput, LErrors, LOutputs);
      end
    );
    Result := LOutputs.Text;
    AErrors := LErrors;
  finally
    LOutputs.Free;
    AFullNameList := LFullNames.Text;
    LFullNames.Free;
  end;
end;

procedure TPokepasteProcessor.CreateFromInput(const AInput: TInput; var AErrors: string;
  const AOutputs: TStringList);
var
  LOutput: string;
  LDoIt: Boolean;
  LOutputType: string;
  LErrorText: string;
begin
  try
    FPokepaste.LoadPokepaste(AInput.Link, FDataFiles, FAssetsPath);
    FPokepaste.Owner := AInput.FullName;
    FPokepaste.TrainerName := AInput.TrainerName;
    FPokepaste.BattleTeam := AInput.BattleTeam;
    FPokepaste.Profile := AInput.Profile;
    FPokepaste.PlayerId := AInput.PlayerId;
    FPokepaste.BirthDate := AInput.BirthDate;
  except
    on E: Exception do
    begin
      LErrorText := Format('Loading Pokepaste of "%s": %s', [AInput.FullName, E.Message]);
      FLog.Log('ERROR - ' + LErrorText);
      AErrors := AErrors + LErrorText + sLineBreak;
      if StopOnErrors then
        raise Exception.Create(LErrorText);
    end;
  end;
  if Assigned(FOnRender) then
    LDoIt := FOnRender(FPokepaste, AInput)
  else
    LDoIt := True;
  if not LDoIt then
  begin
    FLog.Log('Skipped ' + AInput.FullName + '.');
    Exit;
  end;
  for LOutputType in FOutputs do
  begin
    try
      GameLanguage := AInput.GameLanguageId;
      LOutput := Print(LOutputType);
      if LOutput <> '' then
      begin
        FLog.Log('Processed ' + AInput.FullName + ' -> ' + LOutput);
        if Assigned(AOutputs) then
          AOutputs.Add(ExtractFileName(LOutput));
      end;
    except
      on E: Exception do
      begin
        LErrorText := Format('Rendering %s of "%s": %s', [LOutputType, AInput.FullName, E.Message]);
        FLog.Log('ERROR - ' + LErrorText);
        AErrors := AErrors + LErrorText + sLineBreak;
        if StopOnErrors then
          raise Exception.Create(LErrorText);
      end;
    end;
  end;
  if Assigned(FAfterRender) then
    FAfterRender(FPokepaste, AInput, AOutputs.Text);
end;

function TPokepasteProcessor.CreateFromInputList(var AInputList: array of TInput;
  var AFullNameList: string; var AErrors: string): string;
var
  LOutputs: TStringList;
  LFullNames: TStringList;
  LDuplicateIndex: Integer;
  I: Integer;
begin
  LOutputs := TStringList.Create;
  LFullNames := TStringList.Create;
  try
    LFullNames.Text := AFullNameList;
    for I := 0 to Length(AInputList) - 1 do
    begin
      LDuplicateIndex := 1;
      while LFullNames.IndexOf(AInputList[I].FullName) >= 0 do
      begin
        Inc(LDuplicateIndex);
        if LDuplicateIndex = 2 then
          AInputList[I].Surname := AInputList[I].Surname + '_2'
        else
          AInputList[I].Surname := StringReplace(AInputList[I].Surname,
            '_' + IntToStr(LDuplicateIndex - 1),  '_' + IntToStr(LDuplicateIndex), [rfIgnoreCase]);
      end;
      LFullNames.Add(AInputList[I].FullName);
      FLog.Log('Processing manual entry ' + AInputList[I].FullName + ' - ' + AInputList[I].Link);
      CreateFromInput(AInputList[I], AErrors, LOutputs);
    end;
    Result := LOutputs.Text;
  finally
    LOutputs.Free;
    AFullNameList := LFullNames.Text;
    LFullNames.Free;
  end;
end;

function TPokepasteProcessor.CreateFromSingleInput(const AInput: TInput;
  var AErrors: string): string;
var
  LOutput: TStringList;
begin
  LOutput := TStringList.Create;
  try
    CreateFromInput(AInput, AErrors, LOutput);
    Result := LOutput.Text;
  finally
    LOutput.Free;
  end;
end;

destructor TPokepasteProcessor.Destroy;
begin
  if Assigned(FLog) and FLogOwner then
    FLog.Free;
  if Assigned(FOutputs) then
    FOutputs.Free;
  inherited;
end;

function TPokepasteProcessor.GetOutput(const AOutputName: string): Boolean;
begin
  Result := FOutputs.Contains(AOutputName) > -1;
end;

function TPokepasteProcessor.Print(const AOutputType: string): string;
begin
  Result := '';
  if SameText(AOutputType, 'HTML') then
    Result := FPokepaste.PrintHtml(FColorPaletteName, FOutputPath)
  else if SameText(AOutputType, 'PNG') then
    Result := FPokepaste.PrintPng(FColorPaletteName, FOutputPath)
  else if SameText(AOutputType, 'PDF_OTS') then
    Result := FPokepaste.PrintOpenPdf(OTSLanguage, FOutputPath)
  else if SameText(AOutputType, 'PDF_CTS') then
    Result := FPokepaste.PrintClosedPdf(GameLanguage, FOutputPath)
  else
    raise Exception.CreateFmt('Unknown output type "%s"', [AOutputType]);
end;

procedure TPokepasteProcessor.ResetOutputs;
begin
  if Assigned(FOutputs) then
    FreeAndNil(FOutputs);
  FOutputs := TStringList.Create;
  FOutputs.Text := FOutputList;
end;

procedure TPokepasteProcessor.SetOutputs(const AOutputList: string);
begin
  FOutputList := StringReplace(AOutputList, sLineBreak + sLineBreak, sLineBreak, [rfReplaceAll]);
  ResetOutputs;
end;

end.
