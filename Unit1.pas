unit Unit1;

interface

uses
  DateUtils, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin, ExtCtrls, Menus, ClipBrd;

type
  TForm1 = class(TForm)
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Label3: TLabel;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label4: TLabel;
    SpinEdit1: TSpinEdit;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    Panel1: TPanel;
    Edit3: TEdit;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
  private
    { D�clarations priv�es }
  public
    { D�clarations publiques }
  end;

var
  Form1: TForm1;
   datevm: string;
   namep: string;
   poz: string;
   userpoz:string;
implementation

uses Unit2, Unit3;

{$R *.dfm}

type
  TJJMMAA = record
    JJ, MM, AA: byte;
  end;
{
Le r�sultat retourn� est True si la diff�rence est positive, False dans le cas contraire.
Mais les variables Years, Months et Days sont toudays en valeur absolue.
}

function GetYMDBetween(FromDate, ToDate: TDateTime;
  var Years, Months, Days: Integer): Boolean;
var
  FromY, FromM, FromD,    // from date
  ToY, ToM, ToD: Word;    // to date
  TmpDate: TDateTime;
  PreviousMonth: Byte;
  DaysInMonth: Byte;
begin
  Result := FromDate <= ToDate;
  if not Result then
  begin
    TmpDate := ToDate;
    ToDate := FromDate;
    FromDate := TmpDate;
  end;
  DecodeDate(ToDate, ToY, ToM, ToD);
  DecodeDate(FromDate, FromY, FromM, FromD);
  Years := ToY - FromY;
  Months := ToM - FromM;
  Days := ToD - FromD;
  if Days < 0 then
  begin
    Dec(Months);
    PreviousMonth := ToM + (Byte(ToM = 1) * 12) - 1;
    case PreviousMonth of
      1,3,5,7,8,10,12: DaysInMonth := 31;
      4,6,9,11       : DaysInMonth := 30;
      else
        DaysInMonth := 28 + Byte(IsLeapYear(ToY));
    end;
    Days := DaysInMonth - Abs(Days);
  end;
  if Months < 0 then
  begin
    Dec(Years);
    Months := 12 - Abs(Months);
  end;
end;

{
      Pour calculer l'�cart entre 2 dates on incr�mente l'ann�e de la 1�re date en incr�mentant en parall�le un compteur (AA)
      jusqu'� ce que cette date soit sup�rieure � la 2�me, on d�cr�mente alors le compteur de 1, on obtient le nombre d'ann�es
      qui s�pare les 2 dates.
      On r�p�te cette op�ration pour les monts et les days (MM et JJ).

      Si la seconde date est ant�rieure � la premi�re on calcul n�anmoins la Delta�rence (non sign�e), c'est � la partie appelante du programme de traiter
      l'affichage du r�sultat.

      C'est un peu le marteau-pilon pour �craser un moustique mais au moins �a marche, enfin je crois ;-) et le traitement
          pour un �cart de 99 ans, 11 monts et 30 days est de 100 + 12 + 31 soit 143 boucles de 5 lignes alors ...
}

function DeltaDatetoJJMMAA(const CDate1, CDate2 : TDate) : TJJMMAA;

var
  Date1,
  Date2,
  WDate : TDate;

begin
  if CompareDate(CDate1, CDate2) > 0 then begin  // si 2�me date < 1�re on intervertit pour le traitement
    Date1 := CDate2;
    Date2 := CDate1;
  end
  else begin
    Date1 := CDate1;
    Date2 := CDate2;
  end;
  with result do begin
    AA := 0;                                 // initialisation du 'compteur' d'ann�es
    repeat                                   // debut de la boucle d'incr�mentation et de comptage
      inc(AA);                               // on incr�mente le 'compteur' d'ann�es
      WDate := Date1;                        // on stocke la 1 �re date pour la restituer apr�s d�passement
      Date1 := incyear(Date1);               // on incr�mente la 1�re date d'un an
    until comparedate(Date1, Date2) > 0;     // on sort de la boucle quand la 1 �re date est sup�rieure � la seconde
    dec(AA);                                 // comme il y a eu d�passement on retire 1 an
    Date1 := WDate;                          //     puis on restaure la date avant la derni�re incr�mentation

    MM := 0;                                 // m�me traitement que ci-dessu mais pour les monts
    repeat
      inc(MM);
      WDate := Date1;
      Date1 := incmonth(Date1);
    until comparedate(Date1, Date2) > 0;
    dec(MM);
    Date1 := WDate;

    JJ := 0;                                 // m�me traitement que ci-dessu mais pour les days
    repeat
      inc(JJ);
      Date1 := incday(Date1);
    until comparedate(Date1, Date2) > 0;
    dec(JJ);
  end;
end;

// un click sur le bouton pour lancer le calcul de l'�cart entre les 2 dates affich�es
procedure TForm1.Button1Click(Sender: TObject);

var
  texte : string;  //  Utilis� pour la construction du resultat
  Delta : TJJMMAA;  //  retourn� par la fonction DeltaDatetoJJMMAA

begin
  Delta := DeltaDatetoJJMMAA(DateTimePicker1.date, DateTimePicker2.date); // appel de la fonction
// mise en forme du r�sultat
  texte := '';
  with Delta do begin
    case JJ of                     // si au moins un day on l'affiche en l'accordant en nombre
      0 : ;
      1 : texte := '1 day';
    else
      texte := format('%2d ����', [JJ]);
    end;
    if MM > 0 then                 // si au moins un moins on l'affiche, 'monts' se terminant par un 's' pose moins de probl�me!
      if texte = '' then
        texte := format('%2d monts', [MM])
      else
        texte := format('%2d �������, ', [MM]) + texte;
    if (AA > 0) and
       (Texte <> '') then
      Texte := ', ' + Texte;
    case AA of                    // si au moins un an on l'affiche en l'accordant en nombre
      0 : ;
      1 : texte := '1 ���' + Texte;
    else
      texte := format('%2d ����', [AA]) + Texte;
    end;
    if CompareDate(DateTimePicker1.date, DateTimePicker2.date) > 0 then // si la 1�re date est post�rieure � la seconde
      Label3.Caption :=  Texte
    else
      Label3.Caption :=  Texte;

  end;

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
namep:= edit1.Text;
datevm:= label3.Caption;
if spinedit1.Text='1' then
edit2.text:= namep + ' �� ������ ���' + datevm;
if spinedit1.Text='2' then
edit2.text:= namep + ' � ���� ����� ���' + datevm;
if spinedit1.Text='3' then
edit2.text:= namep + ' �� ��� ������� ������� ���' + datevm;
if spinedit1.Text='4' then
edit2.text:= namep + ' �� ���� ���� ����� ���� ���' + datevm;
if spinedit1.Text='5' then
edit2.text:= namep + ' �� ������, ��� � ����� ���� �� ���� ���' + datevm;
if spinedit1.Text='6' then
edit2.text:= namep + ' �������, �� ����� ���' + datevm;
if spinedit1.Text='7' then
edit2.text:= namep + ' �� �������� �� ���� ���' + datevm;
if spinedit1.Text='8' then
edit2.text:= namep + ' �� ����� ���� ����� ���' + datevm;
if spinedit1.Text='9' then
edit2.text:= namep + userpoz + datevm;



end;

procedure TForm1.Button3Click(Sender: TObject);
begin
userpoz:=edit3.Text;
panel1.Visible:=false;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
panel1.Visible:=true;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
Clipboard.AsText:=edit2.Text;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
form2.show;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
form3.show;
end;

end.



