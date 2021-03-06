unit CatStrings;
{
  Catarinka - String Operation functions

  Copyright (c) 2003-2017 Felipe Daragon
  License: 3-clause BSD
  See https://github.com/felipedaragon/catarinka/ for details

  MD5 function by Stijn Sanders (MIT license, included at the end of this file)
  IScan, SplitString, GetTextBetweenTags functions by Peter Below
  MatchStrings and PosX functions by Arsne von Wyss

  Note: random functions included with this library are not suitable
  for cryptographic purposes.
}

interface

{$I Catarinka.inc}

uses
{$IFDEF DXE2_OR_UP}
  System.Classes, System.SysUtils, System.StrUtils, System.AnsiStrings;
{$ELSE}
  Classes, SysUtils, StrUtils;
{$ENDIF}

type
  TCatCaseLabel = record
    name: string;
    id: integer;
  end;

function After(const s, substr: string): string;
function ASCIIToInt(const s: string): integer;
function Base64Encode(const s: string): string;
function Base64Decode(const s: string): string;
function Before(const s, substr: string): string;
function BeginsWith(const s, prefix: string; IgnoreCase: Boolean = false)
  : Boolean; overload;
function BeginsWith(const s: string; const prefixes: array of string;
  IgnoreCase: Boolean = false): Boolean; overload;
function BoolToStr(const b: Boolean): string;
function BoolToYN(const b: Boolean): string;
function CatCaseOf(const s: string; labels: array of TCatCaseLabel;
  const casesensitive: Boolean = true): integer;
function CatWrapText(const text: string; const chars: integer): TStringList;
function CharSetToStr(const c: TSysCharSet): string;
function CommaTextToStr(const s: string): string;
function ContainsAnyOfChars(const s: string; const aSet: TSysCharSet): Boolean;
function ContainsAnyOfStrings(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
function ContainsAllOfStrings(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
function EndsWith(const s, prefix: string; IgnoreCase: Boolean = false)
  : Boolean; overload;
function EndsWith(const s: string; const prefixes: array of string;
  IgnoreCase: Boolean = false): Boolean; overload;
function ExtractFromString(const s, startstr, endstr: string): string;
function ExtractFromTag(const s, tag: string): string;
function GetLineByPos(const s: string; const Position: integer): integer;
function GetToken(const aString, SepChar: string; const TokenNum: Byte): string;
function GetValidCompName(const s: string): string;
function HexToInt(const Hex: string; const WarnError: Boolean = false): integer;
function HexToStr(const s: string): string;
function Hex16ToStr(const s: string): string;
function IIF(const Cond: Boolean; const TrueStr: String;
  const FalseStr: string = ''): string; overload;
function IIF(const Cond: Boolean; const TrueInt: integer;
  const FalseInt: integer = 0): integer; overload;
function IScan(ch: Char; const s: string; fromPos: integer): integer;
function IsAlpha(const s: string): Boolean;
function IsAlphaNumeric(const s: string): Boolean;
function IsHexStr(const s: string): Boolean;
function IsInteger(const s: string): Boolean;
function IsLowercase(const s: string): Boolean;
function IsUppercase(const s: string): Boolean;
function IsRoman(const s: string): Boolean;
function LastChar(const s: string): Char;
function LeftPad(const s: string; const c: Char; const len: integer): string;
function LeftStr(s: string; c: longword): string;
function MatchIntInArray(const i: integer; aArray: array of integer): Boolean;
function MatchStrInArray(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
function MatchStrings(s, Mask: string; IgnoreCase: Boolean = false): Boolean;
function MemStreamToStr(m: TMemoryStream): String;
function Occurs(substr, s: string): integer;
function RandomCase(const s: string;
  const ToUpperSet: TSysCharSet = ['a' .. 'z'];
  const ToLowerSet: TSysCharSet = ['A' .. 'Z']): string;
function RandomString(const len: integer;
  const chars: string = 'abcdefghijklmnopqrstuvwxyz'): string;
function RemoveLastChar(const s: string): string;
function RemoveNumbers(const s: string): string;
function RemoveQuotes(const s: string): string;
function RemoveShortcuts(const s: string): string;
function RepeatString(const s: string; count: cardinal): string;
function ReplaceChars(const s: string; const aSet: TSysCharSet;
  const repwith: Char = '_'): string;
function ReplaceStr(const s, substr, repstr: string): string;
function RestStr(const s: string; const index: longword): string;
function RightPad(const s: string; const c: Char; const len: integer): string;
function StrDecrease(const s: string; const step: integer = 1): string;
function StrIncrease(const s: string; const step: integer = 1): string;
function StripChars(const s: string; const aSet: TSysCharSet): string;
function StrMaxLen(const s: string; const MaxLen: integer;
  const AddEllipsis: Boolean = false): string;
function StrToAlphaNum(const s: string): string;
function StrToBool(const s: string): Boolean;
function StrToCharSet(const s: string): TSysCharSet;
function StrToCommaText(const s: string): string;
function StrToHex(const s: string): string;
function StrToHex16(const s: string): string;
function TitleCase(const s: string): string;
procedure GetTextBetweenTags(const s, tag1, tag2: string; const list: TStrings;
  const includetags: Boolean = false);
procedure MergeStrings(const dest, source: TStrings);
procedure SplitString(const s: string; separator: Char;
  substrings: TStringList);

{$IFDEF CHARINSET_UNAVAILABLE}
function CharInSet(c: Char; CharSet: TSysCharSet): Boolean;
{$ENDIF}

// string list related functions
function CompareStrings(sl: TStringList; Index1, Index2: integer): integer;
procedure StripBlankLines(const sl: TStringList);

const
  CRLF = #13 + #10;

implementation

uses
  CatBase64;

{$IFDEF CHARINSET_UNAVAILABLE}

// Before D2009
function CharInSet(c: Char; CharSet: TSysCharSet): Boolean;
begin
  if c in CharSet then
    result := true
  else
    result := false;
end;
{$ENDIF}

function After(const s, substr: string): string;
var
  i: Byte;
begin
  i := pos(substr, s);
  if i = 0 then
    result := emptystr
  else
    result := Copy(s, i + length(substr), length(s));
end;

function ASCIIToInt(const s: string): integer;
var
  i, len: integer;
  c: Char;
begin
  result := 0;
  len := length(s);
  for i := len downto 1 do
  begin
    c := s[i];
    result := result + ord(c) shl ((len - i) shl 8);
  end;
end;

function Base64Encode(const s: string): string;
begin
  Result := CatBase64.Base64Encode(s);
end;

function Base64Decode(const s: string): string;
begin
  Result := CatBase64.Base64Decode(s);
end;

function Before(const s, substr: string): string;
var
  i: Byte;
begin
  i := pos(substr, s);
  if i = 0 then
    result := s
  else
    result := Copy(s, 1, i - 1);
end;

function BeginsWith(const s, prefix: string;
  IgnoreCase: Boolean = false): Boolean;
var
  tmpstr: string;
begin
  tmpstr := s;
{$IFDEF DXE2_OR_UP}
  SetLength(tmpstr, System.AnsiStrings.StrLen
    (System.PAnsiChar(AnsiString(prefix))));
{$ELSE}
  SetLength(tmpstr, StrLen(PAnsiChar(prefix)));
{$ENDIF}
  if IgnoreCase = false then
    result := AnsiCompareStr(tmpstr, prefix) = 0
  else
    result := AnsiCompareText(tmpstr, prefix) = 0;
end;

function BeginsWith(const s: string; const prefixes: array of string;
  IgnoreCase: Boolean = false): Boolean;
var
  b: Byte;
begin
  result := false;
  for b := Low(prefixes) to High(prefixes) do
  begin
    if BeginsWith(s, prefixes[b], IgnoreCase) then
    begin
      result := true;
      break;
    end;
  end;
end;

function BoolToStr(const b: Boolean): string;
begin
  if b = true then
    result := 'True'
  else
    result := 'False';
end;

function BoolToYN(const b: Boolean): string;
begin
  if b = true then
    result := 'Yes'
  else
    result := 'No';
end;

{
  A CaseOf function using arrays
  Usage Example:

  procedure TForm1.Button1Click(Sender: TObject);
  const
  ana = 1;
  roberto = 2;
  lucia = 3;
  const
  labels : array [1..3] of TCatCaseLabel =
  (
  (name:'ana';id:ana),
  (name:'roberto';id:roberto),
  (name:'lucia';id:lucia)
  );
  begin
  case CatCaseOf(edit1.text,labels) of
  ana: form1.caption:='ana!';
  roberto: form1.caption:='roberto!';
  lucia: form1.caption:='lucia!';
  else
  form1.Caption:=edit1.text+' not in case list!';
  end;
  end;

}
function CatCaseOf(const s: string; labels: array of TCatCaseLabel;
  const casesensitive: Boolean = true): integer;
var
  i: integer;
  astr: string;
begin
  result := -1; // label not found
  astr := s;
  if casesensitive = false then begin
    astr := lowercase(astr);
    for i := low(labels) to high(labels) do
      labels[i].name := lowercase(labels[i].name);
  end;
  for i := low(labels) to high(labels) do
  begin
    if astr = labels[i].name then
      result := labels[i].id;
    if result <> -1 then
      break;
  end;
end;

// Wraps a text and returns it as a stringlist
function CatWrapText(const text: string; const chars: integer): TStringList;
var
  sl: TStringList;
  P, ln: integer;
  s, newln: string;
begin
  sl := TStringList.Create;
  result := sl;
  if length(text) = 0 then
    Exit;
  ln := 0;
  sl.Add(emptystr);
  s := text + ' ';
  P := pos(' ', s);
  while P <> 0 do
  begin
    newln := Copy(s, 1, P);
    if (length(sl.Strings[ln]) + length(newln)) < (chars + 1) then
      sl.Strings[ln] := sl.Strings[ln] + newln
    else
    begin
      sl.Add(newln);
      inc(ln);
    end;
    Delete(s, 1, P);
    P := pos(' ', s);
  end;
end;

function ContainsAnyOfChars(const s: string; const aSet: TSysCharSet): Boolean;
var
  i: integer;
begin
  result := false;
  for i := 1 to length(s) do
  begin
    if (CharInSet(s[i], aSet)) then
    begin
      result := true;
      break;
    end;
  end;
end;

function ContainsAllOfStrings(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
var
  b: Byte;
begin
  result := true;
  if IgnoreCase then
  begin
    s := lowercase(s);
    for b := Low(aArray) to High(aArray) do
      aArray[b] := lowercase(aArray[b]);
  end;
  for b := Low(aArray) to High(aArray) do
  begin
    if pos(aArray[b], s) = 0 then
    begin
      result := false;
      break;
    end;
  end;
end;

function ContainsAnyOfStrings(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
var
  b: Byte;
begin
  result := false;
  if IgnoreCase then
  begin
    s := lowercase(s);
    for b := Low(aArray) to High(aArray) do
      aArray[b] := lowercase(aArray[b]);
  end;
  for b := Low(aArray) to High(aArray) do
  begin
    if pos(aArray[b], s) <> 0 then
    begin
      result := true;
      break;
    end;
  end;
end;

// Useful for sorting a string list containing filenames
// Usage sl.CustomSort(CompareStrings);
function CompareStrings(sl: TStringList; Index1, Index2: integer): integer;
begin
  if Length(sl[Index1]) = Length(sl[Index2]) then
  begin
    if sl[Index1] = sl[Index2] then
      result := 0
    else if sl[Index1] < sl[Index2] then
      result := -1
    else
      result := 1;
  end
  else if Length(sl[Index1]) < Length(sl[Index2]) then
    result := -1
  else
    result := 1;
end;

function EndsWith(const s, prefix: string; IgnoreCase: Boolean = false)
  : Boolean;
begin
  if IgnoreCase = false then
    result := AnsiEndsStr(prefix, s)
  else
    result := AnsiEndsText(prefix, s);
end;

function EndsWith(const s: string; const prefixes: array of string;
  IgnoreCase: Boolean = false): Boolean;
var
  b: Byte;
begin
  result := false;
  for b := Low(prefixes) to High(prefixes) do
  begin
    if EndsWith(s, prefixes[b], IgnoreCase) then
    begin
      result := true;
      break;
    end;
  end;
end;

function ExtractFromTag(const s, tag: string): string;
begin
  result := ExtractFromString(s, '<' + tag + '>', '</' + tag + '>');
end;

function GetLineByPos(const s: string; const Position: integer): integer;
var
  i, ln: integer;
begin
  result := -1;
  if (Position = -1) then
    Exit;

  i := 1;
  ln := 0;
  while i < Position do
  begin
    if (s[i] = #13) then
      ln := ln + 1;
    i := i + 1;
  end;
  result := ln;
end;

// Returns a valid Pascal component name (stripping invalid chars)
function GetValidCompName(const s: string): string;
var
  i: integer;
begin
  result := emptystr;
  for i := 1 to length(s) do
  begin
    if (CharInSet(s[i], ['0' .. '9', 'A' .. 'Z', 'a' .. 'z', '_'])) then
      result := result + Copy(s, i, 1);
  end;
end;

function HexToInt(const Hex: string; const WarnError: Boolean = false): integer;
begin
  if IsHexStr(Hex) then
    result := StrToInt('$' + Hex)
  else
  begin
    if WarnError = true then
      raise EConvertError.Create('Invalid character in hex string')
    else
      result := 0;
  end;
end;

function IIF(const Cond: Boolean; const TrueStr: String;
  const FalseStr: String = ''): string; overload;
begin
  if Cond = true then
    result := TrueStr
  else
    result := FalseStr;
end;

function IIF(const Cond: Boolean; const TrueInt: integer;
  const FalseInt: integer = 0): integer; overload;
begin
  if Cond = true then
    result := TrueInt
  else
    result := FalseInt;
end;

function IsAlpha(const s: string): Boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to length(s) do
    if CharInSet(s[i], ['0' .. '9']) then
    begin
      result := false;
      break;
    end;
end;

function IsAlphaNumeric(const s: string): Boolean;
var
  i: integer;
  alpha, num: Boolean;
begin
  alpha := false;
  num := false;
  for i := 1 to length(s) do
  begin
    if CharInSet(s[i], ['A' .. 'Z', 'a' .. 'z']) then
      alpha := true
    else if CharInSet(s[i], ['0' .. '9']) then
      num := true;
  end;
  result := alpha and num;
end;

function IsInteger(const s: string): Boolean;
var
  v, c: integer;
begin
  Val(s, v, c);
  if v = 0 then
  begin // avoid compiler warning
  end;
  result := c = 0;
end;

// Returns true if the string contains valid hexadecimal digits
function IsHexStr(const s: string): Boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to length(s) do
    if not(CharInSet(s[i], ['0' .. '9', 'A' .. 'F', 'a' .. 'f'])) then
    begin
      result := false;
      break;
    end;
end;

function IsUppercase(const s: string): Boolean;
var
  i: integer;
begin
  result := false;
  for i := 1 to length(s) do
    if CharInSet(s[i], ['a' .. 'z']) then
      Exit;
  result := true;
end;

function IsLowercase(const s: string): Boolean;
var
  i: integer;
begin
  result := false;
  for i := 1 to length(s) do
    if CharInSet(s[i], ['A' .. 'Z']) then
      Exit;
  result := true;
end;

function IsRoman(const s: string): Boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to length(s) do
  begin
    if CharInSet(UpCase(s[i]), ['I', 'V', 'X', 'L', 'C', 'D', 'M']) = false then
    begin
      result := false;
      Exit;
    end;
  end;
end;

function LastChar(const s: string): Char;
begin
  if s = emptystr then
    result := #0
  else
    result := s[length(s)];
end;

function LeftPad(const s: string; const c: Char; const len: integer): string;
var
  i: integer;
begin
  result := s;
  i := len - length(s);
  if i < 1 then
    Exit;
  result := s + StringOfChar(c, i);
end;

function RightPad(const s: string; const c: Char; const len: integer): string;
var
  i: integer;
begin
  result := s;
  i := len - length(s);
  if i < 1 then
    Exit;
  result := StringOfChar(c, i) + s;
end;

function LeftStr(s: string; c: longword): string;
begin
  result := Copy(s, 1, c);
end;

procedure MergeStrings(const dest, source: TStrings);
var
  i: integer;
begin
  for i := 0 to -1 + source.count do
    if dest.IndexOf(source[i]) = -1 then
      dest.Add(source[i]);
end;

function Occurs(substr, s: string): integer;
var
  i: integer;
begin
  result := 0;
  for i := 1 to length(s) do
    if Copy(s, i, length(substr)) = substr then
      inc(result);
end;

function RandomCase(const s: string;
  const ToUpperSet: TSysCharSet = ['a' .. 'z'];
  const ToLowerSet: TSysCharSet = ['A' .. 'Z']): string;
var
  i: integer;
begin
  Randomize();
  result := s;
  for i := 1 to length(result) do
    if Random(2) = 1 then
      if CharInSet(result[i], ToLowerSet) then
        inc(result[i], 32)
      else if CharInSet(result[i], ToUpperSet) then
        Dec(result[i], 32);
end;

function RandomString(const len: integer;
  const chars: string = 'abcdefghijklmnopqrstuvwxyz'): string;
begin
  Randomize;
  result := emptystr;
  repeat
    result := result + chars[Random(length(chars)) + 1];
  until (length(result) = len);
end;

// Strips a quote pair off a string if it exists
// The leading and trailing quotes will only be removed if both exist
// Otherwise, the string is left unchanged
function RemoveQuotes(const s: string): string;
var
  i: integer;
begin
  result := s;
  i := length(s);
  if i = 0 then
    Exit;
  if (CharInSet(s[1], ['"', '''']) = true) and (s[1] = LastChar(s)) then
  begin
    Delete(result, 1, 1);
    SetLength(result, length(result) - 1);
  end;
end;

// Removes the last character from a string
function RemoveLastChar(const s: string): string;
var
  len: integer;
  astr: string;
begin
  astr := s;
  len := length(astr);
  if len > 0 then
    Delete(astr, len, 1);
  result := astr;
end;

function RemoveNumbers(const s: string): string;
var
  i, l: integer;
begin
  SetLength(result, length(s));
  l := 0;
  for i := 1 to length(s) do
    if not(CharInSet(s[i], ['0' .. '9'])) then
    begin
      inc(l);
      result[l] := s[i];
    end;
  SetLength(result, l);
end;

function RemoveShortcuts(const s: string): string;
begin
  result := ReplaceStr(s, '&', emptystr);
end;

function RepeatString(const s: string; count: cardinal): string;
var
  i: integer;
begin
  for i := 1 to count do
    result := result + s;
end;

function ReplaceStr(const s, substr, repstr: string): string;
begin
  result := stringreplace(s, substr, repstr, [rfReplaceAll]);
end;

function StrIncrease(const s: string; const step: integer = 1): string;
var
  i, c: integer;
  tmpstr: WideString;
begin
  tmpstr := '';
  for i := 1 to length(s) do
  begin
    c := ord(s[i]);
    inc(c, step);
    tmpstr := tmpstr + widechar(c);
  end;
  result := tmpstr;
end;

function StrDecrease(const s: string; const step: integer = 1): string;
var
  i, c: integer;
  tmpstr: WideString;
begin
  tmpstr := '';
  for i := 1 to length(s) do
  begin
    c := ord(s[i]);
    Dec(c, step);
    tmpstr := tmpstr + widechar(c);
  end;
  result := tmpstr;
end;

function RestStr(const s: string; const index: longword): string;
var
  l: integer;
begin
  l := length(s);
  if l > 0 then
    result := Copy(s, index, l)
  else
    result := emptystr;
end;

procedure StripBlankLines(const sl: TStringList);
var
  i: integer;
begin
  for i := (sl.count - 1) downto 0 do
  begin
    if (Trim(sl[i]) = emptystr) then
      sl.Delete(i);
  end;
end;

function StrToCommaText(const s: string): string;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.text := s;
  result := sl.CommaText;
  sl.free;
end;

function StripChars(const s: string; const aSet: TSysCharSet): string;
var
  i, P: integer;
begin
  P := 0;
  SetLength(result, length(s));
  for i := 1 to length(s) do
  begin
    if not(CharInSet(s[i], aSet)) then
    begin
      inc(P);
      result[P] := s[i];
    end;
  end;
  SetLength(result, P);
end;

function ReplaceChars(const s: string; const aSet: TSysCharSet;
  const repwith: Char = '_'): string;
var
  i, P: integer;
begin
  P := 0;
  SetLength(result, length(s));
  for i := 1 to length(s) do
  begin
    inc(P);
    result[P] := s[i];
    if (CharInSet(s[i], aSet)) then
      result[P] := repwith;
  end;
  SetLength(result, P);
end;

function CommaTextToStr(const s: string): string;
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  sl.CommaText := s;
  result := sl.GetText;
  sl.free;
end;

function StrMaxLen(const s: string; const MaxLen: integer;
  const AddEllipsis: Boolean = false): string;
var
  i: integer;
begin
  result := s;
  if length(result) <= MaxLen then
    Exit;
  SetLength(result, MaxLen);
  if AddEllipsis = false then
    Exit;
  for i := MaxLen downto MaxLen - 2 do
    result[i] := '.';
end;

function StrToAlphaNum(const s: string): string;
var
  i: integer;
  tmpstr: string;
begin
  tmpstr := emptystr;
  for i := 1 to length(s) do
  begin
    if (CharInSet(s[i], ['0' .. '9', 'A' .. 'Z', 'a' .. 'z'])) then
      tmpstr := tmpstr + Copy(s, i, 1);
  end;
  result := tmpstr;
end;

function StrToBool(const s: string): Boolean;
begin
  if MatchStrInArray(Trim(lowercase(s)), ['true', '1', 'yes', 't', 'y', 'on']) then
    result := true
  else
    result := false;
end;

function StrToCharSet(const s: string): TSysCharSet;
var
  P: PAnsiChar;
begin
  result := [];
  if s = emptystr then
    Exit;
  P := PAnsiChar(AnsiString(s));
  while P^ <> #0 do
  begin
    Include(result, P^);
    inc(P);
  end;
end;

function CharSetToStr(const c: TSysCharSet): string;
var
  i: integer;
begin
  result := emptystr;
  for i := 0 to 255 do
    if Chr(i) in c then
      result := result + Chr(i);
end;

function StrToHex(const s: string): string;
var
  i: integer;
begin
  result := emptystr;
  for i := 1 to length(s) do
    result := result + IntToHex(ord(Copy(s, i, 1)[1]), 2);
end;

function StrToHex16(const s: string): string;
var
  i: integer;
  str: string;
begin
  str := emptystr;
  for i := 1 to length(s) do
    str := str + IntToHex(integer(s[i]), 4);
  result := str;
end;

function HexToStr(const s: string): string;
var
  i: integer;
  h: string;
begin
  result := emptystr;
  try
    for i := 1 to length(s) div 2 do
    begin
      h := Copy(s, (i - 1) * 2 + 1, 2);
      result := result + Char(StrToInt('$' + h));
    end;
  except
    result := emptystr;
  end;
end;

function Hex16ToStr(const s: string): string;
var
  i: integer;
  c: string;
begin
  result := emptystr;
  i := 1;
  while i < length(s) do
  begin
    c := Copy(s, i, 4);
    result := result + Chr(StrToInt('$' + c));
    inc(i, 4);
  end;
end;

function TitleCase(const s: string): string;
var
  i: integer;
begin
  if s = emptystr then
    result := emptystr
  else
  begin
    result := Uppercase(s[1]);
    for i := 2 to length(s) do
      if s[i - 1] = ' ' then
        result := result + Uppercase(s[i])
      else
        result := result + lowercase(s[i]);
  end;
end;

// CONTRIBUTED ------------------------------------------------------------//

// Peter Below, 11.27.1996
function IScan(ch: Char; const s: string; fromPos: integer): integer;
var
  i: integer;
begin
  result := 0;
  for i := fromPos to length(s) do
  begin
    if s[i] = ch then
    begin
      result := i;
      break;
    end;
  end;
end;

// PB, 08.07.1997
procedure SplitString(const s: string; separator: Char;
  substrings: TStringList);
var
  i, n: integer;
begin
  if Assigned(substrings) and (length(s) > 0) then
  begin
    i := 1;
    repeat
      n := IScan(separator, s, i);
      if n = 0 then
        n := length(s) + 1;
      substrings.Add(Copy(s, i, n - i));
      i := n + 1;
    until i > length(s);
  end;
end;

// Based on an example by PB
procedure GetTextBetweenTags(const s, tag1, tag2: string; const list: TStrings;
  const includetags: Boolean = false);
var
  pScan, pEnd, pTag1, pTag2: PAnsiChar;
  foundText, searchtext: string;
begin
  searchtext := Uppercase(s);
  pTag1 := PAnsiChar(AnsiString(Uppercase(tag1)));
  pTag2 := PAnsiChar(AnsiString(Uppercase(tag2)));
  pScan := PAnsiChar(AnsiString(searchtext));
  repeat

{$IFDEF DXE2_OR_UP}
    pScan := System.AnsiStrings.StrPos(pScan, pTag1);
{$ELSE}
    pScan := StrPos(pScan, pTag1);
{$ENDIF}
    if pScan <> nil then
    begin
      inc(pScan, length(tag1));

{$IFDEF DXE2_OR_UP}
      pEnd := System.AnsiStrings.StrPos(pScan, pTag2);
{$ELSE}
      pEnd := StrPos(pScan, pTag2);
{$ENDIF}
      if pEnd <> nil then
      begin
        SetString(foundText, PAnsiChar(AnsiString(s)) +
          (pScan - PAnsiChar(AnsiString(searchtext))), pEnd - pScan);
        if includetags then
          list.Add(Uppercase(tag1) + foundText + Uppercase(tag2))
        else
          list.Add(foundText);
        list.text := list.GetText;
        pScan := pEnd + length(tag2);
      end
      else
        pScan := nil;
    end;
  until pScan = nil;
end;

// Based on an example by Mike Orriss
function ExtractFromString(const s, startstr, endstr: string): string;
var
  ps, pe: integer;
begin
  ps := pos(startstr, s);
  pe := pos(endstr, s);
  if (pe <= ps) or (ps = 0) then
    result := emptystr
  else
  begin
    inc(ps, length(startstr));
    result := Copy(s, ps, pe - ps);
  end;
end;

// Based on an example from Thomas Scheffczyk
function GetToken(const aString, SepChar: String; const TokenNum: Byte): String;
var
  Token, tmpstr: String;
  StrLen, num, EndofToken: integer;
begin
  tmpstr := aString;
  StrLen := length(tmpstr);
  num := 1;
  EndofToken := StrLen;
  while ((num <= TokenNum) and (EndofToken <> 0)) do
  begin
    EndofToken := pos(SepChar, tmpstr);
    if EndofToken <> 0 then
    begin
      Token := Copy(tmpstr, 1, EndofToken - 1);
      Delete(tmpstr, 1, EndofToken);
      inc(num);
    end
    else
      Token := tmpstr;
  end;
  if num >= TokenNum then
    result := Token
  else
    result := emptystr;
end;

function PosX(const substr, s: string; Start: integer): integer;
var
  i, J, len: integer;
begin
  len := length(substr);
  if len = 0 then
  begin
    PosX := 1;
    Exit;
  end;
  for i := Start to Succ(length(s) - len) do
  begin
    J := 1;
    while J <= len do
    begin
      if not((substr[J] = '?') or (substr[J] = s[Pred(i + J)])) then
        break;
      inc(J);
    end;
    if J > len then
    begin
      PosX := i;
      Exit;
    end;
  end;
  PosX := 0;
end;

function MatchIntInArray(const i: integer; aArray: array of integer): Boolean;
var
  b: Byte;
begin
  result := false;
  for b := Low(aArray) to High(aArray) do
  begin
    if i = aArray[b] then begin
      result := true;
      break;
    end;
  end;
end;

function MatchStrInArray(s: string; aArray: array of string;
  IgnoreCase: Boolean = false): Boolean;
var
  b: Byte;
begin
  result := false;
  if IgnoreCase then
  begin
    s := lowercase(s);
    for b := Low(aArray) to High(aArray) do
      aArray[b] := lowercase(aArray[b]);
  end;
  for b := Low(aArray) to High(aArray) do
  begin
    if s = aArray[b] then begin
      result := true;
      break;
    end;
  end;
end;

{
  This function takes two strings and compares them. The first string
  can be anything, but should not contain pattern characters (* or ?).
  The pattern string can have as many of these pattern characters as you want.
  For example: MatchStrings('Pascal','*as*') would return True.

  Copyright (c) 1999 Arsne von Wyss
}
function MatchStrings(s, Mask: string; IgnoreCase: Boolean = false): Boolean;
const
  WildSize = 0; { minimal number of characters representing a "*" }
var
  Min, Max, At, MaskSTart, MaskEnd: integer;
  T: string;
begin
  if IgnoreCase then
  begin
    for At := 1 to length(s) do
      s[At] := UpCase(s[At]);
    for At := 1 to length(Mask) do
      Mask[At] := UpCase(Mask[At]);
  end;
  s := s + #0;
  Mask := Mask + #0;
  Min := 1;
  Max := 1;
  MaskEnd := 0;
  while length(Mask) >= MaskEnd do
  begin
    MaskSTart := MaskEnd + 1;
    repeat
      inc(MaskEnd);
    until (MaskEnd > length(Mask)) or (Mask[MaskEnd] = '*');
    T := Copy(Mask, MaskSTart, MaskEnd - MaskSTart);
    At := PosX(T, s, Min);
    if (At = 0) or (At > Max) then
    begin
      MatchStrings := false;
      Exit;
    end;
    Min := At + length(T) + WildSize;
    Max := length(s);
  end;
  MatchStrings := true;
end;

function MemStreamToStr(m: TMemoryStream): String;
begin
  SetString(Result, PAnsiChar(AnsiString(m.Memory)), M.Size);
end;

// ------------------------------------------------------------------------//
end.
