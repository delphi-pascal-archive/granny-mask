program Feathering;

uses
  Forms,
  ScreenFeathering in 'ScreenFeathering.pas' {FormFeathering},
  VectorGraphicsNodeLibrary in 'VectorGraphicsNodeLibrary.PAS',
  LineLibrary in 'LineLibrary.pas',
  VectorGraphicsListLibrary in 'VectorGraphicsListLibrary.PAS',
  ScreenJPEGQuality in 'ScreenJPEGQuality.pas' {FormJPEGQuality};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TFormFeathering, FormFeathering);
  Application.Run;
end.
