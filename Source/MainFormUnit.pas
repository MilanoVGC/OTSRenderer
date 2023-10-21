unit MainFormUnit;

interface

uses
  System.SysUtils, System.Variants, System.Classes, System.ImageList,
  Winapi.Windows, Winapi.Messages,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ImgList, Vcl.ExtCtrls, Vcl.Imaging.pngimage, Vcl.ComCtrls,
  AKUtils, PokeParser;

type
  TInput = record
    Name: string;
    Surname: string;
    Link: TUrl;
    function FullName: string;
  end;

  TMainForm = class(TForm)
  private
    FDataFiles: array of TFileName;
    FPokepaste: TPokepaste;
    FCsvColumnNames: array of string;
    FCsvDelimiter: Char;
    FAddedInputs: array of TInput;
    FPreviewEnabled: Boolean;
    FOutputs: TStringList;
    FHtmlOutput: Boolean;
    FPngOutput: Boolean;
    FStopOnErrors: Boolean;
    FLogger: TAkLogger;

    { Setup / Enable / Disable components }
    procedure UpdateCreateBtn;
    procedure UpdateResourcesPath;
    procedure UpdateInputAddBtn;
    procedure UpdateInputRemoveBtn;
    procedure UpdateCsvColumnNames;
    procedure UpdateCsvDelimiter;
    procedure UpdateOutputs;
    procedure PaintCombobox;

    { Dependencies }
    procedure CalcPalette(const ACssPath: string; var AColorNames, AColorValues: TArray<string>);
    procedure CheckAndSetData;

    { Manual inputs }
    procedure AddInput(const AName, ASurname, AUrl: string);
    procedure DeleteInput(const AIndex: Integer);
    procedure DeleteAllInputs;

    { Preview }
    procedure SetSprite(const AIndex: Integer; const ASet: array of TImage);
    procedure SetAllSprites;
    procedure ClearSprites;
    procedure DisplayPreview(const AShow: Boolean);

    { Pokepaste }
    procedure CreatePokepaste(const AUrl: TUrl; const ADataFileNames: array of TFileName;
      const AAssetsPath: string);
    procedure ProcessPokepaste(const AInput: TInput; const AAssetsPath, AColorPaletteName: string;
      const AOutputPath: string = '');
  protected
    { Dialogs }
    procedure GeneralDlg(const ADlgType: TMsgDlgType; const AMessage: string);
    procedure WarningDlg(const AMessage: string);
    procedure InfoDlg(const AMessage: string);
    function ConfirmDlg(const AMessage: string): Boolean;
    function YesNoDlg(const AMessage: string): Boolean;

    { Utilities }
    function AppTitle: string;
    function AppPath: string;
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
    { Config components }
    TabConfig: TTabSheet;
    LblColumnName: TLabel;
    LblColumnSurname: TLabel;
    LblColumnPaste: TLabel;
    EdtColumnPaste: TEdit;
    EdtColumnSurname: TEdit;
    EdtColumnName: TEdit;
    ChkEnablePreview: TCheckBox;
    LblResourcePath: TLabel;
    BtnResourcePath: TButton;
    EdtResourcePath: TEdit;
    LblAssetsPath: TLabel;
    EdtAssetsPath: TEdit;
    LblDataPath: TLabel;
    EdtDataPath: TEdit;
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
    { Main components }
    Page: TPageControl;
    TabInputOutput: TTabSheet;
    BtnInputFile: TButton;
    EdtInputFile: TEdit;
    LblInputFile: TLabel;
    PnlInput: TPanel;
    EdtInputName: TEdit;
    EdtInputSurname: TEdit;
    EdtInputUrl: TEdit;
    LblInputName: TLabel;
    LblInputSurname: TLabel;
    LblInputUrl: TLabel;
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
    BtnCreate: TButton;
    ChkHtmlOutput: TCheckBox;
    ChkPngOutput: TCheckBox;
    CbxDelimiter: TComboBox;
    LblDelimiter: TLabel;
    { Event handlers }
    procedure FormCreate(Sender: TObject);
    procedure EdtResourcePathChange(Sender: TObject);
    procedure BtnOutputPathSelectClick(Sender: TObject);
    procedure BtnInputFileClick(Sender: TObject);
    procedure BtnResourcePathClick(Sender: TObject);
    procedure CbxPaletteDrawItem(Control: TWinControl; Index: Integer; Rect:TRect; State: TOwnerDrawState);
    procedure EdtInputNameChange(Sender: TObject);
    procedure EdtInputSurnameChange(Sender: TObject);
    procedure EdtInputUrlChange(Sender: TObject);
    procedure BtnInputRemoveAllClick(Sender: TObject);
    procedure EdtInputFileChange(Sender: TObject);
    procedure ChkEnablePreviewClick(Sender: TObject);
    procedure EdtColumnNameChange(Sender: TObject);
    procedure EdtColumnSurnameChange(Sender: TObject);
    procedure EdtColumnPasteChange(Sender: TObject);
    procedure CbxDelimiterChange(Sender: TObject);
    procedure ChkHtmlOutputClick(Sender: TObject);
    procedure ChkPngOutputClick(Sender: TObject);
    procedure BtnInputAddClick(Sender: TObject);
    procedure LstInputListClick(Sender: TObject);
    procedure BtnInputRemoveClick(Sender: TObject);
    procedure BtnCreateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

uses
  StrUtils, UITypes, IOUtils,
  CsvParser;

{$R *.dfm}

procedure TMainForm.AddInput(const AName, ASurname, AUrl: string);
begin
  SetLength(FAddedInputs, Length(FAddedInputs) + 1);
  FAddedInputs[Length(FAddedInputs) - 1].Name := AName;
  FAddedInputs[Length(FAddedInputs) - 1].Surname := ASurname;
  FAddedInputs[Length(FAddedInputs) - 1].Link := AUrl;
  LstInputList.AddItem(AName[1] + '. ' + ASurname, TObject(Length(FAddedInputs) - 1));
end;

function TMainForm.AppPath: string;
begin
  Result := ExtractFilePath(ParamStr(0));
end;

function TMainForm.AppTitle: string;
begin
  Result := StringReplace(ExtractFileName(ParamStr(0)), ExtractFileExt(ParamStr(0)), '', [rfIgnoreCase]);
end;

procedure TMainForm.BtnCreateClick(Sender: TObject);
begin
  BtnCreate.Enabled := False;
  AddFontResource(PWideChar(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'SourceSansPro-Semibold.ttf'));
  try
    SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
    CheckAndSetData;
    if not FHtmlOutput and not FPngOutput then
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
    UpdateCreateBtn;
  end;
end;

procedure TMainForm.BtnInputAddClick(Sender: TObject);
begin
  AddInput(EdtInputName.Text, EdtInputSurname.Text, EdtInputUrl.Text);
  EdtInputName.Clear;
  EdtInputSurname.Clear;
  EdtInputUrl.Clear;
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

procedure TMainForm.CbxDelimiterChange(Sender: TObject);
begin
  UpdateCsvDelimiter;
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
  SetLength(FDataFiles, Length(DATA_ITEMS));
  for I := 0 to Length(DATA_ITEMS) - 1 do
  begin
    Assert(FileExists(EdtDataPath.Text + DATA_ITEMS[I] + '.csv'),
      Format('Missing data file "%s".', [DATA_ITEMS[I] + '.csv']));

    FDataFiles[I] := EdtDataPath.Text + DATA_ITEMS[I] + '.csv';
  end;
  Assert(DirectoryExists(EdtAssetsPath.Text),
    Format('Assets folder "%s" not found.', [EdtAssetsPath.Text]));
end;

procedure TMainForm.ChkEnablePreviewClick(Sender: TObject);
begin
  DisplayPreview(ChkEnablePreview.Checked);
end;

procedure TMainForm.ChkHtmlOutputClick(Sender: TObject);
begin
  UpdateOutputs;
end;

procedure TMainForm.ChkPngOutputClick(Sender: TObject);
begin
  UpdateOutputs;
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
  LFullNames: TStringList;
  LDuplicateIndex: Integer;
  I: Integer;
begin
  if Assigned(FOutputs) then
    FOutputs.Free;

  FOutputs := TStringList.Create;
  LFullNames := TStringList.Create;
  try
    if FileExists(AInputFileName) then
    begin
      LCsv := TCsv.Create(AInputFileName, FCsvDelimiter, True);
      try
        LCsv.ForEach(FCsvColumnNames,
          procedure(const AValues: TArray<string>)
          var
            LInput: TInput;
          begin
            LInput.Name := AValues[0];
            LInput.Surname := AValues[1];
            LInput.Link := AValues[2];
            LDuplicateIndex := 1;
            while LFullNames.IndexOf(LInput.FullName) >= 0 do
            begin
              Inc(LDuplicateIndex);
              LInput.Surname := LInput.Surname + '_' + IntToStr(LDuplicateIndex);
            end;
            LFullNames.Add(LInput.FullName);
            Log('Processing file entry ' + LInput.FullName + ' - ' + LInput.Link);
            try
              ProcessPokepaste(LInput, AAssetsPath, AColorPaletteName, AOutputPath);
            except
              on E: Exception do
              begin
                Log('ERROR - ' + E.Message);
                if FStopOnErrors then
                  raise E;
              end;
            end;
          end
        );
      finally
        FreeAndNil(LCsv);
      end;
    end;
    for I := 0 to Length(FAddedInputs) - 1 do
    begin
      LDuplicateIndex := 1;
      while LFullNames.IndexOf(FAddedInputs[I].FullName) >= 0 do
      begin
        Inc(LDuplicateIndex);
        FAddedInputs[I].Surname := FAddedInputs[I].Surname + '_' + IntToStr(LDuplicateIndex);
      end;
      LFullNames.Add(FAddedInputs[I].FullName);
      Log('Processing manual entry ' + FAddedInputs[I].FullName + ' - ' + FAddedInputs[I].Link);
      try
        ProcessPokepaste(FAddedInputs[I], AAssetsPath, AColorPaletteName, AOutputPath);
      except
        on E: Exception do
        begin
          Log('ERROR - ' + E.Message);
          if FStopOnErrors then
            raise E;
        end;
      end;
    end;
    if FOutputs.Count > 0 then
      InfoDlg('Operation completed, created following output files:' + sLineBreak + FOutputs.Text)
    else
      InfoDlg('No output selected, nothing has been created.');
  finally
    LFullNames.Free;
  end;
end;

procedure TMainForm.CreatePokepaste(const AUrl: TUrl; const ADataFileNames: array of TFileName;
  const AAssetsPath: string);
begin
  if Assigned(FPokepaste) then
    FreeAndNil(FPokepaste);
  FPokepaste := TPokepaste.Create(AUrl, ADataFileNames, AAssetsPath);
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

procedure TMainForm.EdtColumnNameChange(Sender: TObject);
begin
  UpdateCsvColumnNames;
end;

procedure TMainForm.EdtColumnPasteChange(Sender: TObject);
begin
  UpdateCsvColumnNames;
end;

procedure TMainForm.EdtColumnSurnameChange(Sender: TObject);
begin
  UpdateCsvColumnNames;
end;

procedure TMainForm.EdtInputFileChange(Sender: TObject);
begin
  UpdateCreateBtn;
end;

procedure TMainForm.EdtInputNameChange(Sender: TObject);
begin
  UpdateInputAddBtn;
end;

procedure TMainForm.EdtInputSurnameChange(Sender: TObject);
begin
  UpdateInputAddBtn;
end;

procedure TMainForm.EdtInputUrlChange(Sender: TObject);
begin
  UpdateInputAddBtn;
end;

procedure TMainForm.EdtResourcePathChange(Sender: TObject);
begin
  UpdateResourcesPath;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  LLogPath: string;
begin
  PaintComboBox;
  DisplayPreview(ChkEnablePreview.Checked);
  SetLength(FCsvColumnNames, 3);
  UpdateCsvColumnNames;
  UpdateCsvDelimiter;
  UpdateOutputs;
  LLogPath := IncludeTrailingPathDelimiter(AppPath + 'Log');
  if not MakeDir(LLogPath) then
  begin
    WarningDlg('Error creating log folder.' + sLineBreak + 'Log file will be placed in the application directory.');
    LLogPath := IncludeTrailingPathDelimiter(AppPath);
  end;
  FLogger := TAkLogger.Create(AppTitle, LLogPath + AppTitle);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FPokepaste) then
    FreeAndNil(FPokepaste);
  if Assigned(FOutputs) then
    FOutputs.Free;
  if Assigned(FLogger) then
    FreeAndNil(FLogger);
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

procedure TMainForm.ProcessPokepaste(const AInput: TInput; const AAssetsPath,
  AColorPaletteName, AOutputPath: string);
var
  LOutput: string;
begin
  ClearSprites;
  CreatePokepaste(AInput.Link, FDataFiles, AAssetsPath);
  FPokepaste.Owner := AInput.FullName;
  if FPreviewEnabled then
    SetAllSprites;

  if FHtmlOutput then
  begin
    LOutput := FPokepaste.PrintHtml(AColorPaletteName, AOutputPath);
    FOutputs.Add('- ' + ExtractFileName(LOutput));
    Log('Processed ' + AInput.FullName + ' -> ' + LOutput);
  end;
  if FPngOutput then
  begin
    LOutput := FPokepaste.PrintPng(AColorPaletteName, AOutputPath);
    FOutputs.Add('- ' + ExtractFileName(LOutput));
    Log('Processed ' + AInput.FullName + ' -> ' + LOutput);
  end;

  if FPreviewEnabled then
    Sleep(1000);
end;

procedure TMainForm.PaintCombobox;
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

procedure TMainForm.UpdateCsvColumnNames;
begin
  FCsvColumnNames[0] := EdtColumnName.Text;
  FCsvColumnNames[1] := EdtColumnSurname.Text;
  FCsvColumnNames[2] := EdtColumnPaste.Text;
end;

procedure TMainForm.UpdateCsvDelimiter;
begin
  FCsvDelimiter := CbxDelimiter.Text[1];
end;

procedure TMainForm.UpdateInputAddBtn;
begin
  if (Trim(EdtInputName.Text) = '')
  or (Trim(EdtInputSurname.Text) = '')
  or (Trim(EdtInputUrl.Text) = '') then
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

procedure TMainForm.UpdateOutputs;
begin
  FHtmlOutput := ChkHtmlOutput.Checked;
  FPngOutput := ChkPngOutput.Checked;
end;

procedure TMainForm.UpdateResourcesPath;
begin
  EdtAssetsPath.Text := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'Assets');
  EdtDataPath.Text := IncludeTrailingPathDelimiter(IncludeTrailingPathDelimiter(EdtResourcePath.Text) + 'Data');
  PaintComboBox;
end;

procedure TMainForm.WarningDlg(const AMessage: string);
begin
  GeneralDlg(mtWarning, AMessage);
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

{ TInput }

function TInput.FullName: string;
begin
  Result := CapitalFirst(Name) + ' ' + CapitalFirst(Surname);
end;

end.
