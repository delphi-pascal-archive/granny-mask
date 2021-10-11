// The TVectorGraphicsList is used to store a number of TVectorGraphicsNode
// objects.
//
// efg, December 2000
// www.efg2.com/Lab


UNIT VectorGraphicsListLibrary;

INTERFACE

  USES
    Graphics,   // TCanvas
    WinTypes,   // TPoint
    Classes,    // TList
    VectorGraphicsNodeLibrary;

  CONST
    FigureNotSelected:  INTEGER  = -1;  // No figure selected constant


  /////////////////////////////////////////////////////////////////////////


  TYPE
    // Use TList of TVectorGraphicsNodes to store list of graphical objects.
    TVectorGraphicsList =
    CLASS(TList)
      PROTECTED
        FIndexOfSelected:  INTEGER;  // index of node in TList when only single
                                     // figure is selected

      PUBLIC
        CONSTRUCTOR Create;
        DESTRUCTOR  Destroy;  OVERRIDE;

        // Group of routines that manages "selected" flags for the figures.
        PROCEDURE SelectedFigureIncrementIndex (CONST increment:  INTEGER);
        FUNCTION  SelectedFigureCount:  INTEGER;
        FUNCTION  SelectedContainsPoint(CONST TargetPoint:  TPoint):  BOOLEAN;

        PROCEDURE DeleteSelectedFigures;

        PROCEDURE DrawAllFigures(CONST Canvas:  TCanvas);
        PROCEDURE DrawSelectedFigures(CONST Canvas:  TCanvas);
        PROCEDURE DrawBandAround(CONST Canvas:  TCanvas; CONST Factor:  INTEGER);

        FUNCTION  GetSelectedNode:  TVectorGraphicsNode;

        PROCEDURE TranslateSelectedFigures (CONST TranslateVector:  TPoint);

        PROCEDURE SelectFigures (CONST Shift:  TShiftState;
                                 CONST X, Y:  Integer);
        FUNCTION  GetSelectedHandleAtPoint(CONST X,Y:  INTEGER):  TDrawingHandle;

        PROCEDURE SetSelectedFlags (CONST state:  BOOLEAN);
        PROCEDURE SetSelectedIndex (CONST index:  INTEGER);

        PROPERTY  SelectedIndex:  INTEGER  READ  FIndexOfSelected  WRITE  SetSelectedIndex;
    END;


    /////////////////////////////////////////////////////////////////////////


IMPLEMENTATION

  USES
    LineLibrary;  // AddPoints, SubtractPoints, SquareContainsPoint, DrawEndPoint


  /////////////////////////////////////////////////////////////////////////

  CONSTRUCTOR TVectorGraphicsList.Create;
  BEGIN
    INHERITED Create;
    FIndexOfSelected := FigureNotSelected
  END {Create};


  DESTRUCTOR TVectorGraphicsList.Destroy;
    VAR
      i   :  INTEGER;
  BEGIN
    {Free items in List}
    FOR i := SELF.Count-1 DOWNTO 0 DO
    BEGIN
      SELF.Delete(i);
    END;

    INHERITED Destroy
  END {Destroy};


  FUNCTION TVectorGraphicsList.SelectedFigureCount:  INTEGER;
    VAR
      count:  INTEGER;
      i    :  INTEGER;
  BEGIN
    count := 0;
    FOR i := 0 TO SELF.Count-1 DO
    BEGIN
      IF   TVectorGraphicsNode(SELF.Items[i]).Selected
      THEN INC(count)
    END;
    RESULT := count
  END {SelectedFigureCount};


  FUNCTION  TVectorGraphicsList.SelectedContainsPoint(CONST TargetPoint:  TPoint):  BOOLEAN;
    VAR
      Found:  BOOLEAN;
      i    :  INTEGER;
  BEGIN
    Found := FALSE;
    i := 0;
    WHILE (NOT Found) AND (i < Self.Count) DO
    BEGIN
      IF   TVectorGraphicsNode(SELF.Items[i]).Selected
      THEN Found := TBoundingRectangle(SELF.Items[i]).ContainsPoint(TargetPoint);

      INC(i);
    END;

    RESULT := Found
  END {SelectedContainsPoint};


  // Increment is intended to be +1 or -1 to select the next or last figure.
  PROCEDURE TVectorGraphicsList.SelectedFigureIncrementIndex (CONST increment:  INTEGER);
    VAR
      CurrentlySelectedIndex:  INTEGER;
  BEGIN
    IF   self.Count > 0   // Do nothing if there are no figures to select
    THEN BEGIN
      IF   FIndexOfSelected = FigureNotSelected
      THEN BEGIN
        IF   increment > 0
        THEN FIndexOfSelected := 0              // first in list
        ELSE FIndexOfSelected := self.Count-1;  // last in list

        TVectorGraphicsNode(SELF.Items[FIndexOfSelected]).Selected := TRUE
      END
      ELSE BEGIN
        // Save this index since SetSelectedFlags (next) as a side-effect
        // alters value.
        CurrentlySelectedIndex := FIndexOfSelected;

        // Clear all flags in case multiple figures are currently selected
        SetSelectedFlags (FALSE);

        FIndexOfSelected := CurrentlySelectedIndex + increment;
        IF   FIndexOfSelected = self.Count
        THEN FIndexOfSelected := 0                 // wrap around
        ELSE
          IF   FIndexOfSelected < 0
          THEN FIndexOfSelected := self.Count-1;   // wrap around

        TVectorGraphicsNode(SELF.Items[FIndexOfSelected]).Selected := TRUE
      END
    END
  END {SelectedFigureIncrementIndex};


  // The main purpose of this method is to turn all flags off.
  PROCEDURE TVectorGraphicsList.SetSelectedFlags (CONST state:  BOOLEAN);
    VAR
      i:  INTEGER;
  BEGIN
    FOR i := 0 TO self.Count-1 DO
    BEGIN
      TVectorGraphicsNode(SELF.Items[i]).Selected := state
    END;

    // If no figures are selected, or if they are all selected, then
    // say there is no one figure selected.
    FIndexOfSelected := FigureNotSelected
  END {ClearSelectedFlags};


  PROCEDURE TVectorGraphicsList.SetSelectedIndex (CONST index:  INTEGER);
  BEGIN
    FIndexOfSelected := index;

    // index < 0 for FigureNotSelected
    IF   index >= 0
    THEN BEGIN
      TVectorGraphicsNode(SELF.Items[FIndexOfSelected]).Selected := TRUE
    END
  END {SetSelectedIndex};


  PROCEDURE TVectorGraphicsList.TranslateSelectedFigures (CONST TranslateVector:  TPoint);
    VAR
      i   :  INTEGER;
      node:  TVectorGraphicsNode;
  BEGIN
    FOR i := 0 TO self.Count-1 DO
    BEGIN
      IF   TVectorGraphicsNode(self.Items[i]).Selected
      THEN BEGIN
        node := TVectorGraphicsNode(self.Items[i]);

        IF   node.Selected
        THEN TBoundingRectangle(node).Translate(TranslateVector);

      END
    END
  END {TranslateSelectedFigures};


  PROCEDURE TVectorGraphicsList.DeleteSelectedFigures;
    VAR
      i:  INTEGER;
  BEGIN
    // Don't do anything unless at least one figure is selected
    IF   SelectedFigureCount = 0
    THEN FIndexOfSelected := FigureNotSelected
    ELSE BEGIN
      // Go in reverse order so indices are not affected by deletions.
      FOR i := self.Count-1 DOWNTO 0 DO
      BEGIN
        IF   TVectorGraphicsNode(self.Items[i]).Selected
        THEN SELF.Delete(i);
      END;

      // If any items are left, make the last one selected.
      IF   self.Count = 0
      THEN FIndexOfSelected := FigureNotSelected
      ELSE BEGIN
        FIndexOfSelected := self.Count-1;
        TVectorGraphicsNode(self.Items[FIndexOfSelected]).Selected := TRUE
      END
    END
  END {DeleteSelectedFigures};


  PROCEDURE  TVectorGraphicsList.SelectFigures (CONST Shift:  TShiftState;
                                                CONST X, Y:  Integer);
    VAR
      i        :  INTEGER;
      NotFound :  BOOLEAN;
      RectNode :  TBoundingRectangle;
      TestPoint:  TPoint;
  BEGIN
    TestPoint := Point(X,Y);

    IF   NOT (ssShift IN Shift)
    THEN self.SetSelectedFlags(FALSE);

    // Go through "z" order and see if figure selected.  (Future:
    // Use multiple WHILE loops for various types of objects.  For
    // example, look for line objects before rectangular objects.)

    i := 0;
    NotFound := TRUE;
    WHILE NotFound AND (i < Self.Count) DO
    BEGIN
      RectNode := Self.Items[i];

      // Don't check item if it's already selected.  This will allow
      // selection of items on top of each other.
      IF   (RectNode IS TBoundingRectangle) AND (NOT RectNode.Selected)
      THEN BEGIN
        IF   RectNode.ContainsPoint(TestPoint)
        THEN BEGIN
          Self.SetSelectedIndex(i);
          NotFound := FALSE
        END
      END;

      INC(i)
    END;

  END {SelectFigures};


  PROCEDURE TVectorGraphicsList.DrawAllFigures(CONST Canvas:  TCanvas);
    VAR
      i   :  INTEGER;
      node:  TVectorGraphicsNode;
  BEGIN
    Canvas.Pen.Mode  := pmCopy;
    FOR i := 0 TO self.Count-1 DO
    BEGIN
      node := TVectorGraphicsNode(self.Items[i]);
      Canvas.Pen.Color := node.PenColor;
      Canvas.Pen.Style := node.PenStyle;
      Canvas.Pen.Width := node.PenWidth;
      Canvas.Brush.Style := bsClear;

      // Each figure "knows" how to draw itself
      node.DrawFigure (Canvas);
    END
  END {DrawAllFigures};


  // Just redraw selected figures so this can be used for XORing.
  PROCEDURE TVectorGraphicsList.DrawSelectedFigures(CONST Canvas:  TCanvas);
    VAR
      i   :  INTEGER;
      node:  TVectorGraphicsNode;
  BEGIN
    FOR i := 0 TO self.Count-1 DO
    BEGIN
      node := TVectorGraphicsNode(self.Items[i]);

      IF   node.Selected
      THEN node.DrawFigure (Canvas);
    END
  END {DrawAllFigures};

  
  // Draw bands around figure for Factor <> 0
  PROCEDURE TVectorGraphicsList.DrawBandAround(CONST Canvas:  TCanvas; CONST Factor:  INTEGER);
   VAR
      i   :  INTEGER;
      node:  TVectorGraphicsNode;
  BEGIN
    FOR i := 0 TO self.Count-1 DO
    BEGIN
      node := TVectorGraphicsNode(self.Items[i]);
      node.DrawFigure (Canvas, Factor);
    END
  END {DrawBandAround};


  FUNCTION  TVectorGraphicsList.GetSelectedNode:  TVectorGraphicsNode;
  BEGIN
    IF   SelectedIndex = FigureNotSelected
    THEN RESULT := NIL
    ELSE RESULT := SELF.Items[SELF.SelectedIndex];
  END {GetSelectedNode};


  FUNCTION TVectorGraphicsList.GetSelectedHandleAtPoint(CONST X,Y:  INTEGER):  TDrawingHandle;
    VAR
      node:  TVectorGraphicsNode;
  BEGIN
    RESULT := dhNone;

    IF   (SELF.SelectedIndex <> FigureNotSelected) AND (SelectedFigureCount = 1)
    THEN BEGIN
      node:= TVectorGraphicsNode(SELF.Items[SELF.SelectedIndex]);
      RESULT := node.GetHandleAtPoint(X,Y, HandleRadius);
    END
  END {GetSelectedHandleAtPoint};


  /////////////////////////////////////////////////////////////////////////

END.
