unit ScreenJPEGQuality;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, Buttons;

type
  TFormJPEGQuality = class(TForm)
    BitBtnOK: TBitBtn;
    BitBtnCancel: TBitBtn;
    SpinEditQuality: TSpinEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;


implementation
{$R *.DFM}

end.
