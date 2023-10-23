program OTSRenderer;

uses
  Vcl.Forms,
  MainFormUnit in '..\..\Source\MainFormUnit.pas' {MainForm},
  PokeParser in '..\..\Source\PokeParser.pas',
  PokeUtils in '..\..\Source\PokeUtils.pas',
  AkUtils in '..\..\Source\AkLib\AkUtils.pas',
  CsvParser in '..\..\Source\AkLib\CsvParser.pas',
  AkUtilsVcl in '..\..\Source\AkLib\AkUtilsVcl.pas',
  PokeParserVcl in '..\..\Source\PokeParserVcl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
