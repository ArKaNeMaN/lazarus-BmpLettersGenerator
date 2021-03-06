unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Math, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls, LazFileUtils, LazUTF8, FileUtil;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ColorButton1: TColorButton;
    ColorButton2: TColorButton;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Edit2: TEdit;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ProgressBar1: TProgressBar;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    function FindMinPowBiggerOrEqualThan(const Base: longint; const Num: longint): longint;
    function GetAAMode: TAntialiasingMode;    
    function GetAAModeFont: TFontQuality;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var Bmp: TBitmap;
var CharH, CharW, CurW: longint;
var i: longint;
var CharsSet, CurChar: UTF8String;
var FileMap: Text;
begin

  if Edit1.Text[Length(Edit1.Text)] <> PathDelim then
    Edit1.Text:= Edit1.Text + PathDelim;

  if FileExistsUTF8(Edit1.Text) then begin
    ShowMessage('Output folder is invalid.');
    exit;
  end;

  //if DirectoryExistsUTF8(Edit1.Text) then
  //  if DeleteDirectory(Edit1.Text, True) then RemoveDirUTF8(Edit1.Text);
  //MkDir(Edit1.Text);
  if not DirectoryExistsUTF8(Edit1.Text) then
    MkDir(Edit1.Text);

  Bmp:= TBitmap.Create();
  Bmp.PixelFormat:= pf8bit;

  Bmp.Canvas.Font:= Edit2.Font;
  Bmp.Canvas.Font.Color:= ColorButton1.ButtonColor;
  Bmp.Canvas.Brush.Color:= ColorButton2.ButtonColor;

  CharsSet:= String(Edit2.Text);

  Bmp.Canvas.Font.Quality:= GetAAModeFont;
  Bmp.Canvas.AntialiasingMode:= GetAAMode;

  CharH:= Bmp.Canvas.TextHeight(CharsSet[1]);
  CharW:= 0;
  for i:= 1 to UTF8Length(CharsSet) do begin
    CharW:= Max(Bmp.Canvas.TextWidth(UTF8Copy(CharsSet, i, 1)), CharW);
  end;

  Bmp.Width:= FindMinPowBiggerOrEqualThan(2, CharW);
  Bmp.Height:= FindMinPowBiggerOrEqualThan(2, CharH);

  System.Assign(FileMap, Edit1.Text + 'map.txt');
  ReWrite(FileMap);
     
  ProgressBar1.Max:= UTF8Length(CharsSet);
  for i:= 1 to UTF8Length(CharsSet) do begin
    CurChar:= UTF8Copy(CharsSet, i, 1);

    CurW:= Bmp.Canvas.TextWidth(CurChar);

    Bmp.Canvas.FillRect(0, 0, Bmp.Width, Bmp.Height);
    Bmp.Canvas.TextOut(
      (Bmp.Width - CurW) div 2,
      (Bmp.Height - CharH) div 2,
      CurChar
    );

    WriteLn(FileMap, CurChar, ' ', i);

    Bmp.SaveToFile(Edit1.Text + IntToStr(i) + '.bmp');
    ProgressBar1.Position:= ProgressBar1.Position + 1;
    Bmp.Canvas.Clear();
  end;
  System.Close(FileMap);

  ShowMessage('Done.');
  ProgressBar1.Position:= 0;
  Bmp.Free();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if not SelectDirectoryDialog1.Execute then
    exit;

  Edit1.Text:= SelectDirectoryDialog1.FileName;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if FontDialog1.Execute then
    Edit2.Font:= FontDialog1.Font;
end;

const CHARSSET_FILE = 'chars.txt';

procedure TForm1.FormCreate(Sender: TObject);
var i: longint;
var F: Text;
var Str: string;
begin
  Edit1.Text:= '.' + PathDelim + 'output';

  Edit2.Text:= '';
  if FileExistsUTF8(CHARSSET_FILE) then begin
    System.Assign(F, CHARSSET_FILE);
    ReSet(F);
    Read(F, Str);
    System.Close(F);
    Edit2.Text:= Str;
  end
  else begin
    for i:= 33 to 126 do
      Edit2.Text:= Edit2.Text + Char(i);
  end;
end;

function TForm1.FindMinPowBiggerOrEqualThan(const Base: longint; const Num: longint): longint;
var Pow: real;
begin
  Pow:= Floor(ln(Num) / ln(Base));
  FindMinPowBiggerOrEqualThan:= Floor(Power(Base, Pow+1));
end;

function TForm1.GetAAMode: TAntialiasingMode;
begin
  case ComboBox1.ItemIndex of
    0: GetAAMode:= amOn;
    1: GetAAMode:= amOff;
    2: GetAAMode:= amDontCare;
  end;

end;

function TForm1.GetAAModeFont: TFontQuality;
begin
  case ComboBox1.ItemIndex of
    0: GetAAModeFont:= fqAntialiased;
    1: GetAAModeFont:= fqNonAntialiased;
    2: GetAAModeFont:= fqDraft;
  end;

end;

end.

