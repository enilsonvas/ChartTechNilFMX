unit uChartTechNil.BarHorz;

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

  TChartBarHorz = class(TInterfacedObject, iBarHorz)
  private
    FLayout: TLayout;
    FJsonArray: TJSONArray;
    FDataSet: TDataSet;

    FColorArgument: TList<TAlphaColor>;
    FFieldNameValue: TStringList;
    FTextBar: TStringList;

    FFormatValue: string;
    FFieldNameArgument: string;
    FTextArgument: string;


    FLayoutHeight: Single;
    FLayoutWidth: Single;

    FRecordCount: Integer;
    aID: Integer;

    FSizeFontValue   : Single;
    FSizeFontArgument: Single;
    FSizeFontBarName : Single;

    function AddBar(aLayout: TLayout;
      aBarName, aFormatValue: string; aValue, aMaxValue: Double; aWidth: Single;
      aColor: TAlphaColor=$00000000; idxBar: Integer=0): TLayout;

    procedure ClearLayout;
    procedure CarregaDataSet;
    procedure CarregaJson;

  public
    TotalMax: TObjectList<TMaxValue>;

    class function New: iBarHorz;
    constructor Create;
    destructor Destroy; override;

    function Layout(aLayout: TLayout): iBarHorz;
    function JsonArray(aJsonArray: TJSONArray): iBarHorz;
    function DataSet(aDataSet: TDataSet): iBarHorz;

    function AddFieldNameArgument(aFieldNameArgument: string): iBarHorz;
    function AddColorArgument(aColor: TAlphaColor): iBarHorz;
    function AddFieldNameValue(aFieldNameValue: string): iBarHorz;
    function AddTextArgument(aTextArgument: string): iBarHorz;
    function AddTextBar(aTextBar: string): iBarHorz;

    function FormatValue(aFormatValue: string): iBarHorz;

    function SizeFontValue(aSize: Single): iBarHorz;
    function SizeFontArgument(aSize: Single): iBarHorz;
    function SizeFontBarName(aSize: Single): iBarHorz;

    procedure CarregarChart;
  end;

implementation

{ TChartBarHorz }

function TChartBarHorz.AddBar(aLayout: TLayout;
      aBarName, aFormatValue: string; aValue, aMaxValue: Double; aWidth: Single;
      aColor: TAlphaColor=$00000000; idxBar: Integer=0): TLayout;
var
  LBar: TRectangle;
  lblBarName, lblBarValue: TLabel;
  Perc: Double;
  LHeight: Single;
begin
  Inc(aID);
  Result := nil;

  Result        := TLayout.Create(aLayout);
  Result.Parent := aLayout;
  Result.Name   := 'LytBar_'+aID.ToString;
  Result.Width  := aWidth;
  Result.Height := aLayout.Height;
  Result.Tag    := aID;
  Result.Position.Y := 0;

  Result.Position.X := aWidth * idxBar;

  //LABEL ARGUMENT
  lblBarName          := TLabel.Create(Result);
  lblBarName.Parent   := Result;
  lblBarName.Name     := 'lblBarName_'+aID.ToString;
  lblBarName.Height   := 30;
  lblBarName.AutoSize := True;

  lblBarName.StyledSettings := [];
  lblBarName.TextSettings.HorzAlign := TTextAlign.Center;
  lblBarName.TextSettings.Trimming  := TTextTrimming.Word;

  lblBarName.Font.Style := [TFontStyle.fsBold];

  if FSizeFontBarName > 0 then
    lblBarName.Font.Size := FSizeFontBarName;

  lblBarName.Text     := aBarName;

  //RECTANGLE
  LBar        := TRectangle.Create(Result);
  LBar.Parent := Result;
  LBar.Name   := 'LBar_'+aID.ToString;
  LBar.Stroke.Kind := TBrushKind.None;
  LBar.Margins.Left := 3;

  if aColor <> TAlphaColors.Null then
    LBar.Fill.Color := aColor;

  Perc := SimpleRoundTo((aValue / aMaxValue) * 100);

  LHeight := aLayout.Height - Trunc((100 - SimpleRoundTo((aLayout.Height * Perc) / 100)));
  LBar.AnimateFloat('Height', LHeight , 0.8, TAnimationType.In, TInterpolationType.Back);


  lblBarName.Align := TAlignLayout.MostBottom;
  LBar.Align       := TAlignLayout.Bottom;

  //FIELD VALUE
  lblBarValue          := TLabel.Create(Result);
  lblBarValue.Parent   := Result;
  lblBarValue.Name     := 'lblBarValue_'+aID.ToString;
  lblBarValue.AutoSize := True;

  if FSizeFontValue > 0 then
    lblBarValue.Font.Size := FSizeFontValue;

  lblBarValue.Font.Style := [TFontStyle.fsBold];
  lblBarValue.StyledSettings := [];
  lblBarValue.TextSettings.HorzAlign := TTextAlign.Center;
  lblBarValue.TextSettings.Trimming  := TTextTrimming.Word;

  if FFormatValue <> '' then
    lblBarValue.Text := FormatCurr(FFormatValue, aValue)
  else
    lblBarValue.Text := aValue.ToString;

  lblBarValue.Align := TAlignLayout.Bottom;
end;

function TChartBarHorz.AddColorArgument(aColor: TAlphaColor): iBarHorz;
begin
  Result := Self;
  FColorArgument.Add(aColor);
end;

function TChartBarHorz.AddFieldNameArgument(aFieldNameArgument: string)
  : iBarHorz;
begin
  Result := Self;
  FFieldNameArgument := aFieldNameArgument;
end;

function TChartBarHorz.AddFieldNameValue(aFieldNameValue: string): iBarHorz;
begin
  Result := Self;
  FFieldNameValue.Add(aFieldNameValue);
end;

function TChartBarHorz.AddTextArgument(aTextArgument: string): iBarHorz;
begin
  Result := Self;
  FTextArgument := aTextArgument;
end;

function TChartBarHorz.AddTextBar(aTextBar: string): iBarHorz;
begin
  Result := Self;
  FTextBar.Add(aTextBar);
end;

procedure TChartBarHorz.CarregarChart;
begin
  ClearLayout;

  if FLayout = nil then
    raise Exception.Create('Por favor informar o componente TLayout.');

  if (FJsonArray = nil) and (FDataSet = nil) then
    raise Exception.Create
      ('Por favor informar os dados através do DataSet ou JsonArray.');

  if (FJsonArray <> nil) and (FDataSet <> nil) then
    raise Exception.Create
      ('Por favor informar os dados Somente através do DataSet ou JsonArray.');

  if (FDataSet <> nil) and (FDataSet.RecordCount = 0) then
    raise Exception.Create('DataSet não contem dados.');

  if (FJsonArray <> nil) and (FJsonArray.Size > 0) then
    raise Exception.Create('JsonArray não contem dados.');

  if FFieldNameArgument.IsEmpty then
    raise Exception.Create('Favor informar o FieldNameArgument.');

  if FFieldNameValue.Count = 0 then
    raise Exception.Create('Favor informar o FieldNameValue.');

  FLayout.BeginUpdate;

  if FDataSet <> nil then
    CarregaDataSet
  else if FJsonArray <> nil then
    CarregaJson;

  FLayout.EndUpdate;
end;

procedure TChartBarHorz.CarregaDataSet;
var
  I: Integer;
  LTotalMax: TMaxValue;
  LLayoutBase: TLayout;
  lblBarArgument: TLabel;
begin
  FDataSet.DisableControls;

  FRecordCount  := FDataSet.RecordCount;
  FLayoutHeight := FLayout.Height - 10;
  FLayoutWidth  := FLayout.Width - 70;

  for I := 0 to FFieldNameValue.Count - 1 do
    begin
      LTotalMax := TMaxValue.Create;

      FDataSet.First;
      while not FDataSet.Eof do
        begin
          LTotalMax.Total := LTotalMax.Total + FDataSet.FieldByName(FFieldNameValue.Strings[i]).AsFloat;
          FDataSet.Next;
        end;

      TotalMax.Add(LTotalMax);
    end;

  FDataSet.First;
  while not FDataSet.Eof do
    begin
      LLayoutBase        := TLayout.Create(FLayout);
      LLayoutBase.Parent := FLayout;
      LLayoutBase.Name   := 'LLayoutBase_' + FDataSet.RecNo.ToString;
      LLayoutBase.Align  := TAlignLayout.Left;
      LLayoutBase.Width  := Trunc(FLayoutWidth / FRecordCount);
      LLayoutBase.Height := FLayoutHeight;

      LLayoutBase.Margins.Left   := 2;
      LLayoutBase.Margins.Top    := 5;
      LLayoutBase.Margins.Bottom := 5;

      //LABEL ARGUMENT
      lblBarArgument          := TLabel.Create(LLayoutBase);
      lblBarArgument.Align    := TAlignLayout.MostBottom;
      lblBarArgument.Parent   := LLayoutBase;
      lblBarArgument.Name     := 'lblBarArgument_' + aID.ToString;
      lblBarArgument.Height   := 20;
      lblBarArgument.AutoSize := True;
      lblBarArgument.Text     := FDataSet.FieldByName(FFieldNameArgument).AsString;

      lblBarArgument.StyledSettings := [];

      lblBarArgument.TextSettings.HorzAlign := TTextAlign.Center;
      lblBarArgument.TextSettings.Trimming  := TTextTrimming.Word;

      lblBarArgument.Font.Style := [TFontStyle.fsBold];

      if FSizeFontArgument > 0 then
        lblBarArgument.Font.Size := FSizeFontArgument;

      LLayoutBase.Height := FLayoutHeight - lblBarArgument.Height;

      for I := 0 to FFieldNameValue.Count - 1 do
        begin
          AddBar(LLayoutBase,
                 FTextBar.Strings[i],
                 FFormatValue,
                 FDataSet.FieldByName(FFieldNameValue.Strings[i]).AsFloat,
                 TotalMax.Items[i].Total,
                 (LLayoutBase.Width / FFieldNameValue.Count),
                 FColorArgument.Items[i], i);
        end;

      FDataSet.Next;
    end;

  FDataSet.EnableControls;
end;

procedure TChartBarHorz.CarregaJson;
var
  I: Integer;
  LTotalMax: TMaxValue;
  LJsonObj: TJSONObject;
  LLayoutBase: TLayout;
  lblBarArgument: TLabel;
  X: Integer;
begin
  FRecordCount := FJsonArray.Count;
  FLayoutHeight := FLayout.Height - 10;
  FLayoutWidth  := FLayout.Width - 70;

  for I := 0 to FFieldNameValue.Count - 1 do
    begin
      LTotalMax := TMaxValue.Create;

      FJsonArray
      while not FDataSet.Eof do
        begin
          LTotalMax.Total := LTotalMax.Total + FDataSet.FieldByName(FFieldNameValue.Strings[i]).AsFloat;

          FDataSet.Next;
        end;

      TotalMax.Add(LTotalMax);
    end;

  for I := 0 to FJsonArray.Count -1 do
    begin
      LJsonObj := TJSONObject.Create;
      LJsonObj := (FJsonArray.Items[i] as TJSONObject);

      LLayoutBase        := TLayout.Create(FLayout);
      LLayoutBase.Parent := FLayout;
      LLayoutBase.Name   := 'LLayoutBase_' + i.ToString;
      LLayoutBase.Align  := TAlignLayout.Left;
      LLayoutBase.Width  := Trunc(FLayoutWidth / FRecordCount);
      LLayoutBase.Height := FLayoutHeight;

      LLayoutBase.Margins.Left   := 2;
      LLayoutBase.Margins.Top    := 5;
      LLayoutBase.Margins.Bottom := 5;

      //LABEL ARGUMENT
      lblBarArgument          := TLabel.Create(LLayoutBase);
      lblBarArgument.Align    := TAlignLayout.MostBottom;
      lblBarArgument.Parent   := LLayoutBase;
      lblBarArgument.Name     := 'lblBarArgument_' + aID.ToString;
      lblBarArgument.Height   := 20;
      lblBarArgument.AutoSize := True;
      lblBarArgument.Text     := LJsonObj.GetValue<string>(FFieldNameArgument);

      lblBarArgument.StyledSettings := [];

      lblBarArgument.TextSettings.HorzAlign := TTextAlign.Center;
      lblBarArgument.TextSettings.Trimming  := TTextTrimming.Word;

      lblBarArgument.Font.Style := [TFontStyle.fsBold];

      if FSizeFontArgument > 0 then
        lblBarArgument.Font.Size := FSizeFontArgument;

      LLayoutBase.Height := FLayoutHeight - lblBarArgument.Height;

      for X := 0 to FFieldNameValue.Count - 1 do
        begin
          AddBar(LLayoutBase,
                 FTextBar.Strings[i],
                 FFormatValue,
                 LJsonObj.GetValue<Double>(FFieldNameValue.Strings[i]),
                 TotalMax.Items[i].Total,
                 (LLayoutBase.Width / FFieldNameValue.Count),
                 FColorArgument.Items[i], i);
        end;
    end;
end;

procedure TChartBarHorz.ClearLayout;
begin
  for var X := FLayout.ControlsCount - 1 downto 0 do
    FLayout.Controls[X].DisposeOf;
end;

constructor TChartBarHorz.Create;
begin
  FSizeFontValue    := 0;
  FSizeFontArgument := 0;
  FSizeFontBarName  := 0;

  aID := 0;
  TotalMax := TObjectList<TMaxValue>.Create;

  FFieldNameValue := TStringList.Create;
  FTextBar        := TStringList.Create;
  FColorArgument  := TList<TAlphaColor>.Create;
end;

function TChartBarHorz.DataSet(aDataSet: TDataSet): iBarHorz;
begin
  Result := Self;
  FDataSet := aDataSet;
end;

destructor TChartBarHorz.Destroy;
begin
  FFieldNameValue.DisposeOf;
  FTextBar.DisposeOf;
  TotalMax.DisposeOf;
  FColorArgument.DisposeOf;

  inherited;
end;

function TChartBarHorz.FormatValue(aFormatValue: string): iBarHorz;
begin
  Result := Self;
  FFormatValue := aFormatValue;
end;

function TChartBarHorz.JsonArray(aJsonArray: TJSONArray): iBarHorz;
begin
  Result := Self;
  FJsonArray := aJsonArray;
end;

function TChartBarHorz.Layout(aLayout: TLayout): iBarHorz;
begin
  Result := Self;
  FLayout := aLayout;
end;

class function TChartBarHorz.New: iBarHorz;
begin
  Result := Self.Create;
end;

function TChartBarHorz.SizeFontArgument(aSize: Single): iBarHorz;
begin
  Result := Self;
  FSizeFontArgument := aSize;
end;

function TChartBarHorz.SizeFontBarName(aSize: Single): iBarHorz;
begin
  Result := Self;
  FSizeFontBarName := aSize;
end;

function TChartBarHorz.SizeFontValue(aSize: Single): iBarHorz;
begin
  Result := Self;
  FSizeFontValue := aSize;
end;

{ TMaxValue }

constructor TMaxValue.Create;
begin
  Total := 0;
end;

end.
