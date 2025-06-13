module full_adder (  /*AUTOARG*/
    // Outputs
    sum,
    cout,
    // Inputs
    a,
    b,
    cin
);

  input a, b, cin;
  output logic sum, cout;

  assign sum  = cin ^ a ^ b;
  assign cout = a & b || cin & b || cin & a;


endmodule
