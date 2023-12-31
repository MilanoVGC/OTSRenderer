unit MainFormUnit;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.ImageList,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  AkUtils, PokeParserVcl, PokepasteProcessor;

type
  TMainForm = class(TForm)
  private
    FDataFiles: array of TFileName;
    FPokepaste: TPokepasteVcl;
    FCsvColumnDefinitions: array of string;
    FCsvColumnNames: array of string;
    FCsvDelimiter: Char;
    FAddedInputs: array of TInput;
    FPreviewEnabled: Boolean;
    FOutputs: TStringList;
    FOutputTypes: TStringList;
    FStopOnErrors: Boolean;
    FLogger: TAkLogger;

    { Setup / Enable / Disable components }
    procedure UpdateCreateBtn;
    procedure UpdateResourcesPath;
    procedure UpdateInputRemoveBtn;
    procedure SetCsvDelimiter;
    procedure CalcCsvColumnNames;
    procedure PaintComboboxPalette;
    procedure PaintComboBoxLanguages;

    { Dependencies }
    procedure CalcPalette(const ACssPath: string; var AColorNames, AColorValues: TArray<string>);
    procedure CheckAndSetData;
    function EvalDateTime(const ADateTime: TDateTime): TDateTime;

    { Manual inputs }
    procedure AddInput(const AName, ASurname, AUrl: string;
      const ATrainerName: string = ''; const ABattleTeam: string = '';
      const AProfile: string = ''; const APlayerId: string = '';
      const AGameLanguageId: string = '';
      const ABirthDate: TDateTime = NULL_DATETIME);
    procedure DeleteInput(const AIndex: Integer);
    procedure DeleteAllInputs;

    { Preview }
    procedure SetSprite(const AIndex: Integer; const ASet: array of TImage);
    procedure SetAllSprites;
    procedure ClearSprites;
    procedure DisplayPreview(const AShow: Boolean);

  protected
    { Dialogs }
    procedure GeneralDlg(const ADlgType: TMsgDlgType; const AMessage: string);
    procedure WarningDlg(const AMessage: string);
    procedure InfoDlg(const AMessage: string);
    function ConfirmDlg(const AMessage: string): Boolean;
    function YesNoDlg(const AMessage: string): Boolean;
    function YesNoAllDlg(const AMessage: string): string;

    { Utilities }
    procedure Log(const AString: string);
  public
    { The main Create method }
    procedure CreateAll(const AInputFileName: TFileName; const AAssetsPath, AColorPaletteName: string;
      const AOutputPath: string = '');
  published
    { Non-visual components }
    DlgPathSelect: TFileOpenDialog;
    DlgFileSelect: TFileOpenDialog;
    Icons: TImageList;
    { Main components }
    Page: TPageControl;
    TabInputOutput: TTabSheet;
    BtnInputFile: TButton;
    EdtInputFile: TEdit;
    LblInputFile: TLabel;
    PnlInput: TPanel;
    LblInputName: TLabel;
    LblInputSurname: TLabel;
    LblInputUrl: TLabel;
    LblInputTrainerName: TLabel;
    LblInputBattleTeam: TLabel;
    LblInputProfile: TLabel;
    LblInputPlayerId: TLabel;
    LblInputBirthDate: TLabel;
    LblInputGameLanguage: TLabel;
    EdtInputName: TEdit;
    EdtInputSurname: TEdit;
    EdtInputUrl: TEdit;
    EdtInputTrainerName: TEdit;
    EdtInputBattleTeam: TEdit;
    EdtInputProfile: TEdit;
    EdtInputPlayerId: TEdit;
    DtpInputBirthDate: TDateTimePicker;
    CbxInputGameLanguage: TComboBox;
    LstInputList: TListBox;
    LblInputList: TLabel;
    BtnInputAdd: TButton;
    BtnInputRemove: TButton;
    BtnInputRemoveAll: TButton;
    CbxPalette: TComboBox;
    LblPalette: TLabel;
    BtnOutputPathSelect: TButton;
    EdtOutputPathSelect: TEdit;
    LblOutputPathSelect: TLabel;
    CbxOtsLanguage: TComboBox;
    LblOtsLanguage: TLabel;
    BtnCreate: TButton;
    { Config components }
    TabConfig: TTabSheet;
    PnlCsvColumns: TPanel;
    LblColumnName: TLabel;
    LblColumnSurname: TLabel;
    LblColumnPaste: TLabel;
    LblTrainerName: TLabel;
    LblBattleTeam: TLabel;
    LblProfile: TLabel;
    LblBirthDate: TLabel;
    LblPlayerId: TLabel;
    LblGameLanguage: TLabel;
    EdtColumnPaste: TEdit;
    EdtColumnSurname: TEdit;
    EdtColumnName: TEdit;
    EdtColumnTrainerName: TEdit;
    EdtColumnBattleTeam: TEdit;
    EdtColumnProfile: TEdit;
    EdtColumnBirthDate: TEdit;
    EdtColumnPlayerId: TEdit;
    EdtColumnGameLanguage: TEdit;
    PnlCsvConfig: TPanel;
    LblDateFormat: TLabel;
    LblDelimiter: TLabel;
    CbxDateFormat: TComboBox;
    CbxDelimiter: TComboBox;
    LblOutputs: TLabel;
    ChkHtmlOutput: TCheckBox;
    ChkPngOutput: TCheckBox;
    ChkOtsOutput: TCheckBox;
    ChkCtsOutput: TCheckBox;
    LblResourcePath: TLabel;
    BtnResourcePath: TButton;
    EdtResourcePath: TEdit;
    LblAssetsPath: TLabel;
    EdtAssetsPath: TEdit;
    LblDataPath: TLabel;
    EdtDataPath: TEdit;
    ChkEnablePreview: TCheckBox;
    BtnReloadLanguages: TButton;
    { Preview components }
    ShpPreview: TShape;
    LblPlayerName: TLabel;
    Pokemon1: TImage;
    Pokemon2: TImage;
    Pokemon3: TImage;
    Pokemon4: TImage;
    Pokemon5: TImage;
    Pokemon6: TImage;
    Item1: TImage;
    Item2: TImage;
    Item3: TImage;
    Item4: TImage;
    Item5: TImage;
    Item6: TImage;
    FirstTyping1: TImage;
    FirstTyping2: TImage;
    FirstTyping3: TImage;
    FirstTyping4: TImage;
    FirstTyping5: TImage;
    FirstTyping6: TImage;
    SecondTyping1: TImage;
    SecondTyping2: TImage;
    SecondTyping3: TImage;
    SecondTyping4: TImage;
    SecondTyping5: TImage;
    SecondTyping6: TImage;
    { App info components }
    LblInfo: TLabel;
    { Event handlers }
    procedure FormCreate(Sender: TObject);
    procedure UpdateInputAddBtn(Sender: TObject);
    procedure EdtResourcePathChange(Sender: TObject);
    procedure BtnOutputPathSelectClick(Sender: TObject);
    procedure BtnInputFileClick(Sender: TObject);
    procedure BtnResourcePathClick(Sender: TObject);
    procedure CbxPaletteDrawItem(Control: TWinControl; Index: Integer; Rect:TRect; State: TOwnerDrawState);
    procedure BtnInputRemoveAllClick(Sender: TObject);
    procedure EdtInputFileChange(Sender: TObject);
    procedure ChkEnablePreviewClick(Sender: TObject);
    procedure UpdateOutputs(Sender: TObject);
    procedure BtnInputAddClick(Sender: TObject);
    procedure LstInputListClick(Sender: TObject);
    procedure BtnInputRemoveClick(Sender: TObject);
    procedure BtnReloadLanguagesClick(Sender: TObject);
    procedure BtnCreateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  StrUtils, UITypes, IOUtils,
  CsvParser, AkUtilsVcl, PokeParser;

{$R *.dfm}

procedure TMainForm.AddInput(const AName, ASurname, AUrl, ATrainerName,
  ABattleTeam, AProfile, APlayerId, AGameLanguageId: string; const ABirthDate: TDateTime);
begin
  SetLength(FAddedInputs, Length(FAddedInputs) + 1);
  FAddedInputs[Length(FAddedInputs) - 1] := TInput.Create(AName, ASurname, AUrl,
    ATrainerName, ABattleTeam, AProfile, APlayerId, AGameLanguageId, ABirthDate);
  LstInputList.AddItem(AName[1] + '. ' + ASurname, TObject(Length(FAddedInputs) - 1));
end;

procedure TMainForm.BtnCreateClick(Sender: TObject);
begin
  BtnCreate.Enabled := False;
  AddFontResource(PWideChar(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'SourceSansPro-Semibold.ttf'));
  AddFontResource(PWideChar(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'SimSun.ttf'));
  try
    // This is probably unnecessary, should test it in an environment where the font is not installed
    SendMessage(Application.Handle, WM_FONTCHANGE, 0, 0);
    CheckAndSetData;
    if FOutputTypes.Count = 0 then
      if not ConfirmDlg('You have not selected any output, nothing will be created.' + sLineBreak + 'Proceed anyway?') then
        Exit;
    {$IFDEF DEBUG}
    FStopOnErrors := YesNoDlg('Stop on errors?');
    {$ELSE}
    FStopOnErrors := False;
    {$ENDIF}
    CreateAll(EdtInputFile.Text, EdtAssetsPath.Text, CbxPalette.Items[CbxPalette.ItemIndex], EdtOutputPathSelect.Text);
  finally
    RemoveFontResource(PWideChar(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'SourceSansPro-Semibold.ttf'));
    RemoveFontResource(PWideChar(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'SimSun.ttf'));
    UpdateCreateBtn;
  end;
end;

procedure TMainForm.BtnInputAddClick(Sender: TObject);
var
  I: Integer;
begin
  AddInput(
    Trim(EdtInputName.Text),
    Trim(EdtInputSurname.Text),
    Trim(EdtInputUrl.Text),
    Trim(EdtInputTrainerName.Text),
    Trim(EdtInputBattleTeam.Text),
    Trim(EdtInputProfile.Text),
    Trim(EdtInputPlayerId.Text),
    string(CbxInputGameLanguage.Items.Objects[CbxInputGameLanguage.ItemIndex]),
    EvalDateTime(DtpInputBirthDate.DateTime)
    );
  for I := 0 to PnlInput.ControlCount - 1 do
  begin
    if PnlInput.Controls[I] is TEdit then
      (PnlInput.Controls[I] as TEdit).Clear
    else if PnlInput.Controls[I] is TDateTimePicker then
      (PnlInput.Controls[I] as TDateTimePicker).DateTime := Date;
  end;
  EdtInputName.SetFocus;
end;

procedure TMainForm.BtnInputFileClick(Sender: TObject);
begin
  if DlgFileSelect.Execute then
    EdtInputFile.Text := DlgFileSelect.FileName;
  UpdateCreateBtn;
end;

procedure TMainForm.BtnInputRemoveAllClick(Sender: TObject);
begin
  DeleteAllInputs;
end;

procedure TMainForm.BtnInputRemoveClick(Sender: TObject);
begin
  DeleteInput(LstInputList.ItemIndex);
  UpdateInputRemoveBtn;
end;

procedure TMainForm.BtnOutputPathSelectClick(Sender: TObject);
begin
  if DlgPathSelect.Execute then
    EdtOutputPathSelect.Text := DlgPathSelect.FileName;
end;

procedure TMainForm.BtnReloadLanguagesClick(Sender: TObject);
begin
  TAkLanguageRegistry.Config := AppPath + 'languages.csv';
  PaintComboBoxLanguages;
end;

procedure TMainForm.BtnResourcePathClick(Sender: TObject);
begin
  if DlgPathSelect.Execute then
    EdtResourcePath.Text := DlgPathSelect.FileName;
end;

procedure TMainForm.CalcPalette(const ACssPath: string;
  var AColorNames, AColorValues: TArray<string>);
const
  ERR_BAD_FORMAT_CSS = 'Palette css file "%s" is not correctly formatted: skipped.';
var
  LFileList: TArray<TFileName>;
  LFile: TStringList;
  LBaseColorRow: Integer;
  I: Integer;
begin
  SetLength(AColorNames, 0);
  SetLength(AColorValues, 0);
  LFileList := CreateFileList(ACssPath, '*_palette.css');
  LFile := TStringList.Create;
  try
    for I := 0 to Length(LFileList) - 1 do
    begin
      LFile.Clear;
      LFile.LoadFromFile(LFileList[I]);
      LBaseColorRow := LFile.Contains('--baseColor');
      if LBaseColorRow < 0 then
      begin
        WarningDlg(Format(ERR_BAD_FORMAT_CSS, [LFileList[I]]));
        Continue;
      end;

      SetLength(AColorNames, Length(AColorNames) + 1);
      SetLength(AColorValues, Length(AColorValues) + 1);
      AColorNames[Length(AColorNames) - 1] := RemoveStrings(ExtractFileName(LFileList[I]), ['_palette.css']);
      AColorValues[Length(AColorValues) - 1] := Trim(RemoveStrings(LFile[LBaseColorRow], ['--baseColor:', ';']));
    end;
  finally
    LFile.Free;
  end;
end;

procedure TMainForm.CbxPaletteDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
var
  LIcon: TBitmap;
begin
  LIcon := TBitmap.Create;
  try
    LIcon.SetSize(18, CbxPalette.ItemHeight - 2);
    LIcon.PixelFormat := pf24bit;
    LIcon.Canvas.Brush.Color := TColor(CbxPalette.Items.Objects[Index]);
    LIcon.Canvas.FillRect(System.Classes.Rect(0, 0, Width, Height));

    with CbxPalette.Canvas do
    begin
      FillRect(Rect);
      if LIcon.Handle <> 0 then
        Draw(Rect.Left + 2, Rect.Top + 1, LIcon);
      Rect := Bounds(Rect.Left + LIcon.Width + 6, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top);
      DrawText(Handle, PChar(CbxPalette.Items[Index]), Length(CbxPalette.Items[Index]), Rect, DT_VCENTER+DT_SINGLELINE);
    end;
  finally
    LIcon.Free;
  end;
end;

procedure TMainForm.CheckAndSetData;
var
  I: Integer;
begin
  SetLength(FDataFiles, TPokepasteVcl.DataItemsCount);
  for I := 0 to TPokepasteVcl.DataItemsCount - 1 do
  begin
    Assert(FileExists(EdtDataPath.Text + TPokepasteVcl.DataItems[I] + '.csv'),
      Format('Missing data file "%s".', [TPokepasteVcl.DataItems[I] + '.csv']));

    FDataFiles[I] := EdtDataPath.Text + TPokepasteVcl.DataItems[I] + '.csv';
  end;
  Assert(DirectoryExists(EdtAssetsPath.Text),
    Format('Assets folder "%s" not found.', [EdtAssetsPath.Text]));
end;

procedure TMainForm.ChkEnablePreviewClick(Sender: TObject);
begin
  DisplayPreview(ChkEnablePreview.Checked);
end;

procedure TMainForm.ClearSprites;
var
  I: Integer;
  LPokemon: TImage;
  LItem: TImage;
  LFirstType: TImage;
  LSecondType: TImage;
begin
  for I := 1 to 6 do
  begin
    LPokemon := FindComponent('Pokemon' + IntToStr(I)) as TImage;
    LItem := FindComponent('Item' + IntToStr(I)) as TImage;
    LFirstType := FindComponent('FirstTyping' + IntToStr(I)) as TImage;
    LSecondType := FindComponent('SecondTyping' + IntToStr(I)) as TImage;
    LPokemon.Picture := nil;
    LItem.Picture := nil;
    LFirstType.Picture := nil;
    LSecondType.Picture := nil;
    LPokemon.Repaint;
    LItem.Repaint;
    LFirstType.Repaint;
    LSecondType.Repaint;
  end;
  LblPlayerName.Caption := 'Preview';
  LblPlayerName.Update;
end;

procedure TMainForm.CreateAll(const AInputFileName: TFileName;
  const AAssetsPath, AColorPaletteName, AOutputPath: string);
var
  LCsv: TCsv;
  LFullNames: string;
  LErrors: string;
  LDlgResult: string;
  LNeverOverwrite: Boolean;
  LAlwaysOverwrite: Boolean;
  LProcessor: TPokepasteProcessor;

begin
  if Assigned(FOutputs) then
    FreeAndNil(FOutputs);

  LAlwaysOverwrite := False;
  LNeverOverwrite := False;
  FOutputs := TStringList.Create;
  LProcessor := TPokepasteProcessor.Create(FDataFiles,
    AAssetsPath, AColorPaletteName, AOutputPath,
    FPokepaste, FOutputTypes.Text, FLogger);
  try
    LProcessor.StopOnErrors := FStopOnErrors;
    LProcessor.OTSLanguage := string(CbxOtsLanguage.Items.Objects[CbxOtsLanguage.ItemIndex]);

    if FPreviewEnabled then
    begin
      LProcessor.OnInput :=
        function(APokepaste: TPokepaste; AInput: TInput): Boolean
        begin
          SetAllSprites;
          Result := True;
        end;
      LProcessor.AfterInput :=
        procedure(APokepaste: TPokepaste; AInput: TInput; AOutputs: string)
        begin
          Sleep(1000);
          ClearSprites;
        end;
    end;

    LProcessor.OnRender :=
      function(APokepaste: TPokepaste; AInput: TInput; AOutputType: string): Boolean
      var
        LOutputName: string;
      begin
        Result := True;
        LOutputName := IncludeTrailingPathDelimiter(LProcessor.OutputPath + AOutputType) + APokepaste.OutputName + OutputExt(AOutputType);
        if FileExists(LOutputName) then
        begin
          if LAlwaysOverwrite then
            Exit;
          if LNeverOverwrite then
          begin
            Result := False;
            Exit;
          end;
            LDlgResult := YesNoAllDlg(Format('The file "%s" already exists: overwrite it?', [LOutputName]));

          if SameText(LDlgResult, 'YesAll') then
            LAlwaysOverwrite := True
          else if SameText(LDlgResult, 'NoAll') then
            LNeverOverwrite := True;
          if Pos('YES', AnsiUpperCase(LDlgResult)) > 0  then
            Result := True
          else
            Result := False;
        end;
      end;

    if FileExists(AInputFileName) then
    begin
      SetCsvDelimiter;
      CalcCsvColumnNames;
      LCsv := TCsv.Create(AInputFileName, FCsvDelimiter, True);
      try
        LCsv.DateFormat := CbxDateFormat.Items[CbxDateFormat.ItemIndex];
        FOutputs.Text := LProcessor.CreateFromFile(LCsv, FCsvColumnDefinitions, FCsvColumnNames, LFullNames, LErrors);
        if FOutputs.Text <> '' then
          FOutputs.Text := FOutputs.Text + sLineBreak;
      finally
        LCsv.Free;
      end;
    end;

    FOutputs.Text := FOutputs.Text + LProcessor.CreateFromInputList(FAddedInputs, LFullNames, LErrors);
    if (FOutputs.Count > 0) and (LErrors = '') then
      if YesNoDlg('Operation completed without errors, show complete output?') then
        InfoDlg(FOutputs.Text)
      else
        InfoDlg('The complete output is detailed in the log file')
    else if (LErrors <> '') then
      WarningDlg('Operation completed, there are the following errors:' + sLineBreak + LErrors)
    else
      InfoDlg('Nothing has been created.');
    if FPreviewEnabled then
      ClearSprites;
  finally
    LProcessor.Free;
  end;
end;

procedure TMainForm.DeleteAllInputs;
const
  CONFIRM_MSG = 'All the entries will be deleted.' + sLineBreak +
    'Are you sure?';
begin
  if ConfirmDlg(CONFIRM_MSG) then
  begin
    LstInputList.Clear;
    SetLength(FAddedInputs, 0);
  end;
  UpdateInputRemoveBtn;
end;

procedure TMainForm.DeleteInput(const AIndex: Integer);
const
  CONFIRM_MSG = 'The entry "%s - %s" will be deleted.' + sLineBreak +
    'Are you sure?';
begin
  if AIndex >= Length(FAddedInputs) then
    Exit;

  if ConfirmDlg(Format(CONFIRM_MSG, [FAddedInputs[AIndex].FullName, FAddedInputs[AIndex].Link])) then
  begin
    LstInputList.DeleteSelected;
    Delete(FAddedInputs, AIndex, 1);
  end;
end;

procedure TMainForm.DisplayPreview(const AShow: Boolean);
begin
  if AShow then
    ClientHeight := 756
  else
    ClientHeight := 378;
  FPreviewEnabled := AShow;
end;

procedure TMainForm.EdtInputFileChange(Sender: TObject);
begin
  UpdateCreateBtn;
end;

procedure TMainForm.EdtResourcePathChange(Sender: TObject);
begin
  UpdateResourcesPath;
end;

function TMainForm.EvalDateTime(const ADateTime: TDateTime): TDateTime;
begin
  if ADateTime = Date then
    Result := NULL_DATETIME
  else
    Result := ADateTime
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LLogPath: string;
begin
  FOutputTypes := TStringList.Create;
  PaintComboBoxPalette;
  DisplayPreview(ChkEnablePreview.Checked);
  UpdateOutputs(Sender);
  LLogPath := IncludeTrailingPathDelimiter(AppPath + 'Log');
  DtpInputBirthDate.DateTime := Date;
  if not MakeDir(LLogPath) then
  begin
    WarningDlg('Error creating log folder.' + sLineBreak + 'Log file will be placed in the application directory.');
    LLogPath := IncludeTrailingPathDelimiter(AppPath);
  end;
  FPokepaste := TPokepasteVcl.Create;
  FLogger := TAkLogger.CreateAndInit(AppTitle, LLogPath + AppTitle, 'Y', 'dd-mm-yy_hh:nn:ss');

  TAkLanguageRegistry.Config := AppPath + 'languages.csv';
  PaintComboBoxLanguages;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FPokepaste) then
    FPokepaste.Free;
  if Assigned(FOutputs) then
    FOutputs.Free;
  if Assigned(FLogger) then
    FLogger.Free;
  if Assigned(FOutputTypes) then
    FOutputTypes.Free;
end;

procedure TMainForm.GeneralDlg(const ADlgType: TMsgDlgType;
  const AMessage: string);
var
  LForm: TForm;
  LLabel: TLabel;
begin
  LForm := CreateMessageDialog(AMessage, ADlgType, [mbOK]);
  try
    LLabel := LForm.FindComponent('Message') as TLabel;
    LLabel.Width := LLabel.Width;
    LForm.ClientWidth := LForm.ClientWidth;
    LForm.Position := poScreenCenter;
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TMainForm.InfoDlg(const AMessage: string);
begin
  GeneralDlg(mtInformation, AMessage);
end;

procedure TMainForm.Log(const AString: string);
begin
  FLogger.Log(AString);
end;

procedure TMainForm.LstInputListClick(Sender: TObject);
begin
  UpdateInputRemoveBtn;
end;

procedure TMainForm.PaintComboBoxLanguages;
begin
  CbxOtsLanguage.Clear;
  CbxInputGameLanguage.Clear;
  TAkLanguageRegistry.Instance.ForEach(
    procedure(ALanguage: TLanguage)
    begin
      CbxOtsLanguage.AddItem(ALanguage.Description, TObject(ALanguage.Id));
      CbxInputGameLanguage.AddItem(ALanguage.Description, TObject(ALanguage.Id));
    end
  );
  CbxOtsLanguage.ItemIndex := 0;
  CbxInputGameLanguage.ItemIndex := 0;
end;

procedure TMainForm.PaintComboboxPalette;
const
  ERR_NO_CSS = 'There are no palette css files (*_palette.css) in the selected resource path ' + sLineBreak +
    '("%s").' + sLineBreak +
    'Add the palette css files or select another path in order to enable the creation.';
var
  I: Integer;
  LColorNames: TArray<string>;
  LColorValues: TArray<string>;
begin
  CalcPalette(EdtResourcePath.Text, LColorNames, LColorValues);
  CbxPalette.Clear;

  if Length(LColorNames) < 1 then
  begin
    BtnCreate.Enabled := False;
    WarningDlg(Format(ERR_NO_CSS, [EdtResourcePath.Text]));
  end
  else
    UpdateCreateBtn;

  for I := 0 to Length(LColorNames) - 1 do
    CbxPalette.AddItem(LColorNames[I], TObject(HexToColor(LColorValues[I])));
  CbxPalette.ItemIndex := 0;
end;

procedure TMainForm.SetAllSprites;
var
  I: Integer;
  LPokemon: TImage;
  LItem: TImage;
  LFirstType: TImage;
  LSecondType: TImage;
begin
  for I := 1 to 6 do
  begin
    LPokemon := FindComponent('Pokemon' + IntToStr(I)) as TImage;
    LItem := FindComponent('Item' + IntToStr(I)) as TImage;
    LFirstType := FindComponent('FirstTyping' + IntToStr(I)) as TImage;
    LSecondType := FindComponent('SecondTyping' + IntToStr(I)) as TImage;
    SetSprite(I - 1, [LPokemon, LItem, LFirstType, LSecondType]);
  end;
  LblPlayerName.Caption := FPokepaste.Owner;
  LblPlayerName.Repaint;
end;

procedure TMainForm.SetSprite(const AIndex: Integer;
  const ASet: array of TImage);
var
  I: Integer;
  LFileName: string;

  function SpriteType: string;
  begin
    if Pos('Item', ASet[I].Name) > 0 then
      Result := 'Items'
    else if Pos('Pokemon', ASet[I].Name) > 0 then
      Result := 'Pokemon'
    else if Pos('FirstTyping', ASet[I].Name) > 0 then
      Result := 'FirstTyping'
    else if Pos('SecondTyping', ASet[I].Name) > 0 then
      Result := 'SecondTyping'
    else
      raise Exception.CreateFmt('Unknown component "%s"', [ASet[I].Name]);
  end;
begin
  Assert(Assigned(FPokepaste), 'Pokepaste was not initialized.');

  if FPokepaste.Count <= AIndex then
    Exit;
  for I := 0 to Length(ASet) - 1 do
  begin
    LFileName := FPokepaste.Sprite[SpriteType, AIndex];
    if MatchText(ExtractFileExt(LFileName), ['.png', '.bmp', '.jpg']) then
    begin
      ASet[I].Picture.LoadFromFile(LFileName);
      ASet[I].Repaint;
    end;
  end;
end;

procedure TMainForm.UpdateCreateBtn;
begin
  BtnCreate.Enabled := (Length(FAddedInputs) <> 0) or (Trim(EdtInputFile.Text) <> '');
end;

procedure TMainForm.CalcCsvColumnNames;
var
  LColumnCount: Integer;

  function CountColumns: Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := 0 to PnlCsvColumns.ControlCount - 1 do
      if PnlCsvColumns.Controls[I] is TEdit then
        if Trim((PnlCsvColumns.Controls[I] as TEdit).Text) <> '' then
          Inc(Result);
  end;

  procedure SetColumns(const AEdits: array of TEdit);
  var
    LSkipCount: Integer;
    I: Integer;
  begin
    LSkipCount := 0;
    for I := 0 to Length(FCsvColumnNames) - 1 do
    begin
      while Trim(AEdits[I + LSkipCount].Text) = '' do
        Inc(LSkipCount);
      FCsvColumnNames[I] := AEdits[I + LSkipCount].Text;
      FCsvColumnDefinitions[I] := RemoveStrings(AEdits[I + LSkipCount].Name, ['EdtColumn']);
    end;
  end;
begin
  LColumnCount := CountColumns;
  Assert(LColumnCount > 3, 'Columns Name, Surname, Pokepaste URL and Trainer Name are mandatory');
  SetLength(FCsvColumnDefinitions, LColumnCount);
  SetLength(FCsvColumnNames, LColumnCount);
  SetColumns([
    EdtColumnName,
    EdtColumnSurname,
    EdtColumnPaste,
    EdtColumnTrainerName,
    EdtColumnBattleTeam,
    EdtColumnProfile,
    EdtColumnPlayerId,
    EdtColumnBirthDate,
    EdtColumnGameLanguage
  ]);
end;

procedure TMainForm.SetCsvDelimiter;
begin
  FCsvDelimiter := CbxDelimiter.Text[1];
end;

procedure TMainForm.UpdateInputAddBtn(Sender: TObject);
begin
  if (Trim(EdtInputName.Text) = '')
  or (Trim(EdtInputSurname.Text) = '')
  or (Trim(EdtInputUrl.Text) = '')
  or (Trim(EdtInputTrainerName.Text) = '') then
    BtnInputAdd.Enabled := False
  else
    BtnInputAdd.Enabled := True;
  UpdateCreateBtn;
end;

procedure TMainForm.UpdateInputRemoveBtn;
begin
  if LstInputList.ItemIndex >= 0 then
    BtnInputRemove.Enabled := True
  else
    BtnInputRemove.Enabled := False;
  UpdateCreateBtn;
end;

procedure TMainForm.UpdateOutputs(Sender: TObject);
begin
  FOutputTypes.Clear;
  if ChkHtmlOutput.Checked then
    FOutputTypes.Add('HTML');
  if ChkPngOutput.Checked then
    FOutputTypes.Add('PNG');
  if ChkOtsOutput.Checked then
    FOutputTypes.Add('PDF_OTS');
  if ChkCtsOutput.Checked then
    FOutputTypes.Add('PDF_CTS');
end;

procedure TMainForm.UpdateResourcesPath;
begin
  EdtAssetsPath.Text := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'Assets');
  EdtDataPath.Text := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'Data');
  PaintComboBoxPalette;
end;

procedure TMainForm.WarningDlg(const AMessage: string);
begin
  GeneralDlg(mtWarning, AMessage);
end;

function TMainForm.YesNoAllDlg(const AMessage: string): string;
var
  LForm: TForm;
  LLabel: TLabel;
  LResult: Integer;
begin
  LForm := CreateMessageDialog(AMessage, mtInformation, [mbYes, mbYesToAll, mbNo, mbNoToAll]);
  try
    LLabel := LForm.FindComponent('Message') as TLabel;
    LLabel.Width := LLabel.Width;
    LForm.ClientWidth := lForm.ClientWidth;
    LForm.Position := poScreenCenter;
    LResult := LForm.ShowModal;
    if LResult = mrYes then
      Result := 'Yes'
    else if LResult = mrYesToAll then
      Result := 'YesAll'
    else if LResult = mrNoToAll then
      Result := 'NoAll'
    else
      Result := 'No';
  finally
    LForm.Free;
  end;
end;

function TMainForm.YesNoDlg(const AMessage: string): Boolean;
var
  LForm: TForm;
  LLabel: TLabel;
begin
  LForm := CreateMessageDialog(AMessage, mtInformation, [mbYes, mbNo]);
  try
    LLabel := LForm.FindComponent('Message') as TLabel;
    LLabel.Width := LLabel.Width;
    LForm.ClientWidth := lForm.ClientWidth;
    LForm.Position := poScreenCenter;
    Result := LForm.ShowModal = mrYes;
  finally
    LForm.Free;
  end;
end;

function TMainForm.ConfirmDlg(const AMessage: string): Boolean;
var
  LForm: TForm;
  LLabel: TLabel;
begin
  LForm := CreateMessageDialog(AMessage, mtWarning, [mbYes, mbCancel]);
  try
    LLabel := LForm.FindComponent('Message') as TLabel;
    LLabel.Width := LLabel.Width;
    LForm.ClientWidth := lForm.ClientWidth;
    LForm.Position := poScreenCenter;
    Result := LForm.ShowModal = mrYes;
  finally
    LForm.Free;
  end;
end;

end.
