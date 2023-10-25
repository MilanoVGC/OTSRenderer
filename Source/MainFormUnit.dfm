object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'OTS Renderer'
  ClientHeight = 756
  ClientWidth = 600
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ShpPreview: TShape
    Left = 8
    Top = 378
    Width = 584
    Height = 370
  end
  object Pokemon1: TImage
    Left = 20
    Top = 448
    Width = 128
    Height = 128
  end
  object Pokemon2: TImage
    Left = 238
    Top = 448
    Width = 128
    Height = 128
  end
  object Pokemon3: TImage
    Left = 441
    Top = 448
    Width = 128
    Height = 128
  end
  object Pokemon4: TImage
    Left = 20
    Top = 614
    Width = 128
    Height = 128
  end
  object Pokemon5: TImage
    Left = 238
    Top = 614
    Width = 128
    Height = 128
  end
  object Pokemon6: TImage
    Left = 441
    Top = 614
    Width = 128
    Height = 128
  end
  object Item1: TImage
    Left = 132
    Top = 433
    Width = 32
    Height = 32
    Stretch = True
  end
  object Item2: TImage
    Left = 352
    Top = 433
    Width = 32
    Height = 32
    Stretch = True
  end
  object Item3: TImage
    Left = 553
    Top = 433
    Width = 32
    Height = 32
    Stretch = True
  end
  object Item4: TImage
    Left = 132
    Top = 601
    Width = 32
    Height = 32
    Stretch = True
  end
  object Item5: TImage
    Left = 352
    Top = 601
    Width = 32
    Height = 32
    Stretch = True
  end
  object Item6: TImage
    Left = 553
    Top = 601
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping3: TImage
    Left = 439
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping6: TImage
    Left = 439
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping5: TImage
    Left = 238
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping2: TImage
    Left = 238
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping4: TImage
    Left = 18
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object FirstTyping1: TImage
    Left = 18
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping3: TImage
    Left = 473
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping6: TImage
    Left = 473
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping5: TImage
    Left = 272
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping2: TImage
    Left = 272
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping4: TImage
    Left = 52
    Top = 584
    Width = 32
    Height = 32
    Stretch = True
  end
  object SecondTyping1: TImage
    Left = 52
    Top = 416
    Width = 32
    Height = 32
    Stretch = True
  end
  object LblPlayerName: TLabel
    Left = 18
    Top = 385
    Width = 561
    Height = 25
    Alignment = taCenter
    AutoSize = False
    Caption = 'Preview'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LblInfo: TLabel
    Left = 410
    Top = 6
    Width = 175
    Height = 11
    Caption = 'OTSRenderer by relder (github/relderDev)'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Page: TPageControl
    Left = 8
    Top = 1
    Width = 584
    Height = 371
    ActivePage = TabInputOutput
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    object TabInputOutput: TTabSheet
      Caption = 'Home'
      object LblInputFile: TLabel
        Left = 8
        Top = 30
        Width = 47
        Height = 13
        Caption = 'Input file:'
        Layout = tlCenter
      end
      object LblOutputPathSelect: TLabel
        Left = 269
        Top = 256
        Width = 69
        Height = 13
        Caption = 'Output folder:'
        Layout = tlCenter
      end
      object LblPalette: TLabel
        Left = 3
        Top = 255
        Width = 66
        Height = 13
        Caption = 'Color palette:'
        Layout = tlCenter
      end
      object LblInputList: TLabel
        Left = 428
        Top = 60
        Width = 111
        Height = 13
        Caption = 'Manually added inputs:'
      end
      object CbxPalette: TComboBox
        Left = 75
        Top = 252
        Width = 150
        Height = 22
        Style = csOwnerDrawVariable
        TabOrder = 7
        StyleElements = [seFont, seClient]
        OnDrawItem = CbxPaletteDrawItem
      end
      object BtnInputFile: TButton
        Left = 550
        Top = 24
        Width = 23
        Height = 23
        ImageAlignment = iaCenter
        ImageIndex = 1
        ImageMargins.Left = 1
        Images = Icons
        TabOrder = 1
        OnClick = BtnInputFileClick
      end
      object EdtInputFile: TEdit
        Left = 61
        Top = 25
        Width = 483
        Height = 21
        TabOrder = 0
        OnChange = EdtInputFileChange
      end
      object EdtOutputPathSelect: TEdit
        Left = 344
        Top = 253
        Width = 200
        Height = 21
        TabOrder = 8
      end
      object BtnOutputPathSelect: TButton
        Left = 550
        Top = 252
        Width = 23
        Height = 23
        ImageAlignment = iaCenter
        ImageIndex = 0
        ImageMargins.Left = 1
        Images = Icons
        TabOrder = 9
        OnClick = BtnOutputPathSelectClick
      end
      object BtnCreate: TButton
        Left = 3
        Top = 288
        Width = 570
        Height = 52
        Caption = 'Create images!'
        Enabled = False
        TabOrder = 10
        OnClick = BtnCreateClick
      end
      object PnlInput: TPanel
        Left = 3
        Top = 72
        Width = 382
        Height = 120
        BorderStyle = bsSingle
        Caption = 'Manually add inputs'
        TabOrder = 2
        VerticalAlignment = taAlignTop
        object LblInputName: TLabel
          Left = 48
          Top = 23
          Width = 31
          Height = 13
          Caption = 'Name:'
        end
        object LblInputSurname: TLabel
          Left = 33
          Top = 52
          Width = 46
          Height = 13
          Caption = 'Surname:'
        end
        object LblInputUrl: TLabel
          Left = 3
          Top = 79
          Width = 76
          Height = 13
          Caption = 'Pokepaste URL:'
        end
        object EdtInputName: TEdit
          Left = 85
          Top = 20
          Width = 280
          Height = 21
          TabOrder = 0
          OnChange = EdtInputNameChange
        end
        object EdtInputSurname: TEdit
          Left = 85
          Top = 47
          Width = 280
          Height = 21
          TabOrder = 1
          OnChange = EdtInputSurnameChange
        end
        object EdtInputUrl: TEdit
          Left = 85
          Top = 74
          Width = 280
          Height = 21
          TabOrder = 2
          OnChange = EdtInputUrlChange
        end
      end
      object BtnInputRemove: TButton
        Left = 435
        Top = 200
        Width = 66
        Height = 31
        Caption = 'Remove'
        Enabled = False
        TabOrder = 5
        OnClick = BtnInputRemoveClick
      end
      object BtnInputRemoveAll: TButton
        Left = 507
        Top = 200
        Width = 66
        Height = 31
        Caption = 'Clear All'
        TabOrder = 6
        OnClick = BtnInputRemoveAllClick
      end
      object LstInputList: TListBox
        Left = 391
        Top = 72
        Width = 182
        Height = 118
        ItemHeight = 13
        TabOrder = 4
        OnClick = LstInputListClick
      end
      object BtnInputAdd: TButton
        Left = 0
        Top = 198
        Width = 382
        Height = 31
        Caption = 'Add'
        Enabled = False
        TabOrder = 3
        OnClick = BtnInputAddClick
      end
    end
    object TabConfig: TTabSheet
      Caption = 'Configuration'
      ImageIndex = 1
      object LblResourcePath: TLabel
        Left = 3
        Top = 210
        Width = 79
        Height = 13
        Caption = 'Resources path:'
        Layout = tlCenter
      end
      object LblDataPath: TLabel
        Left = 24
        Top = 299
        Width = 58
        Height = 13
        Caption = 'Data folder:'
        Layout = tlCenter
      end
      object LblAssetsPath: TLabel
        Left = 14
        Top = 255
        Width = 68
        Height = 13
        Caption = 'Sprites folder:'
        Layout = tlCenter
      end
      object LblColumnName: TLabel
        Left = 48
        Top = 18
        Width = 154
        Height = 13
        Caption = 'Input CSV column name - Name:'
        Layout = tlCenter
      end
      object LblColumnSurname: TLabel
        Left = 33
        Top = 51
        Width = 169
        Height = 13
        Caption = 'Input CSV column name - Surname:'
        Layout = tlCenter
      end
      object LblColumnPaste: TLabel
        Left = 3
        Top = 86
        Width = 199
        Height = 13
        Caption = 'Input CSV column name - Pokepaste URL:'
        Layout = tlCenter
      end
      object LblDelimiter: TLabel
        Left = 107
        Top = 122
        Width = 95
        Height = 13
        Caption = 'Input CSV delimiter:'
        Layout = tlCenter
      end
      object EdtResourcePath: TEdit
        Left = 88
        Top = 207
        Width = 456
        Height = 21
        ReadOnly = True
        TabOrder = 0
        Text = '.\Resources\'
        OnChange = EdtResourcePathChange
      end
      object EdtDataPath: TEdit
        Left = 88
        Top = 296
        Width = 485
        Height = 21
        Ctl3D = True
        Enabled = False
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
        Text = '.\Resources\Data\'
      end
      object BtnResourcePath: TButton
        Left = 550
        Top = 206
        Width = 23
        Height = 23
        ImageAlignment = iaCenter
        ImageIndex = 0
        ImageMargins.Left = 1
        Images = Icons
        TabOrder = 2
        OnClick = BtnResourcePathClick
      end
      object EdtAssetsPath: TEdit
        Left = 88
        Top = 252
        Width = 485
        Height = 21
        Ctl3D = True
        Enabled = False
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 3
        Text = '.\Resources\Assets\'
      end
      object ChkEnablePreview: TCheckBox
        Left = 3
        Top = 165
        Width = 100
        Height = 17
        Alignment = taLeftJustify
        Caption = 'Enable preview: '
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = ChkEnablePreviewClick
      end
      object EdtColumnPaste: TEdit
        Left = 208
        Top = 83
        Width = 149
        Height = 21
        TabOrder = 5
        Text = 'Pokepaste OT'
        OnChange = EdtColumnPasteChange
      end
      object EdtColumnSurname: TEdit
        Left = 208
        Top = 48
        Width = 149
        Height = 21
        TabOrder = 6
        Text = 'Surname'
        OnChange = EdtColumnSurnameChange
      end
      object EdtColumnName: TEdit
        Left = 208
        Top = 15
        Width = 149
        Height = 21
        TabOrder = 7
        Text = 'Name'
        OnChange = EdtColumnNameChange
      end
      object ChkHtmlOutput: TCheckBox
        Left = 232
        Top = 165
        Width = 100
        Height = 17
        Alignment = taLeftJustify
        Caption = 'HTML output:'
        Checked = True
        State = cbChecked
        TabOrder = 8
        OnClick = ChkHtmlOutputClick
      end
      object ChkPngOutput: TCheckBox
        Left = 444
        Top = 165
        Width = 100
        Height = 17
        Alignment = taLeftJustify
        Caption = 'PNG Output: '
        Checked = True
        State = cbChecked
        TabOrder = 9
        OnClick = ChkPngOutputClick
      end
      object CbxDelimiter: TComboBox
        Left = 208
        Top = 119
        Width = 41
        Height = 21
        Style = csDropDownList
        ItemIndex = 0
        TabOrder = 10
        Text = ','
        OnChange = CbxDelimiterChange
        Items.Strings = (
          ','
          ';'
          '|'
          '~')
      end
    end
  end
  object DlgPathSelect: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders]
    Left = 515
    Top = 376
  end
  object Icons: TImageList
    ColorDepth = cd32Bit
    DrawingStyle = dsTransparent
    Left = 579
    Top = 377
    Bitmap = {
      494C010102000800040010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000023000000330000
      0033000000330000003300000033000000330000003300000033000000330000
      0033000000330000002300000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000003000000033000000330000
      0033000000330000003300000033000000330000003300000033000000330000
      0033000000330000002F000000000000000000000000483F33C08A7760FF8976
      5FFF88755DFF88755DFF88745DFF88755DFF88755DFF89765EFF89765EFF8976
      5FFF8A7760FF483F33C000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003D89BCF24298D2FF3F94D0FF3D92
      CFFF3D92CEFF3E92CEFF3E92CEFF3E92CEFF3E92CEFF3E92CEFF3E92CEFF3E92
      CEFF3E93CFFF3983B6F00000000E00000000000000008A775FFFAE9A89FFA893
      80FFA48F7AFFA28D77FFA28C77FFA28D77FFA48E7AFFA6917CFFA6917DFFA994
      81FFAE9A89FF8A775FFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000004399D2FF3E94D0FFABFBFFFF9BF3
      FFFF92F1FFFF93F1FFFF93F1FFFF93F1FFFF93F1FFFF93F1FFFF93F1FFFF93F1
      FFFFA6F8FFFF64B8E3FF060F155F000000000000000089765FFFAD9A89FF9F8C
      77FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF9B8670FFFFFFFFFFA08C
      78FFAD9A89FF89765FFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000004298D2FF4EA6D9FF8EDAF5FFA2EE
      FFFF82E5FEFF84E5FEFF84E5FEFF85E6FEFF85E6FEFF85E6FEFF85E6FEFF84E6
      FEFF96EBFFFF8CD8F5FF1D4562B8000000000000000089765EFFB09C8CFF9D88
      73FF967E69FF927A64FF947B65FF957E69FF957D68FF968069FF98816CFF9D88
      73FFB09C8CFF89765EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000004196D1FF6ABEE8FF6CBDE6FFBBF2
      FFFF74DEFDFF76DEFCFF77DEFCFF7ADFFCFF7CDFFCFF7CDFFCFF7CDFFCFF7BDF
      FCFF80E0FDFFADF0FFFF4C9DD3FF0000000E0000000089765EFFB19F8FFF9A84
      70FFFFFFFFFFFFFFFFFFFFFFFFFF947D67FFFFFFFFFFFFFFFFFFFFFFFFFF9A84
      70FFB19F8FFF89765EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003F95D0FF8AD7F5FF43A1D8FFDDFD
      FFFFDAFAFFFFDBFAFFFFDEFAFFFF73DCFCFF75DBFAFF74DAFAFF73DAFAFF73DA
      FAFF71D9FAFFA1E8FFFF7BBFE6FF060F155E0000000089765EFFB3A291FF9783
      6DFF927C66FF907A64FF907962FF907962FF8D765FFF8D765EFF907963FF9783
      6DFFB3A291FF89765EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003D94D0FFABF0FFFF439DD6FF358C
      CBFF358CCBFF358CCBFF368BCBFF5BBEEAFF6ED9FBFF69D6FAFF67D5F9FF66D4
      F9FF65D4F9FF82DEFCFFAAE0F6FF1D4563B90000000089765EFFB5A494FF9580
      69FFFFFFFFFF8F7961FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF947E
      68FFB5A494FF89765EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003C92CFFFB9F4FFFF72DBFBFF6ACC
      F2FF6BCDF3FF6BCEF3FF6CCEF3FF469CD4FF55BAE9FFDAF8FFFFD7F6FFFFD6F6
      FFFFD5F6FFFFD5F7FFFFDBFCFFFF3D94D0FF0000000089755EFFB7A797FF937D
      67FF8E7860FF8C755DFF89725AFF89725AFF8B745CFF89725AFF8B755DFF927C
      66FFB7A797FF89755EFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003B92CFFFC0F3FFFF70DAFBFF73DB
      FBFF74DBFCFF74DBFCFF75DCFCFF72DAFAFF439CD4FF368CCBFF358CCBFF348C
      CCFF338DCCFF3790CEFF3C94D0FF3881B3EB0000000088755EFFB9AA9AFF8E7A
      63FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF89745BFFFFFFFFFFFFFFFFFF8C78
      60FFB9A998FF88755DFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003A92CFFFCAF6FFFF68D5F9FF6BD5
      F9FF6AD5F9FF68D5F9FF68D5FAFF69D7FBFF67D4FAFF5DC7F1FF5DC7F2FF5CC8
      F2FFB4E3F8FF3C94D0FF0A182169000000000000000088755DFFBBAD9EFF8F7B
      64FF8D7961FF8B775FFF8B765EFF8B775FFF9B8973FFB4A493FFB3A393FFB6A7
      97FFB9AB9CFF88755DFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003A92CFFFD5F7FFFF5FD1F9FF60D0
      F8FFB4EBFDFFD9F6FFFFDAF8FFFFDAF8FFFFDBF9FFFFDCFAFFFFDCFAFFFFDCFB
      FFFFE0FFFFFF3D95D0FF02060833000000000000000088755DFFBDB0A1FF8F7A
      63FF907C65FF907C66FF907B65FF8E7963FFBBAE9FFF96856EFF7E6A50FF7E6A
      50FFBBAD9EFF88755DFF00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000003C94D0FFDCFCFFFFD8F7FFFFD8F7
      FFFFDBFAFFFF348ECDFF3891CEFF3992CFFF3992CFFF3992CFFF3992CFFF3A92
      CFFF3C94D0FF2F6C95D700000000000000000000000088755DFFBFB2A4FF8B77
      61FF8D7A64FF8E7B65FF8D7A64FF8B7761FFBEB1A1FF806B52FFF7FAFEFFFFFF
      FFFFA69684FF3D352BAC00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000001F4864B03C94D0FF3992CFFF3992
      CFFF3C94D0FF2C658DD200000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000088745DFFC0B4A6FF8673
      5AFF88755DFF89755EFF88755DFF86725AFFBEB2A3FF7D6950FFFFFFFFFFA493
      80FF393027A70000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000089755EFFC4B8A9FFC3B7
      A8FFC3B7A9FFC3B8A9FFC3B7A9FFC2B6A8FFC1B5A6FFC0B4A5FFA89987FF3830
      26A6000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007A6854EF89755EFF8874
      5DFF88745DFF88745DFF88745DFF88745DFF87745CFF88745DFF73634FEA0000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
  object DlgFileSelect: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = []
    Left = 547
    Top = 376
  end
end
