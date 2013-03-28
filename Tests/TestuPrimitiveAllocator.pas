unit TestuPrimitiveAllocator;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Variants, uPrimitiveAllocator;

{$i DelphiVersion_defines.inc}

type
  // Test methods for class TStack

  TestTPrimitiveAllocator = class(TTestCase)
  private
    FAllocator: IPrimitiveAllocator;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAllocInteger;
    procedure TestAllocBoolean;
    procedure TestAllocAnsiChar;
    procedure TestAllocShortString;
    procedure TestAllocExtended;
    procedure TestAllocPAnsiChar;
    procedure TestAllocAnsiString;
    procedure TestAllocInt64;
    procedure TestAllocShortString_Realloc;
    {$IFDEF DELPHI2007}
    procedure TestAllocWideString;
    {$ENDIF}
    procedure TestAllocWideChar;
    {$IFDEF DELPHI2009}
    procedure TestAllocPWideChar;
    procedure TestAllocUnicodeString;
    procedure TestAllocCurrency;
    procedure TestAllowUnicodeStringFromArrayOfConst;
    {$ENDIF}
  end;

implementation

uses
  SysUtils;

const
  BYTES_TO_ALLOCATE = 512;

procedure TestTPrimitiveAllocator.SetUp;
begin
  FAllocator := NewPrimitiveAllocator(BYTES_TO_ALLOCATE);
end;

procedure TestTPrimitiveAllocator.TearDown;
begin
  FAllocator := nil;
end;

procedure TestTPrimitiveAllocator.TestAllocInteger;
var
  Val : PInteger;
begin
  Val := FAllocator.New(10);
  Check(Val <> nil, 'Value returned by call to New(10) should return <> nil');
  CheckEquals(10, Val^, 'Value returned by New(10) doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocBoolean;
var
  Val : PBoolean;
begin
  Val := FAllocator.New(True);
  Check(Val <> nil, 'Value returned by call to New(True) should return <> nil');
  Check(Val^, 'Value returned by New(True) doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocAnsiChar;
var
  Val : PAnsiChar;
begin
  Val := FAllocator.New(AnsiChar('a'));
  Check(Val <> nil, 'Value returned by call to New(''a'') should return <> nil');
  CheckEqualsString(AnsiChar('a'), AnsiChar(Val^), 'Value returned by New(''a'') doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocShortString;
const
  TheVal : ShortString = 'abc';
var
  Val : PShortString;
begin
  Val := FAllocator.NewShortString(TheVal);
  Check(Val <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(''abc'') doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocExtended;
const
  TheVal : Extended = 1.1;
var
  Val : PExtended;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(1.1) should return <> nil');
  CheckEqualsString(Format('%.2g', [TheVal]), Format('%.2g', [Val^]), 'Value returned by New(1.1) doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocPAnsiChar;
const
  TheVal : PAnsiChar = 'abc';
var
  Val : PAnsiChar;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(PAnsiChar(''abc'')) should return <> nil');
  CheckEqualsString(TheVal, Val, 'Value returned by New(PAnsiChar(''abc'')) doesn''t match expected value');
end;

{$IFDEF DELPHI2009}
procedure TestTPrimitiveAllocator.TestAllocPWideChar;
const
  TheVal : PWideChar = 'abc';
var
  Val : PWideChar;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(PWideChar(''abc'')) should return <> nil');
  CheckEqualsString(string(TheVal), string(Val), 'Value returned by New(PWideChar(''abc'')) doesn''t match expected value');
end;
{$ENDIF}

procedure TestTPrimitiveAllocator.TestAllocAnsiString;
const
  TheVal : AnsiString = 'abc';
var
  Val : PAnsiString;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(''abc'') doesn''t match expected value');
end;

{$IFDEF DELPHI2009}
procedure TestTPrimitiveAllocator.TestAllocUnicodeString;
const
  TheVal : UnicodeString = 'abc';
var
  Val : PUnicodeString;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(''abc'') doesn''t match expected value');
end;
{$ENDIF}

{$IFDEF DELPHI2009}
procedure TestTPrimitiveAllocator.TestAllocCurrency;
const
  TheVal : Currency = 1.1;
var
  Val : PCurrency;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(Currency(1.1)) should return <> nil');
  CheckEqualsString(Format('%.2g', [TheVal]), Format('%.2g', [Val^]), 'Value returned by New(Currency(1.1)) doesn''t match expected value');
end;
{$ENDIF}

procedure TestTPrimitiveAllocator.TestAllocInt64;
var
  Val : PInt64;
begin
  Val := FAllocator.New(Int64(10));
  Check(Val <> nil, 'Value returned by call to New(10) should return <> nil');
  CheckEquals(10, Val^, 'Value returned by New(10) doesn''t match expected value');
end;

procedure TestTPrimitiveAllocator.TestAllocShortString_Realloc;
const
  TheVal : ShortString = 'abc';
var
  Val, Val2, Val3 : PShortString;
begin
  Val := FAllocator.NewShortString(TheVal);
  Val2 := FAllocator.NewShortString(TheVal);
  Val3 := FAllocator.NewShortString(TheVal);
  Check(Val <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  Check(Val2 <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  Check(Val3 <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(''abc'') doesn''t match expected value');
  CheckEqualsString(TheVal, Val2^, 'Value returned by New(''abc'') doesn''t match expected value');
  CheckEqualsString(TheVal, Val3^, 'Value returned by New(''abc'') doesn''t match expected value');
end;

{$IFDEF DELPHI2007}
procedure TestTPrimitiveAllocator.TestAllocWideString;
const
  TheVal : WideString = 'abc';
var
  Val : PWideString;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(''abc'') should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(''abc'')) doesn''t match expected value');
end;
{$ENDIF}

procedure TestTPrimitiveAllocator.TestAllocWideChar;
const
  TheVal : WideChar = 'd';
var
  Val : PWideChar;
begin
  Val := FAllocator.New(TheVal);
  Check(Val <> nil, 'Value returned by call to New(WideChar(''d'')) should return <> nil');
  CheckEqualsString(TheVal, Val^, 'Value returned by New(WideChar(''d'')) doesn''t match expected value');
end;

{$IFDEF DELPHI2009}
procedure TestTPrimitiveAllocator.TestAllowUnicodeStringFromArrayOfConst;
var
  p : PUnicodeString;
  procedure AllocString(const arr : array of const);
  begin
    p := FAllocator.New(UnicodeString(arr[0].VUnicodeString));
  end;
begin
  p := nil;
  AllocString(['hola']);
  CheckEqualsString('hola', p^, 'Allocated string doesn''t match');
end;
{$ENDIF}

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTPrimitiveAllocator.Suite);
end.
