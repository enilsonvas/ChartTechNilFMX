unit uChartTechNil.Factory;

interface

uses
  System.SysUtils,
  System.Classes,

  uChartTechNil.Interfaces,
  uChartTechNil.BarHorz;

type
  TChartFactory = class(TInterfacedObject, iChartFactory)
    class function New: iChartFactory;
    function BarHorz: iBarHorz;
  end;
implementation

{ TChartFactory }

function TChartFactory.BarHorz: iBarHorz;
begin
  Result := TChartBarHorz.New;
end;

class function TChartFactory.New: iChartFactory;
begin
  Result := Self.Create;
end;

end.
