program test_units_unicode;

//FastMM4 in '..\..\_Share\extern\FastMM\FastMM4.pas',
//FastMM4Messages in '..\..\_Share\extern\FastMM\FastMM4Messages.pas',

uses
  Vcl.Forms,
  Unit1 in 'Unit1.pas' {Testform},

  unicode_decode_unit in '..\unicode_decode_unit.pas',
  unicode_def_unit in '..\unicode_def_unit.pas',
  unicode_encode_unit in '..\unicode_encode_unit.pas',
  unicode_util_unit in '..\unicode_util_unit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestform, Testform);
  Application.Run;
end.
