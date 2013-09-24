using Units
using Base.Test

l = Quantity(Micro, Meter, 380)
@test prefix(l) == Micro
@test base(l) == Meter
pshow(l)
println()
lshow(l)
println()
fshow(l)
println()
lcm = convert(Unit(Centi,Meter), l)
@test lcm.value == l.value/10^4

temp = parse_quantity("32F")
tempC = convert(Unit(SINone,Celsius), temp)
println(temp, " = ", tempC)

q1 = parse_quantity("3.2 μm")
q2 = parse_quantity("5.7 m")
@test q2/q1 == (5.7/3.2)*1e6
@test 5*q1 == Quantity(Micro, Meter, 5*3.2)
@test q2/7 == Quantity(SINone, Meter, 5.7/7)

q1 = parse_quantity("7 s")
q2 = parse_quantity("4 d")
@test q1/q2 == 7/4/86400

q1 = parse_quantity("1 g")
q2 = parse_quantity("1 Da")
@test q2/q1 == 1.66053892173e-24

q1 = parse_quantity("3.2 μm")
q2 = parse_quantity("4 d")
@test_throws q1/q2
