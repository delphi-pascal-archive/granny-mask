object FormJPEGQuality: TFormJPEGQuality
  Left = 622
  Top = 428
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = 'JPEG Quality'
  ClientHeight = 126
  ClientWidth = 236
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtnOK: TBitBtn
    Left = 27
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 0
    Kind = bkOK
  end
  object BitBtnCancel: TBitBtn
    Left = 140
    Top = 80
    Width = 75
    Height = 25
    TabOrder = 1
    Kind = bkCancel
  end
  object SpinEditQuality: TSpinEdit
    Left = 88
    Top = 32
    Width = 65
    Height = 22
    MaxValue = 100
    MinValue = 1
    TabOrder = 2
    Value = 70
  end
end
