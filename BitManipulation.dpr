program BitManipulation;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Math, System.Classes;

const
  OPTION_EXIT                = '0';
  OPTION_SET_SELECTED_BITS   = '1';
  OPTION_CLEAR_SELECTED_BITS = '2';
  OPTION_SET_ALL_BITS        = '3';

type
  TBitSet = set of 0..7;

// Note: Bit offsets are 0 based, example ABitSet can be [0,1], [1..7], [5,4,2]
function SetBits( var AByte: Byte; const ABitSet : TBitSet;
  const AValue : Byte ) : Boolean;
var
  BitCount,
    SetValue,
    Offset      : Byte;
  BitCtr        : Integer;
begin

  Result   := True;

  { Value may be adjusted hence use local }
  SetValue := AValue;

  BitCount := 0;
  Offset   := 255;
  for BitCtr := 0 to 7 do begin

    if BitCtr in ABitSet then begin

      Inc( BitCount );

      if Offset = 255 then begin
        Offset := BitCtr;
      end;

    end;

  end;

  { Set value adjusted to max which can be set for passed bits }
  if SetValue > ( Trunc( Power( 2, BitCount ) ) - 1 ) then begin
    SetValue := Trunc( Power( 2, BitCount ) ) - 1;
  end;

  { Calculate mask }
  AByte := AByte or ( SetValue shl Offset );

end;

// Note: Bit offsets are 0 based, example ABitSet can be [0,1], [1..7], [5,4,2]
function ClearBits( var AByte: Byte; const ABitSet : TBitSet ) : Boolean;
var
  BitCtr,
    Mask : Byte;
begin

  Result := True;

  Mask := 0;
  for BitCtr := 0 to 7 do begin
    if BitCtr in ABitSet then begin
      Mask := Mask + Trunc( Power( 2, BitCtr ) );
    end;
  end;

  { Clear bits at offset }
  AByte := AByte and not Mask;

end;

function IntToBin( const AValue : Byte ) : String;
var
  Ctr : Integer;
begin

  SetLength( Result, 8 );

  for Ctr := 1 to 8 do begin
    if ( ( Avalue shl ( Ctr - 1 ) ) shr 7 ) = 0 then begin
      Result[ Ctr ] := '0';
    end
    else begin
      Result[ Ctr ] := '1';
    end;
  end;

end;

procedure Split( ADelimiter: Char; AStr: string; AStrings: TStrings );
begin
   AStrings.Clear;
   AStrings.Delimiter       := ADelimiter;
   AStrings.StrictDelimiter := True;
   AStrings.DelimitedText   := AStr;
end;

procedure ExecuteProgram;
var
  ByteValue      : Byte;
  Ctr,
    PosSpace     : Integer;
  BitsToSet,
    CommaValues,
    InputValue   : String;
  ValueList      : TStringList;
  BitSet         : TBitSet;
begin

  try

    ValueList := TStringList.Create;

    Write( 'Please enter initial bit values as a byte (0 to 255): ' );
    ReadLn( InputValue );
    InputValue := Trim( InputValue );

    if InputValue = '' then begin
      Exit;
    end;

    ByteValue := StrToInt( InputValue );

    WriteLn( 'Binary: ' + IntToBin( ByteValue ) );

    while True do begin

      WriteLn( '' );
      WriteLn( 'Options: 0-Exit, 1-Set Bits, 2-Clear Bits, 3-Set All Bits' );

      ReadLn( InputValue );
      InputValue := Trim( InputValue );

      if InputValue = OPTION_EXIT then begin
        Break;
      end;

      if ( InputValue = OPTION_SET_SELECTED_BITS   ) or
         ( InputValue = OPTION_CLEAR_SELECTED_BITS ) then begin

        if ( InputValue = OPTION_SET_SELECTED_BITS ) then begin
          WriteLn( 'Enter comma separated values then enter space plus value(s) to set, Example: 3,6,7 2 :' );
        end
        else begin
          WriteLn( 'Enter comma separated values, Example: 3,6,7 :' );
        end;

        ReadLn( InputValue );
        InputValue := Trim( InputValue );

        PosSpace := Pos( ' ', InputValue );

        CommaValues := Copy( InputValue, 1, PosSpace - 1 );
        BitsToSet   := Copy( InputValue, PosSpace + 1, 3 );

        Split( ',', CommaValues, ValueList );

        BitSet := [];

        for Ctr := 0 to Pred( ValueList.Count ) do begin
          Include( BitSet, StrToInt( ValueList[ Ctr ] ) );
        end;

        if InputValue = OPTION_SET_SELECTED_BITS then begin
          SetBits( ByteValue, BitSet, StrToInt( BitsToSet ) );
        end
        else begin
          ClearBits( ByteValue, BitSet );
        end;

        WriteLn( 'Binary: ' + IntToBin( ByteValue ) );

      end
      else if InputValue = OPTION_SET_ALL_BITS then begin

        WriteLn( 'Enter comma separated values, Example: 3,6,7 : ' );
        ReadLn( InputValue );
        InputValue := Trim( InputValue );

        CommaValues := InputValue;

        Split( ',', CommaValues, ValueList );

        BitSet := [];

        for Ctr := 0 to Pred( ValueList.Count ) do begin
          Include( BitSet, StrToInt( ValueList[ Ctr ] ) );
        end;

        SetBits( ByteValue, BitSet, 255 );

        WriteLn( 'Binary: ' + IntToBin( ByteValue ) );

      end

    end;

  finally

    ValueList.Free;

  end;

end;

begin

  try
    ExecuteProgram;
  except
    on E: Exception do begin
      WriteLn( E.ClassName, ': ', E.Message );
      ExitCode := 1;
    end;
  end;

end.
