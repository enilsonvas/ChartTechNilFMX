unit uChartTechNil.Interfaces;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.UITypes,


  Data.DB,

  FMX.Layouts;

type
  TPosLegenda = (aNone, aLeft, aRight, aBotoom);

  iBarHorz = interface
    ['{FCAF8907-0FFA-444D-9181-B63075A50837}']

    function Layout(aLayout: TLayout): iBarHorz;
    function PosLegenda(aPos: TPosLegenda): iBarHorz;

    function JsonArray(aJsonArray: TJSONArray): iBarHorz;
    function DataSet(aDataSet: TDataSet): iBarHorz;

    function Title(aTitle: string): iBarHorz;

    function AddFieldNameArgument(aFieldNameArgument: string): iBarHorz;
    function AddColorArgument(aColor: TAlphaColor): iBarHorz;
    function AddFieldNameValue(aFieldNameValue: string): iBarHorz;
    function AddTextArgument(aTextArgument: string): iBarHorz;
    function AddTextBar(aTextBar: string): iBarHorz;

    function FormatValue(aFormatValue: string): iBarHorz;

    function SizeFontValue(aSize: Single): iBarHorz;
    function SizeFontArgument(aSize: Single): iBarHorz;
    function SizeFontBarName(aSize: Single): iBarHorz;

    function FontTitleFamily(aFontFamily: TFontName): iBarHorz;
    procedure CarregarChart;
  end;

  iBarVert = interface
    ['{4AAEBCEF-2E27-4B5B-BF0E-CD33BD30F3E9}']
  end;

  iDonut = interface
    ['{F158B060-B851-4584-87ED-61E9F970289C}']
  end;

  iCicle = interface
    ['{7AB03023-4DC9-46B0-8863-8047602C1319}']
  end;

  iLine = interface
    ['{BFA0CFB6-33D1-4B71-81E8-3202320787F3}']
  end;


  iChartFactory = interface
    ['{30C41487-F609-4B12-B448-D11385E0E190}']
    function BarHorz: iBarHorz;
  end;

  TChartFactory = class(TInterfacedObject, iChartFactory)
    class function New: iChartFactory;
    function BarHorz: iBarHorz;
    function BarVert: iBarVert;
    function Dount  : iDonut;
    function Pizza  : iCicle;
    function Line   : iLine;
  end;

implementation

uses
  uChartTechNil.BarHorz;

{ TChartFactory }

function TChartFactory.BarHorz: iBarHorz;
begin
  Result := TChartBarHorz.New;
end;

function TChartFactory.BarVert: iBarVert;
begin

end;

function TChartFactory.Dount: iDonut;
begin

end;

function TChartFactory.Line: iLine;
begin

end;

class function TChartFactory.New: iChartFactory;
begin
  Result := Self.Create;
end;


function TChartFactory.Pizza: iCicle;
begin

end;

end.
