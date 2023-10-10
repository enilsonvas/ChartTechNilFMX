unit FrmModelo;

interface

uses
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Classes,
  System.Variants,

  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.StdCtrls,

  uChartTechNil.Interfaces,
  uChartTechNil.Factory, Data.DB, Datasnap.DBClient, FMX.Objects;

type
  TForm1 = class(TForm)
    spbBar: TSpeedButton;
    cds: TClientDataSet;
    cdsMES: TIntegerField;
    cdsCMES: TStringField;
    cdsRECEITA: TFloatField;
    cdsDESPESA: TFloatField;
    cdsLIQUIDO: TFloatField;
    lytModBarHorz: TLayout;
    Rectangle1: TRectangle;
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
    procedure spbBarClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormShow(Sender: TObject);
begin

 Caption := Width.ToString+' X' + Height.ToString;
end;

procedure TForm1.spbBarClick(Sender: TObject);
var
  BarHorz: iBarHorz;
  I: Integer;
begin
  cds.Close;
  cds.CreateDataSet;

  for I := 1 to 12 do
    begin
      cds.Append;
      cdsMES.AsInteger := i;
      case I of
        1 : cdsCMES.AsString := 'JANEIRO';
        2 : cdsCMES.AsString := 'FEVEREIRO';
        3 : cdsCMES.AsString := 'MARÇO';
        4 : cdsCMES.AsString := 'ABRIL';
        5 : cdsCMES.AsString := 'MAIO';
        6 : cdsCMES.AsString := 'JUNHO';
        7 : cdsCMES.AsString := 'JULHO';
        8 : cdsCMES.AsString := 'AGOSTO';
        9 : cdsCMES.AsString := 'SETEMBRO';
        10: cdsCMES.AsString := 'OUTUBRO';
        11: cdsCMES.AsString := 'NOVEMBRO';
        12: cdsCMES.AsString := 'DEZEMBRO';
      end;

      cdsRECEITA.AsFloat := Random(999999);
      cdsDESPESA.AsFloat := Random(999999);
      cdsLIQUIDO.AsFloat := Random(999999);
      cds.Post;
    end;

  BarHorz := TChartFactory.New.BarHorz;

  BarHorz
   .Layout(lytModBarHorz)
   .PosLegenda(aRight)
   .DataSet(cds)
    .Title('COMPARATIOVO MENSAL')
    .AddFieldNameArgument(cdsMES.FieldName)
    .AddFieldNameValue(cdsRECEITA.FieldName)
//    .AddFieldNameValue(cdsDESPESA.FieldName)
    .AddTextArgument(cdsCMES.FieldName)
//    .AddTextBar('RECEITA')
//    .AddTextBar('DESPESAS')
//    .AddColorArgument(TAlphaColors.Mediumblue)
//    .AddColorArgument(TAlphaColors.Orangered)
    .FormatValue('R$ #,0.00')
    .CarregarChart;
end;

end.
