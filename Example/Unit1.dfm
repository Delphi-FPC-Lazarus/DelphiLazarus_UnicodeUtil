object Testform: TTestform
  Left = 0
  Top = 0
  Caption = 'Testform'
  ClientHeight = 506
  ClientWidth = 901
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnLaden: TButton
    Left = 8
    Top = 8
    Width = 177
    Height = 25
    Caption = 'DecodeBufToString (aus Datei)'
    TabOrder = 0
    OnClick = btnLadenClick
  end
  object btnStringtoBuf: TButton
    Left = 8
    Top = 153
    Width = 177
    Height = 25
    Caption = 'StringtoBuf / BuftoString'
    TabOrder = 1
    OnClick = btnStringtoBufClick
  end
  object btnEncode: TButton
    Left = 8
    Top = 184
    Width = 177
    Height = 25
    Caption = 'Encode'
    TabOrder = 2
    OnClick = btnEncodeClick
  end
  object eenc1: TEdit
    Left = 8
    Top = 224
    Width = 841
    Height = 21
    TabOrder = 3
  end
  object eenc2: TEdit
    Left = 9
    Top = 251
    Width = 841
    Height = 21
    TabOrder = 4
  end
  object eenc3: TEdit
    Left = 8
    Top = 278
    Width = 841
    Height = 21
    TabOrder = 5
  end
  object Button1: TButton
    Left = 320
    Top = 153
    Width = 75
    Height = 25
    Caption = 'TBytesAdd'
    TabOrder = 6
    OnClick = Button1Click
  end
  object OpenDialog1: TOpenDialog
    Filter = 'Textdateien (*.TXT)|*.TXT|Alle Dateien (*.*)|*.*'
    Left = 232
    Top = 8
  end
end
