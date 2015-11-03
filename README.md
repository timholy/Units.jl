Units.jl
========

Infrastructure for handling physical units for the Julia programming language

Warning
=======

**This `Units.jl` package is deprecated! Use the [`SIUnits`](https://github.com/Keno/SIUnits.jl) package instead.**

Here is some advice on transitioning:

Parsing
-------

You'll need to create your own custom `_unit_string_dict` and copy-paste the version of `parse_quantity` below:

```
_unit_string_dict = ["um" => Micro*Meter, "s" => Second, "us" => Micro*Second, "MHz" => Mega*Hertz]

function parse_quantity(s::String, strict::Bool = true)
    # Find the last character of the numeric component
    m = match(r"[0-9\.\+-](?![0-9\.\+-])", s)
    if m == nothing
        error("String does not have a 'value unit' structure")
    end
    val = float64(s[1:m.offset])
    ustr = strip(s[m.offset+1:end])
    if isempty(ustr)
        if strict
            error("String does not have a 'value unit' structure")
        else
            return val
        end
    end
    val * _unit_string_dict[ustr]
end
```


Representation
--------------

Define a `NonSIUnit` quantity for each type you want to represent in fixed terms as follows:

```
Micron = SIUnits.NonSIUnit{typeof(Meter),:µm}()
convert(::Type{SIUnits.SIQuantity},::typeof(Micron)) = Micro*Meter
```

Then display objects and arrays like this: `as(x, Micron)`. If you need this as a string, you can use an `IOBuffer`.
