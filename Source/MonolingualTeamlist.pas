unit MonolingualTeamlist;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.ExtCtrls,
  Pokeparser, TeamlistTemplateFrame, Vcl.StdCtrls;

type
  TMonolingualTemplate = class(TFrame)
    PnlPageLayout: TPanel;
    GrdPokemon1: TStringGrid;
    GrdPokemon2: TStringGrid;
    GrdPokemon3: TStringGrid;
    GrdPokemon4: TStringGrid;
    GrdPokemon5: TStringGrid;
    GrdPokemon6: TStringGrid;
    GrdHeaderPokemon1: TStringGrid;
    GrdHeaderPokemon2: TStringGrid;
    GrdHeaderPokemon3: TStringGrid;
    GrdHeaderPokemon4: TStringGrid;
    GrdHeaderPokemon5: TStringGrid;
    GrdHeaderPokemon6: TStringGrid;
    GrdStatPokemon1: TStringGrid;
    GrdStatPokemon2: TStringGrid;
    GrdStatPokemon3: TStringGrid;
    GrdStatPokemon4: TStringGrid;
    GrdStatPokemon5: TStringGrid;
    GrdStatPokemon6: TStringGrid;
    LblAgeDivision: TLabel;
    LblBattleTeam: TLabel;
    LblBirthDate: TLabel;
    LblHeaderAgeDivision: TLabel;
    LblHeaderBattleTeam: TLabel;
    LblHeaderBirthDate: TLabel;
    LblHeaderPlayerId: TLabel;
    LblHeaderPlayerName: TLabel;
    LblHeaderProfile: TLabel;
    LblHeaderTrainerName: TLabel;
    LblPlayerId: TLabel;
    LblPlayerName: TLabel;
    LblProfile: TLabel;
    LblTrainerName: TLabel;
    LblTitle: TLabel;
  private
    { Private declarations }
    FIsOpen: Boolean;
  public
    { Public declarations }
    property IsOpen: Boolean read FIsOpen write FIsOpen;
    procedure PaintCanvas(const ACanvas: TCanvas); override;
  end;

implementation

uses
  UITypes,
  AkUtils;

{$R *.dfm}

{ TMonolingualTemplate }

procedure TMonolingualTemplate.PaintCanvas(const ACanvas: TCanvas);
var
  LGrid: TStringGrid;
  LLabel: TLabel;
  LIndex: Integer;
  LRect: TRect;
  I: Integer;
  CIndex: Integer;
  RIndex: Integer;
begin
  inherited;
  Assert(Assigned(Pokepaste));

  ACanvas.Pen.Color := clBlack;
  ACanvas.Font.Size := 8;
  ACanvas.Font.Name := Pokepaste.Language.FontName;
  ACanvas.Brush.Style := bsClear;

  for I := 0 to PnlPageLayout.ControlCount - 1 do
  begin
    if PnlPageLayout.Controls[I] is TStringGrid then
    begin
      LGrid := PnlPageLayout.Controls[I] as TStringGrid;

      if IsOpen and StrContains(LGrid.Name, 'Stat') then
        Continue;

      LIndex := StrToInt(RemoveStrings(LGrid.Name, ['Grd', 'Header', 'Pokemon', 'Stat'])) - 1;

      for CIndex := 0 to LGrid.ColCount - 1 do
      begin
        for RIndex := 0 to LGrid.RowCount - 1 do
        begin
          LRect := CellRect(LGrid, CIndex, RIndex);
          if StrContains(LGrid.Name, 'Header') then
            FillHeaderRow(ACanvas, RIndex, LRect)
          else if StrContains(LGrid.Name, 'Stat') then
            FillStatRow(Pokepaste.Pokemon[LIndex], ACanvas, RIndex, LRect)
          else
            FillPokemonRow(Pokepaste.Pokemon[LIndex], ACanvas, RIndex, LRect);
        end;
      end;
    end
    else if PnlPageLayout.Controls[I] is TLabel then
    begin
      LLabel := PnlPageLayout.Controls[I] as TLabel;

      // Skip all the CTS labels
      if IsOpen and not StrContains(LLabel.Name, ['Title', 'PlayerName', 'TrainerName']) then
        Continue;

      // Adjust spacing for OTS
      if IsOpen then
        LLabel.Top := LLabel.Top + 30;

      if StrContains(LLabel.Name, 'Header') then
      begin
        ACanvas.Font.Name := TAkLanguageRegistry.Instance.DefaultLanguage.FontName;
        FillLabel(LLabel, ACanvas, taRight);
        ACanvas.Font.Name := Pokepaste.Language.FontName;
      end
      else if StrContains(LLabel.Name, 'Title') then
      begin
        if IsOpen then
          LLabel.Caption := StringReplace(LLabel.Caption, 'Tournament Staff', 'Opponents', [rfReplaceAll, rfIgnoreCase]);
        FillLabel(LLabel, ACanvas, taCenter);
      end
      else
      begin
        LLabel.Caption := Pokepaste[RemoveStrings(LLabel.Name, ['Lbl'])];
        FillLabel(LLabel, ACanvas);
      end;
    end;
  end;
end;

end.
