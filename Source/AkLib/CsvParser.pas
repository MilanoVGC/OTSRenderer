unit CsvParser;

interface

uses
  Classes, SysUtils;

type
  TConstProc<T1> = reference to procedure(const Arg1: T1);

  TCsv = class
  strict private
    FHeaderIndex: Integer;
    FDelimiter: Char;
    FText: TStringList;
    FHeader: TStringList;
    FColumnCount: Integer;
    procedure Init(const ADelimiter: Char = ';';
      const AHasHeader: Boolean = False);
    function GetHeaderColumn(const AColumnTitle: string): Integer;
  public
    property Delimiter: Char read FDelimiter;
    property Header[const AColumnTitle: string]: Integer read GetHeaderColumn;
    constructor Create(const AFileName: TFileName; const ADelimiter: Char = ';';
      const AHasHeader: Boolean = False); overload;
    constructor Create(const AText: string; const ADelimiter: Char = ';';
      const AHasHeader: Boolean = False); overload;
    procedure AfterConstruction; override;
    function FindByValue(const AValue: string; const AColumnToFindIndex: Integer;
      const AColumnWhereSearchIndex: Integer = 0): string; overload;
    function FindByValue(const AValue, AColumnToFindTitle, AColumnWhereSearchTitle: string): string; overload;
    destructor Destroy; override;
    procedure ForEach(const AColumnIndex: Integer; const AProc: TConstProc<string>); overload;
    procedure ForEach(const AColumnTitle: string; const AProc: TConstProc<string>); overload;
    procedure ForEach(const AColumnIndexes: array of Integer; const AProc: TConstProc<TArray<string>>); overload;
    procedure ForEach(const AColumnTitles: array of string; const AProc: TConstProc<TArray<string>>); overload;
    procedure ForEach(const AProc: TConstProc<TArray<string>>); overload;
  end;

  TCsvArchive = class
  strict private
    FNames: TStringList;
    FData: array of TCsv;
    FDelimiter: Char;
    FHasHeader: Boolean;
    function GetItem(const AName: string): TCsv;
    procedure PrepareAdd(const AName: string);
  public
    property Item[const AName: string]: TCsv read GetItem; default;
    property Delimiter: Char read FDelimiter write FDelimiter;
    property HasHeader: Boolean read FHasHeader write FHasHeader;
    constructor Create(const ADelimiter: Char = ';'; const AHasHeader: Boolean = False);
    function Add(const AItemFileName: TFileName; const AName: string = ''): string; overload;
    function Add(const AItemText: string; const AName: string = ''): string; overload;
    procedure Add(const AItemFileNames: array of TFileName); overload;
    function Find(const AName, AValue: string; const AColumnToFindIndex: Integer;
      const AColumnWhereSearchIndex: Integer = 0): string; overload;
    function Find(const AName, AValue, AColumnToFindTitle, AColumnWhereSearchTitle: string): string; overload;
    destructor Destroy; override;
  end;

implementation

uses
  StrUtils, IOUtils;

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

{ TCsv }

constructor TCsv.Create(const AFileName: TFileName; const ADelimiter: Char;
  const AHasHeader: Boolean);
begin
  Init(ADelimiter, AHasHeader);
  FText.LoadFromFile(AFileName, TEncoding.UTF8);
end;

procedure TCsv.AfterConstruction;
begin
  inherited;

  FColumnCount := Occurrences(FDelimiter, FText[0]) + 1;

  if FHeaderIndex < 0 then
    Exit;

  FHeader := TStringList.Create;
  FHeader.Delimiter := FDelimiter;
  FHeader.StrictDelimiter := True;
  FHeader.CaseSensitive := False;
  FHeader.DelimitedText := FText[FHeaderIndex];
end;

constructor TCsv.Create(const AText: string; const ADelimiter: Char;
  const AHasHeader: Boolean);
begin
  Init(ADelimiter, AHasHeader);
  FText.Text := AText;
end;

destructor TCsv.Destroy;
begin
  if Assigned(FText) then
    FText.Free;
  if Assigned(FHeader) then
    FHeader.Free;
  inherited;
end;

function TCsv.FindByValue(const AValue: string;
  const AColumnToFindIndex, AColumnWhereSearchIndex: Integer): string;
var
  LRow: TStringList;
  I: Integer;
begin
  LRow := TStringList.Create;
  try
    LRow.StrictDelimiter := True;
    LRow.Delimiter := Delimiter;
    for I := 0 to FText.Count - 1 do
    begin
      LRow.DelimitedText := FText[I];
      if SameText(Trim(LRow[AColumnWhereSearchIndex]), Trim(AValue)) then
      begin
        Result := LRow[AColumnToFindIndex];
        Break;
      end;
    end;
    if Result = '' then
      raise Exception.CreateFmt('Value "%s" not found.', [AValue]);
  finally
    LRow.Free;
  end;
end;

function TCsv.FindByValue(const AValue, AColumnToFindTitle, AColumnWhereSearchTitle: string): string;
begin
  Result := FindByValue(AValue, Header[AColumnWhereSearchTitle], Header[AColumnToFindTitle]);
end;

procedure TCsv.ForEach(const AColumnTitle: string; const AProc: TConstProc<string>);
begin
  ForEach(Header[AColumnTitle], AProc);
end;

function TCsv.GetHeaderColumn(const AColumnTitle: string): Integer;
begin
  Assert(FHeaderIndex >= 0, 'Could not search for column names in a CSV without a header.');
  Result := FHeader.IndexOf(AColumnTitle);
  Assert(Result >= 0, Format('Column with title "%s" not found.', [AColumnTitle]));
end;

procedure TCsv.ForEach(const AColumnIndex: Integer; const AProc: TConstProc<string>);
var
  LRow: TStringList;
  I: Integer;
begin
  LRow := TStringList.Create;
  try
    LRow.StrictDelimiter := True;
    LRow.Delimiter := FDelimiter;
    for I := 0 to FText.Count - 1 do
    begin
      if I = FHeaderIndex then
        Continue;
      LRow.DelimitedText := FText[I];
      AProc(LRow[AColumnIndex]);
    end;
  finally
    LRow.Free;
  end;
end;

procedure TCsv.Init(const ADelimiter: Char; const AHasHeader: Boolean);
begin
  FText := TStringList.Create;
  FDelimiter := ADelimiter;
  if AHasHeader then
    FHeaderIndex := 0
  else
    FHeaderIndex := -1;
end;

procedure TCsv.ForEach(const AColumnIndexes: array of Integer;
  const AProc: TConstProc<TArray<string>>);
var
  LRow: TStringList;
  LValues: TArray<string>;
  I: Integer;
  J: Integer;
begin
  SetLength(LValues, Length(AColumnIndexes));
  LRow := TStringList.Create;
  try
    LRow.StrictDelimiter := True;
    LRow.Delimiter := FDelimiter;
    for I := 0 to FText.Count - 1 do
    begin
      if I = FHeaderIndex then
        Continue;
      LRow.DelimitedText := FText[I];
      for J := 0 to Length(AColumnIndexes) - 1 do
        LValues[J] := LRow[AColumnIndexes[J]];
      AProc(LValues);
    end;
  finally
    LRow.Free;
  end;
end;

procedure TCsv.ForEach(const AColumnTitles: array of string;
  const AProc: TConstProc<TArray<string>>);
var
  LIndexes: array of Integer;
  I: Integer;
begin
  SetLength(LIndexes, Length(AColumnTitles));
  for I := 0 to Length(LIndexes) - 1 do
    LIndexes[I] := Header[AColumnTitles[I]];
  ForEach(LIndexes, AProc);
end;

procedure TCsv.ForEach(const AProc: TConstProc<TArray<string>>);
var
  LIndexes: array of Integer;
  I: Integer;
begin
  SetLength(LIndexes, FColumnCount);
  for I := 0 to Length(LIndexes) - 1 do
    LIndexes[I] := I;
  ForEach(LIndexes, AProc);
end;

{ TCsvArchive }

function TCsvArchive.Add(const AItemFileName: TFileName;
  const AName: string): string;
begin
  Assert(FileExists(AItemFileName), Format('File "%s" not found.', [AItemFileName]));

  Result := AName;
  if Result = '' then
    Result := StringReplace(ExtractFileName(AItemFileName), ExtractFileExt(AItemFileName), '', [rfReplaceAll, rfIgnoreCase]);

  PrepareAdd(Result);
  FData[Length(FData) - 1] := TCsv.Create(AItemFileName, FDelimiter, FHasHeader);
end;

function TCsvArchive.Add(const AItemText, AName: string): string;
var
  LGuid: TGuid;
begin
  Result := AName;
  if Result = '' then
    if CreateGuid(LGuid) = S_OK then
      Result := GuidToString(LGuid)
    else
      raise Exception.Create('Could not create a unique ID.');

  PrepareAdd(Result);
  FData[Length(FData) - 1] := TCsv.Create(AItemText, FDelimiter, FHasHeader);
end;

procedure TCsvArchive.Add(const AItemFileNames: array of TFileName);
var
  I: Integer;
begin
  for I := 0 to Length(AItemFileNames) - 1 do
    Add(AItemFileNames[I]);
end;

constructor TCsvArchive.Create(const ADelimiter: Char; const AHasHeader: Boolean);
begin
  FDelimiter := ADelimiter;
  FHasHeader := AHasHeader;
  FNames := TStringList.Create;
  FNames.CaseSensitive := False;
end;

destructor TCsvArchive.Destroy;
var
  I: Integer;
begin
  if Assigned(FNames) then
    FNames.Free;
  for I := 0 to Length(FData) - 1 do
    if Assigned(FData[I]) then
      FData[I].Free;
  inherited;
end;

function TCsvArchive.Find(const AName, AValue, AColumnToFindTitle,
  AColumnWhereSearchTitle: string): string;
begin
  Result := Item[AName].FindByValue(AValue, AColumnToFindTitle, AColumnWhereSearchTitle);
end;

function TCsvArchive.Find(const AName, AValue: string; const AColumnToFindIndex,
  AColumnWhereSearchIndex: Integer): string;
begin
  Result := Item[AName].FindByValue(AValue, AColumnToFindIndex, AColumnWhereSearchIndex);
end;

function TCsvArchive.GetItem(const AName: string): TCsv;
begin
  if FNames.IndexOf(AName) < 0 then
    raise Exception.CreateFmt('No data item found with name "%s"', [AName]);
  Result := FData[FNames.IndexOf(AName)];
end;

procedure TCsvArchive.PrepareAdd(const AName: string);
var
  LName: string;
begin
  LName := Trim(AName);
  if FNames.IndexOf(LName) >= 0 then
    raise Exception.CreateFmt('The name "%s" for the data item is already in use.', [LName]);

  SetLength(FData, Length(FData) + 1);
  FNames.Add(LName);
end;

end.
