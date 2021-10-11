object FormFeathering: TFormFeathering
  Tag = 1
  Left = 218
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #1069#1092#1092#1077#1082#1090' '#1074#1080#1085#1100#1077#1090#1082#1080' (Granny Mask)'
  ClientHeight = 705
  ClientWidth = 822
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 120
  TextHeight = 16
  object LabelLab1: TLabel
    Left = 6
    Top = 682
    Width = 185
    Height = 24
    Caption = 'efg'#39's Computer Lab'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsItalic]
    ParentFont = False
  end
  object LabelLab2: TLabel
    Left = 643
    Top = 682
    Width = 172
    Height = 24
    Alignment = taRightJustify
    Caption = 'www.efg2.com/lab'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -20
    Font.Name = 'Arial'
    Font.Style = [fsBold, fsUnderline]
    ParentFont = False
    OnClick = LabelLab2Click
  end
  object PageControl: TPageControl
    Left = 2
    Top = 2
    Width = 815
    Height = 679
    ActivePage = TabSheetForeground
    HotTrack = True
    TabOrder = 0
    OnChange = PageControlChange
    object TabSheetForeground: TTabSheet
      Caption = '  Foreground  '
      object ImageForeground: TImage
        Left = 7
        Top = 48
        Width = 788
        Height = 591
        OnMouseDown = ImageForegroundMouseDown
        OnMouseMove = ImageForegroundMouseMove
        OnMouseUp = ImageForegroundMouseUp
      end
      object ButtonReadForegroundFile: TButton
        Left = 8
        Top = 9
        Width = 94
        Height = 30
        Hint = 'Read foreground image from file'
        Caption = 'Open image'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = ButtonReadForegroundFileClick
      end
      object PanelDrawingTools: TPanel
        Left = 223
        Top = 2
        Width = 203
        Height = 40
        TabOrder = 2
        object SpeedButtonRectangle: TSpeedButton
          Tag = 2
          Left = 57
          Top = 5
          Width = 30
          Height = 31
          Hint = 'Rectangle'
          GroupIndex = 1
          Glyph.Data = {
            66010000424D6601000000000000760000002800000014000000140000000100
            040000000000F000000000000000000000001000000000000000000000000000
            BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            3333333300003000000000000000000300003033333333333333330300003033
            3333333333333303000030333333333333333303000030333333333333333303
            0000303333333333333333030000303333333333333333030000303333333333
            3333330300003033333333333333330300003033333333333333330300003033
            3333333333333303000030333333333333333303000030333333333333333303
            0000303333333333333333030000303333333333333333030000303333333333
            3333330300003033333333333333330300003000000000000000000300003333
            33333333333333330000}
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButtonToolClick
        end
        object SpeedButtonErase: TSpeedButton
          Left = 167
          Top = 5
          Width = 31
          Height = 31
          Hint = 'Delete'
          GroupIndex = 1
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            04000000000000010000120B0000120B00001000000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555555555
            5555555555555555555555555555055555555555555585555555555555505555
            555555555558555555555555550555555555555555855FF55555555550550055
            55555555585588FF5555555505501105555555558558888FF555555055099910
            5555555855888888FF55550555099991055555855F88888885F5505555509990
            3055585555F88888585F55555555090B030555555555888585855555555550B0
            B030555555555858585855555555550B0B335555555555858555555555555550
            BBB35555555555585F555555555555550BBB55555555555585F5555555555555
            50BB555555555555585F555555555555550B5555555555555585}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButtonEraseClick
        end
        object SpeedButtonEllipse: TSpeedButton
          Tag = 4
          Left = 118
          Top = 5
          Width = 31
          Height = 31
          Hint = 'Ellipse'
          GroupIndex = 1
          Glyph.Data = {
            4E010000424D4E01000000000000760000002800000012000000120000000100
            040000000000D800000000000000000000001000000000000000000000000000
            80000080000000808000800000008000800080800000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000000
            3333330000003333003333330033330000003330333333333303330000003303
            3333333333303300000030333333333333330300000030333333333333330300
            0000033333333333333330000000033333333333333330000000033333333333
            3333300000000333333333333333300000000333333333333333300000000333
            3333333333333000000030333333333333330300000030333333333333330300
            0000330333333333333033000000333033333333330333000000333300333333
            003333000000333333000000333333000000}
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButtonToolClick
        end
        object SpeedButtonSelect: TSpeedButton
          Tag = 1
          Left = 7
          Top = 5
          Width = 31
          Height = 31
          Hint = 'Select'
          GroupIndex = 1
          Down = True
          Glyph.Data = {
            76010000424D7601000000000000760000002800000020000000100000000100
            04000000000000010000120B0000120B00001000000000000000000000000000
            800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            333333333333333FFF3333333333333707333333333333F777F3333333333370
            9033333333F33F7737F33333373337090733333337F3F7737733333330037090
            73333333377F7737733333333090090733333333373773773333333309999073
            333333337F333773333333330999903333333333733337F33333333099999903
            33333337F3333F7FF33333309999900733333337333FF7773333330999900333
            3333337F3FF7733333333309900333333333337FF77333333333309003333333
            333337F773333333333330033333333333333773333333333333333333333333
            3333333333333333333333333333333333333333333333333333}
          NumGlyphs = 2
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButtonToolClick
        end
        object SpeedButtonRoundRect: TSpeedButton
          Tag = 3
          Left = 87
          Top = 5
          Width = 31
          Height = 31
          Hint = 'Round Rectangle'
          GroupIndex = 1
          Glyph.Data = {
            66010000424D6601000000000000760000002800000014000000140000000100
            040000000000F0000000C40E0000C40E00001000000000000000000000000000
            BF0000BF000000BFBF00BF000000BF00BF00BFBF0000C0C0C000808080000000
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
            3333333300003333300000000003333300003333033333333330333300003330
            3333333333330333000033033333333333333033000030333333333333333303
            0000303333333333333333030000303333333333333333030000303333333333
            3333330300003033333333333333330300003033333333333333330300003033
            3333333333333303000030333333333333333303000030333333333333333303
            0000303333333333333333030000330333333333333330330000333033333333
            3333033300003333033333333330333300003333300000000003333300003333
            33333333333333330000}
          ParentShowHint = False
          ShowHint = True
          OnClick = SpeedButtonToolClick
        end
      end
      object ButtonPasteForegroundFile: TButton
        Left = 108
        Top = 9
        Width = 93
        Height = 30
        Hint = 'Paste foreground image from clipboard'
        Caption = 'Paste'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = ButtonPasteForegroundFileClick
      end
      object PanelDrawingAttributes: TPanel
        Left = 436
        Top = 2
        Width = 365
        Height = 40
        TabOrder = 3
        object LabelLineColor: TLabel
          Left = 8
          Top = 11
          Width = 32
          Height = 16
          Caption = 'Color'
        end
        object ShapeLineColor: TShape
          Left = 44
          Top = 6
          Width = 25
          Height = 25
          Hint = 'Click to change color'
          Brush.Color = clYellow
          ParentShowHint = False
          ShowHint = True
          OnMouseDown = ShapeLineColorMouseDown
        end
        object LabelLineWidth: TLabel
          Left = 81
          Top = 10
          Width = 34
          Height = 16
          Caption = 'Width'
        end
        object LabelLineStyle: TLabel
          Left = 224
          Top = 10
          Width = 30
          Height = 16
          Caption = 'Style'
        end
        object ComboBoxLineWidth: TComboBox
          Left = 121
          Top = 7
          Width = 92
          Height = 22
          Hint = 'Select width'
          Style = csOwnerDrawFixed
          ItemHeight = 16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          OnChange = ComboBoxLineWidthChange
          OnDrawItem = ComboBoxLineWidthDrawItem
          Items.Strings = (
            '0'
            '1'
            '2'
            '3'
            '4'
            '5'
            '6'
            '7')
        end
        object ComboBoxLineStyle: TComboBox
          Left = 265
          Top = 7
          Width = 92
          Height = 22
          Hint = 'Select style'
          Style = csOwnerDrawFixed
          ItemHeight = 16
          ParentShowHint = False
          ShowHint = True
          TabOrder = 1
          OnChange = ComboBoxLineStyleChange
          OnDrawItem = ComboBoxLineStyleDrawItem
          Items.Strings = (
            '0'
            '1'
            '2'
            '3'
            '4')
        end
      end
    end
    object TabSheetBackground: TTabSheet
      Caption = '  Background  '
      ImageIndex = 1
      object ImageBackground: TImage
        Left = 7
        Top = 48
        Width = 788
        Height = 591
      end
      object ShapeBackground: TShape
        Left = 246
        Top = 10
        Width = 25
        Height = 24
        Hint = 'Click to change color'
        Brush.Color = clRed
        ParentShowHint = False
        ShowHint = True
        OnMouseDown = ShapeBackgroundMouseDown
      end
      object ButtonReadBackgroundTileFile: TButton
        Left = 286
        Top = 9
        Width = 92
        Height = 30
        Hint = 'Read background bitmap tile from file'
        Caption = 'Read File'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Visible = False
        OnClick = ButtonReadBackgroundTileFileClick
      end
      object RadioGroupBackground: TRadioGroup
        Left = 9
        Top = 1
        Width = 219
        Height = 41
        Hint = 'Background style'
        Caption = 'Style'
        Columns = 2
        ItemIndex = 0
        Items.Strings = (
          'Solid Color'
          'Bitmap Tiling')
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = RadioGroupBackgroundClick
      end
      object ButtonPasteBackgroundTileFile: TButton
        Left = 384
        Top = 9
        Width = 92
        Height = 30
        Hint = 'Paste background bitmap tile'
        Caption = 'Paste'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Visible = False
        OnClick = ButtonPasteBackgroundTileFileClick
      end
    end
    object TabSheetMask: TTabSheet
      Caption = '   Mask   '
      ImageIndex = 2
      object ImageMask: TImage
        Left = 7
        Top = 48
        Width = 788
        Height = 591
      end
      object LabelSteps: TLabel
        Left = 11
        Top = 12
        Width = 39
        Height = 16
        Caption = 'Bands'
      end
      object SpinEditBands: TSpinEdit
        Left = 60
        Top = 10
        Width = 70
        Height = 22
        Hint = 'Number of feathering bands'
        MaxValue = 128
        MinValue = 1
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Value = 16
        OnChange = SpinEditBandsChange
      end
      object CheckBoxBlur: TCheckBox
        Left = 183
        Top = 7
        Width = 55
        Height = 31
        Hint = 'Blur feathering mask'
        Caption = 'Blur'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = CheckBoxMaskChange
      end
      object CheckBoxInvert: TCheckBox
        Left = 246
        Top = 7
        Width = 110
        Height = 31
        Hint = 'Invert feathering mask'
        Caption = 'Invert'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = CheckBoxMaskChange
      end
    end
    object TabSheetFeathering: TTabSheet
      Caption = '  Feathering  '
      ImageIndex = 3
      object ImageFeathering: TImage
        Left = 7
        Top = 48
        Width = 788
        Height = 591
        OnMouseDown = ImageFeatheringMouseDown
        OnMouseMove = ImageFeatheringMouseMove
        OnMouseUp = ImageFeatheringMouseUp
      end
      object ButtonSaveFile: TButton
        Left = 10
        Top = 9
        Width = 92
        Height = 30
        Hint = 'Save feathered image to file'
        Caption = 'Save To File'
        TabOrder = 0
        OnClick = ButtonSaveFileClick
      end
      object ButtonCopyToClipboard: TButton
        Left = 108
        Top = 9
        Width = 93
        Height = 30
        Hint = 'Copy feathered image to clipboard'
        Caption = 'Copy'
        TabOrder = 1
        OnClick = ButtonCopyToClipboardClick
      end
    end
  end
  object ColorDialog: TColorDialog
    Left = 651
    Top = 128
  end
  object OpenPictureDialog: TOpenPictureDialog
    Left = 616
    Top = 128
  end
  object SavePictureDialog: TSavePictureDialog
    DefaultExt = 'BMP'
    Filter = 
      'All (*.jpg;.bmp)|*.jpg;*.bmp|JPEG Image File (*.jpg)|*.jpg|Bitma' +
      'ps (*.bmp)|*.bmp'
    FilterIndex = 3
    Left = 688
    Top = 128
  end
  object TimerMarchingAnts: TTimer
    OnTimer = TimerMarchingAntsTimer
    Left = 720
    Top = 128
  end
end
