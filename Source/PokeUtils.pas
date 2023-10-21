unit PokeUtils;

interface

uses
  Classes, CsvParser;

type

  TEvSpread = record
    Hp: Integer;
    Atk: Integer;
    Def: Integer;
    SpA: Integer;
    SpD: Integer;
    Spe: Integer;
    Nature: string;
  end;

  TTyping = (tNone,
    tWater, tFire, tGrass, tFlying, tRock, tGround,
    tFighting, tPsychic, tDark, tGhost, tNormal, tPoison,
    tBug, tIce, tElectric, tSteel, tDragon, tFairy);

  TMove = record
    Name: string;
    Typing: TTyping;
  end;

  function TypingToStr(const AType: TTyping): string;
  function StrToTyping(const AType: string): TTyping;
  function GetMoveInfo(const AMoveName: string; const AMovesCsv: TCsv): TMove;
  function TranslateEvs(const AEvs: string): TEvSpread;
  function TypingSpriteName(const AType: TTyping; const AIsTera: Boolean = False): string;
  function RandomString(const ALength: Integer): string;

implementation

uses
  SysUtils, StrUtils,
  TypInfo,
  AKUtils;

function TypingToStr(const AType: TTyping): string;
begin
  Result := GetEnumName(TypeInfo(TTyping), Integer(AType));
  Delete(Result, 1, 1);
end;

function StrToTyping(const AType: string): TTyping;
begin
  Result := TTyping(GetEnumValue(TypeInfo(TTyping), 't' + AType));
end;

function TypingSpriteName(const AType: TTyping; const AIsTera: Boolean): string;
begin
  Result := IfThen(AIsTera, 'T_') + AnsiLowerCase(TypingToStr(AType)) + '.svg';
end;

function TypingColor(const AType: TTyping; const ATypesCsv: TCsv): string;
begin
  Result := ATypesCsv.FindByValue(AnsiLowerCase(TypingToStr(AType)), 1);
end;

function GetMoveInfo(const AMoveName: string; const AMovesCsv: TCsv): TMove;
begin
  Result.Name := AMoveName;
  Result.Typing := StrToTyping(AMovesCsv.FindByValue(AMoveName, 1));
end;

function TranslateEvs(const AEvs: string): TEvSpread;
var
  LEvs: string;
  LEvsList: TStringList;

  function EvalEv(const AStat: string): Integer;
  var
    LEvIndex: Integer;
    LEvStr: string;
  begin
    LEvIndex := LEvsList.Contains(AStat);
    if LEvIndex < 0 then
    begin
      Result := 0;
      Exit;
    end;
    LEvStr := Trim(StringReplace(Trim(LEvsList[LEvIndex]), AStat, '', [rfReplaceAll, rfIgnoreCase]));
    Result := StrToInt(LEvStr);
  end;
begin
  if AEvs = '' then
    Exit;
  Result.Nature := AEvs.Substring(Pos(sLineBreak, AEvs) + 1);
  LEvs := AEvs.Substring(0, Pos(sLineBreak, AEvs) - 1);

  LEvsList := TStringList.Create;
  try
    LEvsList.Delimiter := '/';
    LEvsList.StrictDelimiter := True;
    LEvsList.CaseSensitive := False;
    LEvsList.DelimitedText := LEvs;
    Result.Hp := EvalEv('Hp');
    Result.Atk := EvalEv('Atk');
    Result.Def := EvalEv('Def');
    Result.SpA := EvalEv('SpA');
    Result.SpD := EvalEv('SpD');
    Result.Spe := EvalEv('Spe');
  finally
    LEvsList.Free;
  end;
end;

function RandomString(const ALength: Integer): string;
const
  CHARS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
var
  I: Integer;
begin
  Randomize;
  SetLength(Result, ALength);
  for I := 1 to ALength do
    Result[I] := CHARS[Random(Length(CHARS)) + 1];
end;

end.
