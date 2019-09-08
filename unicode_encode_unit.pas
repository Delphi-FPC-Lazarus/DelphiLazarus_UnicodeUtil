{ Unicode Encoder

  Erzeugt das gewünschte Format und gibt es als TByes zurück
  class TEncoding Handling beachten

  11/2012 für XE2
  02/2016 XE10 x64 Test
  xx/xxxx FPC Ubuntu

  --------------------------------------------------------------------
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  THE SOFTWARE IS PROVIDED "AS IS" AND WITHOUT WARRANTY

  Author: Peter Lorenz
  Is that code useful for you? Donate!
  Paypal webmaster@peter-ebe.de
  --------------------------------------------------------------------

}

{$I ..\share_settings.inc}
unit unicode_encode_unit;

interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

{ ----------------------------------------------------------------------------- }

// Encoding von String in TBytes - Unicode (UTF16/UTF16BE/UTF8 mit BOM)
// Zielcodepage kann übergeben werden
function StringToBytes_Encode(const s: string; destcodepage: integer;
  withBOM: boolean = true): TBytes;

{ ----------------------------------------------------------------------------- }

implementation

uses unicode_util_unit, unicode_def_unit;

{ ----------------------------------------------------------------------------- }

function StringToBytes_Encode(const s: string; destcodepage: integer;
  withBOM: boolean = true): TBytes;
var
  Encoding: TEncoding;
begin
  // preset Result
  setlength(Result, 0);
  // wenn übergebener String leer ist, beenden mit leerer Rückgabe (sonst würde BOM trotzdem zurückgegeben)
  if length(s) < 1 then
  begin
    exit;
  end;

  if destcodepage = 0 then
    destcodepage := {$IFDEF UNIX}CodePage_ANSI; {$ELSE}GetACP; {$ENDIF}
  case destcodepage of
    // .ANSI .UNICODE .BigEdianUnicode .UTF8 sind intern verwaltete Klassenvariablen, nicht freigeben!
    CodePage_ANSI:
      if withBOM = true then
        Result := TBytesMerge(TEncoding.ANSI.GetPreamble,
          TEncoding.ANSI.GetBytes(s))
      else
        Result := TEncoding.ANSI.GetBytes(s);
    CodePage_UTF16:
      if withBOM = true then
        Result := TBytesMerge(TEncoding.Unicode.GetPreamble,
          TEncoding.Unicode.GetBytes(s))
      else
        Result := TEncoding.Unicode.GetBytes(s);
    CodePage_UTF16BE:
      if withBOM = true then
        Result := TBytesMerge(TEncoding.BigEndianUnicode.GetPreamble,
          TEncoding.BigEndianUnicode.GetBytes(s))
      else
        Result := TEncoding.BigEndianUnicode.GetBytes(s);
    CodePage_UTF8:
      if withBOM = true then
        Result := TBytesMerge(TEncoding.UTF8.GetPreamble,
          TEncoding.UTF8.GetBytes(s))
      else
        Result := TEncoding.UTF8.GetBytes(s);
  else
    Encoding := nil;
    Try
      // .GetEncoding Erzeugt Instanz von von TEncoding, die muss freigegeben werden
      Encoding := TEncoding.GetEncoding(destcodepage);
      Result := Encoding.GetBytes(s);
    finally
      FreeAndNil(Encoding);
    end;
  end;
end;

{ ----------------------------------------------------------------------------- }

end.
