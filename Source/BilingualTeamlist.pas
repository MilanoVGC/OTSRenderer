unit BilingualTeamlist;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.Grids, Vcl.ExtCtrls,
  Pokeparser, TeamlistTemplateFrame, Vcl.StdCtrls;

type
  TBilingualTemplate = class(TFrame)
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
    LblPlayerName: TLabel;
    LblHeaderPlayerName: TLabel;
    LblTrainerName: TLabel;
    LblHeaderTrainerName: TLabel;
    LblSecondLanguage1: TLabel;
    LblDefaultLanguage1: TLabel;
    LblSecondLanguage2: TLabel;
    LblDefaultLanguage2: TLabel;
  private
    { Private declarations }
    FExtraLanguageId: string;
  public
    { Public declarations }
    property SecondLanguage: string read FExtraLanguageId write FExtraLanguageId;
    procedure PaintCanvas(const ACanvas: TCanvas); override;
  end;

implementation

uses
  UITypes,
  AkUtils;

{$R *.dfm}

{ TBilingualTemplate }

procedure TBilingualTemplate.PaintCanvas(const ACanvas: TCanvas);
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
  ACanvas.Brush.Style := bsClear;
  ACanvas.Font.Name := TAkLanguageRegistry.Instance.DefaultLanguage.FontName;

  for I := 0 to PnlPageLayout.ControlCount - 1 do
  begin
    if PnlPageLayout.Controls[I] is TStringGrid then
    begin
      LGrid := PnlPageLayout.Controls[I] as TStringGrid;
      LIndex := StrToInt(RemoveStrings(LGrid.Name, ['Grd', 'Header', 'Pokemon'])) - 1;

      for CIndex := 0 to LGrid.ColCount - 1 do
      begin
        if CIndex = 0 then
          Pokepaste.LanguageId := SecondLanguage
        else
          Pokepaste.Language := TAkLanguageRegistry.Instance.DefaultLanguage;
        for RIndex := 0 to LGrid.RowCount - 1 do
        begin
          LRect := CellRect(LGrid, CIndex, RIndex);
          if StrContains(LGrid.Name, 'Header') then
            FillHeaderRow(ACanvas, RIndex, LRect)
          else
          begin
            ACanvas.Font.Name := Pokepaste.Language.FontName;
            FillPokemonRow(Pokepaste.Pokemon[LIndex], ACanvas, RIndex, LRect);
            ACanvas.Font.Name := TAkLanguageRegistry.Instance.DefaultLanguage.FontName;
          end;
        end;
      end;
    end
    else if PnlPageLayout.Controls[I] is TLabel then
    begin
      LLabel := PnlPageLayout.Controls[I] as TLabel;
      if StrContains(LLabel.Name, 'Header') then
        FillLabel(LLabel, ACanvas)
      else if not StrContains(LLabel.Name, 'Language') then
      begin
        LLabel.Caption := Pokepaste[RemoveStrings(LLabel.Name, ['Lbl'])];
        FillLabel(LLabel, ACanvas);
      end
      else if StrContains(LLabel.Name, 'DefaultLanguage') then
      begin
        ACanvas.Font.Name := TAkLanguageRegistry.Instance.DefaultLanguage.FontName;
        LLabel.Caption := TAkLanguageRegistry.Instance.DefaultLanguage.Description;
        FillLabel(LLabel, ACanvas);
      end
      else
      begin
        ACanvas.Font.Name := TAkLanguageRegistry.Instance[SecondLanguage].FontName;
        LLabel.Caption := TAkLanguageRegistry.Instance[SecondLanguage].Description;
        FillLabel(LLabel, ACanvas);
        ACanvas.Font.Name := TAkLanguageRegistry.Instance.DefaultLanguage.FontName;
      end;
    end;
  end;
end;

end.
