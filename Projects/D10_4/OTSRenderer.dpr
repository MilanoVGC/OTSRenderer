program OTSRenderer;

uses
  Vcl.Forms,
  MainFormUnit in '..\..\Source\MainFormUnit.pas' {MainForm},
  PokeParser in '..\..\Source\PokeParser.pas',
  PokeUtils in '..\..\Source\PokeUtils.pas',
  AkUtils in '..\..\Source\AkLib\AkUtils.pas',
  CsvParser in '..\..\Source\AkLib\CsvParser.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
