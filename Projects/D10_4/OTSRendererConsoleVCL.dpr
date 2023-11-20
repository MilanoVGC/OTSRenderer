program OTSRendererConsoleVCL;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  CsvParser in '..\..\Source\AkLib\CsvParser.pas',
  PokeParserVcl in '..\..\Source\PokeParserVcl.pas',
  PokepasteProcessor in '..\..\Source\PokepasteProcessor.pas',
  PokeParser in '..\..\Source\PokeParser.pas',
  AkUtils in '..\..\Source\AkLib\AkUtils.pas',
  AkUtilsVcl in '..\..\Source\AkLib\AkUtilsVcl.pas',
  PokeUtils in '..\..\Source\PokeUtils.pas',
  RendererConsole in '..\..\Source\RendererConsole.pas',
  TeamlistTemplateFrame in '..\..\Source\TeamlistTemplateFrame.pas',
  BilingualTeamlist in '..\..\Source\BilingualTeamlist.pas' {BilingualTemplate: TFrame},
  MonolingualTeamlist in '..\..\Source\MonolingualTeamlist.pas' {MonolingualTemplate: TFrame};

const
  HELP_TEXT = '***************************** OTSRendererConsoleVCL - by relder (twitter.com/relderVGC) ******************************' + sLineBreak +
    'Usage:' + sLineBreak +
    '  -c [configuration file name]' + sLineBreak +
    '    ## MANDATORY: - all the main settings are read from this file (resources path, input file info, ...) ##' + sLineBreak +
    '  -f [input file name]' + sLineBreak +
    '    ## ALTERNATIVE TO -n: executes the app in file mode: player and paste informations are read from the input file ##' + sLineBreak +
    '  -n [player''s name] -s [player''s surname] -u [player''s pokepaste URL] -t [player''s trainer name in game]' + sLineBreak +
    '    ## ALTERNATIVE TO -i: executes the app in manual mode: it renders only the single given pokepaste ##' + sLineBreak +
    '  -b [player''s battle team name/number] -p [player''s switch profile name]' + sLineBreak +
    '    ## OPTIONAL: further parameters for the manual mode run of the app (in file mode this options are ignored) ##' + sLineBreak +
    '  -i [player''s Player ID] -l [player''s game language ID] -d [player''s date of birth in YYYYMMDD format]' + sLineBreak +
    '    ## OPTIONAL: further parameters for the manual mode run of the app (in file mode this options are ignored) ##' + sLineBreak +
    '  -verbose' + sLineBreak +
    '    ## OPTIONAL - prints to the console the registered configuration and each processed file ##' + sLineBreak +
    '  -keep' + sLineBreak +
    '    ## OPTIONAL - prompts a line at the end of the run, before exiting from the application ##' + sLineBreak +
    '  -h or -help' + sLineBreak +
    '    ## shows this display ##' + sLineBreak +
    'Remarks:' + sLineBreak +
    '  Either "-f" or "-n" must be specified.' + sLineBreak +
    '  All of the parameters listed above are case insensitive.' + sLineBreak +
    '  Enclose one parameter in double quotes (") or use the %space% macro to include a space in it.' + sLineBreak +
    sLineBreak +
    '******************************************** Have fun with your pokepastes! *********************************************' + sLineBreak;

var
  LOutputHandle: THandle;
  LBufferInfo: TConsoleScreenBufferInfo;
  LVerbose: Boolean;
  LKeep: Boolean;
  LPokepaste: TPokepasteVcl;
  LLogger: TAkLogger;
  LConfigFileName: string;
  LRenderer: TRendererConsole;
  LAppMode: Char;
  LFileName: string;
  LSingle: TInput;
  LUrl: string;
  LBirthDateStr: string;

  procedure PrintHelp;
  var
    LHelpList: TStringList;
    LRemarks: Boolean;
    J: Integer;
  begin
    LRemarks := False;
    LHelpList := TStringList.Create;
    try
      LHelpList.Text := HELP_TEXT;
      for J := 0 to LHelpList.Count - 2 do
      begin
        if Pos('REMARKS', AnsiUpperCase(LHelpList[J])) > 0 then
          LRemarks := True;
        if (Pos('##', LHelpList[J]) > 0) and (Pos('##', LHelpList[J], Pos('##', LHelplist[J]) + 1) > 0) then
          SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY or FOREGROUND_BLUE)
        else if LRemarks then
          SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY or FOREGROUND_RED or FOREGROUND_GREEN)
        else
          SetConsoleTextAttribute(LOutputHandle, LBufferInfo.wAttributes);

        WriteLn(LHelpList[J]);
      end;
      SetConsoleTextAttribute(LOutputHandle, LBufferInfo.wAttributes);
      WriteLn(LHelpList[LHelpList.Count - 1]);
    finally
      LHelpList.Free;
    end;
  end;

  procedure Close(const AIsError: Boolean = False);
  begin
    if AIsError then
      WriteLn(Format('Execute %s -h for help.', [ParamStr(0)]));

    if LKeep then
    begin
      WriteLn('Press [ENTER] to exit.');
      ReadLn;
    end
    else
      WriteLn('Exiting...');

    if Assigned(LLogger) then
      LLogger.Free;
  end;

  procedure ReplaceSpace(var AString: string);
  begin
    AString := StringReplace(AString, '%space%', ' ', [rfReplaceAll, rfIgnoreCase]);
  end;

begin
  // Log creation
  LLogger := TAkLogger.Create('OTSRendererConsole',
    IncludeTrailingPathDelimiter(AppPath + 'Log') + AppTitle, 'Y',
    'yyyymmdd_hh:nn:ss');
  try
    // Basic setup
    WriteLn('');
    LOutputHandle := TTextRec(Output).Handle;
    GetConsoleScreenBufferInfo(LOutputHandle, LBufferInfo);
    LVerbose := FindCmdLineSwitch('verbose');
    LKeep := FindCmdLineSwitch('keep');

    // Help
    if (ParamCount = 0) or FindCmdLineSwitch('help') or FindCmdLineSwitch('H') then
    begin
      LKeep := True;
      PrintHelp;
      Close;
      Exit;
    end;

    // Check for config file parameter
    Assert(FindCmdLineSwitch('c', LConfigFileName), 'A configuration file must be provided.');

    // Setting AppMode and options
    if FindCmdLineSwitch('f', LFileName) and not FindCmdLineSwitch('n') then
      LAppMode := amFile
    else if FindCmdLineSwitch('n', LSingle.Name) then
    begin
      LAppMode := amSingle;
      ReplaceSpace(LSingle.Name);
      Assert(FindCmdLineSwitch('s', LSingle.Surname), '"-s" option must be provided when running manual mode.');
      ReplaceSpace(LSingle.Surname);
      Assert(FindCmdLineSwitch('u', LUrl), '"-u" option must be provided when running manual mode.');
      LSingle.Link := LUrl;
      Assert(FindCmdLineSwitch('t', LSingle.TrainerName), '"-t" option must be provided when running manual mode.');
      ReplaceSpace(LSingle.TrainerName);
      FindCmdLineSwitch('b', LSingle.BattleTeam);
      ReplaceSpace(LSingle.BattleTeam);
      FindCmdLineSwitch('p', LSingle.Profile);
      ReplaceSpace(LSingle.Profile);
      FindCmdLineSwitch('i', LSingle.PlayerId);
      FindCmdLineSwitch('l', LSingle.GameLanguageId);
      FindCmdLineSwitch('d', LBirthDateStr);
      LSingle.BirthDate := StringToDate(LBirthDateStr, 'yyyymmdd');
      Assert(LSingle.Valid, 'Mandatory options cannot be empty.');
    end
    else
      raise Exception.Create('Either "-f" or "-n" option must be provided.');

    // Starting the logger (no need to log option-broke runs...)
    LLogger.Initialize;

    TAkLanguageRegistry.Config := AppPath + 'languages.csv';

    LPokepaste := TPokepasteVcl.Create;
    LRenderer := TRendererConsole.Create(LConfigFileName, LPokepaste, LLogger);
    AddFontResource(PWideChar(LRenderer.ResourcesPath + 'SourceSansPro-Semibold.ttf'));
    AddFontResource(PWideChar(LRenderer.ResourcesPath + 'SimSun.ttf'));
    try
      // This is probably unnecessary, should test it in an environment where the font is not installed
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
      LRenderer.AppMode := LAppMode;
      LRenderer.SingleInput := LSingle;
      LRenderer.InputFileName := LFileName;
      if LVerbose then
      begin
        LRenderer.OnRender :=
          function(APokepaste: TPokepaste; AInput: TInput; AOutputType: string): Boolean
          begin
            WriteLn(Format('Processing %s output for entry "%s".', [AOutputType, AInput.FullName]));
            Result := True;
          end;
        LRenderer.AfterRender :=
          procedure(APokepaste: TPokepaste; AInput: TInput; AOutputType: string; AOutputName: TFileName)
          begin
            WriteLn(Format('Successfully processed %s output for entry "%s": %s.',
              [AOutputType, AInput.FullName, AOutputName]));
          end;
        LRenderer.OnError :=
          procedure(APokepaste: TPokepaste; AInput: TInput; AException: Exception)
          begin
            SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY or FOREGROUND_RED);
            WriteLn(Format('Error processing entry "%s": %s', [AInput.FullName, AException.Message]));
            SetConsoleTextAttribute(LOutputHandle, LBufferInfo.wAttributes);
          end;
        WriteLn(LRenderer.Settings);
      end;
      LRenderer.Run;
    finally
      LPokepaste.Free;
      LRenderer.Free;
      RemoveFontResource(PWideChar(LRenderer.ResourcesPath + 'SourceSansPro-Semibold.ttf'));
      RemoveFontResource(PWideChar(LRenderer.ResourcesPath + 'SimSun.ttf'));
    end;

    WriteLn('');
    WriteLn('All done!');
    WriteLn('');

    Close;

  except
    on E: Exception do
    begin
      if not LLogger.IsInitialized then
        LLogger.Initialize;
      LLogger.Log(E.Message);
      WriteLn(E.Message);
      Close(True);
      ExitCode := -1;
    end;
  end;
end.
