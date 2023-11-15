unit PdfTemplateFrame;

interface

uses
  Vcl.Graphics, Vcl.Forms;

type
  TFrame = class(Vcl.Forms.TFrame)
  public
    procedure PaintCanvas(const ACanvas: TCanvas); virtual;
  end;

implementation

{ TFrame }

procedure TFrame.PaintCanvas(const ACanvas: TCanvas);
begin

end;

end.
