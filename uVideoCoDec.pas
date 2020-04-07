{
http://msdn.microsoft.com/library/default.asp?url=/library/en-us/multimed/htm/_win32_multimedia_functions.asp
http://h30266.www3.hp.com/odl/axplp/progtool/mmserv22/mmeos022.htm

    Compression scheme taken from VirtualDub
    Wrote by Bajenov Andrey 2006.Sen.10 - 10.dec.2013

ver. 12

������� ��������� �������� ��� ������:
InitDecompressor
������������ ������� ��������� ��������� �������
ICDecompressGetFormat
� ��� ��� ��� ��������� ������� ���� MS Video1
��� �������� �������� ��������� ������ - �������� 16 ������!
� ���������� � Unit1 ��� ������������ BMP �� ������ �����������
��� � ��� 16 ��� ��������� ��������� � ��� ��� ������� �����������!!!


��� �������� ���:
InitCompressor( );
InitDecompressor( );
��� ��� ����� ������� ������� ������ � �������� �����������
CloseCompressor;
CloseDecompressor;


ICSeqCompress ��� ������, ������� ������ �������� ��� �� �� ICCompress 
���� ������������ ������������������
When finished with compression, use the ICCompressorFree function to release the resources specified in COMPVARS.
}

unit uVideoCoDec;

interface

uses windows, sysutils, Classes, vfw, Graphics;


const
  VFW_EXT_RESULT = 1;
  FOURCC_YUY2 = $32595559;//MKFOURCC('Y','U','Y','2');
  ffdShow = 1396983366;

resourcestring
  sErrorICGetInfo = 'Unable to retrieve video compressor information';
  sErrorICCompressBegin = 'Cannot start video compression'#13#10'Error code: %d';
  sErrorICCompressBeginBF = 'Cannot start video compression'#13#10'Unsupported format (Error code: %d)';

type
  TCompressorMode = (CM_SingleFrame, CM_SequenceFrame);

//type
//TCallbackStatusFunction  = function (lParam: DWord; wMessage: word):Longint of object;
//TCallbackStatusFunction  = function (lParam: lparam; wMessage: word):Longint of object;
//TCallbackStatusFunction  = function (lParam: lparam; wMessage: word; l: Longint):Longint of object;
//  TCallbackStatusFunction  = function (lParam: lparam; wMessage: word; l: Longint):cardinal of object;
//  TCallbackStatusFunction  = function (lParam: lparam; wMessage: word):Longint;
//��.  TICStatusProc

type
  TFourCC = packed record
    case Integer of
      0: (AsCardinal: Cardinal);
      1: (AsString: array[0..3] of Char);
  end;

  EVideoCoDecError = class(Exception);

  TVideoCoDec = class(TObject)
  private
//    hICDec: THandle;
    cv: TCompVars;
    cvDec: TCompVars;
    FCodecInfo : TICINFO;
    cvDontFree: boolean;
    FFlags: Cardinal;
//    InputInfoHeader: TBitmapInfoHeader;
//    OutInfoHeader  : TBitmapInfoHeader;
    FPrevBuffer: Pointer;
    FlpbiHeaderPrev: Pointer;
//v05    FBuffCompOut: PChar;//������ ����� ��� PChar, � �� Pointer?
//v05    FBuffDeCompOut: PChar;
    FBuffCompOut: Pointer;
    FBuffDeCompOut: Pointer;
    FCompressorStarted: Boolean;
    FDecompressorStarted: Boolean;
    FCompressorMode: TCompressorMode;
    FCustomErrorMessage: string;

    FFrameNum: Integer;
    FKeyRateCounter: Integer;
    FForceKeyFrameRate: Boolean;
    FMaxKeyFrameInterval: DWORD;//integer;//Cardinal;
    FRequestedMaxFrameSize: DWORD;//Cardinal;
    FMaxFrameSize: integer;//Cardinal;
    FMaxPackedSize: integer;//Cardinal;
    FSlopSpace: integer;//Cardinal;
    FCompressorBuffersWanted: DWORD;
    FDecompressorBuffersWanted: DWORD;

    FCodecName: string;
    FCodecDescription: string;
    FDriver: string;
    FCodecList: TList; //������ ���������� �� ��������� TICINFO;
                       //��������! ���� �������� ������!!! ����� ���� ������ �����������!

    pConfigData: Pointer;
    cbConfigData: integer;//Cardinal;
    FLastError: Integer;
    FCallbackStatusFunction: TICStatusProc;

    FCompressInbiSize, FCompressOutbiSize: byte;//����� �����! ��� ������ ������ biHeader.biSize!
    FDecompressInbiSize, FDecompressOutbiSize: byte;

    FCodecStatusFinish: boolean;
    FCodecStatusInProgress: DWord;

    function InternalInit(const HasComp: Boolean = false): Boolean;
    procedure SetCompVars(CompVars: TCompVars);
    procedure ClearCompVars(var CompVars: TCompVars);
    procedure CloseDrivers;
    function Init(CompVars: TCompVars): Boolean; overload;
    function Init(InputFormat, OutputFormat: TBitmapInfo;
                  const Quality, KeyRate: Integer): Boolean; overload;
    function Init(InputFormat, OutputFormat: TBitmapInfoHeader;
                  const Quality, KeyRate: Integer;
                  CompressMode:  TCompressorMode): Boolean; overload;
    function ICCompressInternalInit(pCV : PCompVars) : Boolean;
    function StartCompressor: Boolean;
    function StartDecompressor: Boolean;
    // start calls the 2 functions above
    procedure Start;
    procedure Finish;
//    function DefaultCodecStatusProc(lParam:lparam; wMessage:word; l: Longint):Longint;
    function DefaultCodecStatusProc(lParam:lparam; wMessage:word; l: Longint):Longint;
//    function DefaultCodecStatusProc(lParam:lparam; wMessage:word; l: Longint): cardinal;
  public

    constructor Create;
    destructor Destroy; override;


    function InitCompressor(CompreccorFccHandler :DWORD;
                            InputFormat: BitmapInfo;
                            OutputFormat: BitmapInfo;
                            const Quality, KeyRate: Integer;
                            RequestedMaxFrameSize: DWORD): pBitmapInfo;
    function InitDecompressor(DecompreccorFccHandler :DWORD;
                              InputFormat: TBitmapInfo;//Header;
                              OutputFormat: TBitmapInfo;//Header;
                              const Quality, KeyRate: Integer;
                              RequestedMaxFrameSize: DWORD): pBitmapInfo;//oolean;

    procedure CloseDecompressor;
    procedure CloseCompressor;
    // finish calls the 2 procedures above
    function ChooseCodec: Boolean;
    procedure ConfigureCompressor;
{
    //���������� � ������������ � ��������� �����������!
    Function UpdateVideoFormat(CompressorFccHandler: DWORD;
                               bmihRawInputFormat: TBitmapInfo;//Header;
                               Quality: integer; CurrentFrameRate: integer; CompressMode: TCompressorMode):string;
}
    function GetDecompressorHICByCompressedHeader(CompressedHEADER, DecompressedHeader: PBITMAPINFOHEADER): HIC;

    procedure SetDataRate(const lLimitDataRatePerSec, lUsPerFrame, lFrameCount: Integer);
    procedure SetQuality(const Value: Integer);
    function GetQuality: Integer;

    function EnumCodecs(List: TStrings): Integer;

    procedure DropFrame;
//    function PackBitmap(Bitmap: TBitmap; var IsKeyFrame: Boolean; var Size: Cardinal): Pointer;
    function UnpackFrame(ImageData: Pointer; KeyFrame: Boolean; var PackedSize: Cardinal): Pointer;
    function CompressImage(ImageData: Pointer; Quality: Integer; var Size: Cardinal): HBITMAP;
    function DecompressImage(ImageData: Pointer): HBITMAP;
    function UnpackBitmap(ImageData: Pointer; KeyFrame: Boolean; Bitmap: TBitmap): Boolean;

    function SeqCompressFrameStart(): Boolean;
    Procedure SeqCompressFrameEnd;
    function SeqCompressFrame(pImageData: Pointer; var IsKeyFrame: Boolean; var Size: DWORD): Pointer;
    //�-��� ����� � ������ Compression.ru
    function PackFrame(ImageData: Pointer; var IsKeyFrame: Boolean;
                       var Size: DWORD): Pointer;
    function ICCompressFrame(pCV : PCompVars; uiFlags : Cardinal;
                       lpBits : Pointer; var dwFlagKey : DWORD;
                       var IsKeyFrame : Boolean; var lSize : DWORD) : Pointer;
    procedure ICSeqCompressFrameEnd2(pCV : PCompVars);
    function TranslateICError(ErrCode: Integer): string;


    function GetCompressorBitmapInfoIn: TBitmapInfo;
    function GetCompressorBitmapInfoOut: TBitmapInfo;
    function GetDecompressorBitmapInfoIn: TBitmapInfo;
    function GetDecompressorBitmapInfoOut: TBitmapInfo;

    function FOURCCtoString(FOURCode: DWORD):string;

    property CompressInbiSize: byte read FCompressInbiSize;
    property CompressOutbiSize: byte read FCompressOutbiSize;//����� �����! ��� ������ ������ biHeader.biSize!
    property DecompressInbiSize: byte read FDecompressInbiSize;
    property DecompressOutbiSize: byte read FDecompressOutbiSize;

    property CompressorMode: TCompressorMode read FCompressorMode;
    property RequestedMaxFrameSize: DWORD read FRequestedMaxFrameSize write FRequestedMaxFrameSize;

    property CompressorStarted: Boolean read FCompressorStarted;
    property DecompressorStarted: Boolean read FDecompressorStarted;
    property CompressorBitmapInfoIn: TBitmapInfo read GetCompressorBitmapInfoIn;
    property CompressorBitmapInfoOut: TBitmapInfo read GetCompressorBitmapInfoOut;
    property DecompressorBitmapInfoIn: TBitmapInfo read GetDecompressorBitmapInfoIn;
    property DecompressorBitmapInfoOut: TBitmapInfo read GetDecompressorBitmapInfoOut;
    property Quality: Integer read GetQuality write SetQuality;
    property ForceKeyFrameRate: Boolean read FForceKeyFrameRate write FForceKeyFrameRate;
//    property MaxKeyFrameRate: Cardinal read FMaxKeyFrameInterval write FMaxKeyFrameInterval;
    property MaxKeyFrameRate: DWORD read FMaxKeyFrameInterval write FMaxKeyFrameInterval;
    property CodecName: string read FCodecName;////Short version of the compressor name. The name in the null-terminated string should be suitable for use in list boxes.
    property CodecDescription: string read FCodecDescription;//Long version of the compressor name

    property CodecInfo: TICINFO read FCodecInfo;//Full codec info
    property Driver: string read FDriver;//Long version of the compressor name
    property CodecList: TList read FCodecList; //������ ���������� �� ��������� TICINFO;
    property LastError: Integer read FLastError;//Name of the module containing VCM compression driver. Normally, a driver does not need to fill this out.
    property CallbackStatusFunction: TICStatusProc read FCallbackStatusFunction write FCallbackStatusFunction;
  end;

function IIF(const Condition: Boolean; const ifTrue, ifFalse: Integer): Integer;overload;
function IIF(const Condition: Boolean; const ifTrue, ifFalse: Pointer): Pointer;overload;
function HasFlag(const Flags, CheckFlag: Integer): Boolean;overload;
function HasFlag(const Flags, CheckFlag: Cardinal): Boolean;overload;

implementation

resourcestring
  sVideoCoDecAbort = 'Abort';
  sVideoCoDecBadBitDepth = 'Bad bit-depth';
  sVideoCoDecBadFlags = 'Bad flags';
  sVideoCoDecBadFormat = 'Bad format';
  sVideoCoDecBadHandle = 'Bad handle';
  sVideoCoDecBadImageSize = 'Bad image size';
  sVideoCoDecBadParameter = 'Bad parameter';
  sVideoCoDecBadSize = 'Bad size';
  sVideoCoDecCanTUpdate = 'Can''t update';
  sVideoCoDecDonTDraw = 'Don''t draw';
  sVideoCoDecError = 'Error';
  sVideoCoDecGoToKeyFrame = 'Go to KeyFrame';
  sVideoCoDecInternalError = 'Internal error';
  sVideoCoDecNewPalette = 'New palette';
  sVideoCoDecNoError = 'No error';
  sVideoCoDecNotEnoughMemory = 'Not enough memory';
  sVideoCoDecStopDrawing = 'Stop drawing';
  sVideoCoDecUnknownError = 'Unknown error';
  sVideoCoDecUnsupportedFunctionFormat = 'Unsupported function/format';

Function CodecStatusProc(lParam: LPARAM; message: UINT; l: DWORD): Longint;
begin
//self.CodecStatusFinish := true;
{
case message of
  ICSTATUS_START: self.CodecStatusFinish := false;
  ICSTATUS_STATUS: self.CodecStatusInProgress := lParam;//Operation is proceeding, and is lParam percent done.
  ICSTATUS_END: self.CodecStatusFinish := true;
//    ICSTATUS_ERROR:
//    ICSTATUS_YIELD://A lengthy operation is proceeding. This value has the same meaning as ICSTATUS_STATUS but does not indicate a value for percentage done.
  end;
}

//Returns zero if processing should continue or a nonzero value if it should end.
result := 0;
if lParam = 2 then result := -1;
if message = 1621432 then result := -1;
end;

function GetSizeMemOfPointer(p: pointer):integer;
begin
//����� ������ ������ ��������� ������ �� ��������� (Pinteger((PChar(Client.pRawBitmapBuffer))-8))^
//http://www.rsdn.ru/article/Delphi/memmanager.xml#E1BAC
result := (Pinteger((PChar(p))-8))^;
end;


function IIF(const Condition: Boolean; const ifTrue, ifFalse: Integer): Integer;overload;
begin
     if Condition then
        Result:=ifTrue
     else
        Result:=ifFalse;
end;

function IIF(const Condition: Boolean; const ifTrue, ifFalse: Pointer): Pointer;overload;
begin
     if Condition then
        Result:=ifTrue
     else
        Result:=ifFalse;
end;

function HasFlag(const Flags, CheckFlag: Integer): Boolean;overload;
begin
     Result:=(Flags and CheckFlag) = CheckFlag;
end;

function HasFlag(const Flags, CheckFlag: Cardinal): Boolean;overload;
begin
     Result:=(Flags and CheckFlag) = CheckFlag;
end;

{ TVideoCoDec }
function TVideoCoDec.FOURCCtoString(FOURCode: DWORD):string;
var
  pb: pByte;
  s: string[4];
begin
pb := @(FOURCode);
s[1] := Char(pb^);
inc(pb);
s[2] := Char(pb^);
inc(pb);
s[3] := Char(pb^);
inc(pb);
s[4] := Char(pb^);
result := s;
end;

function TVideoCoDec.TranslateICError(ErrCode: Integer): string;
begin
     case ErrCode of
       ICERR_OK:            Result:=sVideoCoDecNoError;
       ICERR_DONTDRAW:      Result:=sVideoCoDecDonTDraw;
       ICERR_NEWPALETTE:    Result:=sVideoCoDecNewPalette;
       ICERR_GOTOKEYFRAME:  Result:=sVideoCoDecGoToKeyFrame;
       ICERR_STOPDRAWING:   Result:=sVideoCoDecStopDrawing;

       ICERR_UNSUPPORTED:   Result:=sVideoCoDecUnsupportedFunctionFormat;
       ICERR_BADFORMAT:     Result:=sVideoCoDecBadFormat;
       ICERR_MEMORY:        Result:=sVideoCoDecNotEnoughMemory;
       ICERR_INTERNAL:      Result:=sVideoCoDecInternalError;
       ICERR_BADFLAGS:      Result:=sVideoCoDecBadFlags;
       ICERR_BADPARAM:      Result:=sVideoCoDecBadParameter;
       ICERR_BADSIZE:       Result:=sVideoCoDecBadSize;
       ICERR_BADHANDLE:     Result:=sVideoCoDecBadHandle;
       ICERR_CANTUPDATE:    Result:=sVideoCoDecCanTUpdate;
       ICERR_ABORT:         Result:=sVideoCoDecAbort;
       ICERR_ERROR:         Result:=sVideoCoDecError;
       ICERR_BADBITDEPTH:   Result:=sVideoCoDecBadBitDepth;
       ICERR_BADIMAGESIZE:  Result:=sVideoCoDecBadImageSize;
       ICERR_CUSTOM:        Result:=FCustomErrorMessage;
       else
         Result := sVideoCoDecUnknownError;
     end;
end;

Function TVideoCoDec.DefaultCodecStatusProc(lParam: lparam; wMessage: word; l: Longint): Longint;
//Function TVideoCoDec.DefaultCodecStatusProc(lParam: lparam; wMessage: word; l: Longint): cardinal;
begin
//self.CodecStatusFinish := true;
{
case wMessage of
  ICSTATUS_START: self.CodecStatusFinish := false;
  ICSTATUS_STATUS: self.CodecStatusInProgress := lParam;//Operation is proceeding, and is lParam percent done.
  ICSTATUS_END: self.CodecStatusFinish := true;
//    ICSTATUS_ERROR:
//    ICSTATUS_YIELD://A lengthy operation is proceeding. This value has the same meaning as ICSTATUS_STATUS but does not indicate a value for percentage done.
  end;
}

//Returns zero if processing should continue or a nonzero value if it should end.
result := 0;
end;

constructor TVideoCoDec.Create;
begin
     cvDec.hic := 0;
     cv.hic := 0;
     cv.fccType := 0;
     cvDec.fccType := 0;
     FillChar(cv, SizeOf(cv), 0);
     FillChar(cvDec, SizeOf(cvDec), 0);
     cv.cbSize:=SizeOf(cv);
     cvDec.cbSize:=SizeOf(cvDec);
//   cv.lpbiIn Reserved; do not use. http://msdn.microsoft.com/en-us/library/windows/desktop/dd797797(v=vs.85).aspx

     //� ���������� ������ XVid  compress_get_format() ���������� return sizeof(BITMAPINFOHEADER)
     //�.�. ����� ��� �� ������ ������������ ��������� BITMAPINFOHEADER ��� ������.
     FCompressInbiSize := sizeof(TBitmapInfo);
     FCompressOutbiSize := sizeof(TBitmapInfo);
     cv.lpbiIn := AllocMem(CompressInbiSize);//44 ����� �������� ��� ���� ����� MS VIDEO1
     cv.lpbiOut := AllocMem(CompressOutbiSize);//�������� ��� ���� ����� MS VIDEO1

//     cv.lpbiIn := AllocMem(sizeof(TBitmapInfoHeader));//�������� ��� ���� ����� MS VIDEO1
//     cv.lpbiOut := AllocMem(sizeof(TBitmapInfoHeader));//�������� ��� ���� ����� MS VIDEO1
//     cv.lpbiIn := AllocMem(sizeof(BITMAPV5HEADER) + sizeof(RGBQUAD));
//     cv.lpbiOut := AllocMem(sizeof(BITMAPV5HEADER) + sizeof(RGBQUAD));
//     cv.lpbiIn := AllocMem(sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));
//     cv.lpbiOut := AllocMem(sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));

//     cvDec.lpbiIn := nil;
//     cvDec.lpbiOut := nil;
     FDecompressInbiSize := sizeof(TBitmapInfo);
     FDecompressOutbiSize := sizeof(TBitmapInfo);
     cvDec.lpbiIn := AllocMem(DecompressInbiSize);//�������� ��� ���� ����� MS VIDEO1
     cvDec.lpbiOut := AllocMem(DecompressOutbiSize);//�������� ��� ���� ����� MS VIDEO1
//     cvDec.lpbiIn := AllocMem(sizeof(TBitmapInfoHeader));//�������� ��� ���� ����� MS VIDEO1
//     cvDec.lpbiOut := AllocMem(sizeof(TBitmapInfoHeader));//�������� ��� ���� ����� MS VIDEO1
//     cvDec.lpbiIn := AllocMem(sizeof(BITMAPV5HEADER) + sizeof(RGBQUAD));
//     cvDec.lpbiOut := AllocMem(sizeof(BITMAPV5HEADER) + sizeof(RGBQUAD));
//     cvDec.lpbiIn := AllocMem(sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));
//     cvDec.lpbiOut := AllocMem(sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));

//������� ������ ��� TBitmapInfo, ������ ���������� ������ � ��� TBitmapInfoHeader
     FFlags := 0;
     FPrevBuffer := nil;
     FBuffCompOut:=nil;
     FBuffDeCompOut:=nil;
     pConfigData:=nil;
     FCompressorStarted:=false;
     FDecompressorStarted:=false;
     FForceKeyFrameRate:=false;
     cbConfigData:=0;
     FLastError:=ICERR_OK;
     FCodecList := TList.Create;
     FCompressorMode := CM_SingleFrame;
     FCustomErrorMessage := '';
     FCompressorBuffersWanted := 1;
     FDecompressorBuffersWanted := 1;

//     FCallbackStatusFunction := DefaultCodecStatusProc;
//     FCallbackStatusFunction := nil;
     FCallbackStatusFunction := @CodecStatusProc;
end;

destructor TVideoCoDec.Destroy;
var i: integer;
begin
     if FPrevBuffer <> nil then
       begin
       //FreeMem(FPrevBuffer);
       //FPrevBuffer := nil;
       ReallocMem(FPrevBuffer, 0)
       end;
     if FlpbiHeaderPrev <> nil then
       begin
       //FreeMem(FlpbiHeaderPrev);
       //FlpbiHeaderPrev := nil;
       ReallocMem(FlpbiHeaderPrev, 0);
       end;
     if FPrevBuffer <> nil then
       begin
       //FreeMem(FPrevBuffer);
       //FPrevBuffer := nil;
       ReallocMem(FPrevBuffer, 0);
       end;
     if FBuffCompOut <> nil then
       begin
       //FreeMem(FBuffCompOut);
       //FBuffCompOut := nil;
       ReallocMem(FBuffCompOut, 0);
       end;
     if pConfigData <> nil then
       begin
       //FreeMem(pConfigData);
       //pConfigData := nil;
       ReallocMem(pConfigData, 0);
       end;
     // these could be freed by ICCompressFree
     // but I don't know what that function REALLY does !
     CloseDrivers;
     ClearCompVars(cv);
     ClearCompVars(cvDec);
     for i := 0 to FCodecList.Count - 1 do
       begin
       FreeMem(FCodecList.Items[i]);
       end;
     FCodecList.Free;

     //��� ��������� AV....
//������-�� ��� ��������� �� ������������ ��������������
//������ � �� ��� ����� ��� �����������     
     if FBuffDeCompOut <> nil then
       begin
       FreeMem(FBuffDeCompOut);
       FBuffDeCompOut := nil;
//       ReallocMem(FBuffDeCompOut, 0);
       end;
     inherited;
end;

procedure TVideoCoDec.ClearCompVars(var CompVars: TCompVars);
begin
     if CompVars.lpbiIn <> nil then
       begin
       FreeMem(CompVars.lpbiIn);// ��� ����������� ��� ������� �� ���������
       CompVars.lpbiIn := nil;
       end;
     if CompVars.lpbiOut <> nil then
       begin
       FreeMem(CompVars.lpbiOut);// ��� ����������� ��� ������� �� ���������
       CompVars.lpbiOut := nil;
       end;
ICCompressorFree(@CompVars);
     if CompVars.lpState <> nil then
       begin
       FreeMem(CompVars.lpState);
       CompVars.lpState := nil;
       end;
     if CompVars.lpBitsOut <> nil then
       begin
       FreeMem(CompVars.lpBitsOut);
       CompVars.lpBitsOut := nil;
       end;
     if CompVars.lpBitsPrev <> nil then
       begin
       FreeMem(CompVars.lpBitsPrev);
       CompVars.lpBitsPrev := nil;
       end;
     FillChar(CompVars, SizeOf(TCompVars), 0);
end;

procedure TVideoCoDec.SetCompVars(CompVars: TCompVars);
begin
//You can let ICCompressorChoose fill the contents
//of this structure or you can do it manually. 
//If you manually fill the structure, you must provide information 
//for the following members: cbSize, hic, lpbiOut, lKey, and lQ. 
//Also, you must set the ICMF_COMPVARS_VALID flag in the dwFlags member.

// http://msdn.microsoft.com/en-us/library/windows/desktop/dd797797%28v=vs.85%29.aspx
     cv.cbState:=CompVars.cbState;
//     cv.dwFlags:=CompVars.dwFlags;
     cv.dwFlags := ICMF_COMPVARS_VALID;
     cv.fccHandler:=CompVars.fccHandler;
     cv.fccType:=CompVars.fccType;

     if CompVars.hic > 0 then
     begin
       if cv.hic > 0 then
          ICClose(cv.hic);

       cv.hic:=CompVars.hic;
     end;
     
     cv.lDataRate:=CompVars.lDataRate;
     cv.lFrame:=CompVars.lFrame;
     cv.lKey:=CompVars.lKey;
     cv.lKeyCount:=CompVars.lKeyCount;
     cv.lQ:=CompVars.lQ;
     CopyMemory(cv.lpbiIn, CompVars.lpbiIn, SizeOf(TBitmapInfo));
     CopyMemory(cv.lpbiOut, CompVars.lpbiOut, SizeOf(TBitmapInfo));
end;

//When finished with compression, use the ICCompressorFree function to release the resources specified by COMPVARS.
procedure TVideoCoDec.CloseCompressor;
begin
if (FCompressorMode = CM_SingleFrame) then
  begin
  if cv.hic > 0 then
    begin
    ICClose(cv.hic);
    cv.hic:=0;
    end;
  end
else
  begin
  ICCompressorFree(@cv);
  end;
self.FCompressorStarted := false;
end;

procedure TVideoCoDec.CloseDecompressor;
begin
if cvDec.hic > 0 then
  begin
  ICClose(cvDec.hic);
  cvDec.hic := 0;
  end;
self.FDecompressorStarted := false;
end;

procedure TVideoCoDec.CloseDrivers;
begin
     CloseCompressor;
     CloseDecompressor;
end;

function TVideoCoDec.GetDecompressorHICByCompressedHeader(CompressedHEADER, DecompressedHeader: PBITMAPINFOHEADER): HIC;
var CodecList: TStrings;
begin
//0 - ������������ �� ������
// fccHandler
//   Specifies a single preferred handler of the given type that should be tried first. Typically, this handler comes from the stream header in an AVI file or from the ICINFO structure.
//   If this value is:
//   A zero, then the first compressor or decompressor found is opened.
//   Between 1 and the number of installed compressors of this type, then the compressor or decompressor with that number is opened. If this compressor or decompressor cannot handle the data formats, no device is opened.
//   A FOURCC, then that compressor or decompressor is opened. (If there are multiple devices with the same FOURCC, the first device will be used.) If this compressor or decompressor cannot handle the data formats, the first device that can handle the formats is opened.
result := 0;
//CodecList := TStrings.Create;
//self.EnumCodecs(CodecList);
//if CodecList.Count > 0 then
//  begin
  result := ICLocate(ICTYPE_VIDEO, CompressedHEADER.biCompression, CompressedHEADER, nil, ICMODE_DECOMPRESS);
//  end;
//CodecList.free;
end;

function TVideoCoDec.InternalInit(const HasComp: Boolean = false): Boolean;
var info: TICINFO;
    lRealMaxPackedSize: Cardinal;
    res : integer;
begin
     FCodecName:='';
     FCodecDescription:='';

     CloseDecompressor;
     if not HasComp then
     begin
       CloseCompressor;
       cv.hic := ICOpen(cv.fccType, cv.fccHandler, ICMODE_COMPRESS);
       res := ICSetStatusProc(cv.hic, 0, 0, @FCallbackStatusFunction);
//     if res >= 0 then Result := InternalInit
     end;
     cvDec.hic := ICOpen(cv.fccType, cv.fccHandler, ICMODE_DECOMPRESS);

     FKeyRateCounter := 1;

     // Retrieve compressor information.
     FillChar(info, SizeOf(info), 0);
     FLastError := ICGetInfo(cv.hic, @info, SizeOf(info));
     Result := FLastError <> 0;
     if (not Result) or (info.fccHandler = 0) then
       begin
       //SetLastError();
       Result := false;
       exit;
       end
     else
       FLastError := 0;

     FCodecName := info.szName;//Short version of the compressor name. The name in the null-terminated string should be suitable for use in list boxes.
     FCodecDescription := info.szDescription;//Long version of the compressor name.
     FDriver := info.szDriver;//Name of the module containing VCM compression driver. Normally, a driver does not need to fill this out.

     FFlags := info.dwFlags;
     if HasFlag(info.dwFlags, VIDCF_TEMPORAL) then
       //Driver supports inter-frame compression.
       //����� ���������� ���������� ����, ���� ������� VIDCF_TEMPORAL,
       // �� ������� VIDCF_FASTTEMPORALC � �� �������� ����.
       if not HasFlag(info.dwFlags, VIDCF_FASTTEMPORALC) then
         begin
         //Driver can perform temporal decompression and maintains its own copy of the current frame.
         //When decompressing a stream of frame data, the driver doesn't need image data from the previous frame.
         //� ������ ������ ������� ��������� � ���������� ����� � �� ������ �������� ��� ���� ������
         ReallocMem(FPrevBuffer, cv.lpbiIn^.bmiHeader.biSizeImage);
         cv.lpBitsPrev := FPrevBuffer;
         end;

     if not HasFlag(info.dwFlags, VIDCF_QUALITY) then
        cv.lQ := 0;

     // Allocate destination buffer

     FMaxPackedSize := ICCompressGetSize(cv.hic, @(cv.lpbiIn^.bmiHeader), @(cv.lpbiOut^.bmiHeader));
     CV.lpbiOut.bmiHeader.biSizeImage := FMaxPackedSize;

     // Work around a bug in Huffyuv.  Ben tried to save some memory
     // and specified a "near-worst-case" bound in the codec instead
     // of the actual worst case bound.  Unfortunately, it's actually
     // not that hard to exceed the codec's estimate with noisy
     // captures -- the most common way is accidentally capturing
     // static from a non-existent channel.
     //
     // According to the 2.1.1 comments, Huffyuv uses worst-case
     // values of 24-bpp for YUY2/UYVY and 40-bpp for RGB, while the
     // actual worst case values are 43 and 51.  We'll compute the
     // 43/51 value, and use the higher of the two.

     if (FMaxPackedSize <= 0 ) then
       begin
       FMaxPackedSize := cv.lpbiIn^.bmiHeader.biSizeImage;
       end;

     if (info.fccHandler = MKFOURCC('U', 'Y', 'F', 'H'))  then
     begin
       lRealMaxPackedSize:=cv.lpbiIn^.bmiHeader.biWidth * cv.lpbiIn^.bmiHeader.biHeight;

       if (cv.lpbiIn^.bmiHeader.biCompression = BI_RGB) then
          lRealMaxPackedSize:=(lRealMaxPackedSize * 51) shr 3
       else
          lRealMaxPackedSize:=(lRealMaxPackedSize * 43) shr 3;

       if lRealMaxPackedSize > FMaxPackedSize then
          FMaxPackedSize:=lRealMaxPackedSize;
     end;
//     FMaxPackedSize := 200000;

     ReallocMem(FBuffCompOut, FMaxPackedSize);
     cv.lpBitsOut := FBuffCompOut;

     // Save configuration state.
     //
     // Ordinarily, we wouldn't do this, but there seems to be a bug in
     // the Microsoft MPEG-4 compressor that causes it to reset its
     // configuration data after a compression session.  This occurs
     // in all versions from V1 through V3.
     //
     // Stupid fscking Matrox driver returns -1!!!

     cbConfigData := ICGetStateSize(cv.hic);

     if cbConfigData >= 0 then
     begin
       ReallocMem(pConfigData, cbConfigData);

       cbConfigData:=ICGetState(cv.hic, pConfigData, cbConfigData);
       // As odd as this may seem, if this isn't done, then the Indeo5
       // compressor won't allow data rate control until the next
       // compression operation!

       if cbConfigData <> 0 then
          ICSetState(cv.hic, pConfigData, cbConfigData);
     end;

     FMaxFrameSize:=0;
     FSlopSpace:=0;
end;

function TVideoCoDec.Init(CompVars: TCompVars): Boolean;
begin
     Finish;
     SetCompVars(CompVars);
     Result:=InternalInit(CompVars.hic > 0);
end;

function TVideoCoDec.Init(InputFormat, OutputFormat: TBitmapInfo;
                          const Quality, KeyRate: Integer): Boolean;
begin
     cv.lQ := Quality;
     cv.lKey := KeyRate;
     cv.lpbiIn^ := InputFormat;
     cv.lpbiOut^ := OutputFormat;
     cv.fccType := MKFOURCC('V', 'I', 'D', 'C');
     //cv.fccHandler := OutputFormat.bmiHeader.biCompression;
     if InputFormat.bmiHeader.biCompression <> 0 then
       cv.fccHandler := InputFormat.bmiHeader.biCompression
     else
       cv.fccHandler := OutputFormat.bmiHeader.biCompression;
     Result := InternalInit;
end;

function TVideoCoDec.Init(InputFormat, OutputFormat: TBitmapInfoHeader;
          const Quality, KeyRate: Integer;
          CompressMode:  TCompressorMode): Boolean;
var res: integer;
    uiFlags: word;
    s: string;
begin
     cv.lQ := Quality;
     cv.lKey := KeyRate;
     cv.lpbiIn^.bmiHeader := InputFormat;
     cv.lpbiOut^.bmiHeader := OutputFormat;
     cv.fccType := MKFOURCC('V', 'I', 'D', 'C');
     cv.fccHandler := OutputFormat.biCompression;//
     if CompressMode = CM_SequenceFrame then
       begin
       if OutputFormat.biCompression <> 0 then
         begin
         cv.hic := ICOpen(cv.fccType, cv.fccHandler, ICMODE_COMPRESS);
         res := ICSetStatusProc(cv.hic, 0, 0, @CallbackStatusFunction);
         s := 'Select';
         ICCompressorChoose(0, (uiFlags and ICMF_CHOOSE_ALLCOMPRESSORS), nil, nil, @cv, PChar(s));
         Result := (cv.hic > 0);
         end
       else
          Result := false;
       end
     else
       begin
       Result := InternalInit;
       end;
end;

{
Function TVideoCoDec.UpdateVideoFormat(CompressorFccHandler: DWORD;
                                       bmihRawInputFormat: pBitmapInfo;//Header;
                     Quality: integer; CurrentFrameRate: integer; CompressMode: TCompressorMode):string;
var CompressVideoFormat: pBitmapInfo;//Header;
begin
if FCompressorStarted = true then
  begin
  self.CloseCompressor;
  end;
if FDecompressorStarted = true then
  begin
  self.CloseDecompressor;
  end;

     CompressVideoFormat := bmihRawInputFormat;
     bmihRawInputFormat.bmiHeader.biCompression := 0;
     //���������� ��������� BMP ������. � ��������� ������� ������, ������� ����� � �.�.
     //����� �� ��� � � ����������, ������������ ������� � ��������� biCompression := 0 !!!!

     //FrameRate := round(1000/(Timer1.interval));//����� �����!!! ����� ������ �������������
     //Timer1.interval := round(1000/FrameRate);//����� �����!!! ����� ������ �������������
//     Self.Finish;
     Self.ForceKeyFrameRate := true;
     Self.SetDataRate(1024, 1000 * 1000 div CurrentFrameRate, 1);
     if CompressMode = CM_SingleFrame then
       begin
       if self.InitCompressor(CompressorFccHandler, bmihRawInputFormat, CompressVideoFormat, Quality, CurrentFrameRate, 0) = true then
         begin
         if self.StartDecompressor = false then
           begin
           FCustomErrorMessage := 'UpdateVideoFormat: ' +
                                 self.TranslateICError(FLastError) + ')';
           FLastError := ICERR_CUSTOM;
           end;
         end;
       end
     else
       begin
       if Self.Init( bmihRawInputFormat.bmiHeader, CompressVideoFormat.bmiHeader, Quality, CurrentFrameRate, CM_SequenceFrame) <> true then
         begin
         FCustomErrorMessage := 'UpdateVideoFormat: ' +
                               self.TranslateICError(FLastError) + ')';
         FLastError := ICERR_CUSTOM;
         //MessageBox(0, PChar('VideoCoDec.Init error!'), Pchar(inttostr(0)), mb_ok);;
         end;
       //��������!!!! � bmihOut ����������� ��������� ������� �� cbxFormat
       //� ������� setFrameRate() ���������� ����� �� �����!!! ����� AV!
       if not Self.StartCompressor then
         begin
         result := TranslateICError(Self.LastError);
         raise EVideoCoDecError.Create(TranslateICError(Self.LastError));
         end
       else
         begin
         result := Self.CodecDescription;
         end;
       end;
end;
}

procedure TVideoCoDec.SetDataRate(const lLimitDataRatePerSec, lUsPerFrame,
          lFrameCount: Integer);
var ici: TICINFO;
    icf: TICCOMPRESSFRAMES;
begin
     if cv.hic = 0 then exit;

     if (lLimitDataRatePerSec > 0) and HasFlag(FFlags, VIDCF_CRUNCH) then
        FMaxFrameSize := MulDiv(lLimitDataRatePerSec, lUsPerFrame, 1000000)
     else
        FMaxFrameSize := 0;

     // Indeo 5 needs this message for data rate clamping.

     // The Morgan codec requires the message otherwise it assumes 100%
     // quality :(

     // The original version (2700) MPEG-4 V1 requires this message, period.
     // V3 (DivX) gives crap if we don't send it.  So special case it.




     ICGetInfo(cv.hic, @ici, SizeOf(ici));

     FillChar(icf, SizeOf(icf), 0);

     icf.dwFlags := Cardinal(@icf.lKeyRate);//Applicable flags. The following value is defined: ICCOMPRESSFRAMES_PADDING.
     //                                       If this value is used, padding is used with the frame.

     //� �������
     icf.lpbiOutput := @(cv.lpbiOut^.bmiHeader);//Number of the first frame to compress.
                                                //lpbiOutput Pointer to a BITMAPINFOHEADER structure containing the output format.

     //lOutput :=                               //Reserved; do not use.

     //� �������
     icf.lpbiInput := @(cv.lpbiIn^.bmiHeader);//Number of the first frame to compress.
     //lpbiInput :=                           //Pointer to a BITMAPINFOHEADER structure containing the input format.

     //lInput :=                              //Reserved; do not use.

     icf.lStartFrame := 0;//Number of the first frame to compress.
     icf.lFrameCount := lFrameCount;//Number of frames to compress.
     icf.lQuality := cv.lQ;//Quality setting.
     icf.lDataRate := lLimitDataRatePerSec; // = dwRate div dwScale //Maximum data rate, in bytes per second.
     icf.lKeyRate := cv.lKey;//Maximum number of frames between consecutive key frames.
     icf.dwRate := 1000000;//Compression rate in an integer format.
                           //To obtain the rate in frames per second, divide this value by the value in dwScale.
     icf.dwScale := lUsPerFrame;//Value used to scale dwRate to frames per second.

     //dwOverheadPerFrame: Reserved; do not use.
     //dwReserved2: Reserved; do not use.
     //GetData: Reserved; do not use.
     //PutData: Reserved; do not use.

     FLastError := ICSendMessage(cv.hic, ICM_COMPRESS_FRAMES_INFO, WPARAM(@icf), SizeOf(TICCOMPRESSFRAMES));
end;

procedure TVideoCoDec.Start;
begin
     StartCompressor;
     StartDecompressor;
end;

function TVideoCoDec.StartCompressor: Boolean;
begin
     if cv.hic <= 0 then
       begin
       result := false;
       FLastError := ICERR_BADHANDLE;
       exit;
       end;
     FLastError := ICCompressQuery(cv.hic, @(cv.lpbiIn^.bmiHeader), @(cv.lpbiOut^.bmiHeader));
     if FLastError <> ICERR_OK then
       begin
       result := false;
       exit;
       end;

     FFrameNum := 0;
     FCompressorStarted := false;
     FCompressorMode := CM_SingleFrame;

     // Start compression process
     FLastError := ICCompressBegin(cv.hic, @(cv.lpbiIn^.bmiHeader), @(cv.lpbiOut^.bmiHeader));
     if FLastError <> ICERR_OK then
       begin
       //Result = ICERR_BADFORMAT
       //���� �� ������� ���������� ��������� ���������� ����� ������,
       //(������ ����� ��� �������� ������� ������� ����� ����������� �����
       //� ���������� ������. �.�. ��� ������� �� ������ ���� ��������, � ����� ����
       //�� ������ �����������. ������ ���������� ���� �� ���� ������ ������� � FPrevBuffer)
       //������ ����� �������� ����� ������� ������. ���������� �� ����� ����� ��
       //�� ���� ����� ���������� ���� ������ ���� ������� SeqCompressFrame.
       Result := SeqCompressFrameStart;
       end
     else
       begin
       Result := true;
       end;

     if not Result then exit;

     // Start decompression process if necessary
     if (FCompressorMode = CM_SingleFrame) and Assigned(FPrevBuffer) then
     //  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ <--- ��� ������� �
     begin
       if cvDec.hic <= 0 then
         begin
         FLastError := ICDecompressBegin(cvDec.hic, @(cv.lpbiOut^.bmiHeader), @(cv.lpbiIn^.bmiHeader));
         //� ����������� �� ������� ����� ��� ��������?
         Result := FLastError = ICERR_OK;
         if not Result then
         begin
           ICCompressEnd(cv.hic);
           exit;
         end;
       end;
     end;

     FCompressorStarted := true;
end;

function TVideoCoDec.StartDecompressor: Boolean;
begin
//��������� ������ 2:
//1. ������ �������, ����� ����� StartDecompressor ��� ������� InitDecompressor
//2. �������, ���� ��������� ����������, �� ����� ��������� ������

//���� ���������� ������� �������
     // Start decompression process
     if cvDec.hic <= 0 then
       begin
       result := false;
       FLastError := ICERR_BADHANDLE;
       exit;
       //��� ����� ���������� �� ������ ���������
       //hICDec := ICOpen(cv.fccType, cv.fccHandler, ICMODE_DECOMPRESS);
       //� ����� ��������� �� CV.lpbiIn^.bmiHeader
       end;
     FLastError := ICDecompressQuery(cvDec.hic, @(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
     if FLastError <> ICERR_OK then
       begin
       result := false;
       exit;
       end;

     FLastError := ICDecompressBegin(cvDec.hic, @(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
     FDecompressorStarted := FLastError = ICERR_OK;
     Result := FDecompressorStarted;
end;

procedure TVideoCoDec.Finish;
begin
     if (FCompressorStarted) then
       begin
       //���� �������� � ��������� ������
       if (FCompressorMode = CM_SingleFrame) then
         begin
         if (Assigned(FPrevBuffer)) then ICDecompressEnd(cv.hic);
         ICCompressEnd(cv.hic);

         FCompressorStarted:=false;
         // Reset MPEG-4 compressor
         if (cbConfigData > 0) and Assigned(pConfigData) then
     	     ICSetState(cv.hic, pConfigData, cbConfigData);
         end
       else
         begin
         //���� �������� � ������ ������������������ ������
         SeqCompressFrameEnd;
         end;
       end;

     if FDecompressorStarted then
       begin
       //
       FDecompressorStarted := false;
       ICDecompressEnd(cvDec.hic);
       end;
end;

function TVideoCoDec.ChooseCodec: Boolean;
var pc: TCompVars;
begin
     Result := not FCompressorStarted;
     if not Result then exit;

     pc := cv;
     pc.dwFlags := ICMF_COMPVARS_VALID;
     pc.lpbiIn := nil;
     pc.hic := 0;
     pc.lpbiOut := AllocMem(SizeOf(TBitmapInfo));

     Result := ICCompressorChoose(0, ICMF_CHOOSE_DATARATE or ICMF_CHOOSE_KEYFRAME,
       nil {maybe check input format ? @(cv.lpbiIn^.bmiHeader)}, nil, @pc, nil);

     // copy the original input format as it will be copied back in SetCompVars :)
     pc.lpbiIn := AllocMem(SizeOf(TBitmapInfo));
     CopyMemory(pc.lpbiIn, cv.lpbiIn, SizeOf(TBitmapInfo));

     if Result then
     begin
       SetCompVars(pc);
       InternalInit(pc.hic > 0);
     end;
     ClearCompVars(pc);
end;

procedure TVideoCoDec.ConfigureCompressor;
begin
     if cv.hic > 0 then
        FLastError:=ICConfigure(cv.hic, 0);
end;

function TVideoCoDec.CompressImage(ImageData: Pointer; Quality: Integer;
  var Size: Cardinal): HBITMAP;
begin
     Result:=ICImageCompress(cv.hic, 0, @(cv.lpbiIn^.bmiHeader), ImageData,
       @(cv.lpbiOut^.bmiHeader), Quality, @Size);
end;

function TVideoCoDec.DecompressImage(ImageData: Pointer): HBITMAP;
begin
     Result:=ICImageDecompress(cvDec.hic, 0, @(cv.lpbiOut^.bmiHeader), ImageData,
       @(cv.lpbiIn^.bmiHeader));
end;

procedure TVideoCoDec.DropFrame;
begin
     if (cv.lKey > 0) and (FKeyRateCounter > 1) then
     	Dec(FKeyRateCounter);
     Inc(FFrameNum);
end;

Function TVideoCoDec.SeqCompressFrameStart(): boolean;
Begin
FCompressorMode := CM_SequenceFrame;
result := ICSeqCompressFrameStart(@cv, @(cv.lpbiIn^));
FCompressorStarted := result;
//result := __ICSeqCompressFrameStart(@cv, @(cv.lpbiIn^.bmiHeader));
End;

Procedure TVideoCoDec.SeqCompressFrameEnd;
Begin
ICSeqCompressFrameEnd(@cv);
End;

function TVideoCoDec.SeqCompressFrame(pImageData: Pointer; var IsKeyFrame: Boolean; var Size: DWORD): Pointer;
VAR BoolKey: LongBool;
    Key: DWord;
//    pImSize: PDWord;
    pKey: PDWord;
Begin
//pBool ���������� ���������� �������� 2 �����!!!!!!!!!!
result := nil;
//BoolKey := true;

if IsKeyFrame = true then
  BoolKey := true
else
  BoolKey := false;
//pImSize := @Size;

//BoolKey := true;

result := ICSeqCompressFrame(@cv,        //Pointer to a COMPVARS structure initialized with information about the compression.
                             0,          //Reserved; must be zero.
                             pImageData, //Pointer to the data bits to compress. (The data bits exclude header or format information.)
                             @BoolKey,         //Returns whether or not the frame was compressed into a key frame.
                             @Size);     //Maximum size desired for the compressed image.
                                         //The compressor might not be able to compress the data to fit within this size.
                                         //When the function returns, the parameter points to the size of the compressed image.
                                         //Images sizes are specified in bytes.
//IsKeyFrame := pBoolKey^;
if BoolKey = false then
  IsKeyFrame := false
else
  IsKeyFrame := true;

//�.�. � Size � �������� �������� ��������� ���������� ����������� ������!!
//� ������������ ���, ��� ��������� ����� ������.
//Size := pImSize^;
End;

function TVideoCoDec.UnpackFrame(ImageData: Pointer; KeyFrame: Boolean;
         var PackedSize: Cardinal): Pointer;
begin
//�������������� ������ ������ � ������� ����� ������� ������������� ����
ReallocMem(FBuffDecompOut, cvDec.lpbiOut^.bmiHeader.biSizeImage);

//��� ���� ��������� ���������...
//� ������ H264 ��� ���������� ������������ ������ �����. ��� �����������
//������, ��� ����� �� �������������� Decompressor �������� �� �����������
//�� cvDec.lpbiIn^.bmiHeader.biSizeImage ������ ����� ����������� ����������
//������� ������������������ �����. ��� ��������� ��� �����������
//�����, ����� ��� ���� ��������� ������� ������ ������������������ �����.
//������ �������:
cvDec.lpbiIn.bmiHeader.biSizeImage := PackedSize;
if KeyFrame = false then
  begin
  FLastError := ICDecompress(cvDec.hic,
                           ICDECOMPRESS_NOTKEYFRAME,
                           @(cvDec.lpbiIn^.bmiHeader),//Pointer to a BITMAPINFO structure containing the format of the compressed data.
                           ImageData,//Pointer to the input data.
                           @(cvDec.lpbiOut^.bmiHeader),//Pointer to a BITMAPINFO structure containing the output format.
                           FBuffDecompOut);//Pointer to a buffer that is large enough to contain the decompressed data.
  end
else
  begin
  FLastError := ICDecompress(cvDec.hic,
                           ICDECOMPRESS_HURRYUP,//0
                           @(cvDec.lpbiIn^.bmiHeader),//Pointer to a BITMAPINFO structure containing the format of the compressed data.
                           ImageData,//Pointer to the input data.
                           @(cvDec.lpbiOut^.bmiHeader),//Pointer to a BITMAPINFO structure containing the output format.
                           FBuffDecompOut);//Pointer to a buffer that is large enough to contain the decompressed data.
  end;
Result := nil;
if (FLastError <> ICERR_OK) then
  begin
  //���� ������ ������������������ -2 Bad format
  //�������� ��� ������� � .biBitCount �� ��� ������ ����� ������ biBitCount = 24
  //�������� MS Video 1 �������� ������ .biBitCount = 16
  FCustomErrorMessage := 'ICDecompress: ' +
                          self.TranslateICError(FLastError) + ')';
  FLastError := ICERR_CUSTOM;
  PackedSize := 0;
  exit;
  end;

Result := FBuffDecompOut;
end;

function TVideoCoDec.GetCompressorBitmapInfoIn: TBitmapInfo;
begin
Result := cv.lpbiIn^;
end;

function TVideoCoDec.GetCompressorBitmapInfoOut: TBitmapInfo;
//function TVideoCoDec.GetCompressorBitmapInfoOut: pBitmapInfo;
begin
Result := cv.lpbiOut^;
//CopyMemory(@Result, cv.lpbiOut, cv.lpbiOut.bmiHeader.biSize);
end;

function TVideoCoDec.GetDecompressorBitmapInfoIn: TBitmapInfo;
begin
Result := cvDec.lpbiIn^;
end;

function TVideoCoDec.GetDecompressorBitmapInfoOut: TBitmapInfo;
begin
Result := cvDec.lpbiOut^;
end;

function TVideoCoDec.GetQuality: Integer;
begin
Result := cv.lQ;
end;

procedure TVideoCoDec.SetQuality(const Value: Integer);
begin
cv.lQ := Value;
end;
{
function TVideoCoDec.PackBitmap(Bitmap: TBitmap; var IsKeyFrame: Boolean;
                                var Size: Cardinal): Pointer;
begin
if not Assigned(Bitmap) then
  begin
  Result := nil;
  Size := 0;
  exit;
  end
else
  Result := PackFrame(Bitmap.ScanLine[0], IsKeyFrame, Size);
end;
}
function TVideoCoDec.UnpackBitmap(ImageData: Pointer; KeyFrame: Boolean;
          Bitmap: TBitmap): Boolean;
var Size: Cardinal;
    lpData: Pointer;
    bmi: TBitmapInfo;
    bmih: TBitmapInfoHeader;
    usage, paintmode: Integer;
begin
Result := Assigned(ImageData) and Assigned(Bitmap);
if (not Result) or
   (FDecompressorStarted = false) then
   begin
   FCustomErrorMessage := 'UnpackBitmap: Decompressor not started';
   FLastError := ICERR_CUSTOM;
   result := false;
   exit;
   end;
try
//���������, ���� �������� ������������,
// �� ����� � ���� ������� (������) ������
  bmi := GetDecompressorBitmapInfoIn;
  bmih := bmi.bmiHeader;
  lpData := UnpackFrame(ImageData, KeyFrame, Size);
  Result := Assigned(lpData) and (Size > 0);
  if not Result then exit;
  usage := IIF(bmih.biClrUsed = 0, DIB_RGB_COLORS, DIB_PAL_COLORS);
  PaintMode := IIF(KeyFrame, SRCCOPY, MERGECOPY);
  with Bitmap do
    begin
    Width := bmih.biWidth;
    Height := bmih.biHeight;
    Result := StretchDIBits(Canvas.Handle, 0, 0, bmih.biWidth, bmih.biHeight,
                            0, 0, bmih.biWidth, bmih.biHeight, lpData, bmi,
                            usage, paintmode) > 0;
    //ver. 05 �������� ������ ���?
//    FreeMem(lpData);//��� �� ���
//    lpData := nil;//��� �� ���
    end;
  except
    Result := false;
  end;
end;

// typecast the List.Objects[I] as Cardinal to get the fccHandler code !
function TVideoCoDec.EnumCodecs(List: TStrings): Integer;
var pII: TICINFO;
    c: Integer;
    ok: Boolean;
    fccType: TFourCC;
    hIC: Cardinal;
    p: pointer;
begin
     c:=0;
     List.Clear;
     fccType.AsString:='vidc';
     ZeroMemory(@pII, SizeOf(pII));
     repeat
       ok:=ICInfo(fccType.AsCardinal, c, @pII);
       if ok then
       begin
         Inc(c);
         // open the compressor ..
         // should get all the info with ICInfo but it doesn't ?!?!
         // this slows the whole thing quite a bit .. about 0.5 - 1 sec !
         hIC:=ICOpen(fccType.AsCardinal, pII.fccHandler, ICMODE_COMPRESS);
         if hIC > 0 then
         try
            if ICGetInfo(hIC, @pII, SizeOf(pII)) > 0 then
              begin
              //List.AddObject(pII.szDescription, TObject(pII.fccHandler));
              p := AllocMem(SizeOf(pII));
              CopyMemory(p, @pII, SizeOf(pII));
              FCodecList.Add(p);
//              List.AddObject(pII.szDescription, TObject(pII.fccHandler));
              List.AddObject(pII.szDescription, Pointer(pII.fccHandler));
              end;
         finally
            ICClose(hIC);
         end;
       end;
     until not ok;

     // return the number of installed codecs
     // the list can contain less codecs !
     Result:=c;
end;

///////////////////////////////////////////////////////////////////
function TVideoCoDec.PackFrame(ImageData: Pointer; var IsKeyFrame: Boolean;
         var Size: DWORD): Pointer;
var
   dwChunkId: DWORD;//Cardinal
   dwFlags: DWORD;//Cardinal;
//   pdwFlags: pDWORD;//Cardinal;
   dwFlagsIn: DWORD;//Cardinal
   sizeImage: DWORD;//Cardinal
   lAllowableFrameSize: DWORD;//Cardinal;
   lKeyRateCounterSave: DWORD;//Cardinal;
   bNoOutputProduced: Boolean;
   dwSize: DWORD;
begin
if FCompressorMode = CM_SequenceFrame then
  result := SeqCompressFrame(ImageData, IsKeyFrame, Size)
else
  begin
  result := ICCompressFrame( @cv,
                             dwFlagsIn,
                             ImageData,
                             dwFlags,
                             IsKeyFrame,
                             Size);
  end;
exit;
end;
///////////////////////////////////////////////////////////////////
function TVideoCoDec.InitCompressor(CompreccorFccHandler :DWORD;
                                    InputFormat: TBitmapInfo;
                                    OutputFormat: TBitmapInfo;
                                    const Quality, KeyRate: Integer;
                                    RequestedMaxFrameSize: DWORD): pBitmapInfo;
var Res: dword;
    RGBQ: TRGBQuad;
//    p: pointer;
begin
result := nil;
//    FOURCCtoString(OutputFormat.biCompression);
//    FCustomErrorMessage := 'FOURCCtoString(OutputFormat.biCompression = ' +
//                        FOURCCtoString(OutputFormat.biCompression) + ')';
//    FLastError := ICERR_CUSTOM;
//    exit;

//��� FFD SHOW ���� � ������ ������ ������� ������ YUY2, �� � ��� ����
//����� ��������������� ������� = YUY2
//����� �� ��������, � ��� ������������ � RGB ������������(((
     FRequestedMaxFrameSize := RequestedMaxFrameSize;
     cv.lQ := Quality;
     cv.lKey := KeyRate;
//TODO: ��� ����������� ���������� ����� �� ���� �������� ����������
//���� CV.lpbiIn.bmiHeader := InputFormat; � ������ ����� �����������!

//     CopyMemory(@cv.lpbiIn.bmiHeader, @InputFormat, InputFormat.biSize + sizeof(RGBQUAD));
//     CopyMemory(@cv.lpbiIn.bmiHeader, @pInputFormat^.bmiHeader, pInputFormat.bmiHeader.biSize);

     //�����������! � ���������� XVID ���� ��������� lpbiOut ��� TBITMAPINFO
     //�� compress_get_format ���������� ������ �� TBITMAPINFO, �
     // compress_get_format(...) = return sizeof(BITMAPINFOHEADER)
     //�.�. ��� ���������� ������ ��������� TBITMAPINFOHEADER, � �� ���� TBITMAPINFO ���������!
     //�������� ������ ������ ���������� ������ ����... ����� �����...
     //� ���-���� ���� ��� ��� ����!

     if InputFormat.bmiHeader.biSize > SizeOf(TBITMAPINFOHEADER) then
       begin
       FreeMem(cv.lpbiIn);
       FCompressInbiSize := InputFormat.bmiHeader.biSize + sizeof(RGBQUAD);
       GetMem(cv.lpbiIn, CompressInbiSize);
       end;
     CopyMemory(@(cv.lpbiIn^), @InputFormat, CompressInbiSize);

     if OutputFormat.bmiHeader.biSize > SizeOf(TBITMAPINFOHEADER) then
       begin
       FreeMem(cv.lpbiOut);
       FCompressOutbiSize := OutputFormat.bmiHeader.biSize + sizeof(RGBQUAD);
       GetMem(cv.lpbiOut, CompressOutbiSize);
       end;
     CopyMemory(@(cv.lpbiOut^), @OutputFormat, CompressOutbiSize);

//     cv.lpbiOut^.bmiHeader := pOutputFormat.bmiHeader;
//     cv.lpbiOut^.bmiColors := pOutputFormat.bmiColors;
     //���� ���� ������� 0, �� ��������� ��������!
     //Specifies the size, in bytes, of the image. This may be set to zero for BI_RGB bitmaps.
//     CV.lpbiIn^.bmiHeader.biSize := sizeof(BITMAPINFOHEADER);
//     CV.lpbiOut^.bmiHeader.biSize := sizeof(BITMAPINFOHEADER);

     cv.fccType := ICTYPE_VIDEO;//MKFOURCC('V', 'I', 'D', 'C');
     cv.fccHandler := CompreccorFccHandler;
//     if cv.fccHandler <> OutputFormat.bmiHeader.biCompression then
     if OutputFormat.bmiHeader.biCompression = 0 then
       begin
       OutputFormat.bmiHeader.biCompression := cv.fccHandler;//MS Video1 = 1129730893
       //XVID ��������� ��������� � �������� biCompression ��������� ���� FOURCC:
       //FOURCC_DIVX, FOURCC_DX50, FOURCC_MP4V, FOURCC_xvid, FOURCC_divx, FOURCC_dx50, FOURCC_mp4v
       end;

     if (OutputFormat.bmiHeader.biCompression = MKFOURCC('X','V','I','D'))
        and (InputFormat.bmiHeader.biCompression = bi_RGB)
        and (InputFormat.bmiHeader.biHeight = 480)

//        or (OutputFormat.biCompression = MKFOURCC('F', 'F', 'D', 'S'))
//        or (OutputFormat.biCompression = MKFOURCC('R', 'T', 'V', '1'))
//        or (OutputFormat.biCompression = MKFOURCC('M', 'R', 'L', 'E'))
        then
       begin
       //� ������ ��� XVID ����� ���������, ��� ������ ������ � ������!
//       cv.lpbiIn^.bmiHeader.biCompression := MKFOURCC('Y', 'U', 'Y', '2');//YUY2;//BI_RGB;//
//       cv.lpbiIn^.bmiHeader.biCompression := MKFOURCC('D', 'I', 'B', ' ');//YUY2;//BI_RGB;//
//       cv.lpbiIn^.bmiHeader.biCompression := MKFOURCC('Y', 'U', 'Y', 'V');//YUY2;//BI_RGB;//
//       cv.lpbiOut^.bmiHeader.biCompression := MKFOURCC('D', 'V', '5', '0');//YUY2;//BI_RGB;//
//       cv.lpbiIn^.bmiHeader.biSizeImage := 1900000;
//       cv.lpbiIn^.bmiHeader.biBitCount := 24;
//       cv.lpbiIn^.bmiHeader.biPlanes := 0;
//       cv.lpbiIn^.bmiHeader.biCompression := BI_RGB;//��� ����������� �������
//       RGBQ.rgbBlue     := $01;//XVID �����������
//       RGBQ.rgbGreen    := $00;//XVID �����������
//       RGBQ.rgbRed      := $00;//XVID �����������
//       RGBQ.rgbReserved := $00;//XVID �����������
//       cv.lpbiIn^.bmiColors[0] := RGBQ;//XVID �����������
       FCustomErrorMessage := 'Check format error: XVID have bug and not support 640x480x24bit!' +
       ' Change BI_RBG to YUY|YUY2|YV12 or resolution to other. (XVID can compress 640x478x24bit)!';
       FLastError := ICERR_CUSTOM;
       FCompressorStarted := false;
       exit;
       end
     else
       begin
       cv.lpbiIn^.bmiHeader.biCompression := BI_RGB;//��� ����������� �������
       end;

     cv.hic := ICOpen(cv.fccType, cv.fccHandler, ICMODE_COMPRESS);

//���� ����� ����������� ������ ������ ������� 0 � ������� ��������� ������
//     Res := ICSetStatusProc(cv.hic, 0, 0, @CallbackStatusFunction);
//     Res := ICSetStatusProc(cv.hic, 0, 0, @CodecStatusProc);

    if cv.hic > 0 then
      begin
      //�������� ��������� �������� ��������
      ICGetInfo (cv.hic, @FCodecInfo, sizeof(TICINFO));
      FCodecName := FCodecInfo.szName;//Short version of the compressor name. The name in the null-terminated string should be suitable for use in list boxes.
      FCodecDescription := FCodecInfo.szDescription;//Long version of the compressor name.
      FDriver := FCodecInfo.szDriver;//Name of the module containing VCM compression driver. Normally, a driver does not need to fill this out.
      end
    else
      begin
      //���� ��������, ���� �� � ����� ������ RGB, � ���� ��������, Y2Y
      FCustomErrorMessage := 'ICOpen error: ' +
                             self.TranslateICError(FLastError);
      FLastError := ICERR_CUSTOM;
      FCompressorStarted := false;
      exit;
      end;

     if ICCompressInternalInit(@cv) = false then
       begin;
       FLastError := ICERR_CUSTOM;
       exit;
       end;
     //������-�� ���� �� ������� ������ ���������� �������,
     //�� �� ������ �������� � ������ ��������� VAR OutputFormat
     GetMem(result, CompressOutbiSize);
     //��� �� ����� �� ��� ���������� �������� �������? � ������ ��� ����� �������?
     CopyMemory(result, @(CV.lpbiOut^), CompressOutbiSize);

     FCompressorStarted := true;//Result;
     FCompressorMode := CM_SingleFrame;
end;
///////////////////////////////////////////////////////////////////
function TVideoCoDec.ICCompressInternalInit(pCV : PCompVars) : Boolean;
var
  FormatSize : integer;
  BitCount : WORD;
  ICCOMPRESSFRAMES: TICCOMPRESSFRAMES;
begin
  Result := False;

  if (pCV = nil) or (pCV.cbSize <> SizeOf(TCompVars)) or
     (pCV.hic = 0) or (pCV.lpbiIn = nil) then Exit;

  if pCV.lKey < 0 then pCV.lKey := 1;

  //���������� � �������� ����� ������ ������ �� ������ ��������
  //��� TBITMAPINFO ���������� ������� lpbiIn?

  FormatSize := ICCompressGetFormatSize(pCV.hic, @(pCV.lpbiIn^));
//  if FormatSize > sizeof(pCV.lpbiOut^) then
  if FormatSize < 0 then
    begin
    //���� ��������, ���� �� � ����� ������ RGB, � ���� ��������, Y2Y
    //��� �� ������ 24bit, � ���� 16bit ��� 8
    FCustomErrorMessage := 'ICCompressGetFormatSize(Input format) = ' +
                           self.TranslateICError(FormatSize);
    FLastError := ICERR_CUSTOM;
    exit;
    end;

  //������ ��������� ��������� ������� ������������ ��� �������� ICCompressGetFormatSize
  //��� ICCompressGetFormat(..., ..., nil); (3 �������� = nil)
{
  if (FormatSize > 0) then
    FormatSize := ICCompressGetFormat(pCV.hic, @(pCV.lpbiIn^), @(pCV.lpbiOut^))
  else
    FormatSize := ICCompressGetFormat(pCV.hic, @(pCV.lpbiIn^), nil);
  if FormatSize < 0 then
    begin
    //��������!!! ��� ������ ���� �-��� ����� ����� �������� �������� ������!
    //��������� ��� � ����������������!!!
    FCustomErrorMessage := 'ICCompressGetFormat(������� ������) = ' +
                           self.TranslateICError(FormatSize) + ')';
    FLastError := ICERR_CUSTOM;
    exit;
    end;
}

  //�� ��������� �� ������� ����� ��� 44 �����, �� ��������� ������
  //���� WM9 ���������� 46 ��� ������ �������. ������� �����������
  //� ������� ������������ �������� ����� � ������
  //� ����������� �� �������� �������: YUY2 YVU9 � �.�. ��. untYUVFourCC.pas

  //FFDShow �������� ��� ��������� ������ HuFFYUV, ��! � �������� ���������
  //���������� bmiHeader = 116, � �� 40. �.�. ������ ����� ��� BITMAPV5HEADER
  //���� ������������� ��� �����������!!!

//  if FormatSize > sizeof(pCV.lpbiOut^) then � ���-���� ��� ������!
//��� �� ������ ����� ������ TBitMapInfo = 40, � �� ����� ����?
//�� ����� ���� ��� ����� ���� BITMAPV4HEADER, BITMAPV5HEADER
  if FormatSize > pCV.lpbiOut.bmiHeader.biSize then
    begin
    //����� ��� � ���. tagBITMAPINFO ������� �� 2� ��������
    //1� �������������� ������� TBITMAPINFO
    //2� ��������� ����������� ������� - ������� ������
    //tagBITMAPINFO = packed record
    //    bmiHeader: TBitmapInfoHeader;
    //    bmiColors: array[0..0] of TRGBQuad;
    //The size of the array is determined by the value of bmiHeader.biClrUsed.
    //�� ����� �� �������� ������ ��� ����������� BITMAPINFO
    //� ��� � ������� ������ ����� ���� ���� ������� ������
    //������� ����� �������� ��� ����� ������ �������, ������� ������ �����!

    FCustomErrorMessage := '����� �������� �� ����������� ��������� TBITMAPINFO �� ������. ' +
                           '������ ������� bmiHeader > 40 ! (FormatSize = ' +
                           inttostr(FormatSize) + ')';
    FLastError := ICERR_CUSTOM;
    //�� ������ �������� ������ ��� ����������� ��������� � �������� �������
    //������� ������ �����
    //���������� ������ ����� �� ���������!!!!

    FreeMem(pCV.lpbiOut);
    FCompressOutbiSize := FormatSize + sizeof(RGBQUAD);
    GetMem(pCV.lpbiOut, CompressOutbiSize);
    ZeroMemory(pCV.lpbiOut, CompressOutbiSize);

//    pCV.lpbiOut.bmiHeader.biSize := FormatSize;//��� ������ �� ����! ����� ��� ��������

    FCustomErrorMessage := '�������������� ������ bmiHeader �� (FormatSize = ' +
                           inttostr(FormatSize) + ')';
    end;

  //������ ��� ��������� ������ ������� ����� ��������!
  //������ ����� ��������� ��� ��������� � ��� ����� ������� bmiHeader.biSize
  //�������� � cv.lpbiOut^.bmiHeader �������� ������ ��������� �����.
  //��������! ������� ��� ��������� ��������� ������������ ������ ������� �����
  //� �� ���� ����� ���� ������ ������������!!!
//  FLastError := ICCompressGetFormat(pCV.hic, @(pCV.lpbiIn^.bmiHeader), @(pCV.lpbiOut^.bmiHeader));
  FLastError := ICCompressGetFormat(pCV.hic, @(pCV.lpbiIn^), @(pCV.lpbiOut^));
  if LastError <> ICERR_OK then
    begin
    FCustomErrorMessage := '�� ������� �������� ICCompressGetFormat: ' +
                           self.TranslateICError(LastError) + ')';
    FLastError := ICERR_CUSTOM;
    exit;
    end;

//�����������
//  lFmtLength = ICCompressGetFormat(hicc, pYUVFmt, NULL);
//  pXVIDFmt = (LPBITMAPINFOHEADER)malloc(abs(lFmtLength));
//  ICCompressGetFormat(hicc, pYUVFmt, pXVIDFmt);


  //����������� ����������� ��������� ����� ��� ��������� ������� �����.
  //��������! ������� ��� ��������� ��������� ������������ ������ ������� �����
  //� �� ���� ����� ���� ������ ������������!!!
  pCV.lpbiOut.bmiHeader.biSizeImage := ICCompressGetSize(pCV.hic, @(pCV.lpbiIn^.bmiHeader), @(pCV.lpbiOut^.bmiHeader));
  if pCV.lpbiOut.bmiHeader.biClrUsed = 0 then
  begin
    BitCount := pCV.lpbiOut.bmiHeader.biBitCount;//1 (mono) ��� 4 (16 ������) ��� 8 (256 ������)
    //8 � � ������� ���������� �� 256 ������, ������ ���� ����������� ������ ������ � ������� ��� ������ �������.
    //24 � ������� �� ������������, ������ ������ ���� ����������� ������������ ���� �������,
    if BitCount <= 8 then
      pCV.lpbiOut.bmiHeader.biClrUsed := 1 shl BitCount;
  end;

  pCV.lFrame := 0;
  pCV.lKeyCount := pCV.lKey;

  FLastError := ICCompressQuery (pCV.hic, @(pCV.lpbiIn^), @(pCV.lpbiOut^));
  if FLastError <> ICERR_OK then exit;
  //��� �� ������ �������� ������ ��� ����� ��� ������� �����������
  if (FCodecName = 'FFDS') and
     (pCV.lpbiOut.bmiHeader.biSizeImage = pCV.lpbiIn.bmiHeader.biSizeImage) then
    begin
    //�� FFSD Show ������ ��� ���������� ������ ��� ����� ������� �����
    //������� ����� ���� � �������
//    pCV.lpbiOut.bmiHeader.biSizeImage := pCV.lpbiIn.bmiHeader.biSizeImage * 3;
    end;

  //�������� ������ ��� ������ ������� �����������, ��������� �� ����������
//  GetMem (pCV.lpBitsOut, pCV.lpbiOut.bmiHeader.biSizeImage + $810);
  GetMem (pCV.lpBitsOut, pCV.lpbiOut.bmiHeader.biSizeImage);

     // Save configuration state.
     //
     // Ordinarily, we wouldn't do this, but there seems to be a bug in
     // the Microsoft MPEG-4 compressor that causes it to reset its
     // configuration data after a compression session.  This occurs
     // in all versions from V1 through V3.
     //
     // Stupid fscking Matrox driver returns -1!!!

     cbConfigData := ICGetStateSize(cv.hic);

     if cbConfigData >= 0 then
     begin
       ReallocMem(pConfigData, cbConfigData);

       cbConfigData := ICGetState(cv.hic, pConfigData, cbConfigData);
       // As odd as this may seem, if this isn't done, then the Indeo5
       // compressor won't allow data rate control until the next
       // compression operation!

       if cbConfigData <> 0 then
          ICSetState(cv.hic, pConfigData, cbConfigData);
     end;


  if(HasFlag(FCodecInfo.dwFlags, VIDCF_QUALITY) = false) then
    begin
    pCV.lQ := 0;
    end;

  if pCV.lQ <= 0 then
    begin
    pCV.lQ := ICGetDefaultQuality(pCV.hic);
    if pCV.lQ <= 0 then pCV.lQ := 7500;
    end;

  if (pCV.lKey <> 1) and
     (HasFlag(FCodecInfo.dwFlags, VIDCF_TEMPORAL) = true) and
     (HasFlag(FCodecInfo.dwFlags, VIDCF_FASTTEMPORALC) = false) then
    begin
    //�����������, ������� ���������� ������ ����� ������� � ������
    //��� ���������� ������ �������������
    FLastError := ICGetBuffersWanted(pCV.hic, @FCompressorBuffersWanted);
    if FLastError <> ICERR_OK then
      begin
      //���� ������������ ��� ��������, �� ��������� ������ 1
      FCompressorBuffersWanted := 1;
      end;
    //�������� ������ ��� �������� 1 ����������� �����. � ���� ������ �� �������!!!
    GetMem (pCV.lpBitsPrev, pCV.lpbiIn.bmiHeader.biSizeImage * FCompressorBuffersWanted);
    end;
//  GetMem (pCV.lpBitsPrev, pCV.lpbiIn.bmiHeader.biSizeImage * 10);//XVID �����������

  //��� XVID ����� ������
  //codec->fincr = icf->dwScale;
  //codec->fbase = icf->dwRate;
//  ICCOMPRESSFRAMES.dwRate := 1000000;//
//  ICCOMPRESSFRAMES.dwScale := 15;//������ � �������
//  ICSendMessage(pCV.hic, ICM_COMPRESS_FRAMES_INFO, WPARAM(@ICCOMPRESSFRAMES), sizeof(TICCOMPRESSFRAMES));

  FLastError := ICCompressBegin(pCV.hic, @pCV.lpbiIn.bmiHeader, @pCV.lpbiOut.bmiHeader);
  if FLastError <> ICERR_OK then
    begin
    FCustomErrorMessage := 'ICCompressBegin: ' + inttostr(FLastError) + ' (' +
                           self.TranslateICError(LastError) + ')';
    FLastError := ICERR_CUSTOM;
    Exit;
    end;

  Result := True;
end;
///////////////////////////////////////////////////////////////////
function TVideoCoDec.InitDecompressor(DecompreccorFccHandler :DWORD;
                                      InputFormat: TBitmapInfo;
                                      OutputFormat: TBitmapInfo;
                                      const Quality, KeyRate: Integer;
                                      RequestedMaxFrameSize: DWORD): pBitmapInfo;
var FormatSize: integer;
    BitCount : WORD;
    RGBQUADL: TRGBQUAD;
begin
//DecompreccorFccHandler ������ ���� ����� ��� FOURCC ���� ��� 0, ���� �� ������� �� ��������.
//������ ���� � ��� �� ������ ����� ������������ 2 �������������.
//�������, ���� ��������� ������� handler = 0, �� ������� ��������
//������� ICLocate ������� �� ����������� ���������� �������������

//���� ������� ��������. ����� ����, ��� ���������������� ��������� InputFormat
//��� ������ ICCompressGetFormat( InputFormat ), �� ������ �� �������� ���������
//���������� ��������� InputFormat. � ��� ����� �������� � ���� biCompression!!!!
//��� ���� ��� ������ ���������� �� ���� � ICOPEN!!!!!
//������������ �� ����������������!!!
//��������, MS Video1 ���� �����, ����� ICCompressGetFormat() ������ ���� biCompress
//c 'M''S''V''C' �� 'C''R''A''M', �� � ��������� ���� �� �����

result := nil;
if InputFormat.bmiHeader.biCompression <= 0 then
  begin
  FCustomErrorMessage := 'Decompressor: Error input format cannt have biCompression = 0!';
  FLastError := ICERR_CUSTOM;
  exit;
  end;

  FRequestedMaxFrameSize := RequestedMaxFrameSize;
  cvDec.lQ := Quality;
  cvDec.lKey := KeyRate;

//����� ����� � �������������� ����� ������� �� ���� fccHandler, �
//� fccHandler ������� ������, �.�. ��� ����� �� ���������
//���� ����� ����� ������� � ��������� ��������� ��������!
  cvDec.fccHandler := DecompreccorFccHandler;
  cvDec.fccType := ICTYPE_VIDEO;// = MKFOURCC('v', 'i', 'd', 'c');

//������ ��� ����������� ������� ��������� ������� ����������� ��
//���������� ��������� �������� �������� cvDec.lpbiIn
//����� ��������, ��� ��� ���������� � �� ������, ������� �� ������ � .CREATE

//if SizeOf(cvDec.lpbiIn^.bmiHeader) < InputFormat.bmiHeader.biSize then
//� ��� ���� ���� ��� ��� ����!
if cvDec.lpbiIn^.bmiHeader.biSize < InputFormat.bmiHeader.biSize then
  begin
  //���� ������, ��� �� �������� ������� �� �������� �� ���������
  //�������� ������
//  ReallocMem(cvDec.lpbiIn, InputFormat.biSize);
  if cvDec.lpbiIn <> nil then FreeMem(cvDec.lpbiIn);
  FDecompressInbiSize := InputFormat.bmiHeader.biSize + sizeof(RGBQUAD);
  GetMem(cvDec.lpbiIn, DecompressInbiSize);//�� ���� biSize ��� �������� ���� // + sizeof(RGBQUAD));
  ZeroMemory(cvDec.lpbiIn, DecompressInbiSize);//�� ���� biSize ��� �������� ���� // + sizeof(RGBQUAD));
  end;

if cvDec.lpbiOut^.bmiHeader.biSize < OutputFormat.bmiHeader.biSize then
  begin
  //���� ������, ��� �� �������� ������� �� �������� �� ���������
  //�������� ������
  if cvDec.lpbiOut <> nil then FreeMem(cvDec.lpbiOut);
//  GetMem(cvDec.lpbiOut, sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));//�������� ��� ���� ����� MS VIDEO1
//  ZeroMemory(cvDec.lpbiOut, sizeof(TBitmapInfoHeader) + sizeof(RGBQUAD));
  FDecompressOutbiSize := OutputFormat.bmiHeader.biSize + sizeof(RGBQUAD);
  GetMem(cvDec.lpbiOut, DecompressOutbiSize);// + sizeof(RGBQUAD));//�������� ��� ���� ����� MS VIDEO1
  ZeroMemory(cvDec.lpbiOut, DecompressOutbiSize);
  end;

//��� ��� � ��� ��������... � WMV3 ����� bmiHeader, ������������ ��� � bmiColors
//� ��� ����� �������� ����� �� cvDec.lpbiIn! �.�. ���� �� �������� ����������
//����� ���������� �� bmiHeader, � lpbiIn! OPS!
//  CopyMemory(@(cvDec.lpbiIn^).bmiHeader, @InputFormat.bmiHeader, InputFormat.bmiHeader.biSize);
//  CopyMemory(@(cvDec.lpbiIn^).bmiColors, @InputFormat.bmiColors, sizeof(RGBQUAD));
//  CopyMemory(@(cvDec.lpbiOut^).bmiHeader, @OutputFormat.bmiHeader, OutputFormat.bmiHeader.biSize);
//  CopyMemory(@(cvDec.lpbiOut^).bmiColors, @OutputFormat.bmiColors, sizeof(RGBQUAD));
//��� ���� ��� ����!
  CopyMemory(@(cvDec.lpbiIn^), @InputFormat, DecompressInbiSize);
  CopyMemory(@(cvDec.lpbiOut^), @OutputFormat, DecompressOutbiSize);

  //������� ����������� � �������, ����� ������� ��� ����������� ����������������� ���� ������
  if cvDec.fccHandler <= 0 then
    begin
    cvDec.hic := GetDecompressorHICByCompressedHeader(@(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
    if cvDec.hic <= 0 then
      begin
      FCustomErrorMessage := 'Decompressor: can not find default decompressor for this format';
      FLastError := ICERR_CUSTOM;
      exit;
      end;
    end;

  // Force open decompressor
  if cvDec.hic <= 0 then
    begin
    //cvDec.hic := ICOpen(cvDec.fccType, cvDec.fccHandler, ICMODE_DECOMPRESS);//�������� ���� ����� �������, ��� ������� ICOpen
    cvDec.hic := ICDecompressOpen(cvDec.fccType, InputFormat.bmiHeader.biCompression,
                                  @(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
    if cvDec.hic <= 0 then
      begin
      FCustomErrorMessage := 'Decompressor: Can not force open decompressor for this format';
      FLastError := ICERR_CUSTOM;
      exit;
      end;
    end;

    if cvDec.hic > 0 then
      begin
      //�������� ��������� �������� ��������
      ICGetInfo (cvDec.hic, @FCodecInfo, sizeof(TICINFO));
      FCodecName := FCodecInfo.szName;//Short version of the compressor name. The name in the null-terminated string should be suitable for use in list boxes.
      FCodecDescription := FCodecInfo.szDescription;//Long version of the compressor name.
      FDriver := FCodecInfo.szDriver;//Name of the module containing VCM compression driver. Normally, a driver does not need to fill this out.
      end
    else
      begin
      //���� ��������, ���� �� � ����� ������ RGB, � ���� ��������, Y2Y
      FCustomErrorMessage := 'ICGetInfo error: ' +
                             self.TranslateICError(FLastError);
      FLastError := ICERR_CUSTOM;
      exit;
      end;

  FormatSize := ICDecompressGetFormatSize(cvDec.hic, @(cvDec.lpbiIn^));
//  if FormatSize > sizeof(pCV.lpbiOut^) then
  if FormatSize < 0 then
    begin
    //���� ��������, ���� �� � ����� ������ RGB, � ���� ��������, Y2Y
    FCustomErrorMessage := 'ICDecompressGetFormatSize(������� ������ ������) = ' +
                           self.TranslateICError(FormatSize) + ')';
    FLastError := ICERR_CUSTOM;
    exit;
    end;

  //��� ��� ��� ���� ��� ��� ��� ����
{
  if (FormatSize > 0) then
    FormatSize := ICDecompressGetFormat(cvDec.hic, @(cvDec.lpbiIn^), @(cvDec.lpbiOut^))
  else
    FormatSize := ICDecompressGetFormat(cvDec.hic, @(cvDec.lpbiIn^), nil);
  if FormatSize < 0 then
    begin
    //��������!!! ��� ������ ���� �-��� ����� ����� �������� �������� ������!
    //��������� ��� � ����������������!!!
    FCustomErrorMessage := 'ICDecompressGetFormatSize Input format = ' +
                           self.TranslateICError(FormatSize) + ')';
    FLastError := ICERR_CUSTOM;
    exit;
    end;
}
  //�� ��������� �� ������� ����� ��� 44 ����� (40 ���� + 4 ����� �� ����), �� ��������� ������
  //���� WM9 ���������� 46 ��� ������ �������. ������� �����������
  //� ������� ������������ �������� ����� � ������ � �����������
  //�� �������� ������� � ������� �����: YUY2 YVU9 � �.�. ��. untYUVFourCC.pas

  //FFDShow �������� ��� ��������� ������ HuFFYUV, ��! � �������� ���������
  //���������� bmiHeader = 116, � �� 40. �.�. ������ ����� ��� BITMAPV5HEADER
  //���� ������������� ��� �����������!!!

//  if FormatSize > sizeof(cvDec.lpbiOut^) then
  if FormatSize > DecompressOutbiSize then
    begin
    //����� ��� � ���. tagBITMAPINFO ������� �� 2� ��������
    //1� �������������� ������� TBITMAPINFO
    //2� ��������� ����������� ������� - ������� ������
    //tagBITMAPINFO = packed record
    //    bmiHeader: TBitmapInfoHeader;
    //    bmiColors: array[0..0] of TRGBQuad;
    //The size of the array is determined by the value of bmiHeader.biClrUsed.
    //�� ����� �� �������� ������ ��� ����������� BITMAPINFO
    //� ��� � ������� ������ ����� ���� ���� ������� ������
    //������� ����� �������� ��� ����� ������ �������, ������� ������ �����!

    FCustomErrorMessage := 'Decompressor: �� ����������� ��������� lpbiOut ' +
                           '������ ������� bmiHeader > 40 ! (FormatSize = ' +
                           inttostr(FormatSize) + ')';
    FLastError := ICERR_CUSTOM;
    //�� ������ �������� ������ ��� ����������� ��������� � �������� �������
    //������� ������ �����
    //���������� ������ ����� �� ���������!!!!

    FreeMem(cvDec.lpbiOut);
    FDecompressOutbiSize := FormatSize + sizeof(RGBQUAD);
    GetMem(cvDec.lpbiOut, DecompressOutbiSize);
    ZeroMemory(cvDec.lpbiOut, DecompressOutbiSize);

    FCustomErrorMessage := 'bmiHeader <> 40! (FormatSize = ' +
                           inttostr(FormatSize) + ')';
    end;

  //������ ��� ��������� ������ ������� ����� ��������!
  //������ ����� ��������� ��� ��������� � ��� ����� ������� bmiHeader.biSize
  //�������� � cv.lpbiOut^.bmiHeader �������� ������ ��������� �����.
  //��������! ������� ��� ��������� ��������� ������������ ������ �������������� �����
  //� �� ���� ����� ���� ������ ������������!!!
  //���! ��������� ������� ����� ���������� ��� ��������� ������, ��� ���� �� ���������
  //� ����������� XVID ����� ������������� ��������� �������� ������!

//  �����������! ���� � ������ �������� ICDecompressGetFormat, �� �� ����� ��������� ������
//  �� 16 ��� ��������, � ��� ������ ����� �������������
//  �������� ICDecompressGetPalette (�� �����������)
//  + ��� 16 ������ � UNIT1 ��������� BITMAP � ��������, � �� 24������!

  FLastError := ICDecompressGetFormat(cvDec.hic, @(cvDec.lpbiIn^), @(cvDec.lpbiOut^));
  if LastError <> ICERR_OK then
    begin
    FCustomErrorMessage := 'Error ICCompressGetFormat: ' +
                           self.TranslateICError(LastError) + ')';
    FLastError := ICERR_CUSTOM;
    exit;
    end;

//���� � ������� ���������� ������ .bmiHeader!!!
  if cvDec.lpbiOut^.bmiHeader.biBitCount < 16 then
    begin
    FLastError := ICDecompressGetPalette(cvDec.hic, @(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
    if LastError <> ICERR_OK then
      begin
      FCustomErrorMessage := 'Error ICDecompressGetPalette: ' +
                             self.TranslateICError(LastError) + ')';
      FLastError := ICERR_CUSTOM;
    //�� ��� ������ ������������ ��� �-���. ������ �� ��������.
//    exit;
      end;
    end;

  //����������� ����������� ��������� ����� ��� ��������� ������� �����.
  //��������! ������� ��� ��������� ��������� ������������ ������ ������� �����
  //� �� ���� ����� ���� ������ ������������!!!
//  cvDec.lpbiOut.bmiHeader.biSizeImage := ICDeompressGetSize(cvDec.hic, @(cvDec.lpbiIn^.bmiHeader), @(cvDec.lpbiOut^.bmiHeader));
  if cvDec.lpbiOut.bmiHeader.biClrUsed = 0 then
  begin
    BitCount := cvDec.lpbiOut.bmiHeader.biBitCount;//1 (mono) ��� 4 (16 ������) ��� 8 (256 ������)
    //8 � � ������� ���������� �� 256 ������, ������ ���� ����������� ������ ������ � ������� ��� ������ �������.
    //24 � ������� �� ������������, ������ ������ ���� ����������� ������������ ���� �������,
    if BitCount <= 8 then
      cvDec.lpbiOut.bmiHeader.biClrUsed := 1 shl BitCount;
    if BitCount = 32 then
      begin
//      cvDec.lpbiOut.bmiHeader.biClrUsed := 3;//BI_BITFIELDS
      //cvDec.lpbiOut.bmiHeader.biBitCount := 24;
      end;
    if BitCount = 16 then
      begin
//      cvDec.lpbiOut.bmiHeader.biClrUsed := 3;//BI_BITFIELDS
//      FreeMem(cvDec.lpbiOut);
//      GetMem(cvDec.lpbiOut, cvDec.lpbiOut.bmiHeader.biSizeImage);
      end;
  end;

  cvDec.lFrame := 0;
  cvDec.lKeyCount := cvDec.lKey;

//  if InputFormat.bmiHeader.biCompression <> cvDec.fccHandler then
//    begin
    //��� ���� �������� ��� H264
//        InputFormat.biCompression  := cvDec.fccHandler;
//    end;

  FLastError := ICDecompressQuery(cvDec.hic, @(cvDec.lpbiIn^), @(cvDec.lpbiOut^));
  if FLastError <> ICERR_OK then
    begin
    FCustomErrorMessage := 'Error ICDecompressQuery: ' +
                           self.TranslateICError(LastError) + ')';
    FLastError := ICERR_CUSTOM;
    result := nil;
    exit;
    end;

  if (InputFormat.bmiHeader.biCompression = MKFOURCC('X','V','I','D')) then
    begin
    //����������� ���� ������� ������� ����� �����, ��������� ��� ������
    //����� ������� XVID �� �� �������� �� ������ �����! ������ ������ ���! 

    //������� ��� 'X','V','I','D'
    //Y2Y - > ������� -> ��������� -> Y2Y
    //�����������, ��� ������ ��������� ������� � ������ ������
    //������ biCompression = 0, �� ����� ��� ����� ����������
    //������� ������������� ������ �������� ������ ��
//    cvDec.lpbiOut^.bmiHeader.biCompression := MKFOURCC('Y', 'U', 'Y', '2');
//    cvDec.lpbiOut^.bmiHeader.biCompression := MKFOURCC('Y', 'U', 'Y', 'V');
//    cv.lpbiOut^.bmiHeader.biBitCount := 32;
    end;

  FLastError := ICDecompressBegin(cvDec.hic, @(cvDec.lpbiIn^), @(cvDec.lpbiOut^));
  FDecompressorStarted := FLastError = ICERR_OK;
//  CopyMemory(@OutputFormat.bmiHeader, @cvDec.lpbiOut.bmiHeader, OutputFormat.bmiHeader.biSize);//���������������! ����������� � WMV3
//  CopyMemory(@OutputFormat.bmiColors, @cvDec.lpbiOut.bmiColors, sizeof(RGBQUAD));//���������������! ����������� � WMV3
//� ���-���� ���������� ��� ����!
//  CopyMemory(pOutputFormat, @(cvDec.lpbiOut^), pOutputFormat.bmiHeader.biSize);//���������������! ����������� � WMV3

//  GetMem(result, DeCompressOutbiSize);
  //��� �� ����� �� ��� ���������� �������� �������? � ������ ��� ����� �������?
//  CopyMemory(result, @(cvDec.lpbiOut^), DeCompressOutbiSize);
  result := @(cvDec.lpbiOut^);
  FDecompressorStarted := true;
end;
///////////////////////////////////////////////////////////////////

procedure TVideoCoDec.ICSeqCompressFrameEnd2(pCV : PCompVars);
begin
  if (pCV = nil) or (pCV.cbSize <> SizeOf(TCompVars)) or
     (pCV.lpBitsOut = nil) then Exit;

  if pCV.hic <> 0 then
  begin
    ICCompressEnd (pCV.hic);
    if pCV.lpBitsPrev <> nil then
      ICDecompressEnd (pCV.hic);
  end;

  if pCV.lpBitsOut <> nil then
  begin
    FreeMem (pCV.lpBitsOut);
    pCV.lpBitsOut := nil;
  end;

  if pCV.lpBitsPrev <> nil then
  begin
    FreeMem (pCV.lpBitsPrev);
    pCV.lpBitsPrev := nil;
  end;
end;

///////////////////////////////////////////////////////////////////
function TVideoCoDec.ICCompressFrame(pCV : PCompVars; uiFlags : Cardinal;
          lpBits : Pointer; var dwFlagKey : DWORD; var IsKeyFrame : Boolean;
          var lSize : DWORD) : Pointer;
var
  Size : cardinal;
  dwFlags, dwFlagsOut, dwChunkId : DWORD;
  tmp_lpBitsPrev, tmp_lpbiPrev : Pointer;
begin
//���� ���������� �� INTEL IYUV ������!!! �� ����� ��������� ���������� �������� ������
  Result := nil;

  dwChunkId := 0;

  IsKeyFrame := (pCV.lKeyCount >= pCV.lKey);
  if HasFlag(FCodecInfo.dwFlags, VIDCF_CRUNCH) = false then
//  if((FCodecInfo.dwFlags and VIDCF_CRUNCH) = 0) then
    begin
    //����� �� ������������ ������ �� ���������� �������
    Size := 0;
    end
  else
    begin
    //���������� ���������� � ������� ������� �����
    size := lSize;
    end;  
//    Size := 5000;//�������� �����, ������������� ��������� ������ �� ��������
                    //���� ����� ����

  if IsKeyFrame then
    begin
    dwFlags := ICCOMPRESS_KEYFRAME;
    dwFlagsOut := AVIIF_KEYFRAME;
//    tmp_lpBitsPrev := nil;//�����
//    tmp_lpBitsPrev := nil;//�����

    if pCV.lpBitsPrev <> nil then
      begin
      FreeMem(pCV.lpBitsPrev);
      pCV.lpBitsPrev := nil;
      end;

    //�������� ������ ��� �������� N ���������� ���������� ������.
    //������ ���� �� ������� �������!!!
//    GetMem (pCV.lpBitsPrev, (pCV.lpbiIn.bmiHeader.biSizeImage * FCompressorBuffersWanted + $810));//��� ��������
//FCompressorBuffersWanted := 10;//����������� XVID
    GetMem (pCV.lpBitsPrev, (pCV.lpbiIn.bmiHeader.biSizeImage * FCompressorBuffersWanted));//��� ��������
//    GetMem (pCV.lpBitsPrev, (640*480*24*3 * FCompressorBuffersWanted));//����������� XVID
    FPrevBuffer := pCV.lpBitsPrev;

    tmp_lpBitsPrev := FPrevBuffer;
    tmp_lpbiPrev := @(pCV.lpbiIn^.bmiHeader);
    end
  else
    begin
    dwFlags := 0;
    dwFlagsOut := 0;
    tmp_lpBitsPrev := pCV.lpBitsPrev;
    tmp_lpbiPrev := @(pCV.lpbiIn^.bmiHeader);//���
//    tmp_lpbiPrev := pCV.lpbiIn;
//    tmp_lpBitsPrev := nil;
    end;

  if ICCompress(
    pCV.hic,
    dwFlags,
    @pCV.lpbiOut.bmiHeader,
    pCV.lpBitsOut,
    @pCV.lpbiIn.bmiHeader,
    lpBits,
    @dwChunkId,
    @dwFlagsOut,
    pCV.lFrame,
    Size,
    pCV.lQ,
    tmp_lpbiPrev,
    tmp_lpBitsPrev) <> ICERR_OK then Exit;

  lSize := pCV.lpbiOut.bmiHeader.biSizeImage;
  if (lSize = 0)
    //and (FCodecName = 'FFDS')
    //Stupid FFDS dont get me SIZE of compressed buffer
      then
    begin
    //plSize^ := GetSizeMemOfPointer(pCV.lpBitsOut);//do street magic
    if pCV.lpbiOut.bmiHeader.biBitCount = 15 then
      pCV.lpbiOut.bmiHeader.biBitCount := 16;
    lSize := (((pCV.lpbiOut.bmiHeader.biBitCount * pCV.lpbiOut.bmiHeader.biWidth + 31) div 32) * 4) * pCV.lpbiOut.bmiHeader.biHeight * pCV.lpbiOut.bmiHeader.biPlanes
    //����� ���������� �������� �� pCV.lpbiOut.bmiHeader BITMAPV5HEADER?
    //���� ������ ��������� � ��� ���������...
    end;

  dwFlagKey := (dwFlagsOut and AVIIF_KEYFRAME);
  if dwFlagKey <> 0 then pCV.lKeyCount := 0;
  if pCV.lKey <> 0 then Inc(pCV.lKeyCount)
    else pCV.lKeyCount := 0{-1};

  Inc (pCV.lFrame);

  Result := pCV.lpBitsOut;
end;

//---------------------------------------------------------------------------//
end.

