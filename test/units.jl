using Units

l = Quantity(Micro, Meter, 380)
@assert prefix(l) == Micro
@assert base(l) == Meter
pshow(l)
println()
lshow(l)
println()
fshow(l)
println()
lcm = convert(Unit(Centi,Meter), l)
@assert lcm.value == l.value/10^4

temp = parse_quantity("32F")
tempC = convert(Unit(SINone,Celsius), temp)
println(tempC)
