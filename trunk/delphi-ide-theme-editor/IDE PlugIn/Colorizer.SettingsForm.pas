//**************************************************************************************************
//
// Unit Colorizer.SettingsForm
// unit Colorizer.SettingsForm  for the Delphi IDE Colorizer
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is Colorizer.SettingsForm.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2014 Rodrigo Ruz V.
// All Rights Reserved.
//
//**************************************************************************************************
unit Colorizer.SettingsForm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, pngimage, ExtCtrls, StdCtrls, Grids, ComCtrls, ImgList,
  ActnMan, ActnColorMaps, Colorizer.Settings, uDelphiVersions{$IF CompilerVersion >= 23}, Vcl.Styles.Ext{$IFEND};

type
  TFormIDEColorizerSettings = class(TForm)
    CheckBoxEnabled: TCheckBox;
    cbThemeName: TComboBox;
    Label1: TLabel;
    Button3: TButton;
    ListViewTypes: TListView;
    PageControlSettings: TPageControl;
    TabSheetMain: TTabSheet;
    TabSheet2: TTabSheet;
    PanelMain: TPanel;
    Label4: TLabel;
    ListViewProps: TListView;
    Label5: TLabel;
    ImageList1: TImageList;
    XPColorMap: TXPColorMap;
    CbClrElement: TColorBox;
    BtnSelForColor: TButton;
    Label7: TLabel;
    Label6: TLabel;
    cbColorElements: TComboBox;
    CheckBoxAutoColor: TCheckBox;
    LabelSetting: TLabel;
    TabSheetVCLStyles: TTabSheet;
    CheckBoxUseVClStyles: TCheckBox;
    CbStyles: TComboBox;
    Label9: TLabel;
    Panel1: TPanel;
    BtnApply: TButton;
    CheckBoxFixIDEDrawIcon: TCheckBox;
    Image1: TImage;
    CheckBoxActivateDWM: TCheckBox;
    ColorDialog1: TColorDialog;
    Bevel1: TBevel;
    Label2: TLabel;
    CheckBoxGutterIcons: TCheckBox;
    PanelPreview: TPanel;
    Label18: TLabel;
    Label23: TLabel;
    ColorMapCombo: TComboBox;
    StyleCombo: TComboBox;
    TwilightColorMap: TTwilightColorMap;
    StandardColorMap: TStandardColorMap;
    Image2: TImage;
    XPColorMap1: TXPColorMap;
    Button1: TButton;
    ColorBoxBase: TColorBox;
    Label3: TLabel;
    TabSheet1: TTabSheet;
    ListBoxFormsHooked: TListBox;
    EditFormClass: TEdit;
    Label8: TLabel;
    ButtonAddFormClass: TButton;
    ButtonRemoveFormClass: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ListViewTypesChange(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure FormDestroy(Sender: TObject);
    procedure BtnSelForColorClick(Sender: TObject);
    procedure BtnCancelClick(Sender: TObject);
    procedure cbColorElementsChange(Sender: TObject);
    procedure CbClrElementChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure cbThemeNameChange(Sender: TObject);
    procedure BtnApplyClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure CbStylesChange(Sender: TObject);
    procedure CheckBoxUseVClStylesClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ColorBoxBaseChange(Sender: TObject);
    procedure ColorBoxBaseGetColors(Sender: TCustomColorBox; Items: TStrings);
    procedure ButtonAddFormClassClick(Sender: TObject);
    procedure ButtonRemoveFormClassClick(Sender: TObject);
  private
    { Private declarations }
    FPreview:TVclStylesPreview;
    FSettings: TSettings;
    procedure LoadColorElements;
    procedure LoadThemes;
    //procedure LoadProperties(lType: TRttiType);
    procedure LoadSettings;
    function  GetIDEThemesFolder : String;
    function  GetSettingsFolder : String;
    procedure LoadVClStylesList;
    procedure GenerateIDEThemes(const Path : string);
    procedure DrawSeletedVCLStyle;
    procedure DrawPalette;
  public
    procedure Init;
  end;

const
  {$DEFINE DELPHI_OLDER_VERSIONS_SUPPORT}

  DelphiIDEThemePaths: array[TDelphiVersions] of string = (
  {$IFDEF DELPHI_OLDER_VERSIONS_SUPPORT}
    '',
    '',
  {$ENDIF}
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    'BPL\XE',
    'BPL\XE2',
    '',
    '',
    '',
    '',
    '');

  DelphiIDEExpertsNames: array[TDelphiVersions] of string = (
  {$IFDEF DELPHI_OLDER_VERSIONS_SUPPORT}
    '',
    '',
  {$ENDIF}
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    'DelphiIDEColorizerXE',
    'DelphiIDEColorizerXE2',
    'DelphiIDEColorizerXE3',
    'DelphiIDEColorizerXE4',
    'DelphiIDEColorizerXE5',
    '',
    '');

implementation

Uses
 {$IF CompilerVersion >= 23}
 VCL.Themes,
 VCL.Styles,
 {$IFEND}
 {$WARN UNIT_PLATFORM OFF}
 Vcl.FileCtrl,
 {$WARN UNIT_PLATFORM ON}
 System.Types,
 uMisc,
 IOUtils,
 System.UITypes,
 Colorizer.StoreColorMap,
 GraphUtil,
 uIDEExpertUtils,
 Colorizer.Utils,
 TypInfo;

{$R *.dfm}

{
TODO
  Enable / disable
}

function GetTextColor(const BackgroundColor: TColor): TColor;
begin
  if (GetRValue(BackgroundColor) + GetGValue(BackgroundColor) + GetBValue(BackgroundColor)) > 384 then
    result := clBlack
  else
    result := clWhite;
end;

procedure TFormIDEColorizerSettings.BtnSelForColorClick(Sender: TObject);
Var
 LColor : TColor;
begin
 if ColorDialog1.Execute(Handle) then
 begin
   LColor:=ColorDialog1.Color;
   if LColor<>clNone then
   begin
    CbClrElement.Selected:=LColor;
    CbClrElementChange(nil);
   end;
 end;
end;

//procedure TFormIDEColorizerSettings.BtnUnInstallClick(Sender: TObject);
//begin
//  if IsAppRunning(IDEData.Path) then
//    MsgBox(Format('Before to continue you must close all running instances of the %s IDE', [IDEData.Name]))
//  else
//  if MessageDlg(Format('Do you want Uninstall the plugin (expert) in the %s IDE?', [IDEData.Name]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
//  begin
//    if UnInstallExpert(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+DelphiIDEThemePaths[IDEData.Version]+'\'+DelphiIDEExpertsNames[IDEData.Version]+'.bpl', IDEData.Version) then
//    begin
//     MsgBox('PlugIn Uninstalled');
//     BtnInstall.Enabled:=True;
//     BtnUnInstall.Enabled:=False;
//    end;
//  end;
//end;

procedure TFormIDEColorizerSettings.BtnApplyClick(Sender: TObject);
var
   sMessage, StyleFile : string;
   FShowWarning : Boolean;
begin
  FShowWarning:=(CheckBoxEnabled.Checked <> FSettings.Enabled) or (CheckBoxGutterIcons.Checked <> FSettings.ChangeIconsGutter);

  if FShowWarning then
    sMessage:= Format('Do you want apply the changes?'+sLineBreak+
    'Note : some changes will only take effect the next time the IDE is started', [])
  else
    sMessage:= Format('Do you want apply the changes?', []);

  if MessageDlg(sMessage,  mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FSettings.ThemeName := cbThemeName.Text;
    FSettings.Enabled   := CheckBoxEnabled.Checked;
    FSettings.EnableDWMColorization   := CheckBoxActivateDWM.Checked;
    FSettings.FixIDEDisabledIconsDraw   := CheckBoxFixIDEDrawIcon.Checked;
    FSettings.AutogenerateColors   := CheckBoxAutoColor.Checked;

    FSettings.UseVCLStyles :=CheckBoxUseVClStyles.Checked;
    FSettings.ChangeIconsGutter :=CheckBoxGutterIcons.Checked;
//    FSettings.ColorMapName      :=ColorMapCombo.Text;
//    FSettings.StyleBarName      :=StyleCombo.Text;
    FSettings.VCLStyleName :=CbStyles.Text;
    WriteSettings(FSettings, GetSettingsFolder);

    ListBoxFormsHooked.Items.SaveToFile(IncludeTrailingPathDelimiter(ExtractFilePath(GetModuleLocation))+'HookedWindows.dat');
    Colorizer.Utils.LoadSettings(TColorizerLocalSettings.ColorMap, TColorizerLocalSettings.ActionBarStyle, TColorizerLocalSettings.Settings);

    {$IF CompilerVersion >= 23}
    if TColorizerLocalSettings.Settings.UseVCLStyles then
    begin
      StyleFile:=IncludeTrailingPathDelimiter(TColorizerLocalSettings.VCLStylesPath)+TColorizerLocalSettings.Settings.VCLStyleName;
      if FileExists(StyleFile) then
      begin
        TStyleManager.SetStyle(TStyleManager.LoadFromFile(StyleFile));
        GenerateColorMap(TColorizerLocalSettings.ColorMap,TStyleManager.ActiveStyle);
      end
      else
        MessageDlg(Format('The VCL Style file %s was not found',[StyleFile]), mtInformation, [mbOK], 0);
    end;
    {$IFEND}

    RefreshIDETheme();
  end;
end;

procedure TFormIDEColorizerSettings.BtnCancelClick(Sender: TObject);
begin
end;

//procedure TFormIDEColorizerSettings.BtnInstallClick(Sender: TObject);
//begin
//  if IsAppRunning(IDEData.Path) then
//    MsgBox(Format('Before to continue you must close all running instances of the %s IDE',
//      [IDEData.Name]))
//  else
//  if MessageDlg(Format('Do you want install the plugin (expert) in the %s IDE?', [IDEData.Name]), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
//  begin
//    if InstallExpert(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)))+DelphiIDEThemePaths[IDEData.Version]+'\'+DelphiIDEExpertsNames[IDEData.Version]+'.bpl','Delphi IDE Colorizer', IDEData.Version) then
//    begin
//     MsgBox('PlugIn Installed');
//     BtnInstall.Enabled:=False;
//     BtnUnInstall.Enabled:=True;
//    end;
//  end;
//end;

procedure TFormIDEColorizerSettings.Button1Click(Sender: TObject);
Var
 LColor : TColor;
begin
 if ColorDialog1.Execute(Handle) then
 begin
   LColor:=ColorDialog1.Color;
   if LColor<>clNone then
    ColorBoxBase.Selected:=LColor;
 end;
end;

procedure TFormIDEColorizerSettings.Button3Click(Sender: TObject);
Var
  ThemeName, FileName : string;
begin
   ThemeName:= Trim(cbThemeName.Text);
   if ThemeName='' then
   begin
     MsgBox('The theme name is empty');
     exit;
   end;

   FileName:=IncludeTrailingPathDelimiter(GetIDEThemesFolder)+Trim(cbThemeName.Text)+'.idetheme';
   if FileExists(FileName) then
      if Application.MessageBox(PChar(Format('The theme %s already exists, Do you want overwritte the theme ?',[ThemeName])), 'Comfirmation',
        MB_YESNO + MB_ICONQUESTION) = idNo then
        exit;


   SaveColorMapToXmlFile(XPColorMap, FileName);
   if FileExists(FileName) then
   begin
    MsgBox(Format('The theme %s was saved',[ThemeName]));
    LoadThemes;
    CbStyles.ItemIndex:=CbStyles.Items.IndexOf(ThemeName);
   end;
end;


procedure TFormIDEColorizerSettings.ButtonAddFormClassClick(Sender: TObject);
var
 sFormClass : string;
begin
 sFormClass:=Trim(EditFormClass.Text);
 if (sFormClass<>'') then
   if ListBoxFormsHooked.Items.IndexOf(sFormClass)>=0 then
     ShowMessage(Format('The %s form is already included in the list', [sFormClass]))
   else
     ListBoxFormsHooked.Items.Add(sFormClass);
end;

procedure TFormIDEColorizerSettings.ButtonRemoveFormClassClick(Sender: TObject);
begin
 if ListBoxFormsHooked.ItemIndex<>-1 then
   ListBoxFormsHooked.Items.Delete(ListBoxFormsHooked.ItemIndex);
end;

procedure TFormIDEColorizerSettings.CbClrElementChange(Sender: TObject);
Var
 PropName : string;
 AColor   : TColor;
begin
 PropName:=cbColorElements.Text;
 AColor:=CbClrElement.Selected;
 SetOrdProp(XPColorMap, PropName, AColor);
end;

procedure TFormIDEColorizerSettings.cbColorElementsChange(Sender: TObject);
Var
 PropName : string;
 AColor   : TColor;
begin
 PropName:=cbColorElements.Text;
 AColor:= GetOrdProp(XPColorMap, PropName);
 CbClrElement.Selected:=AColor;
end;

procedure TFormIDEColorizerSettings.CbStylesChange(Sender: TObject);
begin
   DrawSeletedVCLStyle;
end;

procedure TFormIDEColorizerSettings.cbThemeNameChange(Sender: TObject);
Var
  FileName : string;
begin
  FileName:=IncludeTrailingPathDelimiter(GetIDEThemesFolder)+cbThemeName.Text+'.idetheme';
  if FileExists(FileName)  then
  begin
    LoadColorMapFromXmlFile(XPColorMap, FileName);
    cbColorElementsChange(nil);
    DrawPalette;
  end;
end;

procedure TFormIDEColorizerSettings.CheckBoxUseVClStylesClick(Sender: TObject);
begin
 LoadVClStylesList;
end;

procedure TFormIDEColorizerSettings.ColorBoxBaseChange(Sender: TObject);
begin
 if CheckBoxAutoColor.Checked then
 begin
   GenerateColorMap(XPColorMap, ColorBoxBase.Selected, GetTextColor(ColorBoxBase.Selected));
   cbColorElementsChange(nil);
   DrawPalette;
 end;
end;

procedure TFormIDEColorizerSettings.ColorBoxBaseGetColors(
  Sender: TCustomColorBox; Items: TStrings);
Var
 Item : TIdentMapEntry;
begin
  for Item in WebNamedColors do
   Items.AddObject(StringReplace(Item.Name, 'clWeb', '' , [rfReplaceAll]),TObject(Item.Value));
end;

procedure TFormIDEColorizerSettings.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action:=caFree;
end;

procedure TFormIDEColorizerSettings.FormCreate(Sender: TObject);
var
  I: Integer;
begin
  ColorMapCombo.Items.AddObject('(Default)', nil);
  ColorMapCombo.ItemIndex := 0;
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TCustomActionBarColorMap then
      ColorMapCombo.Items.AddObject(Components[I].Name, Components[I]);

  StyleCombo.Items.Assign(ActionBarStyles);
  FPreview:=TVclStylesPreview.Create(Self);
  FPreview.Parent:=PanelPreview;
  FPreview.BoundsRect := PanelPreview.ClientRect;
  FSettings:=TSettings.Create;
  //CheckBoxActivateDWM.Enabled:=DwmIsEnabled;
  {$IF CompilerVersion >= 23}
  TabSheetVCLStyles.TabVisible:=True;
  {$ELSE}
  TabSheetVCLStyles.TabVisible:=False;
  {$IFEND}
  ListBoxFormsHooked.Items.LoadFromFile(IncludeTrailingPathDelimiter(ExtractFilePath(GetModuleLocation))+'HookedWindows.dat');
end;

type
  TVclStylesPreviewClass = class(TVclStylesPreview);

procedure TFormIDEColorizerSettings.DrawPalette;
var
  LBitMap : TBitmap;
begin
    LBitMap:=TBitmap.Create;
    try
     CreateArrayBitmap(275,25,[
      XPColorMap.ShadowColor,
      XPColorMap.Color,
      XPColorMap.DisabledColor,
      XPColorMap.DisabledFontColor,
      XPColorMap.DisabledFontShadow,
      XPColorMap.FontColor,
      XPColorMap.HighlightColor,
      XPColorMap.HotColor,
      XPColorMap.HotFontColor,
      XPColorMap.MenuColor,
      XPColorMap.FrameTopLeftInner,
      XPColorMap.FrameTopLeftOuter,
      XPColorMap.FrameBottomRightInner,
      XPColorMap.FrameBottomRightOuter,
      XPColorMap.BtnFrameColor,
      XPColorMap.BtnSelectedColor,
      XPColorMap.BtnSelectedFont,
      XPColorMap.SelectedColor,
      XPColorMap.SelectedFontColor,
      XPColorMap.UnusedColor
      ], LBitMap);
     Image1.Picture.Assign(LBitMap);
    finally
      LBitMap.Free;
    end;
end;

procedure TFormIDEColorizerSettings.DrawSeletedVCLStyle;
var
  StyleName : string;
  LStyle    : TCustomStyleServices;
begin
   StyleName:=CbStyles.Text;
   if (StyleName<>'') and (not SameText(StyleName, 'Windows')) then
   begin
     TStyleManager.StyleNames;//call DiscoverStyleResources
     LStyle:=TStyleManager.Style[StyleName];
     FPreview.Caption:=StyleName;
     FPreview.Style:=LStyle;
     TVclStylesPreviewClass(FPreview).Paint;
   end;
end;

procedure TFormIDEColorizerSettings.FormDestroy(Sender: TObject);
begin
  FPreview.Free;
  FSettings.Free;
end;

procedure TFormIDEColorizerSettings.FormShow(Sender: TObject);
begin
  //LabelSetting.Caption:=Format('Settings for %s',[IDEData.Name]);
  //BtnInstall.Enabled  :=not ExpertInstalled(DelphiIDEExpertsNames[IDEData.Version]+'.bpl',IDEData.Version);
  //BtnUnInstall.Enabled:=not BtnInstall.Enabled;
end;


procedure TFormIDEColorizerSettings.GenerateIDEThemes(const Path: string);
Var
  i        : integer;
  FileName : string;
begin

   FileName:=IncludeTrailingPathDelimiter(GetIDEThemesFolder)+'Twilight.idetheme';
   SaveColorMapToXmlFile(TwilightColorMap, FileName);

   FileName:=IncludeTrailingPathDelimiter(GetIDEThemesFolder)+'XPColorMap.idetheme';
   SaveColorMapToXmlFile(XPColorMap1, FileName);

   FileName:=IncludeTrailingPathDelimiter(GetIDEThemesFolder)+'StandardColorMap.idetheme';
   SaveColorMapToXmlFile(StandardColorMap, FileName);


   for i:=0 to WebNamedColorsCount-1 do
   begin
     GenerateColorMap(XPColorMap, WebNamedColors[i].Value, GetTextColor(WebNamedColors[i].Value));
     FileName:=StringReplace(WebNamedColors[i].Name,'clWeb','',[rfReplaceAll]);
     FileName:=IncludeTrailingPathDelimiter(Path)+FileName+'.idetheme';
     SaveColorMapToXmlFile(XPColorMap, FileName);

//     GenerateColorMap(XPColorMap, GetHighLightColor(WebNamedColors[i].Value));
//     FileName:=StringReplace(WebNamedColors[i].Name, 'clWeb', '',[rfReplaceAll]);
//     FileName:=IncludeTrailingPathDelimiter(Path)+FileName+'Light.idetheme';
//     SaveColorMapToXmlFile(XPColorMap, FileName);
//
//
//     GenerateColorMap(XPColorMap, GetShadowColor(WebNamedColors[i].Value));
//     FileName:=StringReplace(WebNamedColors[i].Name, 'clWeb', '',[rfReplaceAll]);
//     FileName:=IncludeTrailingPathDelimiter(Path)+FileName+'Dark.idetheme';
//     SaveColorMapToXmlFile(XPColorMap, FileName);
   end;
end;

function TFormIDEColorizerSettings.GetIDEThemesFolder: String;
begin
  Result:=IncludeTrailingPathDelimiter(GetSettingsFolder)+'Themes';
end;

function TFormIDEColorizerSettings.GetSettingsFolder: String;
begin
  Result:=ExtractFilePath(GetModuleLocation());
end;

procedure TFormIDEColorizerSettings.Init;
begin
  LoadColorElements;
  LoadThemes;
  LoadSettings;
end;

procedure TFormIDEColorizerSettings.ListViewTypesChange(Sender: TObject;
  Item: TListItem; Change: TItemChange);
begin
  //if ListViewTypes.Selected<>nil then
  //LoadProperties(TRttiType(ListViewTypes.Selected.Data));
end;

procedure TFormIDEColorizerSettings.LoadColorElements;
var
  Count, Index: Integer;
  Properties  : TPropList;
begin
  Count := GetPropList(TypeInfo(TXPColorMap), tkAny, @Properties);
  cbColorElements.Items.BeginUpdate;
  try
    for Index := 0 to Pred(Count) do
     if SameText(string(Properties[Index]^.PropType^.Name),'TColor') then
      cbColorElements.Items.Add(string(Properties[Index]^.Name));
  finally
    cbColorElements.Items.EndUpdate;
  end;
  cbColorElements.ItemIndex:=cbColorElements.Items.IndexOf('Color');
end;
            {
procedure TFrmIDEColorizerSettings.LoadProperties(lType: TRttiType);
var
  p    : TRttiProperty;
  Item : TListItem;
  i    : Integer;
  Add  : Boolean;
begin
  ListViewProps.Items.BeginUpdate;
  try
    ListViewProps.Items.Clear;
    for p in lType.GetProperties do
    if p.IsWritable and ( (CompareText(p.PropertyType.Name,'TColor')=0) or (CompareText(p.PropertyType.Name,'TFont')=0) ) then// (Pos('Color',p.Name)>0) then
    begin
       Add:=True;
       for i := 0 to ListViewProps.Items.Count-1 do
       if CompareText(p.Name,ListViewProps.Items.Item[i].Caption)<>0 then
       begin
         Add:=False;
         Break;
       end;

       if Add then
       begin
        Item:=ListViewProps.Items.Add;
        Item.Caption:=p.Name;
       end;
    end;
  finally
   ListViewProps.Items.EndUpdate;
  end;
end;
         }
procedure TFormIDEColorizerSettings.LoadSettings;
begin
  ReadSettings(FSettings, GetSettingsFolder);
  CheckBoxEnabled.Checked:=FSettings.Enabled;
  CheckBoxActivateDWM.Checked:=FSettings.EnableDWMColorization;
  CheckBoxFixIDEDrawIcon.Checked:=FSettings.FixIDEDisabledIconsDraw;
  CheckBoxAutoColor.Checked:=FSettings.AutogenerateColors;
  CheckBoxGutterIcons.Checked:=FSettings.ChangeIconsGutter;
//  StyleCombo.ItemIndex:=StyleCombo.Items.IndexOf(FSettings.StyleBarName);
//  ColorMapCombo.ItemIndex:=ColorMapCombo.Items.IndexOf(FSettings.ColorMapName);
  cbThemeName.Text:=FSettings.ThemeName;
  cbThemeNameChange(nil);

  CheckBoxUseVClStyles.Checked:=FSettings.UseVCLStyles;
  LoadVClStylesList;
  //EditVCLStylesPath.Text:=FSettings.VCLStylesPath;
  CbStyles.ItemIndex:=CbStyles.Items.IndexOf(FSettings.VCLStyleName);
  DrawSeletedVCLStyle;
end;

procedure TFormIDEColorizerSettings.LoadThemes;
var
 sValue, FileName : string;
 Files : TStringDynArray;
begin
  cbThemeName.Items.Clear;
  Files:=TDirectory.GetFiles(GetIDEThemesFolder,'*.idetheme');
  if Length(Files)=0 then
  begin
    GenerateIDEThemes(GetIDEThemesFolder);
    Files:=TDirectory.GetFiles(GetIDEThemesFolder,'*.idetheme');
  end;

  for sValue in Files do
  begin
    FileName:=ChangeFileExt(ExtractFileName(sValue),'');
    cbThemeName.Items.Add(FileName);
  end;
end;


procedure TFormIDEColorizerSettings.LoadVClStylesList;
var
 s : string;
begin
 if CheckBoxUseVClStyles.Checked then
 begin
  CbStyles.Items.Clear;
  RegisterVClStylesFiles();
   for s in TStyleManager.StyleNames do
    CbStyles.Items.Add(s);

   CbStyles.ItemIndex:=CbStyles.Items.IndexOf(FSettings.VCLStyleName);
 end;
end;

end.