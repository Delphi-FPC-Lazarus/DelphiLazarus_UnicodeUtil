{ Unicode Decoder

  Universalkonvertierung: (UTF16, UTF16BE, UTF-8, ... )
  Erkennt den Typ des Übergebenen TBytes aufgrund der BOM (Byte Order Marks)
  und konvertiert es in einen String.

  class TEncoding Handling beachten

  Unter Windows gibt SysUtils.TEncoding.Default die ANSI-Standardcodeseite zurück; unter Mac OS wird UTF-8 zurückgegeben.
  Der Rückgabewert von System.SysUtils.TEncoding.Default hängt von der Plattform ab.
  Platfform  Standardcodierung  Instanz
  Windows    ANSI               System.SysUtils.TMBCSEncoding
  Mac OS X   UTF-8              System.SysUtils.TUTF8Encoding

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
unit unicode_decode_unit;

interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

{ ----------------------------------------------------------------------------- }

// Decoding von TBytes in String - Unicode (UTF16/ÚTF16BE/UTF8 mit BOM)
// automatischer BOM Erkennung und Umwandlung von Unicode in das Default Encoding Format
// Wenn kein BOM vorhanden ist, kann die Quell Codepage auch übergeben werden
// Buf,fromindex,len müssen übergeben werden, optsourcecodepage ist optional
function BytesToString_Decode(arr: TBytes;
  optsourcecodepage: integer = 0): string;

{ ----------------------------------------------------------------------------- }

implementation

uses unicode_util_unit, unicode_def_unit;

{ ----------------------------------------------------------------------------- }

function BytesToString_Decode(arr: TBytes;
  optsourcecodepage: integer = 0): string;
var
  fromencoding: TEncoding;
  fromencodingcreated: Boolean;
  fromoffset: integer;
  toencoding: TEncoding;
  tobytesbuf: TBytes;

  ResString: string;
  i: integer;
begin
  // Preset Result
  Result := '';
  ResString := '';
  // wenn übergebene TBytes leer, dann hier gleich mit leerem Rückgabestring beenden
  if high(arr) < 0 then
  begin
    exit;
  end;

  fromencodingcreated := false;
  try
    toencoding := TEncoding.Unicode;
    // intern verwaltete Klassenvariablen, nicht freigeben!

    fromencoding := Nil;
    fromencodingcreated := false;

    if optsourcecodepage > 0 then
    begin
      // Vorgabe
      // .GetEncoding Erzeugt eine neue Instanz von TEncoding, die unbedingt wieder aufgelöst werden
      fromencoding := TEncoding.GetEncoding(optsourcecodepage);
      fromencodingcreated := true;
      if not Assigned(fromencoding) then
        exit;
      fromoffset := 0;
    end
    else
    begin
      // automatische Erkennung
      fromencoding := nil;
      // Der Parameter AEncoding soll den Wert NIL haben, ansonsten wird sein Wert zum Feststellen der Codierung verwendet.
      // hier werden die Klassenvariablen von TEncoding zurückzugeben, nicht freigeben!
      fromoffset := TEncoding.GetBufferEncoding(arr, fromencoding);
    end;

    if (fromencoding.CodePage = CodePage_ANSI) and
      (toencoding.CodePage = CodePage_ANSI) and (fromoffset = 0) then
    begin
      // wenn kein encoding durchgeführt wird (fromoffset=0 und encoding ist defaultencoding) nur filter
      // Wichtig: wegen Sonderzeichen und ähnlichem NUR Zeichen < 32 rausfiltern ( > 127 durchlassen!)
      ResString := '';
      for i := low(arr) to high(arr) do
        if (arr[i] >= 32) or (arr[i] = 10) or (arr[i] = 13) then
          // mehrzeilige Felder erlaubt!
          ResString := ResString + chr(arr[i]);
      Result := ResString;
    end
    else
    begin
      // konvertieren und in Ziel kopieren
      tobytesbuf := fromencoding.Convert(fromencoding, toencoding, arr,
        fromoffset, length(arr) - fromoffset);
      Result := toencoding.GetString(tobytesbuf, 0, length(tobytesbuf));
    end;

    // showmessage(fromencoding.EncodingName + #10#13 + toencoding.EncodingName); // Debug
    if fromencodingcreated and Assigned(fromencoding) then
      FreeAndNil(fromencoding);
  except
    on e: exception do
    begin
      try
        if fromencodingcreated and Assigned(fromencoding) then
          FreeAndNil(fromencoding);
      except
        on e: exception do
        begin
          // nix
        end;
      end;
      // nix
    end
  end;

end;

{ ----------------------------------------------------------------------------- }

end.
