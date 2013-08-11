# Support for physical units: I/O and conversion

module Units

import Base.show, Base.convert

export  SIPrefix,
        Quantity,
        Unit,
# Prefixes
        Yocto,
        Zepto,
        Atto,
        Femto,
        Pico,
        Nano,
        Micro,
        Milli,
        Centi,
        Deci,
        SINone,
        Deca,
        Hecto,
        Kilo,
        Mega,
        Giga,
        Tera,
        Peta,
        Exa,
        Zetta,
        Yotta,
# Units
        UnitBase,
        Unknown,
# Length units
        Meter,
        Angstrom,
        Inch,
        Foot,
        Yard,
        Mile,
        LightYear,
        Parsec,
        AstronomicalUnit,
# Time units
        Second,
        Minute,
        Hour,
        Day,
        Week,
        YearJulian,
        PlanckTime,
# Rate units
        Hertz,
# Mass units
        Gram,
        AtomicMassUnit,
        Dalton,
        PlanckMass,
# Electric current
        Ampere,
# Temperature
        Kelvin,
        Celsius,
        Fahrenheit,
# Luminosity
        Candela,
# Amount
        Mole,
        Entities,
#
# Functions
        base,
        fshow,
        lshow,
        prefix,
        pshow,
        parse_quantity


abstract SIPrefix
immutable Yocto <: SIPrefix end
immutable Zepto <: SIPrefix end
immutable Atto <: SIPrefix end
immutable Femto <: SIPrefix end
immutable Pico <: SIPrefix end
immutable Nano <: SIPrefix end
immutable Micro <: SIPrefix end
immutable Milli <: SIPrefix end
immutable Centi <: SIPrefix end
immutable Deci <: SIPrefix end
immutable SINone <: SIPrefix end
immutable Deca <: SIPrefix end
immutable Hecto <: SIPrefix end
immutable Kilo <: SIPrefix end
immutable Mega <: SIPrefix end
immutable Giga <: SIPrefix end
immutable Tera <: SIPrefix end
immutable Peta <: SIPrefix end
immutable Exa <: SIPrefix end
immutable Zetta <: SIPrefix end
immutable Yotta <: SIPrefix end

# PrettyShow and PrettyString
pshow(x) = pshow(STDOUT::IO, x)
function pstring(x)
    s = IOBuffer()
    pshow(s, x)
    takebuf_string(s)
end
# LatexShow and LatexString
lshow(x) = lshow(STDOUT::IO, x)
function lstring(x)
    s = IOBuffer()
    lshow(s, x)
    takebuf_string(s)
end
# FullShow and FullString
fshow(x) = fshow(STDOUT::IO, x)
function fstring(x)
    s = IOBuffer()
    fshow(s, x)
    takebuf_string(s)
end

let
#  Prefix        ToSINone      Show          PrettyShow   LatexShow  Full
const prefix_table = {
  (Yocto,        1e-24,        "y",          "y",         "y",       "yocto")
  (Zepto,        1e-21,        "z",          "z",         "z",       "zepto")
  (Atto,         1e-18,        "a",          "a",         "a",       "atto")
  (Femto,        1e-15,        "f",          "f",         "f",       "femto")
  (Pico,         1e-12,        "p",          "p",         "p",       "pico")
  (Nano,         1e-9,         "n",          "n",         "n",       "nano")
  (Micro,        1e-6,         "u",          "\u03bc",    "\$\\mu\$","micro")
  (Milli,        1e-3,         "m",          "m",         "m",       "milli")
  (Centi,        1e-2,         "c",          "c",         "c",       "centi")
  (Deci,         1e-1,         "d",          "d",         "d",       "deci")
  (Deca,         1e1,          "da",         "da",        "da",      "deca")
  (Hecto,        1e2,          "h",          "h",         "h",       "hecto")
  (Kilo,         1e3,          "k",          "k",         "k",       "kilo")
  (Mega,         1e6,          "M",          "M",         "M",       "mega")
  (Giga,         1e9,          "G",          "G",         "G",       "giga")
  (Tera,         1e12,         "T",          "T",         "T",       "tera")
  (Peta,         1e15,         "P",          "P",         "P",       "peta")
  (Exa,          1e18,         "E",          "E",         "E",       "exa")
  (Zetta,        1e21,         "Z",          "Z",         "Z",       "zetta")
  (Yotta,        1e24,         "Y",          "Y",         "Y",       "yotta")
}
global to_reference
global show
global pshow
global lshow
global _unit_si_prefixes
for (t, f, s, ps, ls, fs) in prefix_table
    @eval to_reference(::Type{$t}) = $f
    @eval show(io::IO, ::Type{$t}) = print(io, $s)
    @eval pshow(io, ::Type{$t}) = print(io, $ps)
    @eval lshow(io, ::Type{$t}) = print(io, $ls)
    @eval fshow(io, ::Type{$t}) = print(io, $fs)
end
function return_prefix(i::Int)
    if i <= length(prefix_table)
        return prefix_table[i][1]
    elseif i == length(prefix_table)+1
        return SINone
    else
        error("Something is wrong")
    end
end
_unit_si_prefixes = ntuple(length(prefix_table)+1, i->return_prefix(i))
end  # let
to_reference(::Type{SINone}) = 1
show(io::IO, ::Type{SINone}) = nothing
pshow(io::IO, ::Type{SINone}) = nothing
lshow(io::IO, ::Type{SINone}) = nothing
fshow(io::IO, ::Type{SINone}) = nothing

# Units
abstract UnitBase
immutable Unit{TP<:SIPrefix, TU<:UnitBase} end
Unit{TP<:SIPrefix, TU<:UnitBase}(tp::Type{TP}, tu::Type{TU}) = Unit{tp, tu}
Unit{TU<:UnitBase}(tu::Type{TU}) = Unit{SINone, tu}
function show{TP<:SIPrefix, TU<:UnitBase}(io::IO, tu::Unit{TP, TU})
    print(io, TP)
    print(io, TU)
end

# Values with units
immutable Quantity{TP<:SIPrefix, TU<:UnitBase, Tdata}
    value::Tdata
end
Quantity{TP<:SIPrefix, TU<:UnitBase, Tdata}(tp::Type{TP}, tu::Type{TU}, val::Tdata) = Quantity{tp, tu, Tdata}(val)
Quantity{TU<:UnitBase, Tdata}(tu::Type{TU}, val::Tdata) = Quantity{SINone, tu, Tdata}(val)
prefix{TP<:SIPrefix, TU<:UnitBase, Tdata}(q::Quantity{TP, TU, Tdata}) = TP
base{TP<:SIPrefix, TU<:UnitBase, Tdata}(q::Quantity{TP, TU, Tdata}) = TU

function show{TP<:SIPrefix, TU<:UnitBase}(io::IO, q::Quantity{TP, TU})
    print(io, q.value, " ")
    show(io, TP)
    show(io, TU)
end
function pshow{TP<:SIPrefix, TU<:UnitBase}(io::IO, q::Quantity{TP, TU})
    print(io, q.value, " ")
    pshow(io, TP)
    pshow(io, TU)
end
function lshow{TP<:SIPrefix, TU<:UnitBase}(io::IO, q::Quantity{TP, TU})
    print(io, q.value, " ")
    lshow(io, TP)
    lshow(io, TU)
end
function fshow{TP<:SIPrefix, TU<:UnitBase}(io::IO, q::Quantity{TP, TU})
    print(io, q.value, " ")
    fshow(io, TP)
    fshow(io, TU)
end

# Functions and dictionaries for parsing
_unit_string_dict = (String=>Tuple)[]

function _unit_gen_func_multiplicative(table)
    for (t, r, to_r, s, ps, ls, fs) in table
        @eval reference(::Type{$t}) = $r
        @eval to_reference(::Type{$t}) = x->x*$to_r
        @eval from_reference(::Type{$t}) = x->x/$to_r
        @eval show(io::IO, ::Type{$t}) = print(io, $s)
        @eval pshow(io::IO, ::Type{$t}) = print(io, $ps)
        @eval lshow(io::IO, ::Type{$t}) = print(io, $ls)
        @eval fshow(io::IO, ::Type{$t}) = print(io, $fs)
    end
end

function _unit_gen_func(table)
    for (t, r, to_func, from_func, s, ps, ls, fs) in table
        @eval reference(::Type{$t}) = $r
        @eval to_reference(::Type{$t}) = $to_func
        @eval from_reference(::Type{$t}) = $from_func
        @eval show(io::IO, ::Type{$t}) = print(io, $s)
        @eval pshow(io::IO, ::Type{$t}) = print(io, $ps)
        @eval lshow(io::IO, ::Type{$t}) = print(io, $ls)
        @eval fshow(io::IO, ::Type{$t}) = print(io, $fs)
    end
end


function _unit_gen_dict_with_prefix(table)
    for (u, rest) in table
        ustr = string(u)
        upstr = pstring(u)
        for p in _unit_si_prefixes
            pstr = string(p)
            key = pstr*ustr
#            println(key, ": ", p, ", ", u) 
            _unit_string_dict[key] = (p, u)
            # Add "pretty" variants, too
            ppstr = pstring(p)
            _unit_string_dict[pstr*upstr] = (p, u)
            _unit_string_dict[ppstr*ustr] = (p, u)
            _unit_string_dict[ppstr*upstr] = (p, u)
        end
    end
end

function _unit_gen_dict(table)
    for (u, rest) in table
        key = string(u)
#        println(key, ": ", u) 
        _unit_string_dict[key] = (SINone, u)
        upstr = pstring(u)
        if key != upstr
            _unit_string_dict[upstr] = (SINone, u)
        end
    end
end

# Unknown unit
immutable Unknown <: UnitBase end

# Length units
immutable Meter <: UnitBase end
immutable Angstrom <: UnitBase end
immutable Inch <: UnitBase end
immutable Foot <: UnitBase end
immutable Yard <: UnitBase end
immutable Mile <: UnitBase end
immutable LightYear <: UnitBase end
immutable Parsec <: UnitBase end
immutable AstronomicalUnit <: UnitBase end
let
  # Unit     RefUnit    ToRef            show      pshow     lshow   fshow
const utable = {
  (Meter,    Meter,    1,                "m",      "m",      "m",    "meter")
  (Angstrom, Meter,    1e-10,            "A",      "\u212b", "\$\\AA\$","angstrom")
  (Inch,     Meter,    25.4/1000,        "in",     "in",     "in",   "inch")
  (Foot,     Meter,    12*25.4/1000,     "ft",     "ft",     "ft",   "foot")
  (Yard,     Meter,    36*25.4/1000,     "yd",     "yd",     "yd",   "yard")
  (Mile,     Meter,    5280*12*25.4/1000,"mi",     "mi",     "mi",   "mile")
  (LightYear,Meter,    9.4605284e15,     "ly",     "ly",     "ly",   "lightyear")
  (Parsec,   Meter,    3.08568025e16,    "pc",     "pc",     "pc",   "parsec")
  (AstronomicalUnit, Meter, 149_597_870_700, "AU", "AU",     "AU",   "astronomical unit")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix({utable[1]})  # parse prefixes only for Meter
_unit_gen_dict(utable[2:end])
end

# Time units
immutable Second <: UnitBase end
immutable Minute <: UnitBase end
immutable Hour <: UnitBase end
immutable Day <: UnitBase end
immutable Week <: UnitBase end
immutable YearJulian <: UnitBase end
immutable PlanckTime <: UnitBase end
let
  # Unit       RefUnit     ToRef            show      pshow     lshow  fshow
const utable = {
  (Second,     Second,      1,             "s",      "s",      "s",    "second")
  (Minute,     Second,      60,            "min",    "min",    "min",  "minute")
  (Hour,       Second,      3600,          "hr",     "hr",     "hr",   "hour")
  (Day,        Second,      86400,         "d",      "d",      "d",    "day")
  (YearJulian, Second,      365.25*86400,  "yr",     "yr",     "yr",   "year")
  (PlanckTime, Second,      5.3910632e-44, "tP",     "tP",     "\$t_P\$","Planck time")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix({utable[1]})   # prefixes are only common for seconds
_unit_gen_dict(utable[2:end])
end

# Rate units
immutable Hertz <: UnitBase end
let
  # Unit       RefUnit     ToRef        show      pshow     lshow   fshow
const utable = {
  (Hertz,      Hertz,      1,           "Hz",     "Hz",     "Hz",   "Hertz")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix(utable)
end

# Mass units
# (note English units like pounds are technically weight, not mass)
immutable Gram <: UnitBase end
immutable AtomicMassUnit <: UnitBase end
immutable Dalton <: UnitBase end
immutable PlanckMass <: UnitBase end
let
  # Unit       RefUnit     ToRef           show      pshow     lshow  fshow
const utable = {
  (Gram,       Gram,        1,             "g",      "g",      "g",   "gram")
  (AtomicMassUnit, Gram,    1.66053892173e-24, "amu","amu",    "amu", "atomic mass unit")
  (Dalton,     Gram,        1.66053892173e-24, "Da", "Da",     "Da",  "Dalton")
  (PlanckMass, Gram,        2.1765113e-5,  "mP",     "mP",     "\$m_P\$","Planck mass")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix({utable[1]})
_unit_gen_dict(utable[2:end])
end

# Electric current units
immutable Ampere <: UnitBase end
let
  # Unit       RefUnit     ToRef        show      pshow     lshow   fshow
const utable = {
  (Ampere,     Ampere,     1,           "A",      "A",      "A",   "ampere")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix(utable)
end


# Temperature units
# The conversions for these are not just a product
immutable Kelvin <: UnitBase end
immutable Celsius <: UnitBase end
immutable Fahrenheit <: UnitBase end
let
  # Unit       RefUnit  ToRef              FromRef     show    pshow  lshow  fshow
const utable = {
  (Kelvin,     Kelvin,  x->x,              x->x,       "K",    "K",   "K",   "Kelvin")
  (Celsius,    Kelvin,  x->x+273.15,       x->x-273.15,"C",    "C",   "C",   "Celsius")
  (Fahrenheit, Kelvin,  x->(x+459.67)*5/9, x->x*9/5-459.67,"F","F",   "F",   "Fahrenheit")
}
_unit_gen_func(utable)
_unit_gen_dict_with_prefix({utable[1]})   # prefixes are only common for Kelvin
_unit_gen_dict(utable[2:end])
end

# Luminosity units
immutable Candela <: UnitBase end
let
  # Unit       RefUnit     ToRef        show      pshow     lshow   fshow
const utable = {
  (Candela,    Candela,    1,           "cd",     "cd",     "cd",   "candela")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix(utable)
end


# Amount units
immutable Mole <: UnitBase end
immutable Entities <: UnitBase end
let
  # Unit       RefUnit     ToRef        show      pshow     lshow   fshow
const utable = {
  (Mole,       Mole,       1,           "mol",    "mol",    "mol",  "mole")
  (Entities,   Mole,       1/6.0221417930e23, "", "",       "",     "entities")
}
_unit_gen_func_multiplicative(utable)
_unit_gen_dict_with_prefix({utable[1]})
end


# Parsing string to extract Quantity
function parse_quantity(s::String, strict::Bool)
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
            return Quantity(SINone, Unknown, val)
        end
    end
    (prefix, unit) = _unit_string_dict[ustr]
    return Quantity(prefix, unit, val)
end
parse_quantity(s::String) = parse_quantity(s, true)


# Conversion between units
function convert{Uin<:UnitBase, Uout<:UnitBase, Pin<:SIPrefix, Pout<:SIPrefix, T}(::Type{Unit{Pout, Uout}}, q::Quantity{Pin, Uin, T})
    if reference(Uin) != reference(Uout)
        error("Not convertable")
    end
    return Quantity(Pout, Uout, from_reference(Uout)(to_reference(Uin)(q.value*to_reference(Pin))) / to_reference(Pout))
end

end
