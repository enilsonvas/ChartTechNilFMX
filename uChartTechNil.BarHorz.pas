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


    FFormatValue      : string;
    FFieldNameArgument: string;
    FTextArgument     : string;
    FTitle            : string;

    FLayoutHeight: Single;
    FLayoutWidth: Single;

    FRecordCount: Integer;
    aID: Integer;

    FSizeFontValue   : Single;
    FSizeFontArgument: Single;
    FSizeFontBarName : Single;
    FSizeFontTitle   : Single;

    FFontTitleFamily: TFontName;

    function AddBar(aLayout: TLayout;
      aBarName, aFormatValue: string; aValue, aMaxValue: Double; aWidth: Single;
      aColor: TAlphaColor=$00000000; idxBar: Integer=0): TLayout;

    procedure ClearLayout;
    procedure CarregaDataSet;
    procedure CarregaJson;
    procedure CarregaLayout(aPos: TPosLegenda);
    procedure CarregaLegenda(aColor: TAlphaColor; aBarName: string);

  public
    TotalMax: TObjectList<TMaxValue>;

    class function New: iBarHorz;
    constructor Create;
    destructor Destroy; override;

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
    function SizeFontTitle(aSize: Single): iBarHorz;

    function FontTitleFamily(aFontFamily: TFontName): iBarHorz;

    procedure CarregarChart;
  end;

implementation

{ TChartBarHorz }

function TChartBarHorz.AddBar(aLayout: TLayout;
      aBarName, aFormatValue: string; aValue, aMaxValue: Double; aWidth: Single;
      aColor: TAlphaColor=$00000000; idxBar: Integer=0): TLayout;
var
  LBar: TRectangle;
  lblBarValue: TLabel;
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

  //RECTANGLE
  LBar        := TRectangle.Create(Result);
  LBar.Parent := Result;
  LBar.Name   := 'LBar_'+aID.ToString;
  LBar.Stroke.Kind := TBrushKind.None;
  LBar.Margins.Left := 3;
  LBar.Size.PlatformDefault := True;

  if aColor <> TAlphaColors.Null then
    LBar.Fill.Color := aColor;

  LBar.Stroke.Kind := TBrushKind.None;

  Perc := SimpleRoundTo((aValue / aMaxValue) * 100);

  LHeight := aLayout.Height - Trunc((100 - SimpleRoundTo((aLayout.Height * Perc) / 100)));
  LBar.AnimateFloat('Height', LHeight , 0.8, TAnimationType.In, TInterpolationType.Back);

  LBar.Align       := TAlignLayout.Bottom;

  //FIELD VALUE
  lblBarValue          := TLabel.Create(Result);
  lblBarValue.Parent   := Result;
  lblBarValue.Name     := 'lblBarValue_'+aID.ToString;
  lblBarValue.AutoSize := True;

  if FSizeFontValue > 0 then
    begin
      lblBarValue.Font.Size := FSizeFontValue;
      lblBarValue.StyledSettings :=  [];
    end
  else
    lblBarValue.StyledSettings         := lblBarValue.StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];

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
var
  lblTitle: TLabel;
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


  CarregaLayout(FPosLegenda);

  if FDataSet <> nil then
    CarregaDataSet
  else if FJsonArray <> nil then
    CarregaJson;

  FLayout.EndUpdate;
end;

procedure TChartBarHorz.CarregaLegenda(aColor: TAlphaColor; aBarName: string);
var
  LBarLegend, LBarBackground: TRectangle;
  lblBarLegend: TLabel;
  aLayout: TLayout;
begin
  if FLegendTextAnt.IndexOf(aBarName) = -1 then
    begin
      FLegendTextAnt.Add(aBarName);

      aLayout        := TLayout.Create(FLayoutLegend);
      aLayout.Parent := FLayoutLegend;
      aLayout.Align  := TAlignLayout.Top;
      aLayout.Height := 20;

      aLayout.Margins.Top := 3;
      aLayout.Margins.Right := 3;
      aLayout.Margins.Left  := 3;

      LBarBackground := TRectangle.Create(aLayout);
      LBarBackground.Parent := aLayout;
      LBarBackground.Align := TAlignLayout.Client;
      LBarBackground.Fill.Color := TAlphaColors.White;
      LBarBackground.Stroke.Kind := TBrushKind.None;

      //LEGENDA
      LBarLegend        := TRectangle.Create(aLayout);
      LBarLegend.Parent := aLayout;
      LBarLegend.Align  := TAlignLayout.Left;
      LBarLegend.Width  := 25;

      LBarLegend.Margins.Top    := 3;
      LBarLegend.Margins.Left   := 3;
      LBarLegend.Margins.Right  := 3;
      LBarLegend.Margins.Bottom := 3;

      if aColor <> TAlphaColors.Null then
        LBarLegend.Fill.Color := aColor;

      LBarLegend.Stroke.Kind := TBrushKind.None;

      //LABEL LEGEND
      lblBarLegend          := TLabel.Create(aLayout);
      lblBarLegend.Parent   := aLayout;
      lblBarLegend.Name     := 'lblBarLegend_' +aBarName;
      lblBarLegend.Align    := TAlignLayout.Client;
      lblBarLegend.AutoSize := True;

      lblBarLegend.Size.PlatformDefault := True;
      lblBarLegend.StyledSettings       := lblBarLegend.StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
      lblBarLegend.TextSettings.HorzAlign := TTextAlign.Center;
      lblBarLegend.TextSettings.Trimming  := TTextTrimming.Word;
      lblBarLegend.Font.Style             := [TFontStyle.fsBold];

      if FSizeFontBarName > 0 then
        lblBarLegend.Font.Size := FSizeFontBarName;

      lblBarLegend.Text := aBarName;

      LBarBackground.SendToBack;
    end;
end;

procedure TChartBarHorz.CarregaDataSet;
var
  I: Integer;
  LTotalMax: TMaxValue;
  LLayoutBase: TLayout;
  lblBarArgument: TLabel;
  LTextBar: string;
  LColor: TAlphaColor;
begin
  FDataSet.DisableControls;

  FRecordCount  := FDataSet.RecordCount;
  FLayoutHeight := FLayoutGrafico.Height - 10;
  FLayoutWidth  := FLayoutGrafico.Width - 70;

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
      LLayoutBase        := TLayout.Create(FLayoutGrafico);
      LLayoutBase.Parent := FLayoutGrafico;
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

      if FTextArgument <> '' then
        lblBarArgument.Text := FDataSet.FieldByName(FTextArgument).AsString
      else
        lblBarArgument.Text := FDataSet.FieldByName(FFieldNameArgument).AsString;

      lblBarArgument.StyledSettings := [];

      lblBarArgument.TextSettings.HorzAlign := TTextAlign.Center;
      lblBarArgument.TextSettings.Trimming  := TTextTrimming.Word;

      lblBarArgument.Font.Style := [TFontStyle.fsBold];

      if FSizeFontArgument > 0 then
        lblBarArgument.Font.Size := FSizeFontArgument;

      LLayoutBase.Height := FLayoutHeight - lblBarArgument.Height;

      for I := 0 to FFieldNameValue.Count - 1 do
        begin
          if FTextBar.Count > 0 then
            LTextBar := FTextBar.Strings[i];

          if FColorArgument.Count > 0 then
            LColor := FColorArgument.Items[i]
          else
            LColor := TAlphaColor($FF000000 or Random($00FFFFFF));

          if FLayoutLegend <> nil then
            if FTextBar.Count > 0 then
              CarregaLegenda(LColor, FTextBar.Strings[i])
            else
              CarregaLegenda(LColor, lblBarArgument.Text);

          AddBar(LLayoutBase,
                 LTextBar,
                 FFormatValue,
                 FDataSet.FieldByName(FFieldNameValue.Strings[i]).AsFloat,
                 TotalMax.Items[i].Total,
                 (LLayoutBase.Width / FFieldNameValue.Count),
                 LColor,
                 i);
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
  LTextBar: string;
  LColor: TAlphaColor;
begin
  FRecordCount := FJsonArray.Count;
  FLayoutHeight := FLayout.Height - 10;
  FLayoutWidth  := FLayout.Width - 70;

  for I := 0 to FFieldNameValue.Count - 1 do
    begin
      LTotalMax := TMaxValue.Create;

//      FJsonArray
//      while not FDataSet.Eof do
//        begin
//          LTotalMax.Total := LTotalMax.Total + FDataSet.FieldByName(FFieldNameValue.Strings[i]).AsFloat;
//
//          FDataSet.Next;
//        end;

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
          if FTextBar.Count > 0 then
            LTextBar := FTextBar.Strings[i];

          if FColorArgument.Count > 0 then
            LColor := FColorArgument.Items[i]
          else
            LColor := TAlphaColor($FF000000 or Random($00FFFFFF));

          AddBar(LLayoutBase,
                 LTextBar,
                 FFormatValue,
                 LJsonObj.GetValue<Double>(FFieldNameValue.Strings[i]),
                 TotalMax.Items[i].Total,
                 (LLayoutBase.Width / FFieldNameValue.Count),
                 FColorArgument.Items[i], i);
        end;
    end;
end;

procedure TChartBarHorz.CarregaLayout(aPos: TPosLegenda);
var
  lblTitle: TLabel;
begin

  case FPosLegenda of
    aNone  :
      begin
        FLayoutGrafico := TLayout.Create(FLayout);
        FLayoutGrafico := FLayout;

        FLayoutGrafico.Position.Y := 0;
        FLayoutGrafico.Position.X := 0;

        FLayoutGrafico.Height := FLayout.Height;
        FLayoutGrafico.Width  := FLayout.Width;
      end;
    aLeft:
      begin
        FLayoutLegend        := TLayout.Create(nil);
        FLayoutLegend.Name   := 'FLayoutLegend';
        FLayoutLegend.Parent := FLayout;
        FLayoutLegend.Align  := TAlignLayout.Left;
        FLayoutLegend.Height := FLayout.Height;
        FLayoutLegend.Width  := (FLayout.Width * 10) / 100;

        FLayoutGrafico        := TLayout.Create(nil);
        FLayoutGrafico.Name   := 'FLayoutGrafico';
        FLayoutGrafico.Parent := FLayout;
        FLayoutGrafico.Align  := TAlignLayout.Client;
        FLayoutGrafico.Height := FLayout.Height;
        FLayoutGrafico.Width  := FLayout.Width - FLayoutLegend.Width;
      end;
    aRight :
      begin
        FLayoutLegend        := TLayout.Create(nil);
        FLayoutLegend.Name   := 'FLayoutLegend';
        FLayoutLegend.Parent := FLayout;
        FLayoutLegend.Align  := TAlignLayout.Right;
        FLayoutLegend.Height := FLayout.Height;
        FLayoutLegend.Width  := (FLayout.Width * 10) / 100;

        FLayoutGrafico        := TLayout.Create(nil);
        FLayoutGrafico.Name   := 'FLayoutGrafico';
        FLayoutGrafico.Parent := FLayout;
        FLayoutGrafico.Align  := TAlignLayout.Client;
        FLayoutGrafico.Height := FLayout.Height;
        FLayoutGrafico.Width  := FLayout.Width - FLayoutLegend.Width;
      end;
    aBotoom:
      begin
        FLayoutGrafico        := TLayout.Create(nil);
        FLayoutGrafico.Name   := 'FLayoutGrafico';
        FLayoutGrafico.Parent := FLayout;
        FLayoutGrafico.Position.Y := 0;
        FLayoutGrafico.Align  := TAlignLayout.Contents;
        FLayoutGrafico.Height := FLayout.Height - (FLayout.Height * 10) / 100;
        FLayoutGrafico.Width  := FLayout.Width;

        FLayoutLegend        := TLayout.Create(nil);
        FLayoutLegend.Name   := 'FLayoutLegend';
        FLayoutLegend.Parent := FLayout;
        FLayoutLegend.Align  := TAlignLayout.MostBottom;
        FLayoutLegend.Width  := FLayout.Width;
        FLayoutLegend.Height := (FLayout.Height * 10) / 100;
      end;
  end;

//  if FTitle <> '' then
//    begin
//      FLayoutTitle        := TLayout.Create(FLayout);
//      FLayoutTitle.Parent := FLayout;
//      FLayoutTitle.Align  := TAlignLayout.Top;
//      FLayoutTitle.Height := 13;
//
//      lblTitle := TLabel.Create(FLayoutTitle);
//      lblTitle.Parent := FLayoutTitle;
//      lblTitle.Align  := TAlignLayout.Client;
//      lblTitle.Text   := FTitle;
//      lblTitle.TextAlign := TTextAlign.Center;
//      lblTitle.TextSettings.Font.Style := [TFontStyle.fsBold];
//      lblTitle.StyledSettings := lblTitle.StyledSettings - [TStyledSetting.Size, TStyledSetting.FontColor];
//      lblTitle.Font.Size := FSizeFontTitle;
//    end;
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
  FSizeFontTitle    := 16;

  aID := 0;
  TotalMax := TObjectList<TMaxValue>.Create;

  FFieldNameValue := TStringList.Create;
  FTextBar        := TStringList.Create;
  FColorArgument  := TList<TAlphaColor>.Create;
  FLegendTextAnt  := TStringList.Create;
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
  FLegendTextAnt.DisposeOf;

  inherited;
end;

function TChartBarHorz.FontTitleFamily(aFontFamily: TFontName): iBarHorz;
begin
  Result := Self;
  FFontTitleFamily := aFontFamily;
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

function TChartBarHorz.PosLegenda(aPos: TPosLegenda): iBarHorz;
begin
  Result := Self;
  FPosLegenda := aPos;
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

function TChartBarHorz.SizeFontTitle(aSize: Single): iBarHorz;
begin
  Result := Self;
  FSizeFontTitle := aSize;
end;

function TChartBarHorz.SizeFontValue(aSize: Single): iBarHorz;
begin
  Result := Self;
  FSizeFontValue := aSize;
end;

function TChartBarHorz.Title(aTitle: string): iBarHorz;
begin
  Result := Self;
  FTitle := aTitle;
end;

{ TMaxValue }

constructor TMaxValue.Create;
begin
  Total := 0;
end;

end.
