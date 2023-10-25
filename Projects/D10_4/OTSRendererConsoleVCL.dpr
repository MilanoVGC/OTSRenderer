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
  PokeUtils in '..\..\Source\PokeUtils.pas';

const
  HELP_TEXT = '****** OTSRendererConsoleVCL - by relder (github/relderDev) ******' + sLineBreak +
    'Main usage (one of the following options has to be used):' + sLineBreak +
    '  -i [input file name] -d [csv delimiter (default=",")] -m [column names (default="Name,Surname,Pokepaste OT")]' + sLineBreak +
    '    ## this executes the app in file mode: read names and URLs from the CSV file ##' + sLineBreak +
    '  -n [player''s name] -s [player''s surname] -u [player''s pokepaste URL]' + sLineBreak +
    '    ## this executes the app in manual mode: it renders only the single given pokepaste ##' + sLineBreak +
    'Main configurations (will be asked when not given on start):' + sLineBreak +
    '  -r [resources path]' + sLineBreak +
    '    ## path with data and assets folders ##' + sLineBreak +
    '  -c [color palette name]' + sLineBreak +
    '  -o [outputs format]' + sLineBreak +
    'Optional configurations:' + sLineBreak +
    '  -p [output path (default="[app folder]/Output")]' + sLineBreak +
    '  -fast' + sLineBreak +
    '    ## defaults all the configurations not set on start skipping the prompt to the user ##' + sLineBreak +
    '  -verbose' + sLineBreak +
    '    ## prints the registered configuration before executing ##' + sLineBreak +
    '  -slow' + sLineBreak +
    '    ## like -verbose but it also ask for confirmation before executing ##' + sLineBreak +
    '  -h or -help' + sLineBreak +
    '    ## shows this display ##' + sLineBreak +
    'Remarks:' + sLineBreak +
    '  If specifying the option for CSV delimiter (-d) enclose it in double quotes "".' + sLineBreak +
    '  All of the parameters listed above are case insensitive.' + sLineBreak +
    '  To include a space in a parameter enclose it in double quotes "" or use the %space% macro instead of the space character.' + sLineBreak +
    sLineBreak +
    '****** Have fun with your pokepastes! ******' + sLineBreak;

var
  LOutputHandle: THandle;
  LBufferInfo: TConsoleScreenBufferInfo;

  LAppMode: string;
  LFileName: string;
  LFile: TCsv;
  LDelimiter: string;
  LColumns: string;
  LColumnSplitter: TStringList;
  LColumnNames: array of string;
  LName: string;
  LSurname: string;
  LUrl: string;

  LResourcesPath: string;
  LColorPaletteName: string;
  LOutputPath: string;
  LOutputs: string;
  LHtmlOutput: Boolean;
  LPngOutput: Boolean;

  LAssetsPath: string;
  LDataFileNames: array of TFileName;

  LConfirm: string;

  LPokepaste: TPokepasteVcl;
  LPokepasteProcessor: TPokepasteProcessor;

  LOutput: string;
  LFullNameList: string;
  LErrors: string;
  I: Integer;

  procedure ReadInput(const AInputName, AInputDefault: string; var AVar: string);
  begin
    if FindCmdLineSwitch('Fast') then
    begin
      AVar := AInputDefault;
      Exit;
    end;
    WriteLn(Format('Please input the %s [default = "%s"])', [AInputName, AInputDefault]));
    ReadLn(AVar);
    if AVar = '' then
      AVar := AInputDefault;
  end;

  procedure ReplaceSpace(var AString: string);
  begin
    AString := StringReplace(AString, '%space%', ' ', [rfReplaceAll, rfIgnoreCase]);
  end;

  procedure PrintConfig;
  begin
    WriteLn('AppMode: ' + LAppMode);
    if SameText(LAppMode, 'File') then
    begin
      WriteLn('FileName: ' + LFileName);
      WriteLn('Delimiter: ' + LDelimiter);
      WriteLn('Columns: ' + LColumns);
    end
    else if SameText(LAppMode, 'Manual') then
    begin
      WriteLn('Name: ' + LName);
      WriteLn('Surname: ' + LSurname);
      WriteLn('Url: ' + LUrl);
    end;
    WriteLn('ResourcesPath: ' + LResourcesPath);
    WriteLn('AssetsPath: ' + LAssetsPath);
    WriteLn('ColorPaletteName: ' + LColorPaletteName);
    WriteLn('OutputPath: ' + LOutputPath);
    WriteLn('Outputs: ' + LOutputs);
    WriteLn('HtmlOutput: ' + BoolToStr(LHtmlOutput, True));
    WriteLn('PngOutput: ' + BoolToStr(LPngOutput, True));
  end;

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

  procedure PrintOutput;
  begin
    if LOutput <> '' then
    begin
      WriteLn('Execution completed with the following output(s):');
      WriteLn(LOutput);
    end;
    if LErrors <> '' then
    begin
      WriteLn('Execution has encountered the following error(s):');
      SetConsoleTextAttribute(TTextRec(Output).Handle, FOREGROUND_INTENSITY or FOREGROUND_RED);
      WriteLn(LErrors);
      SetConsoleTextAttribute(LOutputHandle, LBufferInfo.wAttributes);
    end;
    if FindCmdLineSwitch('Fast') then
      Exit;
    WriteLn('Run concluded, press [ENTER] to exit.');
    ReadLn;
  end;
begin
  try
    WriteLn('');
    LOutputHandle := TTextRec(Output).Handle;
    GetConsoleScreenBufferInfo(LOutputHandle, LBufferInfo);
    if ParamCount = 0 then
    begin
      PrintHelp;
      raise Exception.Create('Press [ENTER] to exit.');
    end;
    if FindCmdLineSwitch('Help') or FindCmdLineSwitch('H') then
    begin
      PrintHelp;
      Exit;
    end;
    if FindCmdLineSwitch('I', LFileName) then
    begin
      LAppMode := 'File';
      if not FindCmdLineSwitch('D', LDelimiter) then
        LDelimiter := ',';
      if not FindCmdLineSwitch('M', LColumns) then
        LColumns := 'Name,Surname,Pokepaste%space%OT';
      ReplaceSpace(LFileName);
      ReplaceSpace(LColumns);
      LColumnSplitter := TStringList.Create;
      try
        LColumnSplitter.Delimiter := ',';
        LColumnSplitter.StrictDelimiter := True;
        LColumnSplitter.DelimitedText := LColumns;
        SetLength(LColumnNames, LColumnSplitter.Count);
        for I := 0 to LColumnSplitter.Count - 1 do
          LColumnNames[I] := LColumnSplitter[I];
      finally
        LColumnSplitter.Free;
      end;
    end
    else if FindCmdLineSwitch('N', LName) and FindCmdLineSwitch('S', LSurname) and FindCmdLineSwitch('U', LUrl) then
    begin
      LAppMode := 'Manual';
      ReplaceSpace(LName);
      ReplaceSpace(LSurname);
    end
    else
      raise Exception.Create('Unrecognized pattern of parameters.');

    if not FindCmdLineSwitch('R', LResourcesPath) then
      ReadInput('resources path', AppPath + 'Resources', LResourcesPath);
    if not FindCmdLineSwitch('C', LColorPaletteName) then
      ReadInput('color palette name', 'blue', LColorPaletteName);
    if not FindCmdLineSwitch('O', LOutputs) then
      ReadInput('output formats', 'HTML,PNG', LOutputs);
    if not FindCmdLineSwitch('P', LOutputPath) then
      LOutputPath := '';

    ReplaceSpace(LResourcesPath);
    ReplaceSpace(LColorPaletteName);
    LAssetsPath := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(LResourcesPath) + 'Assets');

    SetLength(LDataFileNames, TPokepasteVcl.DataItemsCount);
    for I := 0 to TPokepasteVcl.DataItemsCount - 1 do
      LDataFileNames[I] := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(LResourcesPath) + 'Data') +
        TPokepasteVcl.DataItems[I] + '.csv';

    LHtmlOutput := Pos('HTML', AnsiUpperCase(LOutputs)) > 0;
    LPngOutput := Pos('PNG', AnsiUpperCase(LOutputs)) > 0;

    if FindCmdLineSwitch('Verbose') then
      PrintConfig;
    if FindCmdLineSwitch('Slow') then
    begin
      PrintConfig;
      WriteLn('Start executing? [N = No, everything else = Yes]');
      ReadLn(LConfirm);
    end;

    if SameText(LConfirm, 'N') then
      Exit;

    WriteLn('');
    WriteLn('Processing...');
    WriteLn('');

    AddFontResource(PWideChar(IncludeTrailingPathDelimiter(LResourcesPath) + 'SourceSansPro-Semibold.ttf'));
    LPokepaste := TPokepasteVcl.Create;
    LPokepasteProcessor := TPokepasteProcessor.Create(LDataFileNames, LAssetsPath, LColorPaletteName,
      LOutputPath, LPokepaste, LHtmlOutput, LPngOutput);
    try
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
      if SameText(LAppMode, 'File') then
      begin
        LFile := TCsv.Create(TFileName(LFileName), LDelimiter[1], True);
        try
          LOutput := LPokepasteProcessor.CreateFromFile(LFile, LColumnNames, LFullNameList, LErrors);
        finally
          LFile.Free;
        end
      end
      else if SameText(LAppMode, 'Manual') then
        LOutput := LPokepasteProcessor.CreateFromSingleInput(TInput.Create(LName, LSurname, LUrl), LErrors);
    finally
      RemoveFontResource(PWideChar(IncludeTrailingPathDelimiter(LResourcesPath) + 'SourceSansPro-Semibold.ttf'));
      LPokepasteProcessor.Free;
      LPokepaste.Free;
    end;

    PrintOutput;

  except
    on E: Exception do
    begin
      Writeln(E.Message);
      ReadLn;
    end;
  end;
end.
