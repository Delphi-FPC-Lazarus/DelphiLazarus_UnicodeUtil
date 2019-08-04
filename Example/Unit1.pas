unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TTestform = class(TForm)
    btnLaden: TButton;
    OpenDialog1: TOpenDialog;
    btnStringtoBuf: TButton;
    btnEncode: TButton;
    eenc1: TEdit;
    eenc2: TEdit;
    eenc3: TEdit;
    Button1: TButton;
    procedure btnLadenClick(Sender: TObject);
    procedure btnStringtoBufClick(Sender: TObject);
    procedure btnEncodeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
    buf:array[0..1023] of byte;
  end;

var
  Testform: TTestform;

implementation

{$R *.dfm}

uses unicode_def_unit,
     unicode_util_unit,
     unicode_encode_unit,
     unicode_decode_unit;

procedure TTestform.btnEncodeClick(Sender: TObject);
const s:string='Test ‰¸ˆﬂƒ‹÷';
var bytes:TBytes;
    debug1, debug2:string;
    i, toindex:integer;
begin
 bytes:= StringToBytes_Encode(s, CodePage_UTF16);
 eenc1.Text:= inttostr(length(s))+' / '+inttostr(high(bytes)+1);

 debug1:= '';
 debug2:= '';
 for i:= low(bytes) to high(bytes) do
 begin
  debug1:= debug1 + inttohex(bytes[i], 2)+ ' ';
  if bytes[i] >= 32 then
   debug2:= debug2 + chr(bytes[i]);
 end;
 eenc2.Text:= debug1;
 eenc3.Text:= debug2;

 toindex:= 0;
 if BytestoBuf(bytes, Buf, toindex) then
 begin
   beep;
 end;

end;

procedure TTestform.btnLadenClick(Sender: TObject);
var f:file of byte;
    fs:integer;
    tmpstr:string;
begin
 opendialog1.InitialDir:= ExtractFilePath(application.ExeName);
 if not opendialog1.execute then exit;

 fs:= 0;
 try
  assignfile(f, opendialog1.FileName);
  reset(f);
  fs:= filesize(f);
  if fs > sizeof(buf) then raise exception.Create('zu groﬂ');
  BlockRead(f, buf, fs);
 finally
  closefile(f);
 end;

 //tmpstr:= BufToString(buf, 3, fs, CodePage_UTF8);
 tmpstr:= BufToString_Unicode(buf, 0, fs);

 showmessage(tmpstr);

end;

procedure TTestform.btnStringtoBufClick(Sender: TObject);
var i:integer;
    s:string;
    tmpbytes:TBytes;
begin
 ZeroMemory(@buf, sizeof(buf));
 i:= 0;

 if StringToBuf_Ansi('Test', buf, i, 10, $FF) then
 begin
  beep;
 end;

 setlength(tmpbytes, 5);
 tmpbytes[0]:= 01;
 tmpbytes[1]:= 02;
 tmpbytes[2]:= 03;
 tmpbytes[3]:= 04;
 tmpbytes[4]:= 05;
 if BytesToBuf(tmpbytes, buf, i) then
 begin
  beep;
 end;

 if StringToBuf_Ansi('Ende', buf, i, 10, $FF) then
 begin
  beep;
 end;


 s:= BufToString_ANSI(buf, 0, 4);
 showmessage(s);

 setlength(tmpbytes, 0);
 tmpbytes:= BufToBytes(buf, 10, 5+4);



 // showmessage(chr(buf[i-1]));

end;


procedure TTestform.Button1Click(Sender: TObject);
var bytes:TBytes;
begin
 setlength(bytes, 5);
 bytes[0]:= 100;
 bytes[1]:= 101;
 bytes[2]:= 102;
 bytes[3]:= 103;
 bytes[4]:= 104;

 bytes:= TBytesAdd($F1, bytes, addStart);
 bytes:= TBytesAdd($F2, bytes, addEnd);

 showmessage(inttostr(length(bytes)));
end;

end.
