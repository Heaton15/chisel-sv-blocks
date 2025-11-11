module full_adder (
    input  a,
    b,
    cin,
    output z,
    cout
);

  assign z = a ^ b ^ cin;
  assign cout = (a && b) || (cin && b) || (cin && a);
endmodule
