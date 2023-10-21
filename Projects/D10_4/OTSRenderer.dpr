program OTSRenderer;

uses
  Vcl.Forms,
  MainFormUnit in '..\..\Source\MainFormUnit.pas' {MainForm},
  PokeParser in '..\..\Source\PokeParser.pas',
  PokeUtils in '..\..\Source\PokeUtils.pas',
  CsvParser in '..\..\Source\CsvParser.pas',
  AKUtils in '..\..\Source\AKUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
