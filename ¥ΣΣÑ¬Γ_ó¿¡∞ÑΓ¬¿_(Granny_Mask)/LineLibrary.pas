// Library for manipulating line via user interface
// efg, August 1998.  Revised December 2000.
// www.efg2.com/lab2

UNIT LineLibrary;

INTERFACE

  USES
    Windows,   // TPoint, ClipCursor
    Graphics,  // TCanvas
    ExtCtrls;  // TImage

  TYPE
    TLineSelected     = (lsNotSelected, lsPoint1, lsPoint2, lsLine);

    // TLineOrientation is used as part of the heuristic algorithm that decides
    // if a line is selected
    TLineOrientation  = (loPoint, loHorizontal, loVertical);

  FUNCTION AddPoints(CONST PointA, PointB:  TPoint):  TPoint;
  FUNCTION SubtractPoints(CONST PointA, PointB:  TPoint):  TPoint;

  PROCEDURE CalcLineParameters (CONST PointA, PointB  :  TPoint;
                                VAR   Slope, Intercept:  DOUBLE;
                                VAR   LineOrientation :  TLineOrientation);
  FUNCTION NearLine(CONST Target, Point1, Point2:  TPoint):  BOOLEAN;


  PROCEDURE RestrictCursorToDrawingArea (CONST Image:  TImage);
  PROCEDURE RemoveCursorRestrictions;


  PROCEDURE DrawHandle  (CONST Canvas    :  TCanvas;
                         CONST Point     :  TPoint;
                         CONST PenColor  :  TColor;
                         CONST BrushColor:  TColor;
                         CONST Radius    :  INTEGER {Pixels});

  FUNCTION SquareContainsPoint (CONST Center   :  TPoint;
                                CONST Radius   :  INTEGER; {pixels}
                                CONST TestPoint:  TPoint):  BOOLEAN;

IMPLEMENTATION

  USES
    Math,     // MinIntValue, MaxIntValue
    Classes;  // Point


  FUNCTION AddPoints(CONST PointA, PointB:  TPoint):  TPoint;
  BEGIN
    RESULT.X := PointA.X + PointB.X;
    RESULT.Y := PointA.Y + PointB.Y
  END {AddPoints};


  FUNCTION SubtractPoints(CONST PointA, PointB:  TPoint):  TPoint;
  BEGIN
    RESULT.X := PointA.X - PointB.X;
    RESULT.Y := PointA.Y - PointB.Y
  END {SubtractPoints};


  // Determine whether a line is ltHorizonal or ltVertical,  along with the
  // appropriate slope and intercept FOR point-slope line  equations.  These
  // parameters are used to determine if a line is selected.
  PROCEDURE CalcLineParameters (CONST PointA, PointB  :  TPoint;
                                VAR   Slope, Intercept:  DOUBLE;
                                VAR   LineOrientation :  TLineOrientation);
    VAR
      Delta:  TPoint;
  BEGIN
    Delta := SubtractPoints(PointB, PointA);

    IF  (Delta.X = 0) AND (Delta.Y = 0)
    THEN BEGIN
      // This special CASE should never happen if iMinPixels > 0
      LineOrientation := loPoint;
      Slope     := 0.0;
      Intercept := 0.0
    END
    ELSE BEGIN

      IF   ABS(Delta.X) >= ABS(Delta.Y)
      THEN BEGIN
        // The line is more horizontal than vertical.  Determine values for
        // equation:  Y = slope*X + intercept
        LineOrientation := loHorizontal;
        TRY
          Slope := Delta.Y / Delta.X   // conventional slope in geometry
        EXCEPT
          Slope := 0.0
        END;
        Intercept := PointA.Y - PointA.X*Slope
      END
      ELSE BEGIN
        // The line is more vertical than horizontal.  Determine values for
        // equation:  X = slope*Y + intercept
        LineOrientation := loVertical;
        TRY
          Slope := Delta.X / Delta.Y  // reciprocal of conventional slope
        EXCEPT
          Slope := 0.0
        END;
        Intercept := PointA.X - PointA.Y*Slope;
      END

    END
  END {CalcLineParameters};


  // Determine if Target1 is "near" line segment between Point1 and Point2
  FUNCTION NearLine(CONST Target, Point1, Point2:  TPoint):  BOOLEAN;
    CONST
      LineSelectFuzz =  4;  // Pixel "fuzz" used in line selection
    VAR
      Intercept      :  DOUBLE;
      LineOrientation:  TLineOrientation;
      maxX           :  INTEGER;
      maxY           :  INTEGER;
      minX           :  INTEGER;
      minY           :  INTEGER;
      Slope          :  DOUBLE;
      xCalculated    :  INTEGER;
      yCalculated    :  INTEGER;
  BEGIN
    RESULT := FALSE;

    // If an Endpoint is not selected, was part of line selected?
    CalcLineParameters (Point1, Point2, Slope, Intercept, LineOrientation);

    CASE LineOrientation OF
      loHorizontal:
        BEGIN
          minX := MinIntValue([Point1.X, Point2.X]);
          maxX := MaxIntValue([Point1.X, Point2.X]);
          // first check if selection within horizontal range of line
          IF (Target.X >= minX) and (Target.X <= maxX)
          THEN BEGIN
            // Since X is within range of line, now see if Y value is close
            // enough to the calculated Y value FOR the line to be selected.
             yCalculated := ROUND( Slope*Target.X + Intercept );
             IF   ABS(yCalculated - Target.Y) <= LineSelectFuzz
             THEN RESULT := TRUE
          END
        END;

      loVertical:
        BEGIN
          minY := MinIntValue([Point1.Y, Point2.Y]);
          maxY := MaxIntValue([Point1.Y, Point2.Y]);
          // first check if selection within vertical range of line
          IF   (Target.Y >= minY) AND (Target.Y <= maxY)
          THEN BEGIN
            // Since Y is within range of line, now see if X value is close
            // enough to the calculated X value FOR the line to be selected.
            xCalculated := ROUND( Slope*Target.Y + Intercept );
            IF   ABS(xCalculated - Target.X) <= LineSelectFuzz
            THEN RESULT := TRUE
          END
        END;

      loPoint:
        // Do nothing -- should not occur
    END
  END {NearLine};


  ///////////////////////////////////////////////////////////////////////

  PROCEDURE RestrictCursorToDrawingArea (CONST Image:  TImage);
    VAR
      CursorClipArea:  TRect;
  BEGIN
    CursorClipArea := Bounds(Image.ClientOrigin.X,
                             Image.ClientOrigin.Y,
                             Image.Width, Image.Height);
    Windows.ClipCursor(@CursorClipArea)
  END {RestrictCursorToDrawingArea};


  PROCEDURE RemoveCursorRestrictions;
  BEGIN
    Windows.ClipCursor(NIL)
  END {RemoveCursorRestrictions};


  ///////////////////////////////////////////////////////////////////////

  // Draw End Point "Handle"
  PROCEDURE DrawHandle (CONST Canvas    :  TCanvas;
                        CONST Point     :  TPoint;
                        CONST PenColor  :  TColor;
                        CONST BrushColor:  TColor;
                        CONST Radius    :  INTEGER {Pixels});
  BEGIN
    Canvas.Pen.Color   := PenColor;
    Canvas.Pen.Style   := psSolid;
    Canvas.Pen.Width   := 1;  //Hardwire for now

    Canvas.Brush.Color := BrushColor;

    Canvas.Rectangle (Point.X-Radius, Point.Y-Radius,
                      Point.X+Radius, Point.Y+Radius)
  END {DrawEndPoint};


  ///////////////////////////////////////////////////////////////////////

  // Use Windows PtInRect API call (be aware that this call exclude the
  // bottom and right edges of the rectangle while including the left and
  // top edges).  This function determines whether the TestPoint is inside
  // a square that circumscribes a circle of a given radius with a center
  // at a specified point. 
  FUNCTION SquareContainsPoint (CONST Center   :  TPoint;
                                CONST Radius   :  INTEGER; {pixels}
                                CONST TestPoint:  TPoint):  BOOLEAN;
  BEGIN
    // Use Windows API call to see if point is inside square
    RESULT := Windows.PtInRect(Rect(Center.X - Radius,
                                    Center.Y - Radius,
                                    Center.X + Radius,
                                    Center.Y + Radius),
                               TestPoint);
  END {SquareContainsPoint};



END.
