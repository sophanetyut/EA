//+------------------------------------------------------------------+
//|                                           IEEE_Float_Decoder.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "Display the actual stored value of a floating-point number (float or double type),"
#property description "with very high precision up to 55 decimal digits."
#property strict
#property script_show_inputs

#include <ieee_fp.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_DECODE_AS
  {
   FLOAT_TYPE,   // float (32-bits)
   DOUBLE_TYPE   // double (64-bits)
  };

input double          InpNumber = 0.1;            // Floating-point number
input ENUM_DECODE_AS  InpDecodeAs = DOUBLE_TYPE;  // Decode as
input int             InpDecimals = 55;           // Show decimals

#define PRINT(A) Print(#A + " = ", (A));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpDecodeAs==FLOAT_TYPE)
     {
      Print("************ DECODING FLOAT (32-BITS ) ************");
      PRINT(InpNumber);

      Float_t num=(float)InpNumber;

      PRINT(num.sign());
      PRINT(num.exponent());
      PRINT(num.mantissa());

      // Display the actual stored value
      PRINT(num.ToHex());
      PRINT(num.as_integer_ratio());
      PRINT(num.exp_notation());
      PRINT(num.ToString(InpDecimals));
     }

   else if(InpDecodeAs==DOUBLE_TYPE)
     {
      Print("************ DECODING DOUBLE (64-BITS) ************");
      PRINT(InpNumber);

      Double_t num=(double)InpNumber;

      PRINT(num.sign());
      PRINT(num.exponent());
      PRINT(num.mantissa());

      // Display the actual stored value
      PRINT(num.ToHex());
      PRINT(num.as_integer_ratio());
      PRINT(num.exp_notation());
      PRINT(num.ToString(InpDecimals));
     }
  }
//+------------------------------------------------------------------+

// sample output:
// --------------
// IEEE_Float_Decoder EURUSD,M1: ************ DECODING DOUBLE (64-BITS) ************
// IEEE_Float_Decoder EURUSD,M1: InpNumber = 0.1
// IEEE_Float_Decoder EURUSD,M1: num.sign() = 0
// IEEE_Float_Decoder EURUSD,M1: num.exponent() = -4
// IEEE_Float_Decoder EURUSD,M1: num.mantissa() = 2702159776422298
// IEEE_Float_Decoder EURUSD,M1: num.ToHex() = 3FB999999999999A
// IEEE_Float_Decoder EURUSD,M1: num.as_integer_ratio() = 7205759403792794 / 72057594037927936
// IEEE_Float_Decoder EURUSD,M1: num.exp_notation() = 1.6 x 2^-4
// IEEE_Float_Decoder EURUSD,M1: num.ToString(InpDecimals) = 0.1000000000000000055511151231257827021181583404541015625
