object MonolingualTemplate: TMonolingualTemplate
  Left = 0
  Top = 0
  Width = 598
  Height = 844
  TabOrder = 0
  object PnlPageLayout: TPanel
    Left = 0
    Top = 0
    Width = 598
    Height = 844
    Caption = 'PnlPageLayout'
    TabOrder = 0
    object LblAgeDivision: TLabel
      Left = 160
      Top = 123
      Width = 57
      Height = 13
      Caption = 'Age division'
    end
    object LblBattleTeam: TLabel
      Left = 481
      Top = 104
      Width = 55
      Height = 13
      Caption = 'Battle team'
    end
    object LblBirthDate: TLabel
      Left = 160
      Top = 104
      Width = 48
      Height = 13
      Caption = 'Birth Date'
    end
    object LblHeaderAgeDivision: TLabel
      Left = 83
      Top = 123
      Width = 71
      Height = 13
      Caption = 'Age division:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderBattleTeam: TLabel
      Left = 320
      Top = 104
      Width = 157
      Height = 13
      Caption = 'Battle Team Number/Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderBirthDate: TLabel
      Left = 46
      Top = 104
      Width = 108
      Height = 13
      Caption = 'Player'#39's Birth Date:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderPlayerId: TLabel
      Left = 99
      Top = 85
      Width = 55
      Height = 13
      Caption = 'Player ID:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderPlayerName: TLabel
      Left = 80
      Top = 66
      Width = 74
      Height = 13
      Caption = 'Player name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderProfile: TLabel
      Left = 361
      Top = 85
      Width = 114
      Height = 13
      Caption = 'Switch Profile Name:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblHeaderTrainerName: TLabel
      Left = 347
      Top = 66
      Width = 128
      Height = 13
      Caption = 'Trainer name in Game:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object LblPlayerId: TLabel
      Left = 160
      Top = 85
      Width = 41
      Height = 13
      Caption = 'Player id'
    end
    object LblPlayerName: TLabel
      Left = 160
      Top = 66
      Width = 59
      Height = 13
      Caption = 'Player name'
    end
    object LblProfile: TLabel
      Left = 481
      Top = 85
      Width = 64
      Height = 13
      Caption = 'Switch profile'
    end
    object LblTrainerName: TLabel
      Left = 481
      Top = 66
      Width = 63
      Height = 13
      Caption = 'Trainer name'
    end
    object LblTitle: TLabel
      Left = 0
      Top = 25
      Width = 598
      Height = 27
      Alignment = taCenter
      AutoSize = False
      Caption = 'Pok'#233'mon Video Game Team List (for Tournament Staff)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object GrdPokemon1: TStringGrid
      Left = 86
      Top = 154
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 0
    end
    object GrdPokemon2: TStringGrid
      Left = 380
      Top = 154
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 1
    end
    object GrdPokemon3: TStringGrid
      Left = 86
      Top = 375
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 2
    end
    object GrdPokemon4: TStringGrid
      Left = 380
      Top = 375
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 3
    end
    object GrdPokemon5: TStringGrid
      Left = 86
      Top = 596
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 4
    end
    object GrdPokemon6: TStringGrid
      Left = 380
      Top = 596
      Width = 202
      Height = 211
      ColCount = 1
      DefaultColWidth = 200
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 5
    end
    object GrdHeaderPokemon1: TStringGrid
      Left = 4
      Top = 154
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 6
    end
    object GrdHeaderPokemon2: TStringGrid
      Left = 298
      Top = 154
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 7
    end
    object GrdHeaderPokemon3: TStringGrid
      Left = 4
      Top = 375
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 8
    end
    object GrdHeaderPokemon4: TStringGrid
      Left = 298
      Top = 375
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 9
    end
    object GrdHeaderPokemon5: TStringGrid
      Left = 4
      Top = 596
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 10
    end
    object GrdHeaderPokemon6: TStringGrid
      Left = 298
      Top = 596
      Width = 82
      Height = 211
      ColCount = 1
      DefaultColWidth = 80
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 8
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 11
    end
    object GrdStatPokemon1: TStringGrid
      Left = 226
      Top = 180
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 12
    end
    object GrdStatPokemon2: TStringGrid
      Left = 520
      Top = 180
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 13
    end
    object GrdStatPokemon3: TStringGrid
      Left = 226
      Top = 401
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 14
    end
    object GrdStatPokemon4: TStringGrid
      Left = 520
      Top = 401
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 15
    end
    object GrdStatPokemon5: TStringGrid
      Left = 226
      Top = 622
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 16
    end
    object GrdStatPokemon6: TStringGrid
      Left = 520
      Top = 622
      Width = 62
      Height = 185
      ColCount = 1
      DefaultColWidth = 60
      DefaultRowHeight = 25
      FixedCols = 0
      RowCount = 7
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 17
    end
  end
end
