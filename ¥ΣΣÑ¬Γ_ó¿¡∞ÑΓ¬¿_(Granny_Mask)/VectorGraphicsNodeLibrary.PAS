// VectorGraphicsNodeLibrary defines a variety of vector objects needed
// for this application.   These nodes are usually stored in a
// TVectorGraphicsList object.
//
// efg, December 2000
// www.efg2.com/Lab

UNIT VectorGraphicsNodeLibrary;

INTERFACE

  USES
    Graphics,   // TColor
    WinTypes,   // TPoint
    Classes;    // TList

  CONST
    HandleRadius:  INTEGER  =  4;  // End point rectangle for selected figures

  TYPE
    // The Drawing Tool type is used in two ways:  (1) to define the current
    // drawing mode, and (2) to define the "tool" needed to draw a figure.
    TDrawingTool  = (dtNone, dtSelectTool,
                     dtRectangleTool, dtRoundRectangleTool, dtEllipseTool);

    // Type of end point "handles" for selected figures
    TDrawingHandle  = (dhNone,
                       dhAxAy, dhBxBy, dhAxBy, dhBxAy);

    // Could use BOOLEAN instead of the following type, but the following are
    // more descriptive
    THighLightSelectedFigure = (sfHighlightSelectedFigure,
                                sfDoNotHighlightSelectedFigure);


    /////////////////////////////////////////////////////////////////////////

    // Each node in TVectorGraphicsList has a base class of TVectorGraphicsNode
    TVectorGraphicsNode =
    CLASS(TObject)
      PROTECTED
        FHandleRadius:  INTEGER;

        FPenColor    :  TColor;
        FPenStyle    :  TPenStyle;
        FPenWidth    :  INTEGER;

        FPointA      :  TPoint;
        FPointB      :  TPoint;

        // Normally, the selected item is flagged TRUE.  When multiple
        // selections are allowed, more than one node can be flagged as
        // selected, however.
        FSelected   :  BOOLEAN;

      PUBLIC
        PROCEDURE DrawFigure (CONST Canvas:  TCanvas;
                              CONST Factor:  INTEGER = 0);      VIRTUAL; ABSTRACT;


        PROCEDURE Translate  (CONST TranslateVector:  TPoint);  VIRTUAL; ABSTRACT;

        PROCEDURE DrawHandles( CONST Canvas    :  TCanvas;
                               CONST PenColor  :  TColor;
                               CONST BrushColor:  TColor;
                               CONST Radius    :  INTEGER);   VIRTUAL; ABSTRACT;

        FUNCTION  GetHandleAtPoint(CONST x, y  :  INTEGER;
                                   CONST Radius:  INTEGER):  TDrawingHandle;
                                                              VIRTUAL; ABSTRACT;
        PROCEDURE StandardizeOrder;

        PROPERTY  PenColor   :  TColor        READ FPenColor    WRITE FPenColor;
        PROPERTY  PenStyle   :  TPenStyle     READ FPenStyle    WRITE FPenStyle;
        PROPERTY  PenWidth   :  INTEGER       READ FPenWidth    WRITE FPenWidth;

        PROPERTY  PointA     :  TPoint        READ FPointA      WRITE FPointA;
        PROPERTY  PointB     :  TPoint        READ FPointB      WRITE FPointB;

        PROPERTY  Selected   :  BOOLEAN       READ FSelected    WRITE FSelected;
    END;


    /////////////////////////////////////////////////////////////////////////

    TBoundingRectangle =
    CLASS(TVectorGraphicsNode)
      PROTECTED
        // nothing new

      PUBLIC
        CONSTRUCTOR Create (CONST PenColor       :  TColor;
                            CONST PenStyle       :  TPenStyle;
                            CONST PenWidth       :  INTEGER;
                            CONST PointA,PointB  :  TPoint);

        PROCEDURE Translate(CONST TranslateVector:  TPoint);  OVERRIDE;

        PROCEDURE DrawHandles(CONST Canvas    :  TCanvas;
                              CONST PenColor  :  TColor;
                              CONST BrushColor:  TColor;
                              CONST Radius    :  INTEGER);    OVERRIDE;

        FUNCTION  GetHandleAtPoint(CONST x, y  :  INTEGER;
                                   CONST Radius:  INTEGER):  TDrawingHandle;
                                                              OVERRIDE;
        FUNCTION ContainsPoint(CONST TestPoint:  TPoint):  BOOLEAN;

    END;


    /////////////////////////////////////////////////////////////////////////

    TRectangleNode =
    CLASS(TBoundingRectangle)
      PUBLIC
        PROCEDURE DrawFigure (CONST Canvas:  TCanvas;
                              CONST Factor:  INTEGER);  OVERRIDE;
    END;


    TRoundRectangleNode =
    CLASS(TBoundingRectangle)
      PUBLIC
        PROCEDURE DrawFigure (CONST Canvas:  TCanvas;
                              CONST Factor:  INTEGER);  OVERRIDE;
    END;


    TEllipseNode =
    CLASS(TBoundingRectangle)
      PUBLIC
        PROCEDURE DrawFigure (CONST Canvas:  TCanvas;
                              CONST Factor:  INTEGER);  OVERRIDE;
    END;


    /////////////////////////////////////////////////////////////////////////


IMPLEMENTATION

  USES
    Windows,      // PtInRect
    Math,         // MinIntValue
    LineLibrary;  // AddPoints, SubtractPoints, SquareContainsPoint, DrawEndPoint


  /////////////////////////////////////////////////////////////////////////

  // Make sure FPointA is at the upper left and FPointB is at the lower right
  PROCEDURE TVectorGraphicsNode.StandardizeOrder;
    VAR
      TempA:  TPoint;
      TempB:  TPoint;
  BEGIN
    TempA := FPointA;
    TempB := FPointB;

    // FPointA is at the upper left
    FPointA.X := MinIntValue([TempA.X, TempB.X]);
    FPointA.Y := MinIntValue([TempA.Y, TempB.Y]);

    // FPointB is at the lower right
    FPointB.X := MaxIntValue([TempA.X, TempB.X]);
    FPointB.Y := MaxIntValue([TempA.Y, TempB.Y])
  END {StandardizeOrder};


  /////////////////////////////////////////////////////////////////////////

  CONSTRUCTOR TBoundingRectangle.Create (CONST PenColor       :  TColor;
                                         CONST PenStyle       :  TPenStyle;
                                         CONST PenWidth       :  INTEGER;
                                         CONST PointA,PointB  :  TPoint);

  BEGIN
    INHERITED Create;

    // Assign values for new node in TList
    FPenColor    := PenColor;
    FPenStyle    := PenStyle;
    FPenWidth    := PenWidth;

    FPointA      := PointA;
    FPointB      := PointB;

    // Do not automatically select each figure as it is created.
    FSelected    := FALSE
  END {Create};


  PROCEDURE TBoundingRectangle.Translate(CONST TranslateVector:  TPoint);
  BEGIN
    FPointA := AddPoints(FPointA, TranslateVector);
    FPointB := AddPoints(FPointB, TranslateVector)
  END {Translate};


  PROCEDURE TBoundingRectangle.DrawHandles(CONST Canvas    :  TCanvas;
                                           CONST PenColor  :  TColor;
                                           CONST BrushColor:  TColor;
                                           CONST Radius    :  INTEGER);
  BEGIN
    DrawHandle (Canvas, FPointA, PenColor, BrushColor, Radius);
    DrawHandle (Canvas, FPointB, PenColor, BrushColor, Radius);

    DrawHandle (Canvas, Point(FPointA.X, FPointB.Y),
                PenColor, BrushColor, Radius);
    DrawHandle (Canvas, Point(FPointB.X, FPointA.Y),
                PenColor, BrushColor, Radius);
  END {DrawHandles};


  FUNCTION  TBoundingRectangle.GetHandleAtPoint(CONST x, y:  INTEGER;
                                                CONST Radius:  INTEGER):  TDrawingHandle;
  BEGIN
    IF   SquareContainsPoint(FPointA, Radius, Point(X,Y))
    THEN RESULT := dhAxAy
    ELSE
      IF   SquareContainsPoint(FPointB, Radius, Point(X,Y))
      THEN RESULT := dhBxBy
      ELSE
        IF   SquareContainsPoint(Point(FPointA.X, FPointB.Y),
                                 Radius, Point(X,Y))
        THEN RESULT := dhAxBy
        ELSE
          IF   SquareContainsPoint(Point(FPointB.X, FPointA.Y),
                                   Radius, Point(X,Y))
          THEN RESULT := dhBxAy
          ELSE RESULT := dhNone
  END {GetHandleAtPoint};


  FUNCTION TBoundingRectangle.ContainsPoint(CONST TestPoint:  TPoint):  BOOLEAN;
  BEGIN
    RESULT := Windows.PtInRect(Rect(FPointA.X,
                                    FPointA.Y,
                                    FPointB.X,
                                    FPointB.Y),
                               TestPoint)
  END {ContainsPoint};


  /////////////////////////////////////////////////////////////////////////

  FUNCTION Sign(CONST i:  INTEGER):  INTEGER;
  BEGIN
    IF   i = 0
    THEN RESULT := 0
    ELSE
      IF   i > 0
      THEN RESULT := +1
      ELSE RESULT := -1
  END {Sign};


  FUNCTION UnitDelta(CONST PointA, PointB:  TPoint):  TPoint;
  BEGIN
    RESULT := Point( Sign(PointB.X - PointA.X),
                     Sign(PointB.Y - PointA.Y) )
  END;

  /////////////////////////////////////////////////////////////////////////

  PROCEDURE TRectangleNode.DrawFigure (CONST Canvas:  TCanvas;
                                       CONST Factor:  INTEGER);
    VAR
      Delta:  TPoint;
  BEGIN
    IF   Factor = 0
    THEN Canvas.Rectangle (FPointA.X, FPointA.Y, FPointB.X, FPointB.Y)
    ELSE BEGIN
      Delta := UnitDelta(FPointA, FPointB);
      Canvas.Rectangle (FPointA.X - Factor*FPenWidth*Delta.X,
                        FPointA.Y - Factor*FPenWidth*Delta.Y,
                        FPointB.X + Factor*FPenWidth*Delta.X,
                        FPointB.Y + Factor*FPenWidth*Delta.Y)

    END
  END {DrawFigure};


  PROCEDURE TRoundRectangleNode.DrawFigure (CONST Canvas:  TCanvas;
                                            CONST Factor:  INTEGER);
    VAR
      Delta:  TPoint;
  BEGIN
    IF   Factor = 0
    THEN Canvas.RoundRect(FPointA.X, FPointA.Y, FPointB.X, FPointB.Y, 50,50)
    ELSE BEGIN
      Delta := UnitDelta(FPointA, FPointB);
      Canvas.RoundRect(FPointA.X - Factor*FPenWidth*Delta.X,
                       FPointA.Y - Factor*FPenWidth*Delta.Y,
                       FPointB.X + Factor*FPenWidth*Delta.X,
                       FPointB.Y + Factor*FPenWidth*Delta.Y, 50,50)

    END
  END {DrawFigure};


  PROCEDURE TEllipseNode.DrawFigure (CONST Canvas:  TCanvas;
                                     CONST Factor:  INTEGER);
    VAR
      Delta:  TPoint;
  BEGIN
    IF   Factor = 0
    THEN Canvas.Ellipse (FPointA.X, FPointA.Y, FPointB.X, FPointB.Y)
    ELSE BEGIN
      Delta := UnitDelta(FPointA, FPointB);
      Canvas.Ellipse (FPointA.X - Factor*FPenWidth*Delta.X,
                      FPointA.Y - Factor*FPenWidth*Delta.Y,
                      FPointB.X + Factor*FPenWidth*Delta.X,
                      FPointB.Y + Factor*FPenWidth*Delta.Y)

    END
  END {DrawFigure};


  /////////////////////////////////////////////////////////////////////////


END.
