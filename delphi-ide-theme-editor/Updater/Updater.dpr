// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program Updater;

uses
  Forms,
  uMain in 'uMain.pas' {FrmMain},
  uHttpDownload in 'uHttpDownload.pas',
  uMisc in '..\Units\uMisc.pas',
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.ShowMainForm := False;
  TStyleManager.TrySetStyle('Sterling');
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
