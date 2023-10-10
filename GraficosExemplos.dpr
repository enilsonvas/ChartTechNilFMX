program GraficosExemplos;

uses
  System.StartUpCopy,
  FMX.Forms,
  FrmModelo in 'FrmModelo.pas' {Form1},
  uChartTechNil.BarHorz in 'uChartTechNil.BarHorz.pas',
  uChartTechNil.Factory in 'uChartTechNil.Factory.pas',
  uChartTechNil.Interfaces in 'uChartTechNil.Interfaces.pas',
  uChartTechNil.BarVert in 'uChartTechNil.BarVert.pas',
  uChartTechNil.Cicle in 'uChartTechNil.Cicle.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
