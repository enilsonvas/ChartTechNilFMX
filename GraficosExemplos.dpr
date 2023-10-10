program GraficosExemplos;

uses
  System.StartUpCopy,
  FMX.Forms,
  FrmModelo in 'FrmModelo.pas' {Form1},
  uChartTechNil.BarHorz in 'uChartTechNil.BarHorz.pas',
  uChartTechNil.Factory in 'uChartTechNil.Factory.pas',
  uChartTechNil.Interfaces in 'uChartTechNil.Interfaces.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
