// Image "Feathering"
// efg, December 2000-January 2001
// www.efg2.com/Lab

// For GIF support, install Anders Melanders TGIFImage and change the
// "NoGIF" conditional compilation variable to "GIF":  Project | Options |
// Directories/Conditionals | Conditionals.
//
// Added TVectorGraphicsNode.StandardizeOrder to VectorGraphicsNodeLibrary so
// figures can be drawn top left to bottom right, or bottom right to top left,
// or any other order.  Thanks to John Clark for bring this bug to my
// attention.  efg, 25 Feb 2001. 

unit ScreenFeathering;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Spin, ExtDlgs, ComCtrls,
  Buttons,
  VectorGraphicsListLibrary,
  VectorGraphicsNodeLibrary;   // TGraphicsListNode

type
  TDrawingState = (dsNotDrawing, dsNewFigure, dsStretchCorner, dsTranslate);

  TFormFeathering = class(TForm)
    PageControl: TPageControl;
    TabSheetForeground: TTabSheet;
    TabSheetBackground: TTabSheet;
    TabSheetMask: TTabSheet;
    TabSheetFeathering: TTabSheet;
    ImageMask: TImage;
    ImageForeground: TImage;
    ButtonReadForegroundFile: TButton;
    ButtonReadBackgroundTileFile: TButton;
    ImageBackground: TImage;
    ImageFeathering: TImage;
    ShapeBackground: TShape;
    RadioGroupBackground: TRadioGroup;
    ColorDialog: TColorDialog;
    LabelSteps: TLabel;
    SpinEditBands: TSpinEdit;
    CheckBoxBlur: TCheckBox;
    OpenPictureDialog: TOpenPictureDialog;
    PanelDrawingTools: TPanel;
    SpeedButtonRectangle: TSpeedButton;
    SpeedButtonErase: TSpeedButton;
    SpeedButtonEllipse: TSpeedButton;
    SpeedButtonSelect: TSpeedButton;
    SpeedButtonRoundRect: TSpeedButton;
    ButtonPasteForegroundFile: TButton;
    PanelDrawingAttributes: TPanel;
    LabelLineColor: TLabel;
    ShapeLineColor: TShape;
    LabelLineWidth: TLabel;
    ComboBoxLineWidth: TComboBox;
    LabelLineStyle: TLabel;
    ComboBoxLineStyle: TComboBox;
    CheckBoxInvert: TCheckBox;
    ButtonPasteBackgroundTileFile: TButton;
    ButtonSaveFile: TButton;
    SavePictureDialog: TSavePictureDialog;
    ButtonCopyToClipboard: TButton;
    TimerMarchingAnts: TTimer;
    LabelLab1: TLabel;
    LabelLab2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonReadForegroundFileClick(Sender: TObject);
    procedure RadioGroupBackgroundClick(Sender: TObject);
    procedure ShapeBackgroundMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonReadBackgroundTileFileClick(Sender: TObject);
    procedure CheckBoxMaskChange(Sender: TObject);
    procedure SpeedButtonToolClick(Sender: TObject);
    procedure SpeedButtonEraseClick(Sender: TObject);
    procedure ImageForegroundMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageForegroundMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ImageForegroundMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ShapeLineColorMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ComboBoxLineWidthDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ComboBoxLineStyleDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ComboBoxLineWidthChange(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PageControlChange(Sender: TObject);
    procedure SpinEditBandsChange(Sender: TObject);
    procedure ButtonPasteForegroundFileClick(Sender: TObject);
    procedure ComboBoxLineStyleChange(Sender: TObject);
    procedure ButtonPasteBackgroundTileFileClick(Sender: TObject);
    procedure ButtonSaveFileClick(Sender: TObject);
    procedure ButtonCopyToClipboardClick(Sender: TObject);
    procedure ImageFeatheringMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageFeatheringMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ImageFeatheringMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TimerMarchingAntsTimer(Sender: TObject);
    procedure LabelLab2Click(Sender: TObject);
  private
    BitmapBackground    :  TBitmap;
    BitmapFeathering    :  TBitmap;
    BitmapForeground    :  TBitmap;
    BitmapMask          :  TBitmap;
    BitmapTile          :  TBitmap;

    DrawingBasePoint    :  TPoint;
    DrawingHandle       :  TDrawingHandle;
    DrawingNode         :  TVectorGraphicsNode;  // PointA = Origin, PointB = Move
    DrawingState        :  TDrawingState;
    DrawingTool         :  TDrawingTool;

    GraphicsList        :  TVectorGraphicsList;

    OriginalImageHeight :  INTEGER;
    OriginalImageWidth  :  INTEGER;

    PointA              :  TPoint;
    PointB              :  TPoint;

    SelectedPenStyle    :  TPenStyle;           // current drawing settings for new figure
    SelectedPenWidth    :  INTEGER;

    UpdateFlagBackground:  BOOLEAN;
    UpdateFlagMask      :  BOOLEAN;

    MarchingAntsCanvas  :  TControlCanvas;
    MarchingAntsPointA  :  TPoint;
    MarchingAntsPointB  :  TPoint;

    PROCEDURE UpdateForeground;
    PROCEDURE UpdateBackground;
    PROCEDURE UpdateMask;
    PROCEDURE UpdateFeathering;

    PROCEDURE DrawAllFigures (CONST HighlightSelected:  THighlightSelectedFigure);

    PROCEDURE DrawMarchingAnts;
    PROCEDURE RemoveMarchingAnts;
  public
    { Public declarations }
  end;

var
  FormFeathering: TFormFeathering;

implementation
{$R *.DFM}
{$R Background.RES}  // default background pattern tile

  USES
{$IFDEF GIF}
    GIFImage,           // TGIFImage
{$ENDIF}
    Clipbrd,            // Clipboard
    LineLibrary,        // RestrictCursorToDrawingArea, AddPoints, SubtractPoints
    JPEG,               // TJPEGImage
    ScreenJPEGQuality,  // TFormJPEGQuality
    ShellAPI;           // ShellExecute

  CONST
    RubberBandColor   :  TColor = clNavy;
    LineWidthThick    :  INTEGER = 2;   // Thickness[pixels] of regular lines
    LineWidthThin     :  INTEGER = 1;

    clHandleOutline   :  TColor = clBlack;
    clHandleSingle    :  TColor = clLime;
    clHandleMultiple  :  TColor = clRed;

    HandleMinimumPixels:  INTEGER =  8;  // Minimum pixels in a dimension.
                                         // Figures are ignored this size
                                         // or smaller.

  VAR
    MarchingAntsCounter     :  BYTE;
    MarchingAntsCounterStart:  BYTE;

  TYPE
    TRGBTripleArray = ARRAY[WORD] OF TRGBTriple;  // pf24bit Scanline
    pRGBTripleArray = ^TRGBTripleArray;


  PROCEDURE TFormFeathering.UpdateForeground;
    VAR
      Size:  INTEGER;
  BEGIN
    // Adjust size of TImage to same size as TBitmap to reduce flicker
    // while drawing.
    IF   BitmapForeground.Width < OriginalImageWidth
    THEN ImageForeground.Width := BitmapForeground.Width
    ELSE ImageForeground.Width := OriginalImageWidth;

    IF   BitmapForeground.Height < OriginalImageHeight
    THEN ImageForeground.Height := BitmapForeground.Height
    ELSE ImageForeground.Height := OriginalImageHeight;

    ImageForeground.Picture.Graphic := BitmapForeground;
    GraphicsList.Free;

    GraphicsList := TVectorGraphicsList.Create;

    Size := (SpinEditBands.Value+2) * (ComboBoxLineWidth.ItemIndex+1);
    PointA := Point(Size, Size);
    PointB := Point(BitmapForeground.Width  - Size,
                    BitmapForeground.Height - Size);

    // Create RoundRect node and add to image list                
    DrawingNode := TRoundRectangleNode.Create(ShapeLineColor.Brush.Color,
                                  TPenStyle(ComboBoxLineStyle.ItemIndex),
                                  ComboBoxLineWidth.ItemIndex+1 {PenWidth},
                                  PointA, PointB);

    DrawingNode.StandardizeOrder;
    GraphicsList.Add(DrawingNode);
    DrawingNode := NIL;
    GraphicsList.SetSelectedIndex(GraphicsList.Count - 1);
    DrawAllFigures (sfHighlightSelectedFigure);

    // Force update of background and mask
    UpdateFlagBackground := FALSE;
    UpdateFlagMask       := FALSE;
  END {UpdateForeground};
  

  // Create background bitmap based on RadioGroupBackground setting
  PROCEDURE TFormFeathering.UpdateBackground;
    VAR
      i:  Integer;
      j:  Integer;
  BEGIN
    IF   Assigned(BitmapBackground)
    THEN BitmapBackground.Free;

    BitmapBackground := TBitmap.Create;
    BitmapBackground.Width  := BitmapForeground.Width;
    BitmapBackground.Height := BitmapForeground.Height;
    BitmapBackground.PixelFormat := pf24bit;

    CASE RadioGroupBackground.ItemIndex OF

      // fill bitmap with solid color
      0:  BEGIN
            BitmapBackground.Canvas.Brush.Color := ShapeBackground.Brush.Color;
            BitmapBackground.Canvas.FillRect(BitmapBackground.Canvas.ClipRect)
          END;

      // tile bitmap
      1:  BEGIN
            j := 0;
            WHILE j < BitmapBackground.Height DO
            BEGIN
              i := 0;
              WHILE i < BitmapBackground.Width DO
              BEGIN
                BitmapBackground.Canvas.Draw(i,j, BitmapTile);
                INC(i, BitmapTile.Width)
              END;
              INC (j, BitmapTile.Height)
            END

          END
    END;

    ImageBackground.Picture.Graphic := BitmapBackground;

    // Draw the same list of figures as on Foreground, but do
    // not show any handles here since no interaction is
    // allowed on this tabsheet with the graphics figures.
    GraphicsList.DrawAllFigures (ImageBackground.Canvas);

    UpdateFlagBackground := TRUE
  END {UpdateBackground};


  PROCEDURE TFormFeathering.UpdateMask;
    VAR
      grey   :  INTEGER;
      i      :  INTEGER;
      j      :  INTEGER;
      k      :  INTEGER;
      Row    :  pRGBTripleArray;
      RowLast:  pRGBTripleArray;
      RowNext:  pRGBTRipleArray;
  BEGIN
    // This "IF" statement needed since processing is delayed until
    // absolutely necessary.
    IF   NOT UpdateFlagBackground
    THEN UpdateBackground;

    // Get rid of old result and prepare blank new bitmap.
    IF   Assigned(BitmapMask)
    THEN BitmapMask.Free;

    BitmapMask := TBitmap.Create;
    BitmapMask.Height := BitmapForeGround.Height;
    BitmapMask.Width  := BitmapBackground.Width;
    BitmapMask.PixelFormat := pf24bit;

    BitmapMask.Canvas.Brush.Color := clBlack;
    BitmapMask.Canvas.FillRect(BitmapMask.Canvas.ClipRect);

    // Draw several bands from black to white
    FOR k := 1 TO SpinEditBands.Value DO
    BEGIN
      grey := MulDiv(255, k, SpinEditBands.Value);  // last one is white
      BitmapMask.Canvas.Pen.Color   := RGB(grey, grey, grey);
      BitmapMask.Canvas.Brush.Color := BitmapMask.Canvas.Pen.Color;
      GraphicsList.DrawBandAround(BitmapMask.Canvas, SpinEditBands.Value-k);
    END;

    IF   CheckBoxBlur.Checked
    THEN BEGIN
      // skip first and last rows
      FOR j := 1 TO BitmapMask.Height-2 DO
      BEGIN
        RowLast := BitmapMask.Scanline[j-1];
        Row     := BitmapMask.Scanline[j];
        RowNext := BitmapMask.Scanline[j+1];
        // skip first and last columns
        FOR i := 1 TO BitmapMask.Width-2 DO
        BEGIN
          k := (RowLast[i-1].rgbtRed  + RowLast[i].rgbtRed + RowLast[i+1].rgbtRed +
                Row[i-1].rgbtRed      + Row[i].rgbtRed     + Row[i+1].rgbtRed     +
                RowNext[i-1].rgbtRed  + RowNext[i].rgbtRed + RowNext[i+1].rgbtRed) DIV 9;
          row[i].rgbtRed := k;

          k := (RowLast[i-1].rgbtGreen  + RowLast[i].rgbtGreen + RowLast[i+1].rgbtGreen +
                Row[i-1].rgbtGreen      + Row[i].rgbtGreen     + Row[i+1].rgbtGreen     +
                RowNext[i-1].rgbtGreen  + RowNext[i].rgbtGreen + RowNext[i+1].rgbtGreen) DIV 9;
          row[i].rgbtGreen := k;

          k := (RowLast[i-1].rgbtBlue  + RowLast[i].rgbtBlue + RowLast[i+1].rgbtBlue +
                Row[i-1].rgbtBlue      + Row[i].rgbtBlue     + Row[i+1].rgbtBlue     +
                RowNext[i-1].rgbtBlue  + RowNext[i].rgbtBlue + RowNext[i+1].rgbtBlue) DIV 9;
          row[i].rgbtBlue := k;
        END
      END

    END;

    IF   CheckBoxInvert.Checked
    THEN BEGIN
      FOR j := 0 TO BitmapMask.Height-1 DO
      BEGIN
        Row := BitmapMask.Scanline[j];
        FOR i := 0 TO BitmapMask.Width-1 DO
        BEGIN
          row[i].rgbtRed   := 255 - row[i].rgbtRed;
          row[i].rgbtGreen := 255 - row[i].rgbtGreen;
          row[i].rgbtBlue  := 255 - row[i].rgbtBlue
        END
      END
    END;

    ImageMask.Picture.Graphic := BitmapMask;

    UpdateFlagMask := TRUE;
  END {UpdateMask};


  PROCEDURE TFormFeathering.UpdateFeathering;
    VAR
      i            :  INTEGER;
      j            :  INTEGER;
      RowBackground:  pRGBTripleArray;
      RowFeathering:  pRGBTripleArray;
      RowForeground:  pRGBTripleArray;
      RowMask      :  pRGBTripleArray;
      weight       :  INTEGER;

  BEGIN
    // These "IF" statements needed since processing is delayed until
    // absolutely necessary.
    IF   NOT UpdateFlagBackground
    THEN UpdateBackground;
    IF   NOT UpdateFlagMask
    THEN UpdateMask;

    // Get rid of old result and prepare blank new bitmap.
    IF   Assigned(BitmapFeathering)
    THEN BitmapFeathering.Free;

    BitmapFeathering := TBitmap.Create;
    BitmapFeathering.Width  := BitmapForeground.Width;
    BitmapFeathering.Height := BitmapForeground.Height;
    BitmapFeathering.PixelFormat := pf24bit;

    FOR j := 0 TO BitmapForeground.Height - 1 DO
    BEGIN
      RowForeground := BitmapForeground.Scanline[j];
      RowBackground := BitmapBackground.Scanline[j];
      RowFeathering := BitmapFeathering.Scanline[j];
      RowMask       := BitmapMask.Scanline[j];

      // Normally "weight" is the same for all color planes
      FOR i := 0 TO BitmapForeground.Width - 1 DO
      BEGIN
        weight := RowMask[i].rgbtRed;
        RowFeathering[i].rgbtRed :=
          (weight      *RowForeground[i].rgbtRed +
           (255-weight)*RowBackground[i].rgbtRed) DIV 255;

        weight := RowMask[i].rgbtRed;
        RowFeathering[i].rgbtGreen :=
          (weight      *RowForeground[i].rgbtGreen +
           (255-weight)*RowBackground[i].rgbtGreen) DIV 255;

        weight := RowMask[i].rgbtRed;
        RowFeathering[i].rgbtBlue :=
          (weight      *RowForeground[i].rgbtBlue +
           (255-weight)*RowBackground[i].rgbtBlue) DIV 255;
      END
    END;

    ImageFeathering.Picture.Graphic := BitmapFeathering
  END {UpdateFeathering};


procedure TFormFeathering.FormCreate(Sender: TObject);
begin
  PageControl.ActivePage := TabSheetForeground;

{$IFDEF GIF}
  // This will add "GIF" to the list of valid graphics images
  OpenPictureDialog.Filter := GraphicFilter(TGraphic);
{$ENDIF}  

  OriginalImageWidth := ImageForeground.Width;
  OriginalImageHeight := ImageForeground.Height;

  ComboBoxLineWidth.ItemIndex := 0;   // thin
  ComboBoxLineStyle.ItemIndex := 2;   // dot

  BitmapTile := TBitmap.Create;
  BitmapTile.LoadFromResourceName(hInstance, 'PATTERN');

  BitmapForeground := TBitmap.Create;
  BitmapForeground.Width  := ImageForeground.Width;
  BitmapForeground.Height := ImageForeground.Height;
  BitmapForeground.PixelFormat := pf24bit;
  BitmapForeground.Canvas.Brush.Color := clBlue;
  BitmapForeground.Canvas.FillRect(BitmapForeground.Canvas.ClipRect);
  ImageForeground.Picture.Graphic := BitmapForeground;

  GraphicsList := TVectorGraphicsList.Create;

  DrawingTool := dtSelectTool;
  DrawingNode := NIL;
  DrawingState := dsNotDrawing;

  SelectedPenStyle := psDot;         // current drawing settings for new figure
  SelectedPenWidth := LineWidthThin;

  UpdateForeground;

  // Marching Ants
  MarchingAntsCounterStart := 128;
  TimerMarchingAnts.Interval := 100;
  TimerMarchingAnts.Enabled  := FALSE;

  MarchingAntsCanvas := TControlCanvas.Create;
  MarchingAntsCanvas.Control := TControl(TabsheetFeathering);
end;


procedure TFormFeathering.FormDestroy(Sender: TObject);
begin
  BitmapFeathering.Free;
  BitmapForeground.Free;
  BitmapBackground.Free;
  BitmapMask.Free;
  BitmapTile.Free;

  GraphicsList.Free;
  MarchingAntsCanvas.Free
end;


procedure TFormFeathering.ButtonReadForegroundFileClick(Sender: TObject);
  VAR
    Picture:  TPicture;
begin
  IF   OpenPictureDialog.Execute
  THEN BEGIN
    IF   Assigned(BitmapForeground)
    THEN BitmapForeground.Free;

    BitmapForeground := TBitmap.Create;

    // Use polymorphic TPicture to load any registered file type.
    Picture := TPicture.Create;
    TRY
      Picture.LoadFromFile(OpenPictureDialog.Filename);
      // Try converting picture to a bitmap
      TRY
        BitmapForeground.Assign(Picture.Graphic)
      EXCEPT
        // Draw picture on bitmap since conversion not supported
        BitmapForeground.Width  := Picture.Graphic.Width;
        BitmapForeground.Height := Picture.Graphic.Height;
        BitmapForeground.PixelFormat := pf24bit;
        BitmapForeground.Canvas.Draw(0,0, Picture.Graphic)
      END
    FINALLY
      Picture.Free
    END;

    // In case pf8bit bitmap (or other variations) are loaded
    IF   BitmapForeground.PixelFormat <> pf24bit
    THEN BitmapForeground.PixelFormat := pf24bit;

    UpdateForeground
  END;

  // Set focus here so keyboard controls deal with
  // moving figures that are drawn on image
  PageControl.SetFocus
end;


// See "Using the Clipboard with graphics" on pp. 7-20 - 7-22 of the
// Borland Delphi 5 Developer's Guide
procedure TFormFeathering.ButtonPasteForegroundFileClick(Sender: TObject);
begin
  IF   Clipboard.HasFormat(CF_BITMAP)
  THEN BEGIN
    IF   Assigned(BitmapForeground)
    THEN BitmapForeground.Free;

    BitmapForeground := TBitmap.Create;
    BitmapForeground.Assign(Clipboard);

    // In case pf8bit bitmap (or other variations) are loaded
    IF   BitmapForeground.PixelFormat <> pf24bit
    THEN BitmapForeground.PixelFormat := pf24bit;

    UpdateForeground
  END
  ELSE ShowMessage('There is no bitmap on the clipboard.');

  // Set focus here so keyboard controls deal with
  // moving figures that are drawn on image
  PageControl.SetFocus
end;


procedure TFormFeathering.RadioGroupBackgroundClick(Sender: TObject);
begin
  ShapeBackground.Visible               := (RadioGroupBackground.ItemIndex = 0);
  ButtonReadBackgroundTileFile.Visible  := (RadioGroupBackground.ItemIndex = 1);
  ButtonPasteBackgroundTileFile.Visible := (RadioGroupBackground.ItemIndex = 1);

  UpdateBackground;
  UpdateMask;
  UpdateFeathering
end;


procedure TFormFeathering.ShapeBackgroundMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  IF   ColorDialog.Execute
  THEN BEGIN
    ShapeBackground.Brush.Color := ColorDialog.Color;
    UpdateBackground;
    UpdateFeathering
  END
end;


procedure TFormFeathering.ButtonReadBackgroundTileFileClick(Sender: TObject);
  VAR
    Picture:  TPicture;
begin
  IF   OpenPictureDialog.Execute
  THEN BEGIN
    IF   Assigned(BitmapTile)
    THEN BitmapTile.Free;

    BitmapTile := TBitmap.Create;

    // Use polymorphic TPicture to load any registered file type.
    Picture := TPicture.Create;
    TRY
      Picture.LoadFromFile(OpenPictureDialog.Filename);
      // Try converting picture to a bitmap
      TRY
        BitmapTile.Assign(Picture.Graphic)
      EXCEPT
        // Draw picture on bitmap since conversion not supported
        BitmapTile.Width  := Picture.Graphic.Width;
        BitmapTile.Height := Picture.Graphic.Height;
        BitmapTile.PixelFormat := pf24bit;
        BitmapTile.Canvas.Draw(0,0, Picture.Graphic)
      END
    FINALLY
      Picture.Free
    END;

    UpdateBackground;
  END

end;


procedure TFormFeathering.ButtonPasteBackgroundTileFileClick(Sender: TObject);
begin
  IF   Clipboard.HasFormat(CF_BITMAP)
  THEN BEGIN
    IF   Assigned(BitmapTile)
    THEN BitmapTile.Free;

    BitmapTile := TBitmap.Create;
    BitmapTile.Assign(Clipboard);

    UpdateBackground;
  END
  ELSE ShowMessage('There is no bitmap on the clipboard.')
end;


procedure TFormFeathering.CheckBoxMaskChange(Sender: TObject);
begin
  UpdateMask;
  UpdateFeathering
end;


procedure TFormFeathering.SpeedButtonToolClick(Sender: TObject);
begin
  IF   Assigned(DrawingNode)
  THEN DrawingNode.Free;

  CASE (Sender AS TSpeedButton).Tag OF
    ORD(dtSelectTool):
      BEGIN
        DrawingTool := dtSelectTool;
        DrawingNode := NIL
      END;

    ORD(dtRectangleTool):
      BEGIN
        DrawingTool := dtRectangleTool;
        DrawingNode := TRectangleNode.Create(ShapeLineColor.Brush.Color,
                                  TPenStyle(ComboBoxLineStyle.ItemIndex),
                                  ComboBoxLineWidth.ItemIndex+1 {PenWidth},
                                  Point(-1,-1), Point(-1,-1)     );
      END;

   ORD(dtRoundRectangleTool):
      BEGIN
        DrawingTool := dtRectangleTool;
        DrawingNode := TRoundRectangleNode.Create(ShapeLineColor.Brush.Color,
                                  TPenStyle(ComboBoxLineStyle.ItemIndex),
                                  ComboBoxLineWidth.ItemIndex+1 {PenWidth},
                                  Point(-1,-1), Point(-1,-1)     );
      END;

   ORD(dtEllipseTool):
      BEGIN
        DrawingTool := dtRectangleTool;
        DrawingNode := TEllipseNode.Create(ShapeLineColor.Brush.Color,
                                  TPenStyle(ComboBoxLineStyle.ItemIndex),
                                  ComboBoxLineWidth.ItemIndex+1 {PenWidth},
                                  Point(-1,-1), Point(-1,-1)     );
      END;

    ELSE
      DrawingTool := dtNone;
      DrawingNode := NIL;
     
  END
end;


procedure TFormFeathering.SpeedButtonEraseClick(Sender: TObject);
begin
  GraphicsList.DeleteSelectedFigures;
  DrawAllFigures (sfHighlightSelectedFigure)
end;



// Step through list of Figures and re-draw them all.  Here's the high-level
// pseudocode:
//
//   1.  Draw bitmap background
//   2.  Draw all Lines or Rectangles
//   3.  Draw Measurement Lines
//   4.  Draw End Point Handles FOR Selected Figure(s)

PROCEDURE TFormFeathering.DrawAllFigures (CONST HighlightSelected:
                                          THighlightSelectedFigure);

  PROCEDURE DrawEndPointHandlesForSelectedFigures;
    VAR
      BrushColor   :  TColor;
      i            :  INTEGER;
      SelectedCount:  INTEGER;
      node         :  TVectorGraphicsNode;
  BEGIN
    // Go through list once to get selected count
    SelectedCount := GraphicsList.SelectedFigureCount;

    WITH ImageForeground.Canvas DO
    BEGIN
      Pen.Mode  := pmCopy;

      FOR i := 0 to GraphicsList.Count-1 DO
      BEGIN
        node := GraphicsList.Items[i];

        IF   node.Selected AND
             (HighlightSelected = sfHighlightSelectedFigure)
        THEN BEGIN
          IF   SelectedCount > 1
          THEN BrushColor := clHandleMultiple
          ELSE BrushColor := clHandleSingle;

          // Draw End Points for Line
          node.DrawHandles(ImageForeground.Canvas,
                           clBlack, BrushColor, HandleRadius);

        END
      END
    END;

    {one or more selectaable objects are present}
    SpeedButtonErase.Enabled  := (SelectedCount > 0);

    IF   SelectedCount = 0
    THEN GraphicsList.SetSelectedIndex(FigureNotSelected);

  END {DrawEndPointHandlesForSelectedFigures};

BEGIN
  ImageForeground.Picture.Assign(BitmapForeground);
  GraphicsList.DrawAllFigures (ImageForeground.Canvas);
  DrawEndPointHandlesForSelectedFigures
END {DrawAllFigures};


// ** MouseDown ************************************************************
// The first step to draw or move any graphics object is via a MouseDown event.

procedure TFormFeathering.ImageForegroundMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin {DrawingAreaMouseDown}
  DrawingState := dsNotDrawing;

  CASE button OF
    mbLeft:
      BEGIN
        CASE DrawingTool OF
          dtSelectTool:
            BEGIN
              // 1.  Trying to stretch corner of selected figure?
              DrawingHandle := GraphicsList.GetSelectedHandleAtPoint(X, Y);
              IF   DrawingHandle IN [dhAxAy, dhAxBy, dhBxBy, dhBxAy]
              THEN BEGIN
                DrawingNode := GraphicsList.GetSelectedNode;
                Screen.Cursor := crSizeAll;
                DrawingState := dsStretchCorner;
                RestrictCursorToDrawingArea(ImageForeground)
              END
              ELSE BEGIN
                // 2.  Trying to translate selected figure(s)?
                // Check first for existing set of selected figures.
                IF   GraphicsList.SelectedContainsPoint(Point(X,Y))
                THEN BEGIN
                  DrawingBasePoint := Point(X,Y);
                  RestrictCursorToDrawingArea(ImageForeground);                  
                  Screen.Cursor := crDrag;
                  DrawingState := dsTranslate
                END
                ELSE BEGIN
                  // 3.  Try to select an object.
                  // If nothing selected, try to find selected figure.
                  GraphicsList.SelectFigures(Shift, X,Y);
                  DrawAllFigures (sfHighlightSelectedFigure);

                  IF   GraphicsList.SelectedFigureCount > 0
                  THEN BEGIN
                    DrawingBasePoint := Point(X,Y);
                    RestrictCursorToDrawingArea(ImageForeground);
                    Screen.Cursor := crDrag;
                    DrawingState := dsTranslate
                  END
                END

              END

            END;

          dtRectangleTool:
            BEGIN
              DrawingState := dsNewFigure;

              RestrictCursorToDrawingArea(ImageForeground);
              Screen.Cursor := crCross;

              // Get ready to draw new line, including redrawing whole
              // diagram to remove "handles" from current seleced figure.

              SelectedPenWidth   := LineWidthThin;

              // Origin point anchor for drawing
              DrawingNode.PointA := Point(X,Y);

              // Move point is the current position, which is identical to the
              // origin point for now.
              DrawingNode.PointB := Point(X,Y);

              // Get rid of current selection boxes as part of feedback to user
              // that current selected figure is being superseded by the one being
              // drawn.
              DrawAllFigures (sfDoNotHighlightSelectedFigure);

              ImageForeground.Canvas.MoveTo (X,Y);

              // Emphasize origin endpoint "handle" of object being drawn.
              // (Don't use DrawingNode.DrawHandles since that will draw
              // all handles, and only origin handle is desired here.)
              DrawHandle(ImageForeground.Canvas,
                         DrawingNode.PointA,
                         clHandleOutline, clHandleSingle, HandleRadius)
            END;

        END
      END;

    mbRight:
      BEGIN
         // do nothing for now with right mouse events
      END;

    mbMiddle:
      BEGIN
        // do nothing for now with middle mouse events
      END

  END
end;


// ** MouseMove ************************************************************


procedure TFormFeathering.ImageForegroundMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);

  VAR
    NewPoint       :  TPoint;
    TranslateVector:  TPoint;

BEGIN {MouseMove}
  CASE DrawingState OF
    dsNewFigure:
      BEGIN
        IF   SquareContainsPoint(DrawingNode.PointA,
                                 HandleRadius,  Point(X,Y))
        THEN Screen.Cursor := crHandPoint
        ELSE Screen.Cursor := crCross;

        ImageForeground.Canvas.Brush.Style := bsClear;

        // XOR to remove old figure
        ImageForeground.Canvas.Pen.Style := SelectedPenStyle;
        ImageForeground.Canvas.Pen.Mode := pmNotXOR;
        ImageForeground.Canvas.Pen.Color := RubberBandColor;
        ImageForeground.Canvas.Pen.Width := SelectedPenWidth;
        DrawingNode.DrawFigure (ImageForeground.Canvas);

        // draw figure at new position
        DrawingNode.PointB := Point(X,Y);
        DrawingNode.DrawFigure (ImageForeground.Canvas);

        ImageForeground.Canvas.Pen.Mode := pmCopy
      END;

    dsStretchCorner:
      BEGIN
        ImageForeground.Canvas.Brush.Style := bsClear;

        // XOR to remove old figure
        ImageForeground.Canvas.Pen.Style := SelectedPenStyle;
        ImageForeground.Canvas.Pen.Mode := pmNotXOR;
        ImageForeground.Canvas.Pen.Color := RubberBandColor;
        ImageForeground.Canvas.Pen.Width := SelectedPenWidth;
        DrawingNode.DrawFigure (ImageForeground.Canvas);

        // draw figure at new position
        CASE DrawingHandle OF
          dhAxAy:  DrawingNode.PointA := Point(X,Y);
          dhBxBy:  DrawingNode.PointB := Point(X,Y);

          dhAxBy:  BEGIN
                     DrawingNode.PointA :=
                       Point(X, DrawingNode.PointA.Y);
                     DrawingNode.PointB :=
                       Point(DrawingNode.PointB.X, Y)
                   END;

          dhBxAy:  BEGIN
                     DrawingNode.PointB :=
                       Point(X, DrawingNode.PointB.Y);
                     DrawingNode.PointA :=
                       Point(DrawingNode.PointA.X, Y)
                   END
        END;
        DrawingNode.DrawFigure (ImageForeground.Canvas);
      END;

    dsTranslate:
      BEGIN
        ImageForeground.Canvas.Brush.Style := bsClear;

        // XOR to remove old figure
        ImageForeground.Canvas.Pen.Style := SelectedPenStyle;
        ImageForeground.Canvas.Pen.Mode := pmNotXOR;
        ImageForeground.Canvas.Pen.Color := RubberBandColor;
        ImageForeground.Canvas.Pen.Width := SelectedPenWidth;
        GraphicsList.DrawSelectedFigures(ImageForeground.Canvas);

        // draw figure at new position
        NewPoint := Point(X,Y);
        TranslateVector := SubtractPoints(NewPoint, DrawingBasePoint);
        GraphicsList.TranslateSelectedFigures(TranslateVector);
        GraphicsList.DrawSelectedFigures(ImageForeground.Canvas);

        DrawingBasePoint := NewPoint;
        ImageForeground.Canvas.Pen.Mode := pmCopy
      END

    ELSE

      // Show sensitivity to handles of selected object
      IF  GraphicsList.GetSelectedHandleAtPoint(X, Y) = dhNone
      THEN Screen.Cursor := crDefault
      ELSE Screen.Cursor := crSizeAll
  END

end;


// ** MouseDown ************************************************************

procedure TFormFeathering.ImageForegroundMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);

  VAR
    FigureOK  :  BOOLEAN;

BEGIN
  CASE DrawingState OF
    dsNewFigure:
      BEGIN
        RemoveCursorRestrictions;
        Screen.Cursor := crDefault;

        FigureOK :=  (ABS(DrawingNode.PointA.X - DrawingNode.PointB.X) +
                      ABS(DrawingNode.PointA.Y - DrawingNode.PointB.Y) >
                      HandleMinimumPixels);

        IF   FigureOK
        THEN BEGIN
          DrawingNode.PointB := Point(X,Y);
          GraphicsList.SetSelectedFlags (FALSE);

          DrawingNode.StandardizeOrder;
          GraphicsList.Add(DrawingNode);

          DrawingNode := NIL;
          DrawingTool := dtSelectTool;
          SpeedButtonSelect.Down := TRUE;

          GraphicsList.SetSelectedIndex(GraphicsList.Count - 1)
        END;

        // Re-draw to show new figure
        DrawAllFigures (sfHighlightSelectedFigure)
      END;

    dsStretchCorner, dsTranslate:
      BEGIN
        RemoveCursorRestrictions;
        Screen.Cursor := crDefault;
        GraphicsList.GetSelectedNode.StandardizeOrder;
        DrawingNode := NIL;
        DrawAllFigures (sfHighlightSelectedFigure)
      END

  END;

  // Force update of background and mask
  UpdateFlagBackground := FALSE;
  UpdateFlagMask := FALSE;

  DrawingState := dsNotDrawing
end;


procedure TFormFeathering.ShapeLineColorMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  IF   ColorDialog.Execute
  THEN ShapeLineColor.Brush.Color := ColorDialog.Color;

  // Update Drawing Node if drawing tool currently selected
  IF   SpeedButtonRectangle.Down OR SpeedButtonRoundRect.Down OR
       SpeedButtonEllipse.Down
  THEN DrawingNode.PenColor := ColorDialog.Color
end;

// The default pens in Delphi are "Cosmetic" and look awful when drawing
// short lines because of the rounded tips.  This example shows how to
// create a "Geometric" pen with square ends.
procedure TFormFeathering.ComboBoxLineWidthDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
 VAR
    BrushInfo:  TLogBrush;
    i1       :  INTEGER;
    i2       :  INTEGER;
begin
  WITH BrushInfo DO
  BEGIN
    lbStyle := BS_SOLID;
    lbColor := clBlack;
    lbHatch := 0
  END;

  (Control AS TComboBox).Canvas.Pen.Handle :=
    ExtCreatePen(PS_GEOMETRIC OR PS_ENDCAP_SQUARE OR PS_JOIN_MITER,
                 index+1,
                 BrushInfo, 0, NIL);

   WITH (Control AS TComboBox).Canvas DO
   BEGIN
     i1 := MulDiv(rect.Left + rect.Right, 1, 5);
     i2 := MulDiv(rect.Left + rect.Right, 4, 5);

     MoveTo(i1,  (rect.Top + rect.Bottom) DIV 2);
     LineTo(i2, (rect.Top + rect.Bottom) DIV 2)
   END
end;


// The default pens in Delphi are "Cosmetic" and look awful when drawing
// short lines because of the rounded tips.  This example shows how to
// create a "Geometric" pen with square ends.
procedure TFormFeathering.ComboBoxLineStyleDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
VAR
    BrushInfo:  TLogBrush;
    i1       :  INTEGER;
    i2       :  INTEGER;
    PenStyle :  DWORD;
begin
  WITH BrushInfo DO
  BEGIN
    lbStyle := BS_SOLID;
    lbColor := clBlack;
    lbHatch := 0
  END;

  PenStyle := PS_GEOMETRIC OR PS_ENDCAP_SQUARE OR PS_JOIN_MITER;

  CASE index OF
    0: PenStyle := PenStyle + PS_SOLID;
    1: PenStyle := PenStyle + PS_DASH;
    2: PenStyle := PenStyle + PS_DOT;
    3: PenStyle := PenStyle + PS_DASHDOT;
    4: PenStyle := PenStyle + PS_DASHDOTDOT;
  END;


  (Control AS TComboBox).Canvas.Pen.Handle :=
    ExtCreatePen(PenStyle,
                 3,
                 BrushInfo, 0, NIL);

  WITH (Control AS TComboBox).Canvas DO
  BEGIN
    i1 := MulDiv(rect.Left + rect.Right, 1, 5);
    i2 := MulDiv(rect.Left + rect.Right, 4, 5);

    MoveTo(i1,  (rect.Top + rect.Bottom) DIV 2);
    LineTo(i2, (rect.Top + rect.Bottom) DIV 2)
  END

end;

procedure TFormFeathering.ComboBoxLineWidthChange(Sender: TObject);
  VAR
    Bands:  INTEGER;
begin
  ComboBoxLineStyle.Visible := (ComboBoxLineWidth.ItemIndex = 0);
  LabelLineStyle.Visible := ComboBoxLineStyle.Visible;

  IF   NOT ComboBoxLineStyle.Visible
  THEN ComboBoxLineStyle.ItemIndex := 0; 

  // Update Drawing Node if drawing tool currently selected
  IF   SpeedButtonRectangle.Down OR SpeedButtonRoundRect.Down OR
       SpeedButtonEllipse.Down
  THEN BEGIN
    DrawingNode.PenWidth := ComboBoxLineWidth.ItemIndex + 1;

    Bands := 16 DIV DrawingNode.PenWidth;
    IF   Bands < 4
    THEN Bands := 4;
    SpinEditBands.Value := Bands
  END
end;


procedure TFormFeathering.ComboBoxLineStyleChange(Sender: TObject);
begin
  // Update Drawing Node if drawing tool currently selected
  IF   SpeedButtonRectangle.Down OR SpeedButtonRoundRect.Down OR
       SpeedButtonEllipse.Down
  THEN DrawingNode.PenStyle := TPenStyle(ComboBoxLineStyle.ItemIndex)
end;


// The form's KeyPreview must be set to TRUE for this to work.
procedure TFormFeathering.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

  VAR
    TranslateVector:  TPoint;  // "translate" vector to move selected objects
begin
  IF  PageControl.ActivePage = TabSheetForeground
  THEN BEGIN

    // We only care about keystrokes when figure(s) are selected.
    IF  GraphicsList.SelectedFigureCount > 0
    THEN BEGIN
      // Simulte clicking erase button when delete key is pressed
      IF   key = VK_DELETE
      THEN SpeedButtonEraseClick(Sender)
      ELSE BEGIN
        // Use Ctrl-shift keys to translate objects, just like Delphi's IDE
        IF   (ssCtrl IN Shift) AND
             (key IN [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN])
        THEN BEGIN
          CASE key OF
            VK_LEFT:   TranslateVector := Point(-1, 0);
            VK_RIGHT:  TranslateVector := Point( 1, 0);
            VK_UP:     TranslateVector := Point( 0,-1);
            VK_DOWN:   TranslateVector := Point( 0, 1)
          END;
          GraphicsList.TranslateSelectedFigures(TranslateVector);
          DrawAllFigures(sfHighlightSelectedFigure);
          // Make sure other controls don't see this key
          key := 0
        END
      END
    END;

    // Use arrow keys (left, right, up, down) to change selected figure
    IF   (Shift = []) AND
         (key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN])
    THEN BEGIN
      CASE key OF
        VK_UP,   VK_RIGHT:  GraphicsList.SelectedFigureIncrementIndex(+1);
        VK_DOWN, VK_LEFT :  GraphicsList.SelectedFigureIncrementIndex(-1)
      END;
      DrawAllFigures(sfHighlightSelectedFigure);
      // Make sure other controls don't see this key
      key := 0
    END

  END;


  IF  PageControl.ActivePage = TabSheetFeathering
  THEN BEGIN
    TimerMarchingAnts.Enabled := FALSE;
    RemoveMarchingAnts;

    IF   (Shift = []) AND
         (key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN])
    THEN BEGIN
      CASE key OF
        VK_UP   :  BEGIN
                     DEC(MarchingAntsPointA.Y);
                     DEC(MarchingAntsPointB.Y)
                   END;

        VK_RIGHT:  BEGIN
                     INC(MarchingAntsPointA.X);
                     INC(MarchingAntsPointB.X)
                   END;

        VK_DOWN :  BEGIN
                     INC(MarchingAntsPointA.Y);
                     INC(MarchingAntsPointB.Y)
                   END;

        VK_LEFT :  BEGIN
                     DEC(MarchingAntsPointA.X);
                     DEC(MarchingAntsPointB.X)
                   END
      END;
    END;

    TimerMarchingAnts.Enabled := TRUE;
  END

end;


// Delay processing until TabSheet is displayed.
procedure TFormFeathering.PageControlChange(Sender: TObject);
begin
  IF   PageControl.ActivePage = TabSheetBackground
  THEN UpdateBackground;

  IF   PageControl.ActivePage = TabSheetMask
  THEN UpdateMask;

  IF   PageControl.ActivePage = TabSheetFeathering
  THEN UpdateFeathering;

  TimerMarchingAnts.Enabled := (PageControl.ActivePage = TabSheetFeathering)
end;


procedure TFormFeathering.SpinEditBandsChange(Sender: TObject);
begin
  UpdateMask
end;


// Support BMPs and JPGs for now.  It's too bad the SavePictureDialog
// is so limited and doesn't support the "More" option often used to
// specify parameters such as Compression Quality for a JPG.
procedure TFormFeathering.ButtonSaveFileClick(Sender: TObject);
  VAR
    FormJPEGQuality:  TFormJPEGQuality;
    JPEGImage      :  TJPEGImage;
begin
  IF   SavePictureDialog.Execute
  THEN BEGIN
    IF   UpperCase(ExtractFileExt(SavePictureDialog.Filename)) = '.BMP'
    THEN BitmapFeathering.SaveToFile(SavePictureDialog.Filename);

    // Convert TBitmap to TJPEGImage
    IF   UpperCase(ExtractFileExt(SavePictureDialog.Filename)) = '.JPG'
    THEN BEGIN
      FormJPEGQuality := TFormJPEGQuality.Create(NIL);
      TRY
        FormJPEGQuality.ShowModal;
        IF   FormJPEGQuality.ModalResult = mrOK
        THEN BEGIN

          JPEGImage := TJPEGImage.Create;
          TRY
            JPEGImage.CompressionQuality := FormJPEGQuality.SpinEditQuality.Value;
            JPEGImage.Assign(BitmapFeathering);
            JPEGImage.SaveToFile(SavePictureDialog.Filename)
          FINALLY
            JPEGImage.Free
          END

        END
      FINALLY
        FormJPEGQuality.Free
      END

    END;
  END
end;

procedure TFormFeathering.ButtonCopyToClipboardClick(Sender: TObject);
  VAR
    A     :  TPoint;
    B     :  TPoint;
    Bitmap:  TBitmap;
begin
  IF   (MarchingAntsPointA.X = MarchingAntsPointB.X) AND
       (MarchingAntsPointA.Y = MarchingAntsPointB.Y)
  THEN Clipboard.Assign(BitmapFeathering) // whole bitmap to clipboard
  ELSE BEGIN
    Bitmap := TBitmap.Create;
    TRY
      A := TabSheetFeathering.ClientToScreen(MarchingAntsPointA);
      B := TabSheetFeathering.ClientToScreen(MarchingAntsPointB);

      A := ImageFeathering.ScreenToClient(A);
      B := ImageFeathering.ScreenToClient(B);

      Bitmap.Width  := ABS(A.X - B.X) + 1;
      Bitmap.Height := ABS(A.Y - B.Y) + 1;
      Bitmap.PixelFormat := pf24bit;

      Bitmap.Canvas.CopyRect(
           Rect(0,0, Bitmap.Width-1, Bitmap.Height-1),
           BitmapFeathering.Canvas,
           Rect(A.X, A.Y, B.X, B.Y) );

      Clipboard.Assign(Bitmap)
    FINALLY
      Bitmap.Free
    END
  END
end;


////////////////////////////////////////////////////////////////////////////

// See "How to Draw Marching Ants"
// Robert Vivrette, www.undu.co/DN960901/00000008.htm
//
// Shown here is how to put marching ants on a TImage that is on a
// TTabsheet.


  PROCEDURE MarchingAnts(X,Y: Integer; Canvas: TCanvas); stdcall;
  BEGIN
    MarchingAntsCounter := MarchingAntsCounter SHL 1; // Shift one bit left
    IF   MarchingAntsCounter = 0
    THEN MarchingAntsCounter := 1;
    IF   (MarchingAntsCounter AND $E0) > 0  // Any of the left 3 bits set?
    THEN Canvas.Pixels[X,Y] := clWhite      // Erase the pixel
    ELSE Canvas.Pixels[X,Y] := clBlack;     // Draw the pixel
  end {MovingDots};


  FUNCTION NormalizeRect(CONST Rectangle: TRect): TRect;
  BEGIN
    // This routine normalizes a rectangle by making sure that the (Left, Top)
    // coordinates are always above and to the left of the (Bottom, Right)
    // coordiantes.
    WITH Rectangle DO
    BEGIN
      IF   Left > Right
      THEN
        IF   Top > Bottom
        THEN Result := Rect(Right,Bottom,Left,Top)
        ELSE Result := Rect(Right,Top,Left,Bottom)
      ELSE
        IF   Top > Bottom
        THEN Result := Rect(Left,Bottom,Right,Top)
        ELSE Result := Rect(Left,Top,Right,Bottom)
    END
  END {NormalizeRect};


procedure TFormFeathering.DrawMarchingAnts;
begin
  MarchingAntsCounter := MarchingAntsCounterStart;

  // Use LineDDA to draw each of the 4 edges of the rectangle
  LineDDA(MarchingAntsPointA.X, MarchingAntsPointA.Y,
          MarchingAntsPointB.X, MarchingAntsPointA.Y,
          @MarchingAnts, LongInt(MarchingAntsCanvas));

  LineDDA(MarchingAntsPointB.X, MarchingAntsPointA.Y,
          MarchingAntsPointB.X, MarchingAntsPointB.Y,
          @MarchingAnts, LongInt(MarchingAntsCanvas));

  LineDDA(MarchingAntsPointB.X, MarchingAntsPointB.Y,
          MarchingAntsPointA.X, MarchingAntsPointB.Y,
          @MarchingAnts, LongInt(MarchingAntsCanvas));

  LineDDA(MarchingAntsPointA.X, MarchingAntsPointB.Y,
          MarchingAntsPointA.X, MarchingAntsPointA.Y,
          @MarchingAnts, LongInt(MarchingAntsCanvas));
end;


procedure TFormFeathering.RemoveMarchingAnts;
var
  R:  TRect;
begin
  R := NormalizeRect(Rect(MarchingAntsPointA.X, MarchingAntsPointA.Y,
                          MarchingAntsPointB.X, MarchingAntsPointB.Y));
  InflateRect(R,1,1);                // Make the rectangle 1 pixel larger
  InvalidateRect(TabsheetFeathering.Handle, @R, TRUE); // Mark as invalid
  InflateRect(R, -2, -2);            // Now shrink the rectangle 2 pixels
  ValidateRect(TabsheetFeathering.Handle, @R);         // Validate new rectangle
  // This leaves a 2 pixel band all the way around
  // the rectangle that will be erased and redrawn
  UpdateWindow(TabsheetFeathering.Handle);
end;


procedure TFormFeathering.ImageFeatheringMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  X := X + (Sender AS TImage).Left;
  Y := Y + (Sender AS TImage).Top;

  RemoveMarchingAnts;
  MarchingAntsPointA.X := X;
  MarchingAntsPointA.Y := Y;

  MarchingAntsPointB.X := X;
  MarchingAntsPointB.Y := Y;

  // Force mouse movement to stay within TImage
  RestrictCursorToDrawingArea( (Sender AS TImage) )
end;


procedure TFormFeathering.ImageFeatheringMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  IF   ssLeft IN Shift
  THEN BEGIN
    X := X + (Sender AS TImage).Left;
    Y := Y + (Sender AS TImage).top;

    RemoveMarchingAnts;
    MarchingAntsPointB.X := X;
    MarchingAntsPointB.Y := Y;   // Save the new corner where the mouse is
    DrawMarchingAnts
  END
end;


procedure TFormFeathering.ImageFeatheringMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  // If rectangle is too small, set both points to be the same.  This point
  // will not be displayed and the whole image will be copied to the clipboard.
  IF   (ABS(MarchingAntsPointA.X - MarchingAntsPointB.X) < HandleMinimumPixels) AND
       (ABS(MarchingAntsPointA.X - MarchingAntsPointB.X) < HandleMinimumPixels)
  THEN BEGIN
    RemoveMarchingAnts;
    MarchingAntsPointB := MarchingAntsPointA
  END;

  RemoveCursorRestrictions
end;


procedure TFormFeathering.TimerMarchingAntsTimer(Sender: TObject);
begin
  // Use SHR 1 for slower moving ants
  MarchingAntsCounterStart := MarchingAntsCounterStart SHR 2;
  IF   MarchingAntsCounterStart = 0
  THEN MarchingAntsCounterStart := 128;
  DrawMarchingAnts
end;


procedure TFormFeathering.LabelLab2Click(Sender: TObject);
begin
  ShellExecute(0, 'open', pchar('http://www.efg2.com/lab'),
               NIL, NIL, SW_NORMAL)
end;

end.

