unit TeamlistTemplateFrame;

interface

uses
  Winapi.Windows,
  Vcl.Graphics, Vcl.Forms, Vcl.Grids, Vcl.StdCtrls,
  Pokeparser;

const
  taLeft = 'L';
  taRight = 'R';
  taCenter = 'C';

type
  TFrame = class(Vcl.Forms.TFrame)
  private
    FPokepaste: TPokepaste;
    function CalcCellRect(const AGrid: TStringGrid; const ACol, ARow: Integer): TRect;
    procedure AlignText(const ATextWidth: Integer; var ATextRect: TRect;
      const AAlignment: Char = taLeft);
  strict protected
    function CellRect(const AGrid: TStringGrid; const ACol, ARow: Integer): TRect;
    procedure FillValue(const AValue: string; const ACanvas: TCanvas;
      ARect: TRect; const ATextAlignment: Char = taLeft; const ADrawRect: Boolean = True);
    procedure FillLabel(const ALabel: TLabel; const ACanvas: TCanvas;
      const ATextAlignment: Char = taLeft);
    procedure FillHeaderRow(const ACanvas: TCanvas; const ARow: Integer;
      ARect: TRect);
    procedure FillStatRow(const APokemon: TPokemon; const ACanvas: TCanvas;
      const ARow: Integer; ARect: TRect);
    procedure FillPokemonRow(const APokemon: TPokemon; const ACanvas: TCanvas;
      const ARow: Integer; ARect: TRect);
  public
    property Pokepaste: TPokepaste read FPokepaste write FPokepaste;
    procedure PaintCanvas(const ACanvas: TCanvas); virtual;
  end;

implementation

uses
  SysUtils, Types, UITypes;

{ TFrame }

procedure TFrame.AlignText(const ATextWidth: Integer; var ATextRect: TRect;
  const AAlignment: Char);
begin
  if ATextWidth < ATextRect.Width then
    case AAlignment of
      taCenter:
      begin
        ATextRect.Left := ATextRect.Left + Round((ATextRect.Width - ATextWidth) / 2) - 2;
        ATextRect.Width := ATextRect.Width - Round((ATextRect.Width - ATextWidth) / 2) + 2;
      end;
      taRight:
      begin
        ATextRect.Left := ATextRect.Left + (ATextRect.Width - ATextWidth) - 5;
        ATextRect.Width := ATextRect.Width - (ATextRect.Width - ATextWidth) + 5;
      end;
    end;
end;

function TFrame.CalcCellRect(const AGrid: TStringGrid;
  const ACol, ARow: Integer): TRect;
var
  LOffsetX: Integer;
  LOffsetY: Integer;
begin
  LOffsetX := 1 + (ACol * (1 + AGrid.ColWidths[ACol]));
  LOffsetY := 1 + (ARow * (1 + AGrid.RowHeights[ARow]));
  Result := Rect(LOffsetX, LOffsetY, LOffsetX + AGrid.ColWidths[ACol] + 3, LOffsetY + AGrid.RowHeights[ARow] + 3);
end;

function TFrame.CellRect(const AGrid: TStringGrid; const ACol,
  ARow: Integer): TRect;
begin
  Result := CalcCellRect(AGrid, ACol, ARow);
  Result.SetLocation(Result.Left + AGrid.Left, Result.Top + AGrid.Top);
end;

procedure TFrame.FillHeaderRow(const ACanvas: TCanvas; const ARow: Integer;
  ARect: TRect);
begin
  ACanvas.Font.Style := [fsBold];
  case ARow of
    0: FillValue('Pokémon', ACanvas, ARect, taRight, False);
    1: FillValue('Tera Type', ACanvas, ARect, taRight, False);
    2: FillValue('Ability', ACanvas, ARect, taRight, False);
    3: FillValue('Held Item', ACanvas, ARect, taRight, False);
    else
      FillValue('Move ' + IntToStr(ARow - 3), ACanvas, ARect, taRight, False);
  end;
  ACanvas.Font.Style := [];
end;

procedure TFrame.FillLabel(const ALabel: TLabel; const ACanvas: TCanvas;
  const ATextAlignment: Char);
var
  LOgFontStyle: TFontStyles;
  LOgFontSize: Integer;
  LRect: TRect;
begin
  // Save canvas settings
  LOgFontStyle := ACanvas.Font.Style;
  LOgFontSize := ACanvas.Font.Size;

  // Set canvas settings from label
  ALabel.Font.Name := ACanvas.Font.Name;
  ACanvas.Font.Style := ALabel.Font.Style;
  ACanvas.Font.Size := ALabel.Font.Size;
  LRect := Rect(ALabel.Left, ALabel.Top, ALabel.Left + ALabel.Width + 4, ALabel.Top + ALabel.Height + 2);
  AlignText(ACanvas.TextWidth(ALabel.Caption), LRect, ATextAlignment);
  // Draw
  ACanvas.TextRect(LRect, LRect.Left, LRect.Top, ALabel.Caption);

  // Restore original canvas settings
  ACanvas.Font.Style := LOgFontStyle;
  ACanvas.Font.Size := LOgFontSize;
end;

procedure TFrame.FillPokemonRow(const APokemon: TPokemon;
  const ACanvas: TCanvas; const ARow: Integer; ARect: TRect);
begin
  if not Assigned(APokemon) then
  begin
    FillValue('', ACanvas, ARect);
    Exit;
  end;

  case ARow of
    0: FillValue(APokemon.DisplayName, ACanvas, ARect);
    1: FillValue(APokemon.TeraTyping, ACanvas, ARect);
    2: FillValue(APokemon.Ability, ACanvas, ARect);
    3: FillValue(APokemon.Item, ACanvas, ARect);
    else
      FillValue(APokemon.MoveName[ARow - 4], ACanvas, ARect);
  end;
end;

procedure TFrame.FillStatRow(const APokemon: TPokemon; const ACanvas: TCanvas;
  const ARow: Integer; ARect: TRect);
var
  LHeaderRect: TRect;
  LOriginalFontSize: Integer;
  LStatName: string;
begin
  LHeaderRect := Rect(ARect.Left - 2, ARect.Top - 2, ARect.Right - 2, ARect.Bottom -2);
  LOriginalFontSize := ACanvas.Font.Size;
  case ARow of
    0:
    begin
      ACanvas.Font.Size := 5;
      FillValue('Level', ACanvas, LHeaderRect, taLeft, False);
      ACanvas.Font.Size := LOriginalFontSize;
      FillValue(IntToStr(APokemon.Level), ACanvas, ARect, taRight);
      Exit;
    end;
    1: LStatName := 'HP';
    2: LStatName := 'Atk';
    3: LStatName := 'Def';
    4: LStatName := 'Sp. Atk';
    5: LStatName := 'Sp. Def';
    6: LStatName := 'Speed';
  end;
  ACanvas.Font.Size := 5;
  FillValue(LStatName, ACanvas, LHeaderRect, taLeft, False);
  ACanvas.Font.Size := LOriginalFontSize;
  FillValue(IntToStr(APokemon.Stat[LStatName]), ACanvas, ARect, taRight);
end;

procedure TFrame.FillValue(const AValue: string; const ACanvas: TCanvas;
  ARect: TRect; const ATextAlignment: Char; const ADrawRect: Boolean);
var
  LRect: TRect;
  LTopMargin: Integer;
begin
  if ADrawRect then
    ACanvas.Rectangle(ARect);
  LTopMargin := Round((ARect.Height - ACanvas.TextHeight(AValue)) / 2);
  LRect := Rect(ARect.Left + 5, ARect.Top + LTopMargin - 3, ARect.Right - 5, ARect.Bottom - LTopMargin + 3);
  AlignText(ACanvas.TextWidth(AValue), LRect, ATextAlignment);
  ACanvas.TextRect(LRect, LRect.Left, LRect.Top, AValue);
end;

procedure TFrame.PaintCanvas(const ACanvas: TCanvas);
begin
end;

end.
