{ Unicode Toolbox

  <x>ToBuf_...() sind zur Abwärtskompatibilität vorhanden
  - toindex wird automatisch um die Anzahl der hinzugefügten Bytes erhöht
  - die Parameter deslen und destfillbyte sind optional,
  - wenn er nicht übergeben wird, werden nur die tatsälichen Daten geschrieben

  BufTo<x>_...() sind die Umkehrfunktionen von <x>ToBuf_...()

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
unit unicode_util_unit;

interface

uses
{$IFNDEF UNIX}Windows, {$ENDIF}
{$IFDEF FPC}LCLIntf, LCLType, LMessages, {$ENDIF}
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

{ ----------------------------------------------------------------------------- }

// String to Buf (Merge) - erzeugt optional UTF8 und UTF16s (MBCS / Multi-Byte Character Set)
// Achtung: bei leerem String wird toindex trotz gesetzter destfilllen nicht hochgesetzt
function StringToBuf_UNICODE(s: String; var buf; var toindex: integer;
  destcodepage: integer; destfilllen: integer = 0;
  destfillbyte: byte = 0): boolean;

// String to Buf (Merge) - erzeugt Kopie von ANSI String (SBCS / Single-Byte Character Set)
// Achtung: bei leerem String wird toindex trotz gesetzter destfilllen nicht hochgesetzt
function StringToBuf_ANSI(s: String; var buf; var toindex: integer;
  destfilllen: integer = 0; destfillbyte: byte = 0): boolean;

// Bytes to Buf (Merge)
// Achtung: bei leerem String wird toindex trotz gesetzter destfilllen nicht hochgesetzt
function BytesToBuf(arr: TBytes; var buf; var toindex: integer;
  destfilllen: integer = 0; destfillbyte: byte = 0): boolean;

{ ----------------------------------------------------------------------------- }

// Buf to String - lesen als UNICODE
function BufToString_UNICODE(var buf; fromindex, len: integer;
  optsourcecodepage: integer = 0): string;

// Buf to String - lesen als ANSI
function BufToString_ANSI(var buf; fromindex, len: integer): string;

// Buf to Bytes - lesen als TBytes
function BufToBytes(var buf; fromindex, len: integer): TBytes;

{ ----------------------------------------------------------------------------- }

// Hilfsfunktion
function TBytesMerge(arr1, arr2: TBytes): TBytes;

type
  RAddTyp = (addStart, addEnd);
function TBytesAdd(b: byte; arr: TBytes; typ: RAddTyp): TBytes;

function StringToTBytes(s: String): TBytes;

{ ----------------------------------------------------------------------------- }

implementation

uses unicode_encode_unit, unicode_decode_unit, unicode_def_unit;

{ ----------------------------------------------------------------------------- }
{ ----------------------------------------------------------------------------- }

function StringToBuf_UNICODE(s: String; var buf; var toindex: integer;
  destcodepage: integer; destfilllen: integer = 0;
  destfillbyte: byte = 0): boolean;
var
  arr: TBytes;
begin
  result := false;
  if toindex < 0 then
    exit;
  if length(s) < 1 then
  // s kann theoretisch auch leer sein, in dem falle nichts machen aber result true
  begin
    result := true;
    exit;
  end;

  try
    // Encode -> TBytes
    arr := StringToBytes_Encode(s, destcodepage);
    if high(arr) > -1 then
    begin
      // tbytes -> buf (+ inc toindex)
      if BytesToBuf(arr, buf, toindex, destfilllen, destfillbyte) then
        result := true;
    end;
  except
    on e: exception do
    begin
      // nix, result bleibt false
    end
  end;
end;

{ ----------------------------------------------------------------------------- }

function StringToBuf_ANSI(s: String; var buf; var toindex: integer;
  destfilllen: integer = 0; destfillbyte: byte = 0): boolean;
var
  i: integer;
  swrite: Ansistring;
begin
  result := false;
  if toindex < 0 then
    exit;
  if length(s) < 1 then
  // s kann theoretisch auch leer sein, in dem falle nichts machen aber result true
  begin
    result := true;
    exit;
  end;

  try
    swrite := Ansistring(s);

    if destfilllen < 1 then
      destfilllen := length(swrite);
    if destfilllen > 0 then // sonst nichts machen, aber result true!
    begin
      for i := 1 to destfilllen do
      begin
        if i <= length(swrite) then
          PByte(@buf)[toindex + i - 1] := ord(swrite[i])
        else
          PByte(@buf)[toindex + i - 1] := destfillbyte;
      end;
      inc(toindex, destfilllen);
    end;

    result := true;
  except
    on e: exception do
    begin
      // nix, result bleibt false
    end
  end;
end;

{ ----------------------------------------------------------------------------- }

function BytesToBuf(arr: TBytes; var buf; var toindex: integer;
  destfilllen: integer = 0; destfillbyte: byte = 0): boolean;
var
  i: integer;
begin
  result := false;
  if toindex < 0 then
    exit;
  if high(arr) < 0 then
  // arr kann theoretisch auch leer sein, in dem falle nichts machen aber result true
  begin
    result := true;
    exit;
  end;

  try
    if destfilllen < 1 then
      destfilllen := high(arr) + 1;
    if destfilllen > 0 then // sonst nichts machen, aber result true!
    begin
      for i := 1 to destfilllen do
      begin
        if i <= high(arr) + 1 then
          PByte(@buf)[toindex + i - 1] := arr[i - 1]
        else
          PByte(@buf)[toindex + i - 1] := destfillbyte;
      end;
      inc(toindex, destfilllen);
    end;

    result := true;
  except
    on e: exception do
    begin
      // nix, result bleibt false
    end
  end;
end;

{ ----------------------------------------------------------------------------- }
{ ----------------------------------------------------------------------------- }

function BufToString_UNICODE(var buf; fromindex, len: integer;
  optsourcecodepage: integer = 0): string;
var
  arr: TBytes;
begin
  result := '';
  if fromindex < 0 then
    exit;
  if len < 1 then
    exit;

  try
    arr := BufToBytes(buf, fromindex, len);
    if high(arr) > -1 then
      result := BytesToString_Decode(arr, optsourcecodepage);
  except
    on e: exception do
    begin
      result := '';
    end
  end;
end;

{ ----------------------------------------------------------------------------- }

function BufToString_ANSI(var buf; fromindex, len: integer): string;
var
  i: integer;
  t: string;
begin
  result := '';
  if fromindex < 0 then
    exit;
  if len < 1 then
    exit;

  try
    t := '';
    for i := 0 to len - 1 do
      t := t + Chr(byte(PByte(@buf)[fromindex + i]));
    result := t;
  except
    on e: exception do
    begin
      result := '';
    end
  end;
end;

{ ----------------------------------------------------------------------------- }

function BufToBytes(var buf; fromindex, len: integer): TBytes;
var
  i: integer;
begin
  setlength(result, 0);
  if fromindex < 0 then
    exit;
  if len < 1 then
    exit;

  try
    setlength(result, len);
    for i := 0 to len - 1 do
      result[i] := byte(PByte(@buf)[fromindex + i]);
  except
    on e: exception do
    begin
      setlength(result, 0);
    end
  end;
end;

{ ----------------------------------------------------------------------------- }
{ ----------------------------------------------------------------------------- }

function TBytesMerge(arr1, arr2: TBytes): TBytes;
var
  ofs: integer;
begin
  setlength(result, length(arr1) + length(arr2));
  ofs := 0;
  if arr1 <> nil then
  begin
    Move(arr1[0], result[ofs], length(arr1));
    inc(ofs, length(arr1));
  end;
  if arr2 <> nil then
  begin
    Move(arr2[0], result[ofs], length(arr2));
    inc(ofs, length(arr2));
  end;
end;

{ ----------------------------------------------------------------------------- }

function TBytesAdd(b: byte; arr: TBytes; typ: RAddTyp): TBytes;
begin
  setlength(result, 0);
  case typ of
    addStart:
      begin
        setlength(result, length(arr) + 1);
        Move(b, result[0], 1);
        Move(arr[0], result[1], length(arr));
      end;
    addEnd:
      begin
        setlength(result, length(arr) + 1);
        Move(arr[0], result[0], length(arr));
        Move(b, result[length(arr)], 1);
      end;
  end;
end;

{ ----------------------------------------------------------------------------- }

function StringToTBytes(s: String): TBytes;
var
  i: integer;
begin
  setlength(result, length(s));
  for i := 1 to length(s) do
    result[i - 1] := ord(s[i]);
end;

{ ----------------------------------------------------------------------------- }

end.
