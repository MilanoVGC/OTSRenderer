unit AkUtilsVcl;

interface

uses
  SysUtils,
  Winapi.Windows,
  Vcl.Graphics, Vcl.Imaging.pngimage, Vcl.Controls;

function ColorToHex(const AColor: TColor): string;
function HexToColor(const AHex: string): TColor;
procedure SmoothResize(apng:tpngimage; NuWidth,NuHeight:integer);

implementation


function ColorToHex(const AColor: TColor): string;
var
  LRValue: Word;
  LGValue: Word;
  LBValue: Word;
begin
  LRValue := GetRValue(AColor);
  LGValue := GetGValue(AColor);
  LBValue := GetBValue(AColor);
  Result := '#' + IntToHex(LRValue, 2) + IntToHex(LGValue, 2) + IntToHex(LBValue, 2);
end;

function HexToColor(const AHex: string): TColor;
var
  LHexStr: string;
begin
  LHexStr := AHex;
  if not Pos('#', LHexStr) = 1 then
    LHexStr := '#' + LHexStr;

  Result := StrToInt64('$00' +
    Copy(LHexStr, Pos('#', LHexStr) + 5, 2) +
    Copy(LHexStr, Pos('#', LHexStr) + 3, 2) +
    Copy(LHexStr, Pos('#', LHexStr) + 1, 2));
end;

/// taken from http://cc.embarcadero.com/Item/25631
procedure SmoothResize(apng:tpngimage; NuWidth,NuHeight:integer);
var
  xscale, yscale         : Single;
  sfrom_y, sfrom_x       : Single;
  ifrom_y, ifrom_x       : Integer;
  to_y, to_x             : Integer;
  weight_x, weight_y     : array[0..1] of Single;
  weight                 : Single;
  new_red, new_green     : Integer;
  new_blue, new_alpha    : Integer;
  new_colortype          : Integer;
  total_red, total_green : Single;
  total_blue, total_alpha: Single;
  IsAlpha                : Boolean;
  ix, iy                 : Integer;
  bTmp : TPngImage;
  sli, slo : pRGBLine;
  ali, alo: pbytearray;
begin
  if not (apng.Header.ColorType in [COLOR_RGBALPHA, COLOR_RGB]) then
    raise Exception.Create('Only COLOR_RGBALPHA and COLOR_RGB formats' +
    ' are supported');
  IsAlpha := apng.Header.ColorType in [COLOR_RGBALPHA];
  if IsAlpha then new_colortype := COLOR_RGBALPHA else
    new_colortype := COLOR_RGB;
  bTmp := TPngImage.CreateBlank(new_colortype, 8, NuWidth, NuHeight);
  xscale := bTmp.Width / (apng.Width-1);
  yscale := bTmp.Height / (apng.Height-1);
  for to_y := 0 to bTmp.Height-1 do begin
    sfrom_y := to_y / yscale;
    ifrom_y := Trunc(sfrom_y);
    weight_y[1] := sfrom_y - ifrom_y;
    weight_y[0] := 1 - weight_y[1];
    for to_x := 0 to bTmp.Width-1 do begin
      sfrom_x := to_x / xscale;
      ifrom_x := Trunc(sfrom_x);
      weight_x[1] := sfrom_x - ifrom_x;
      weight_x[0] := 1 - weight_x[1];

      total_red   := 0.0;
      total_green := 0.0;
      total_blue  := 0.0;
      total_alpha  := 0.0;
      for ix := 0 to 1 do begin
        for iy := 0 to 1 do begin
          sli := apng.Scanline[ifrom_y + iy];

          new_red := sli[ifrom_x + ix].rgbtRed;
          new_green := sli[ifrom_x + ix].rgbtGreen;
          new_blue := sli[ifrom_x + ix].rgbtBlue;
          weight := weight_x[ix] * weight_y[iy];
          total_red   := total_red   + new_red   * weight;
          total_green := total_green + new_green * weight;
          total_blue  := total_blue  + new_blue  * weight;
          if IsAlpha then
          begin
            ali := apng.AlphaScanline[ifrom_y + iy];
            new_alpha := ali[ifrom_x + ix];
            total_alpha := total_alpha + new_alpha * weight;
          end;
        end;
      end;
      slo := bTmp.ScanLine[to_y];
      slo[to_x].rgbtRed := Round(total_red);
      slo[to_x].rgbtGreen := Round(total_green);
      slo[to_x].rgbtBlue := Round(total_blue);
      if isAlpha then
      begin
        alo := bTmp.AlphaScanLine[to_y];
        alo[to_x] := Round(total_alpha);
      end;
    end;
  end;
  apng.Assign(bTmp);
  bTmp.Free;
end;

end.
