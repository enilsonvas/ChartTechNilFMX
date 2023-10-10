unit uChartTechNil.Cicle;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.UITypes,
  System.Generics.Collections,
  System.Math,

  Data.DB,

  FMX.Layouts,
  FMX.Objects,
  FMX.Graphics,
  FMX.StdCtrls,
  FMX.Types,

  uChartTechNil.Interfaces;

type
  TMaxValue = class
  private

  public
    Total: Double;
    constructor Create;
  end;

  TChartBarHorz = class(TInterfacedObject, iCicle)
  private
    FLayout       : TLayout;
    FLayoutGrafico: TLayout;
    FLayoutLegend : TLayout;
    FLayoutTitle  : TLayout;

    FPosLegenda : TPosLegenda;
    FJsonArray: TJSONArray;
    FDataSet: TDataSet;

    FColorArgument: TList<TAlphaColor>;
    FFieldNameValue: TStringList;
    FTextBar: TStringList;
    FLegendTextAnt: TStringList;

    FFormatValue: string;
  public
    class function New: iCicle;

    constructor Create;
    destructor Destroy; override;

    function Layout(aLayout: TLayout): iCicle;
    function PosLegenda(aPos: TPosLegenda): iCicle;

    function JsonArray(aJsonArray: TJSONArray): iCicle;
    function DataSet(aDataSet: TDataSet): iCicle;
    function AddFieldNameValue(aFieldNameValue: string): iCicle;
    function AddColorArgument(aColor: TAlphaColor): iCicle;
    function FormatValue(aFormatValue: string): iCicle;

    procedure CarregarChart;
  end;

implementation

{ TMaxValue }

constructor TMaxValue.Create;
begin
  Total := 0;
end;

{ TChartBarHorz }

function TChartBarHorz.AddColorArgument(aColor: TAlphaColor): iCicle;
begin
  Result := Self;
  FColorArgument.Add(aColor);
end;

function TChartBarHorz.AddFieldNameValue(aFieldNameValue: string): iCicle;
begin
  Result := Self;
  FFieldNameValue.Add(aFieldNameValue);
end;

procedure TChartBarHorz.CarregarChart;
begin

end;

constructor TChartBarHorz.Create;
begin
  FColorArgument  := TList<TAlphaColor>.Create;
  FFieldNameValue := TStringList.Create;
  FTextBar        := TStringList.Create;
  FLegendTextAnt  := TStringList.Create;
end;

function TChartBarHorz.DataSet(aDataSet: TDataSet): iCicle;
begin
  Result := Self;
  FDataSet := aDataSet;
end;

destructor TChartBarHorz.Destroy;
begin
  FColorArgument.DisposeOf;
  FFieldNameValue.DisposeOf;
  FTextBar.DisposeOf;
  FLegendTextAnt.DisposeOf;

  inherited;
end;

function TChartBarHorz.FormatValue(aFormatValue: string): iCicle;
begin
  Result := Self;
  FFormatValue := aFormatValue;
end;

function TChartBarHorz.JsonArray(aJsonArray: TJSONArray): iCicle;
begin
  Result := Self;
  FJsonArray := aJsonArray;
end;

function TChartBarHorz.Layout(aLayout: TLayout): iCicle;
begin
  Result := Self;
  FLayout := aLayout;
end;

class function TChartBarHorz.New: iCicle;
begin
  Result := Self.Create;
end;

function TChartBarHorz.PosLegenda(aPos: TPosLegenda): iCicle;
begin
  Result := Self;
  FPosLegenda := aPos;
end;

end.
