{####################################################################################################################
                              TINJECT - Componente de comunicação (Não Oficial)
                                           www.tinject.com.br
                                            Novembro de 2019
####################################################################################################################
    Owner.....: Joathan Theiller           - jtheiller@hotmail.com   -
    Developer.: Mike W. Lustosa            - mikelustosa@gmail.com   - +55 81 9.9630-2385
                Daniel Oliveira Rodrigues  - Dor_poa@hotmail.com     - +55 51 9.9155-9228
                Robson André de Morais     - robinhodemorais@gmail.com

####################################################################################################################
  Obs:
     - Código aberto a comunidade Delphi, desde que mantenha os dados dos autores e mantendo sempre o nome do IDEALIZADOR
       Mike W. Lustosa;
     - Colocar na evolução as Modificação juntamente com as informaçoes do colaborador: Data, Nova Versao, Autor;
     - Mantenha sempre a versao mais atual acima das demais;
     - Todo Commit ao repositório deverá ser declarado as mudança na UNIT e ainda o Incremento da Versão de
       compilação (último digito);

####################################################################################################################
                                  Evolução do Código
####################################################################################################################
  Autor........:
  Email........:
  Data.........:
  Identificador:
  Modificação..:
####################################################################################################################
}

///CEF DOCUMENTAÇÃO
//https://www.briskbard.com/index.php?lang=en&pageid=cef
unit uTInject.ConfigCEF;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms,
  DateUtils,
  IniFiles,
  uCEFApplication, uCEFConstants,
  uCEFChromium,

  uTInject,
  uTInject.constant, Vcl.ExtCtrls, uTInject.Classes ;



type

  TCEFConfig = class(TCefApplication)
  private
    FChromium            : TChromium;
    FChromiumForm        : TForm;
    FIniFIle             : TIniFile;
    Falterdo             : Boolean;
    FInject              : TInject;

    FPathFrameworkDirPath: String;
    FPathResourcesDirPath: String;
    FPathLocalesDirPath  : String;
    FPathCache           : String;
    FPathUserDataPath    : String;
    FPathLogFile         : String;
    FPathJS              : String;
    FStartTimeOut        : Cardinal;
    FErrorInt            : Boolean;
    FPathJsUpdate        : TdateTime;
    FPathLogConsole      : String;
    FHandleFrm           : HWND;
    FInDesigner          : Boolean;
    FLogConsoleActive    : Boolean;
    FAutoCreatePaths: Boolean;
    FPathDownloadAttached: string;
    procedure SetDefault;
    procedure SetPathCache   (const Value: String);
    procedure SetPathFrameworkDirPath(const Value: String);
    procedure SetPathLocalesDirPath  (const Value: String);
    procedure SetPathLogFile         (const Value: String);
    procedure SetPathResourcesDirPath(const Value: String);
    procedure SetPathUserDataPath    (const Value: String);
    function  TestaOk                (POldValue, PNewValue: String): Boolean;
    procedure SetChromium            (const Value: TChromium);
    Function  VersaoCEF4Aceita: Boolean;
    procedure SetPathLogConsole(const Value: String);
    procedure SetLogConsoleActive(const Value: Boolean);
    procedure SetPathDownloadAttached(const Value: string);
  public
    SetEnableGPU         : Boolean;
    SetDisableFeatures   : String;
    SetLogSeverity       : Boolean;
    Procedure UpdateIniFile(Const PSection, PKey, PValue :String);

    Procedure  UpdateDateIniFile;
    function   StartMainProcess : boolean;
    Procedure  SetError;

    constructor Create;
    destructor  Destroy; override;

    function PathJsOverdue: Boolean;
    property PathJsUpdate: TdateTime read FPathJsUpdate;
    property IniFIle: TIniFile read FIniFIle write FIniFIle;
    property PathFrameworkDirPath: string read FPathFrameworkDirPath write SetPathFrameworkDirPath;
    property PathResourcesDirPath: string read FPathResourcesDirPath write SetPathResourcesDirPath;
    property PathLocalesDirPath: string read FPathLocalesDirPath write SetPathLocalesDirPath;
    property PathCache: string read FPathCache write SetPathCache;
    property PathUserDataPath: string read FPathUserDataPath write SetPathUserDataPath;
    property PathLogFile: string read FPathLogFile write SetPathLogFile;
    property PathJs: string read FPathJS;
    property PathLogConsole: string read FPathLogConsole write SetPathLogConsole;
    property PathDownloadAttached : string read FPathDownloadAttached write SetPathDownloadAttached;
    property LogConsoleActive: Boolean read FLogConsoleActive write SetLogConsoleActive;
    property StartTimeOut: Cardinal read FStartTimeOut write FStartTimeOut;
    property Chromium: TChromium read FChromium write SetChromium;
    property ChromiumForm: TForm read FChromiumForm;
    property ErrorInt: Boolean read FErrorInt;
    property AutoCreatePaths: Boolean read FAutoCreatePaths write FAutoCreatePaths;
  end;

  procedure DestroyGlobalCEFApp;

var
  GlobalCEFApp: TCEFConfig = nil;


implementation

uses
  uCEFTypes, Vcl.Dialogs, uTInject.Diversos;

{ TCEFConfig }

procedure DestroyGlobalCEFApp;
begin
  if (GlobalCEFApp <> nil) then
      FreeAndNil(GlobalCEFApp);
end;

procedure TCEFConfig.UpdateDateIniFile;
begin
  FPathJsUpdate := Now;
  UpdateIniFile('Tinject Comp', 'Ultima interação', FormatDateTime('dd/mm/yy hh:nn:ss', FPathJsUpdate));
end;

procedure TCEFConfig.UpdateIniFile(const PSection, PKey, PValue: String);
begin
  if FInDesigner then
     Exit;

  if (LowerCase(FIniFIle.ReadString(PSection, PKey, '')) <> LowerCase(PValue))
  or (FIniFIle.ValueExists(PSection, PKey) = false) then
  begin
    FIniFIle.WriteString(PSection, PKey, PValue);
    Falterdo := true;
  end;
end;

constructor TCEFConfig.Create;
begin
  FInDesigner := True;

  inherited;

  FAutoCreatePaths := False;
end;

procedure TCEFConfig.SetChromium(const Value: TChromium);
Var
  LObj: TCOmponent;
begin
  //Acha o FORM que esta o componente
  try
    if FChromium = Value then
       Exit;

    FChromium := Value;
    if FChromium = Nil then
    Begin
      FChromiumForm := Nil;
      Exit;
    End;

    try
      LObj     := FChromium;
      Repeat
        if LObj.Owner is Tform then
        Begin
          FChromiumForm := Tform(LObj.Owner);
          FHandleFrm    := FChromiumForm.Handle;
          if FChromiumForm.Owner is TInject then
             FInject := TInject(FChromiumForm.Owner);
        end else    //Achou
        begin
          LObj          := LObj.Owner                //Nao Achou entao, continua procurando
        end;
      Until FChromiumForm <> Nil;
    Except
      raise Exception.Create(MSG_ExceptErrorLocateForm);
    end;
  Except
     //Esse erro nunca deve acontecer.. o TESTADOR nao conseguiu pelo menos..
  end;
end;


Procedure TCEFConfig.SetDefault;
begin
  if not FInDesigner then
  begin
    FIniFIle.WriteString ('Informacao', 'Aplicativo vinculado',    Application.ExeName);
    FIniFIle.WriteBool   ('Informacao', 'Valor True',    True);
    FIniFIle.WriteBool   ('Informacao', 'Valor False',   False);

    SetDisableFeatures      := 'NetworkService,OutOfBlinkCors';
    SetEnableGPU            := FIniFIle.ReadBool  ('Path Defines', 'GPU',                 True);
    SetLogSeverity          := FIniFIle.ReadBool  ('Path Defines', 'Log Severity',        False);
    LogConsoleActive        := FIniFIle.ReadBool  ('Path Defines', 'Log Console Active',  False);
    // para caso já tenha sido configurado, grava a nova configuracao no arquivo Ini
    PathFrameworkDirPath    := FIniFIle.ReadString('Path Defines', 'FrameWork', FPathFrameworkDirPath);
    PathResourcesDirPath    := FIniFIle.ReadString('Path Defines', 'Binary',    FPathResourcesDirPath);
    PathLocalesDirPath      := FIniFIle.ReadString('Path Defines', 'Locales',   FPathLocalesDirPath);
    Pathcache               := FIniFIle.ReadString('Path Defines', 'Cache',     FPathcache);
    PathUserDataPath        := FIniFIle.ReadString('Path Defines', 'Data User', FPathUserDataPath);
    PathLogFile             := FIniFIle.ReadString('Path Defines', 'Log File',  FPathLogFile);
    PathLogConsole          := FIniFIle.ReadString('Path Defines', 'Log Console', FPathLogConsole);
    PathDownloadAttached    := FIniFIle.ReadString('Path Defines', 'Auto Receiver attached Path', FPathDownloadAttached);

    if PathLogConsole = '' then
      PathLogConsole := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))+'Logs\';
  end;
  Self.FrameworkDirPath   := '';
  Self.ResourcesDirPath   := '';
  Self.LocalesDirPath     := 'locales';
  Self.cache              := 'cache';
  Self.UserDataPath       := 'User Data';
end;

procedure TCEFConfig.SetError;
begin
  FErrorInt := True;
end;

procedure TCEFConfig.SetPathLogConsole(const Value: String);
begin
  if Value <> '' then
  Begin
    FPathLogConsole := IncludeTrailingPathDelimiter(ExtractFilePath(Value));
    ForceDirectories(FPathLogConsole);
  end else
    FPathLogConsole := '';
end;

procedure TCEFConfig.SetLogConsoleActive(const Value: Boolean);
begin
  FLogConsoleActive := Value;
  if (LogConsoleActive) and (PathLogConsole <> '') then
    ForceDirectories(PathLogConsole);
end;

function TCEFConfig.TestaOk(POldValue, PNewValue: String):Boolean;
var
  lDir : String;
begin
  if AnsiLowerCase(POldValue) = AnsiLowerCase(PNewValue) Then
    Result := False
  else begin
    lDir := ExtractFilePath(PNewValue);

    if Self.status = asInitialized then
      raise Exception.Create(MSG_ConfigCEF_ExceptNotFoundPATH);

    if not DirectoryExists(lDir) then
    begin
      if FAutoCreatePaths then
        ForceDirectories(lDir)
      else
        raise Exception.Create(Format('O diretório não foi localizado: [%s]', [lDir]));
    end;
    Result := True;
  end;
end;


function TCEFConfig.VersaoCEF4Aceita: Boolean;
begin
  if CEF_SUPPORTED_VERSION_MAJOR > VersaoMinima_CF4_Major then
  Begin
    //Versao e maior!!! entaoo pode1
    Result := True;
    Exit;
  End;

  //Se chegou aki!! a versao e MENOR ou IGUAL
  //Continuar a testar!
  if (CEF_SUPPORTED_VERSION_MAJOR   < VersaoMinima_CF4_Major) or
     (CEF_SUPPORTED_VERSION_MINOR   < VersaoMinima_CF4_Minor) or
     (CEF_SUPPORTED_VERSION_BUILD   < VersaoMinima_CF4_Release) Then
    Result := False else
    Result := True;
end;

procedure TCEFConfig.SetPathFrameworkDirPath(const Value: String);
begin
  if TestaOk(FPathFrameworkDirPath, Value) Then
    FPathFrameworkDirPath := Value;
end;

procedure TCEFConfig.SetPathResourcesDirPath(const Value: String);
begin
  if TestaOk(FPathResourcesDirPath, Value) Then
    FPathResourcesDirPath := Value;
end;

procedure TCEFConfig.SetPathLocalesDirPath(const Value: String);
begin
  if TestaOk(FPathLocalesDirPath, Value) Then
    FPathLocalesDirPath   := Value;
end;

procedure TCEFConfig.SetPathCache(const Value: String);
begin
  if AnsiLowerCase(FPathCache) = AnsiLowerCase(Value) Then
     Exit;

  ForceDirectories(PWideChar(ExtractFilePath(Value)));

  if TestaOk(FPathCache, Value) Then
    FPathCache := Value;
end;

procedure TCEFConfig.SetPathDownloadAttached(const Value: string);
begin
  if TestaOk(FPathDownloadAttached, Value) then
    FPathDownloadAttached := Value;
end;

procedure TCEFConfig.SetPathUserDataPath(const Value: String);
begin
  if TestaOk(FPathUserDataPath, Value) Then
    FPathUserDataPath   := Value;
end;

function TCEFConfig.StartMainProcess: boolean;
var
  Linicio: Cardinal;
  LVReque, LVerIdent: String;
  lDirApp, Lx: String;

  function GetRelativePath(const AFullPath : string) : string;
  begin
    Result := StringReplace(AFullPath, lDirApp, '.\', [rfIgnoreCase]);
  end;

begin
//ta lento pq estou conectado em um tunel estou daki ao meu pc.;. do meu pc a
  Result  := (Self.status = asInitialized);
  if (Result) Then
  begin
    //Ja iniciada!! cai fora!!
    Exit;
  end;

  FInDesigner          := False;
  lDirApp              := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
  FIniFIle             := TIniFile.create(lDirApp + StringReplace(ExtractFileName(Application.ExeName), '.exe', '.ini', [rfIgnoreCase]));
  Lx                   := FIniFIle.ReadString('Tinject Comp', 'Ultima interação', '01/01/1500 05:00:00');
  FPathJS              := lDirApp + NomeArquivoInject;
  FErrorInt            := False;
  FStartTimeOut        := 5000; //(+- 5 Segundos)
  FPathJsUpdate        := StrToDateTimeDef(Lx, StrTodateTime('01/01/1500 00:00'));
  SetDefault;

  if not VersaoCEF4Aceita then
  Begin
    FErrorInt := true;
    LVReque   := IntToStr(VersaoMinima_CF4_Major)      + '.' + IntToStr(VersaoMinima_CF4_Minor)      + '.' + IntToStr(VersaoMinima_CF4_Release);
    LVerIdent := IntToStr(CEF_SUPPORTED_VERSION_MAJOR) + '.' + IntToStr(CEF_SUPPORTED_VERSION_MINOR) + '.' + IntToStr(CEF_SUPPORTED_VERSION_BUILD);

    Application.MessageBox(PWideChar(Format(MSG_ConfigCEF_ExceptVersaoErrada, [LVReque, LVerIdent])),
                           PWideChar(Application.Title), MB_ICONERROR + mb_ok
                          );
    result := False;
    Exit;
  End;

  Self.EnableGPU              := SetEnableGPU;
  Self.DisableFeatures        := SetDisableFeatures;

  if PathFrameworkDirPath <> '' then
    Self.FrameworkDirPath := PathFrameworkDirPath;

  if PathResourcesDirPath <> '' then
    Self.ResourcesDirPath := PathResourcesDirPath;

  if PathLocalesDirPath <> '' Then
    Self.LocalesDirPath := PathLocalesDirPath;

  if Pathcache <> '' then
    Self.cache := Pathcache;

  if PathUserDataPath <> '' then
    Self.UserDataPath := PathUserDataPath;

  if PathLogFile <> '' then
    Self.LogFile := PathLogFile;

  if PathDownloadAttached <> '' then
    Self.PathDownloadAttached := PathDownloadAttached;

  if SetLogSeverity then
    Self.LogSeverity := LOGSEVERITY_INFO;

  DestroyApplicationObject := True;

  UpdateIniFile('Path Defines', 'FrameWork',     GetRelativePath(Self.FrameworkDirPath));
  UpdateIniFile('Path Defines', 'Binary',        GetRelativePath(Self.ResourcesDirPath));
  UpdateIniFile('Path Defines', 'Locales',       GetRelativePath(Self.LocalesDirPath));
  UpdateIniFile('Path Defines', 'Cache',         GetRelativePath(Self.Cache));
  UpdateIniFile('Path Defines', 'Data User',     GetRelativePath(Self.UserDataPath));
  UpdateIniFile('Path Defines', 'Log File',      GetRelativePath(Self.LogFile));
  UpdateIniFile('Path Defines', 'Log Console',   GetRelativePath(Self.PathLogConsole));
  UpdateIniFile('Path Defines', 'Auto Receiver attached Path', GetRelativePath(Self.PathDownloadAttached));

  FIniFIle.WriteBool('Path Defines', 'GPU',                  SetEnableGPU);
  FIniFIle.WriteBool('Path Defines', 'Log Severity',         SetLogSeverity);
  FIniFIle.WriteBool('Path Defines', 'Log Console Active',   LogConsoleActive);

  UpdateIniFile('Tinject Comp', 'TInject Versão',   TInjectVersion);
  UpdateIniFile('Tinject Comp', 'Caminho JS'    ,   TInjectJS_JSUrlPadrao);
  UpdateIniFile('Tinject Comp', 'CEF4 Versão'   ,   IntToStr(CEF_SUPPORTED_VERSION_MAJOR) +'.'+ IntToStr(CEF_SUPPORTED_VERSION_MINOR)  +'.'+ IntToStr(CEF_SUPPORTED_VERSION_RELEASE) +'.'+ IntToStr(CEF_SUPPORTED_VERSION_BUILD));
  UpdateIniFile('Tinject Comp', 'CHROME Versão' ,   IntToStr(CEF_CHROMEELF_VERSION_MAJOR) +'.'+ IntToStr(CEF_CHROMEELF_VERSION_MINOR)  +'.'+ IntToStr(CEF_CHROMEELF_VERSION_RELEASE) +'.'+ IntToStr(CEF_CHROMEELF_VERSION_BUILD));
  UpdateIniFile('Tinject Comp', 'Dlls'          ,   LIBCEF_DLL + ' / ' + CHROMEELF_DLL);
  if Falterdo then
    UpdateDateIniFile;

  //Chegou aqui, é porque os PATH são validos e pode continuar
  inherited;  //Dispara a THREAD la do objeto PAI

  if Self.status <> asInitialized then
    Exit; //estado invalido!!!! pode trer dado erro acima

  Linicio := GetTickCount;
  try
   if Self.status <> asInitialized then
      Self.StartMainProcess;
    while  Self.status <> asInitialized do
    Begin
      Sleep(10);
      if (GetTickCount - Linicio) >= FStartTimeOut then
         Break;
    End;
  finally
    Result  := (Self.status = asInitialized);
    if not Result then
       Application.MessageBox(PWideChar(MSG_ConfigCEF_ExceptConnection), PWideChar(Application.Title), MB_ICONERROR + mb_ok);
  end;
end;

procedure TCEFConfig.SetPathLogFile(const Value: String);
begin
  if TestaOk(FPathLogFile, Value) Then
    FPathLogFile := Value;
end;

destructor TCEFConfig.Destroy;
begin
  if not FInDesigner then
     FreeandNil(FIniFIle);
  inherited;
end;


function TCEFConfig.PathJsOverdue: Boolean;
begin
  Result := (MinutesBetween(Now, FPathJsUpdate) > MinutosCOnsideradoObsoletooJS)
end;

initialization
  if not Assigned(GlobalCEFApp) then
     GlobalCEFApp := TCEFConfig.Create;


finalization
  if Assigned(GlobalCEFApp) then
     GlobalCEFApp.Free;
end.
