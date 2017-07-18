local function getenv(k, p)
  if string63(k) then
    local __i = edge(environment)
    while __i >= 0 do
      if has63(environment[__i + 1], k) then
        local __b = environment[__i + 1][k]
        local __e25
        if p then
          __e25 = has(__b, p)
        else
          __e25 = __b
        end
        return __e25
      else
        __i = __i - 1
      end
    end
  end
end
local function macro_function(k)
  return getenv(k, "macro")
end
local function macro63(k)
  return is63(macro_function(k))
end
local function special63(k)
  return is63(getenv(k, "special"))
end
local function special_form63(form)
  return not atom63(form) and special63(hd(form))
end
local function statement63(k)
  return special63(k) and getenv(k, "stmt")
end
local function symbol_expansion(k)
  return getenv(k, "symbol")
end
local function symbol63(k)
  return is63(symbol_expansion(k))
end
local function variable63(k)
  return is63(getenv(k, "variable"))
end
function bound63(x)
  return macro63(x) or special63(x) or symbol63(x) or variable63(x)
end
function quoted(form)
  if string63(form) then
    return escape(form)
  else
    if atom63(form) then
      return form
    else
      return join({"list"}, map(quoted, form))
    end
  end
end
local function literal(s)
  if string_literal63(s) then
    return s
  else
    return quoted(s)
  end
end
local function stash42(args)
  if keys63(args) then
    local __l = {"%object", "\"_stash\"", true}
    local ____o = args
    local __k = nil
    for __k in next, ____o do
      local __v = ____o[__k]
      if not number63(__k) then
        add(__l, literal(__k))
        add(__l, __v)
      end
    end
    return join(args, {__l})
  else
    return args
  end
end
local function bias(k)
  if number63(k) then
    k = k - 1
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
      k = k + 1
    end
    return k
  else
    return k
  end
end
function bind(lh, rh)
  if atom63(lh) then
    return {lh, rh}
  else
    local __id = unique("id")
    local __bs = {__id, rh}
    local ____o1 = lh
    local __k1 = nil
    for __k1 in next, ____o1 do
      local __v1 = ____o1[__k1]
      local __e26
      if __k1 == "rest" then
        __e26 = {"cut", __id, _35(lh)}
      else
        __e26 = {"has", __id, {"quote", bias(__k1)}}
      end
      local __x5 = __e26
      if is63(__k1) then
        local __e27
        if __v1 == true then
          __e27 = __k1
        else
          __e27 = __v1
        end
        local __k2 = __e27
        __bs = join(__bs, bind(__k2, __x5))
      end
    end
    return __bs
  end
end
setenv("arguments%", {_stash = true, macro = function (_from)
  local ____x16 = object({"target"})
  ____x16.js = {{"idx", {"idx", {"idx", "Array", "prototype"}, "slice"}, "call"}, "arguments", _from}
  ____x16.py = {"|list|", "|_rest|"}
  ____x16.lua = {"list", "|...|"}
  return ____x16
end})
function bind42(args, body)
  local __args1 = {}
  local function rest()
    __args1.rest = true
    return {"unstash", {"arguments%", _35(__args1)}}
  end
  if atom63(args) then
    return {__args1, join({"let", {args, rest()}}, body)}
  else
    local __bs1 = {}
    local __r19 = unique("r")
    local ____o2 = args
    local __k3 = nil
    for __k3 in next, ____o2 do
      local __v2 = ____o2[__k3]
      if number63(__k3) then
        if atom63(__v2) then
          add(__args1, __v2)
        else
          local __x28 = unique("x")
          add(__args1, __x28)
          __bs1 = join(__bs1, {__v2, __x28})
        end
      end
    end
    if keys63(args) then
      __bs1 = join(__bs1, {__r19, rest()})
      local __n3 = _35(__args1)
      local __i4 = 0
      while __i4 < __n3 do
        local __v3 = __args1[__i4 + 1]
        __bs1 = join(__bs1, {__v3, {"destash!", __v3, __r19}})
        __i4 = __i4 + 1
      end
      __bs1 = join(__bs1, {keys(args), __r19})
    end
    return {__args1, join({"let", __bs1}, body)}
  end
end
local function quoting63(depth)
  return number63(depth)
end
local function quasiquoting63(depth)
  return quoting63(depth) and depth > 0
end
local function can_unquote63(depth)
  return quoting63(depth) and depth == 1
end
local function quasisplice63(x, depth)
  return can_unquote63(depth) and not atom63(x) and hd(x) == "unquote-splicing"
end
local function expand_local(__x36)
  local ____id1 = __x36
  local __x37 = has(____id1, 1)
  local __name = has(____id1, 2)
  local __value = has(____id1, 3)
  setenv(__name, {_stash = true, variable = true})
  return {"%local", __name, macroexpand(__value)}
end
local function expand_function(__x39)
  local ____id2 = __x39
  local __x40 = has(____id2, 1)
  local __args = has(____id2, 2)
  local __body = cut(____id2, 2)
  add(environment, {})
  local ____o3 = __args
  local ____i5 = nil
  for ____i5 in next, ____o3 do
    local ____x41 = ____o3[____i5]
    setenv(____x41, {_stash = true, variable = true})
  end
  local ____x42 = join({"%function", __args}, macroexpand(__body))
  drop(environment)
  return ____x42
end
local function expand_definition(__x44)
  local ____id3 = __x44
  local __x45 = has(____id3, 1)
  local __name1 = has(____id3, 2)
  local __args11 = has(____id3, 3)
  local __body1 = cut(____id3, 3)
  add(environment, {})
  local ____o4 = __args11
  local ____i6 = nil
  for ____i6 in next, ____o4 do
    local ____x46 = ____o4[____i6]
    setenv(____x46, {_stash = true, variable = true})
  end
  local ____x47 = join({__x45, __name1, __args11}, macroexpand(__body1))
  drop(environment)
  return ____x47
end
local function expand_macro(form)
  return macroexpand(expand1(form))
end
function expand1(__x49)
  local ____id4 = __x49
  local __name2 = has(____id4, 1)
  local __body2 = cut(____id4, 1)
  return apply(macro_function(__name2), __body2)
end
function macroexpand(form)
  if symbol63(form) then
    return macroexpand(symbol_expansion(form))
  else
    if atom63(form) then
      return form
    else
      local __x50 = hd(form)
      if __x50 == "%local" then
        return expand_local(form)
      else
        if __x50 == "%function" then
          return expand_function(form)
        else
          if __x50 == "%global-function" then
            return expand_definition(form)
          else
            if __x50 == "%local-function" then
              return expand_definition(form)
            else
              if macro63(__x50) then
                return expand_macro(form)
              else
                return map(macroexpand, form)
              end
            end
          end
        end
      end
    end
  end
end
local function quasiquote_list(form, depth)
  local __xs = {{"list"}}
  local ____o5 = form
  local __k4 = nil
  for __k4 in next, ____o5 do
    local __v4 = ____o5[__k4]
    if not number63(__k4) then
      local __e28
      if quasisplice63(__v4, depth) then
        __e28 = quasiexpand(__v4[2])
      else
        __e28 = quasiexpand(__v4, depth)
      end
      local __v5 = __e28
      last(__xs)[__k4] = __v5
    end
  end
  local ____x53 = form
  local ____i8 = 0
  while ____i8 < _35(____x53) do
    local __x54 = ____x53[____i8 + 1]
    if quasisplice63(__x54, depth) then
      local __x55 = quasiexpand(__x54[2])
      add(__xs, __x55)
      add(__xs, {"list"})
    else
      add(last(__xs), quasiexpand(__x54, depth))
    end
    ____i8 = ____i8 + 1
  end
  local __pruned = keep(function (x)
    return _35(x) > 1 or not( hd(x) == "list") or keys63(x)
  end, __xs)
  if one63(__pruned) then
    return hd(__pruned)
  else
    return join({"join"}, __pruned)
  end
end
function quasiexpand(form, depth)
  if quasiquoting63(depth) then
    if atom63(form) then
      return {"quote", form}
    else
      if can_unquote63(depth) and hd(form) == "unquote" then
        return quasiexpand(form[2])
      else
        if hd(form) == "unquote" or hd(form) == "unquote-splicing" then
          return quasiquote_list(form, depth - 1)
        else
          if hd(form) == "quasiquote" then
            return quasiquote_list(form, depth + 1)
          else
            return quasiquote_list(form, depth)
          end
        end
      end
    end
  else
    if atom63(form) then
      return form
    else
      if hd(form) == "quote" then
        return form
      else
        if hd(form) == "quasiquote" then
          return quasiexpand(form[2], 1)
        else
          return map(function (x)
            return quasiexpand(x, depth)
          end, form)
        end
      end
    end
  end
end
function expand_if(__x59)
  local ____id5 = __x59
  local __a = has(____id5, 1)
  local __b1 = has(____id5, 2)
  local __c = cut(____id5, 2)
  if is63(__b1) then
    return {join({"%if", __a, __b1}, expand_if(__c))}
  else
    if is63(__a) then
      return {__a}
    end
  end
end
setenv("indent-level", {_stash = true, toplevel = true, value = 0})
setenv("indent-level", {_stash = true, symbol = {"get-value", {"quote", "indent-level"}}})
function indentation()
  local __s = ""
  local __i9 = 0
  while __i9 < has(setenv("indent-level", {_stash = true, toplevel = true}), "value") do
    __s = __s .. "  "
    __i9 = __i9 + 1
  end
  return __s
end
local reserved = {["="] = true, ["=="] = true, ["+"] = true, ["-"] = true, ["%"] = true, ["*"] = true, ["/"] = true, ["<"] = true, [">"] = true, ["<="] = true, [">="] = true, ["break"] = true, ["case"] = true, ["catch"] = true, ["class"] = true, ["const"] = true, ["continue"] = true, ["debugger"] = true, ["default"] = true, ["delete"] = true, ["do"] = true, ["else"] = true, ["eval"] = true, ["finally"] = true, ["for"] = true, ["function"] = true, ["if"] = true, ["import"] = true, ["in"] = true, ["instanceof"] = true, ["let"] = true, ["new"] = true, ["return"] = true, ["switch"] = true, ["throw"] = true, ["try"] = true, ["typeof"] = true, ["var"] = true, ["void"] = true, ["with"] = true, ["and"] = true, ["end"] = true, ["load"] = true, ["repeat"] = true, ["while"] = true, ["false"] = true, ["local"] = true, ["nil"] = true, ["then"] = true, ["not"] = true, ["true"] = true, ["elseif"] = true, ["or"] = true, ["until"] = true, ["from"] = true, ["str"] = true, ["print"] = true}
function reserved63(x)
  return has63(reserved, x)
end
local function valid_code63(n)
  return number_code63(n) or n > 64 and n < 91 or n > 96 and n < 123 or n == 95
end
local function id(id)
  local __e29
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    __e29 = "L_"
  else
    __e29 = "_"
  end
  local __x65 = __e29
  local __e30
  if number_code63(code(id, 0)) then
    __e30 = __x65
  else
    __e30 = ""
  end
  local __id11 = __e30
  local __i10 = 0
  while __i10 < _35(id) do
    local __c1 = char(id, __i10)
    local __n7 = code(__c1)
    local __e31
    if __c1 == "-" and not( id == "-") then
      local __e34
      if __i10 == 0 then
        __e34 = __x65
      else
        __e34 = "_"
      end
      __e31 = __e34
    else
      local __e32
      if valid_code63(__n7) then
        __e32 = __c1
      else
        local __e33
        if __i10 == 0 then
          __e33 = __x65 .. __n7
        else
          __e33 = __n7
        end
        __e32 = __e33
      end
      __e31 = __e32
    end
    local __c11 = __e31
    __id11 = __id11 .. __c11
    __i10 = __i10 + 1
  end
  if reserved63(__id11) then
    return __x65 .. __id11
  else
    return __id11
  end
end
function valid_id63(x)
  return some63(x) and x == id(x)
end
local __names = {}
function unique(x)
  local __x66 = id(x)
  if has63(__names, __x66) then
    local __i11 = __names[__x66]
    __names[__x66] = __names[__x66] + 1
    return unique(__x66 .. __i11)
  else
    __names[__x66] = 1
    return "__" .. __x66
  end
end
function key(k)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    return k
  else
    local __i12 = inner(k)
    if valid_id63(__i12) then
      return __i12
    else
      if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
        return k
      else
        return "[" .. k .. "]"
      end
    end
  end
end
function mapo(f, t)
  local __o6 = {}
  local ____o7 = t
  local __k5 = nil
  for __k5 in next, ____o7 do
    local __v6 = ____o7[__k5]
    local __x67 = f(__v6)
    if is63(__x67) then
      add(__o6, literal(__k5))
      add(__o6, __x67)
    end
  end
  return __o6
end
local ____x69 = object({})
local ____x70 = object({})
____x70.js = "!"
____x70.lua = "not"
____x70.py = "not"
____x69["not"] = ____x70
local ____x71 = object({})
____x71["*"] = true
____x71["/"] = true
____x71["%"] = true
local ____x72 = object({})
local ____x73 = object({})
____x73.js = "+"
____x73.lua = ".."
____x72.cat = ____x73
local ____x74 = object({})
____x74["+"] = true
____x74["-"] = true
local ____x75 = object({})
____x75["<"] = true
____x75[">"] = true
____x75["<="] = true
____x75[">="] = true
local ____x76 = object({})
local ____x77 = object({})
____x77.js = "==="
____x77.lua = "=="
____x77.py = "=="
____x76["="] = ____x77
local ____x78 = object({})
local ____x79 = object({})
____x79.js = "&&"
____x79.lua = "and"
____x79.py = "and"
____x78["and"] = ____x79
local ____x80 = object({})
local ____x81 = object({})
____x81.js = "||"
____x81.lua = "or"
____x81.py = "or"
____x80["or"] = ____x81
local infix = {____x69, ____x71, ____x72, ____x74, ____x75, ____x76, ____x78, ____x80}
local function unary63(form)
  return two63(form) and in63(hd(form), {"not", "-"})
end
local function index(k)
  if number63(k) then
    return k - 1
  end
end
local function precedence(form)
  if not( atom63(form) or unary63(form)) then
    local ____o8 = infix
    local __k6 = nil
    for __k6 in next, ____o8 do
      local __v7 = ____o8[__k6]
      if has63(__v7, hd(form)) then
        return index(__k6)
      end
    end
  end
  return 0
end
local function getop(op)
  return find(function (level)
    local __x83 = has(level, op)
    if __x83 == true then
      return op
    else
      if is63(__x83) then
        return has(__x83, has(setenv("target", {_stash = true, toplevel = true}), "value"))
      end
    end
  end, infix)
end
local function infix63(x)
  return is63(getop(x))
end
function infix_operator63(x)
  return obj63(x) and infix63(hd(x))
end
function compile_args(args, default63)
  local __s1 = "("
  local __c2 = ""
  local ____x84 = args
  local ____i15 = 0
  while ____i15 < _35(____x84) do
    local __x85 = ____x84[____i15 + 1]
    __s1 = __s1 .. __c2 .. compile(__x85)
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" and default63 and not id_literal63(__x85) then
      __s1 = __s1 .. "=None"
    end
    __c2 = ", "
    ____i15 = ____i15 + 1
  end
  return __s1 .. ")"
end
local function escape_newlines(s)
  local __s11 = ""
  local __i16 = 0
  while __i16 < _35(s) do
    local __c3 = char(s, __i16)
    local __e35
    if __c3 == "\n" then
      __e35 = "\\n"
    else
      local __e36
      if __c3 == "\r" then
        __e36 = "\\r"
      else
        __e36 = __c3
      end
      __e35 = __e36
    end
    __s11 = __s11 .. __e35
    __i16 = __i16 + 1
  end
  return __s11
end
local function compile_nil()
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    return "None"
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
      return "nil"
    else
      return "undefined"
    end
  end
end
local function compile_boolean(x)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    if x then
      return "True"
    else
      return "False"
    end
  else
    if x then
      return "true"
    else
      return "false"
    end
  end
end
local function compile_atom(x)
  if x == "nil" then
    return compile_nil()
  else
    if id_literal63(x) then
      return inner(x)
    else
      if string_literal63(x) then
        return escape_newlines(x)
      else
        if string63(x) then
          return id(x)
        else
          if boolean63(x) then
            return compile_boolean(x)
          else
            if nan63(x) then
              return "nan"
            else
              if x == inf then
                return "inf"
              else
                if x == _inf then
                  return "-inf"
                else
                  if number63(x) then
                    return x .. ""
                  else
                    error("Cannot compile atom: " .. _str(x))
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
local function terminator(stmt63)
  if not stmt63 then
    return ""
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
      return ";\n"
    else
      return "\n"
    end
  end
end
local function compile_special(form, stmt63)
  local ____id6 = form
  local __x86 = has(____id6, 1)
  local __args2 = cut(____id6, 1)
  local ____id7 = getenv(__x86)
  local __special = has(____id7, "special")
  local __stmt = has(____id7, "stmt")
  local __self_tr63 = has(____id7, "tr")
  local __tr = terminator(stmt63 and not __self_tr63)
  return apply(__special, __args2) .. __tr
end
local function parenthesize_call63(x)
  return not atom63(x) and hd(x) == "%function" or precedence(x) > 0
end
local function compile_call(form)
  local __f = hd(form)
  local __f1 = compile(__f)
  local __args3 = compile_args(stash42(tl(form)))
  if parenthesize_call63(__f) then
    return "(" .. __f1 .. ")" .. __args3
  else
    return __f1 .. __args3
  end
end
local function op_delims(parent, child, ...)
  local ____r59 = unstash({...})
  local __parent = destash33(parent, ____r59)
  local __child = destash33(child, ____r59)
  local ____id8 = ____r59
  local __right = has(____id8, "right")
  local __e37
  if __right then
    __e37 = _6261
  else
    __e37 = _62
  end
  if __e37(precedence(__child), precedence(__parent)) then
    return {"(", ")"}
  else
    return {"", ""}
  end
end
local function compile_infix(form)
  local ____id9 = form
  local __op = has(____id9, 1)
  local ____id10 = cut(____id9, 1)
  local __a1 = has(____id10, 1)
  local __b2 = has(____id10, 2)
  local ____id111 = op_delims(form, __a1)
  local __ao = has(____id111, 1)
  local __ac = has(____id111, 2)
  local ____id12 = op_delims(form, __b2, {_stash = true, right = true})
  local __bo = has(____id12, 1)
  local __bc = has(____id12, 2)
  local __a2 = compile(__a1)
  local __b3 = compile(__b2)
  local __op1 = getop(__op)
  if unary63(form) then
    return __op1 .. __ao .. " " .. __a2 .. __ac
  else
    return __ao .. __a2 .. __ac .. " " .. __op1 .. " " .. __bo .. __b3 .. __bc
  end
end
function compile_body(body)
  setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") + 1
  local ____x90 = compile(body, {_stash = true, stmt = true})
  setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") - 1
  local __s2 = ____x90
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" and none63(__s2) then
    setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") + 1
    local ____x91 = indentation() .. "pass\n"
    setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") - 1
    return ____x91
  else
    return __s2
  end
end
function compile_function(args, body, ...)
  local ____r62 = unstash({...})
  local __args4 = destash33(args, ____r62)
  local __body3 = destash33(body, ____r62)
  local ____id13 = ____r62
  local __name3 = has(____id13, "name")
  local __prefix = has(____id13, "prefix")
  local __e38
  if __name3 then
    __e38 = compile(__name3)
  else
    __e38 = ""
  end
  local __id14 = __e38
  local __e39
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" and has63(__args4, "rest") then
    __e39 = join(__args4, {"|...|"})
  else
    local __e40
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" and has63(__args4, "rest") then
      __e40 = join(__args4, {"|*_rest|", "|**_params|"})
    else
      __e40 = __args4
    end
    __e39 = __e40
  end
  local __args12 = __e39
  local __args5 = compile_args(__args12, true)
  local __body4 = compile_body(__body3)
  local __ind = indentation()
  local __e41
  if __prefix then
    __e41 = __prefix .. " "
  else
    __e41 = ""
  end
  local __p = __e41
  local __e42
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    __e42 = ""
  else
    __e42 = "end"
  end
  local __tr1 = __e42
  if __name3 then
    __tr1 = __tr1 .. "\n"
  end
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    return "function " .. __id14 .. __args5 .. " {\n" .. __body4 .. __ind .. "}" .. __tr1
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      return "def " .. __id14 .. __args5 .. ":\n" .. __body4
    else
      return __p .. "function " .. __id14 .. __args5 .. "\n" .. __body4 .. __ind .. __tr1
    end
  end
end
local function can_return63(form)
  return is63(form) and (atom63(form) or not( hd(form) == "return") and not statement63(hd(form)))
end
function compile(form, ...)
  local ____r64 = unstash({...})
  local __form = destash33(form, ____r64)
  local ____id15 = ____r64
  local __stmt1 = has(____id15, "stmt")
  if nil63(__form) then
    return ""
  else
    if special_form63(__form) then
      return compile_special(__form, __stmt1)
    else
      local __tr2 = terminator(__stmt1)
      local __e43
      if __stmt1 then
        __e43 = indentation()
      else
        __e43 = ""
      end
      local __ind1 = __e43
      local __e44
      if atom63(__form) then
        __e44 = compile_atom(__form)
      else
        local __e45
        if infix63(hd(__form)) then
          __e45 = compile_infix(__form)
        else
          __e45 = compile_call(__form)
        end
        __e44 = __e45
      end
      local __form1 = __e44
      return __ind1 .. __form1 .. __tr2
    end
  end
end
local function lower_statement(form, tail63)
  local __hoist = {}
  local __e = lower(form, __hoist, true, tail63)
  local __e46
  if some63(__hoist) and is63(__e) then
    __e46 = join({"do"}, __hoist, {__e})
  else
    local __e47
    if is63(__e) then
      __e47 = __e
    else
      local __e48
      if _35(__hoist) > 1 then
        __e48 = join({"do"}, __hoist)
      else
        __e48 = hd(__hoist)
      end
      __e47 = __e48
    end
    __e46 = __e47
  end
  return either(__e46, {"do"})
end
local function lower_body(body, tail63)
  return lower_statement(join({"do"}, body), tail63)
end
local function literal63(form)
  return atom63(form) or hd(form) == "%array" or hd(form) == "%object"
end
local function standalone63(form)
  return not atom63(form) and not infix63(hd(form)) and not literal63(form) and not( "get" == hd(form)) or id_literal63(form)
end
local function lower_do(args, hoist, stmt63, tail63)
  local ____x101 = almost(args)
  local ____i17 = 0
  while ____i17 < _35(____x101) do
    local __x102 = ____x101[____i17 + 1]
    local ____y = lower(__x102, hoist, stmt63)
    if yes(____y) then
      local __e1 = ____y
      if standalone63(__e1) then
        add(hoist, __e1)
      end
    end
    ____i17 = ____i17 + 1
  end
  local __e2 = lower(last(args), hoist, stmt63, tail63)
  if tail63 and can_return63(__e2) then
    return {"return", __e2}
  else
    return __e2
  end
end
local function lower_set(args, hoist, stmt63, tail63)
  local ____id16 = args
  local __lh = has(____id16, 1)
  local __rh = has(____id16, 2)
  add(hoist, {"%set", lower(__lh, hoist), lower(__rh, hoist)})
  if not( stmt63 and not tail63) then
    return __lh
  end
end
local function lower_if(args, hoist, stmt63, tail63)
  local ____id17 = args
  local __cond = has(____id17, 1)
  local ___then = has(____id17, 2)
  local ___else = has(____id17, 3)
  if stmt63 then
    local __e50
    if is63(___else) then
      __e50 = {lower_body({___else}, tail63)}
    end
    return add(hoist, join({"%if", lower(__cond, hoist), lower_body({___then}, tail63)}, __e50))
  else
    local __e3 = unique("e")
    add(hoist, {"%local", __e3})
    local __e49
    if is63(___else) then
      __e49 = {lower({"%set", __e3, ___else})}
    end
    add(hoist, join({"%if", lower(__cond, hoist), lower({"%set", __e3, ___then})}, __e49))
    return __e3
  end
end
local function lower_short(x, args, hoist)
  local ____id18 = args
  local __a3 = has(____id18, 1)
  local __b4 = has(____id18, 2)
  local __hoist1 = {}
  local __b11 = lower(__b4, __hoist1)
  if some63(__hoist1) then
    local __id19 = unique("id")
    local __e51
    if x == "and" then
      __e51 = {"%if", __id19, __b4, __id19}
    else
      __e51 = {"%if", __id19, __id19, __b4}
    end
    return lower({"do", {"%local", __id19, __a3}, __e51}, hoist)
  else
    return {x, lower(__a3, hoist), __b11}
  end
end
local function lower_try(args, hoist, tail63)
  return add(hoist, {"%try", lower_body(args, tail63)})
end
local function lower_while(args, hoist)
  local ____id20 = args
  local __c4 = has(____id20, 1)
  local __body5 = cut(____id20, 1)
  local __pre = {}
  local __c5 = lower(__c4, __pre)
  local __e52
  if none63(__pre) then
    __e52 = {"while", __c5, lower_body(__body5)}
  else
    __e52 = {"while", true, join({"do"}, __pre, {{"%if", {"not", __c5}, {"break"}}, lower_body(__body5)})}
  end
  return add(hoist, __e52)
end
local function lower_for(args, hoist)
  local ____id21 = args
  local __t = has(____id21, 1)
  local __k7 = has(____id21, 2)
  local __body6 = cut(____id21, 2)
  return add(hoist, {"%for", lower(__t, hoist), __k7, lower_body(__body6)})
end
local function lower_function(args, hoist)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    local __f11 = unique("f")
    return lower({"do", join({"%local-function", __f11}, args), __f11}, hoist)
  else
    local ____id22 = args
    local __a4 = has(____id22, 1)
    local __body7 = cut(____id22, 1)
    return {"%function", __a4, lower_body(__body7, true)}
  end
end
local function lower_definition(kind, args, hoist)
  local ____id23 = args
  local __name4 = has(____id23, 1)
  local __args6 = has(____id23, 2)
  local __body8 = cut(____id23, 2)
  return add(hoist, {kind, __name4, __args6, lower_body(__body8, true)})
end
local function lower_call(form, hoist)
  local __form2 = map(function (x)
    return lower(x, hoist)
  end, form)
  if some63(__form2) then
    return __form2
  end
end
local function pairwise63(form)
  return in63(hd(form), {"<", "<=", "=", ">=", ">"})
end
local function lower_pairwise(form)
  if pairwise63(form) then
    local __e4 = {}
    local ____id24 = form
    local __x133 = has(____id24, 1)
    local __args7 = cut(____id24, 1)
    reduce(function (a, b)
      add(__e4, {__x133, a, b})
      return a
    end, __args7)
    return join({"and"}, reverse(__e4))
  else
    return form
  end
end
local function lower_infix63(form)
  return infix63(hd(form)) and _35(form) > 3
end
local function lower_infix(form, hoist)
  local __form3 = lower_pairwise(form)
  local ____id25 = __form3
  local __x136 = has(____id25, 1)
  local __args8 = cut(____id25, 1)
  return lower(reduce(function (a, b)
    return {__x136, b, a}
  end, reverse(__args8)), hoist)
end
local function lower_special(form, hoist)
  local __e5 = lower_call(form, hoist)
  if __e5 then
    return add(hoist, __e5)
  end
end
function lower(form, hoist, stmt63, tail63)
  if atom63(form) then
    return form
  else
    if empty63(form) then
      return {"%array"}
    else
      if nil63(hoist) then
        return lower_statement(form)
      else
        if lower_infix63(form) then
          return lower_infix(form, hoist)
        else
          local ____id26 = form
          local __x139 = has(____id26, 1)
          local __args9 = cut(____id26, 1)
          if __x139 == "do" then
            return lower_do(__args9, hoist, stmt63, tail63)
          else
            if __x139 == "%set" then
              return lower_set(__args9, hoist, stmt63, tail63)
            else
              if __x139 == "%if" then
                return lower_if(__args9, hoist, stmt63, tail63)
              else
                if __x139 == "%try" then
                  return lower_try(__args9, hoist, tail63)
                else
                  if __x139 == "while" then
                    return lower_while(__args9, hoist)
                  else
                    if __x139 == "%for" then
                      return lower_for(__args9, hoist)
                    else
                      if __x139 == "%function" then
                        return lower_function(__args9, hoist)
                      else
                        if __x139 == "%local-function" or __x139 == "%global-function" then
                          return lower_definition(__x139, __args9, hoist)
                        else
                          if in63(__x139, {"and", "or"}) then
                            return lower_short(__x139, __args9, hoist)
                          else
                            if statement63(__x139) then
                              return lower_special(form, hoist)
                            else
                              return lower_call(form, hoist)
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
function expand(form)
  return lower(macroexpand(form))
end
local load1 = loadstring or load
local function run(code)
  local f,e = load1(code)
  if f then
    return f()
  else
    error(e .. " in " .. code)
  end
end
local function eval_result(globals)
  return lumen_result
end
function _eval(form, globals)
  local __previous = has(setenv("target", {_stash = true, toplevel = true}), "value")
  setenv("target", {_stash = true, toplevel = true}).value = "lua"
  local __code = compile(expand({"set", "lumen-result", form}))
  setenv("target", {_stash = true, toplevel = true}).value = __previous
  run(__code, globals)
  return eval_result(globals)
end
function immediate_call63(x)
  return obj63(x) and obj63(hd(x)) and hd(hd(x)) == "%function"
end
setenv("do", {_stash = true, special = function (...)
  local __forms1 = unstash({...})
  local __s4 = ""
  local ____x145 = __forms1
  local ____i19 = 0
  while ____i19 < _35(____x145) do
    local __x146 = ____x145[____i19 + 1]
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" and immediate_call63(__x146) and "\n" == char(__s4, edge(__s4)) then
      __s4 = clip(__s4, 0, edge(__s4)) .. ";\n"
    end
    __s4 = __s4 .. compile(__x146, {_stash = true, stmt = true})
    if not atom63(__x146) then
      if hd(__x146) == "return" or hd(__x146) == "break" then
        break
      end
    end
    ____i19 = ____i19 + 1
  end
  return __s4
end, stmt = true, tr = true})
setenv("%if", {_stash = true, special = function (cond, cons, alt)
  local __cond2 = compile(cond)
  local __cons1 = compile_body(cons)
  local __e53
  if alt then
    __e53 = compile_body(alt)
  end
  local __alt1 = __e53
  local __ind3 = indentation()
  local __s6 = ""
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    __s6 = __s6 .. __ind3 .. "if (" .. __cond2 .. ") {\n" .. __cons1 .. __ind3 .. "}"
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      __s6 = __s6 .. __ind3 .. "if " .. __cond2 .. ":\n" .. __cons1
    else
      __s6 = __s6 .. __ind3 .. "if " .. __cond2 .. " then\n" .. __cons1
    end
  end
  if __alt1 and has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    __s6 = __s6 .. " else {\n" .. __alt1 .. __ind3 .. "}"
  else
    if __alt1 and has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      __s6 = __s6 .. __ind3 .. "else:\n" .. __alt1
    else
      if __alt1 then
        __s6 = __s6 .. __ind3 .. "else\n" .. __alt1
      end
    end
  end
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
    return __s6 .. __ind3 .. "end\n"
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
      return __s6 .. "\n"
    else
      return __s6
    end
  end
end, stmt = true, tr = true})
setenv("while", {_stash = true, special = function (cond, form)
  local __cond4 = compile(cond)
  local __body10 = compile_body(form)
  local __ind5 = indentation()
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    return __ind5 .. "while (" .. __cond4 .. ") {\n" .. __body10 .. __ind5 .. "}\n"
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      return __ind5 .. "while " .. __cond4 .. ":\n" .. __body10
    else
      return __ind5 .. "while " .. __cond4 .. " do\n" .. __body10 .. __ind5 .. "end\n"
    end
  end
end, stmt = true, tr = true})
setenv("%for", {_stash = true, special = function (t, k, form)
  local __t2 = compile(t)
  local __ind7 = indentation()
  local __body12 = compile_body(form)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
    return __ind7 .. "for " .. k .. " in next, " .. __t2 .. " do\n" .. __body12 .. __ind7 .. "end\n"
  else
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      return __ind7 .. "for " .. k .. " in indices(" .. __t2 .. "):\n" .. __body12
    else
      return __ind7 .. "for (" .. k .. " in " .. __t2 .. ") {\n" .. __body12 .. __ind7 .. "}\n"
    end
  end
end, stmt = true, tr = true})
setenv("%try", {_stash = true, special = function (form)
  local __e9 = unique("e")
  local __ind9 = indentation()
  local __body14 = compile_body(form)
  local __e54
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    __e54 = {"do", {"import", "sys"}, {"return", {"%array", false, __e9, {{"idx", "sys", "exc_info"}}}}}
  else
    __e54 = {"return", {"%array", false, __e9}}
  end
  local __hf1 = __e54
  setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") + 1
  local ____x164 = compile(__hf1, {_stash = true, stmt = true})
  setenv("indent-level", {_stash = true, toplevel = true}).value = has(setenv("indent-level", {_stash = true, toplevel = true}), "value") - 1
  local __h1 = ____x164
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    return __ind9 .. "try {\n" .. __body14 .. __ind9 .. "}\n" .. __ind9 .. "catch (" .. __e9 .. ") {\n" .. __h1 .. __ind9 .. "}\n"
  else
    return __ind9 .. "try:\n" .. __body14 .. __ind9 .. "except Exception as " .. __e9 .. ":\n" .. __h1
  end
end, stmt = true, tr = true})
setenv("%delete", {_stash = true, special = function (place)
  local __e55
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    __e55 = "del "
  else
    __e55 = "delete "
  end
  return indentation() .. __e55 .. compile(place)
end, stmt = true})
setenv("break", {_stash = true, special = function ()
  return indentation() .. "break"
end, stmt = true})
setenv("%function", {_stash = true, special = function (args, body)
  return compile_function(args, body)
end})
setenv("%global-function", {_stash = true, special = function (name, args, body)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" or has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    local __x168 = compile_function(args, body, {_stash = true, name = name})
    return indentation() .. __x168
  else
    return compile({"%set", name, {"%function", args, body}}, {_stash = true, stmt = true})
  end
end, stmt = true, tr = true})
setenv("%local-function", {_stash = true, special = function (name, args, body)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" or has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    local __x174 = compile_function(args, body, {_stash = true, name = name, prefix = "local"})
    return indentation() .. __x174
  else
    return compile({"%local", name, {"%function", args, body}}, {_stash = true, stmt = true})
  end
end, stmt = true, tr = true})
setenv("return", {_stash = true, special = function (x)
  local __e56
  if nil63(x) then
    __e56 = "return"
  else
    __e56 = "return " .. compile(x)
  end
  local __x178 = __e56
  return indentation() .. __x178
end, stmt = true})
setenv("new", {_stash = true, special = function (x)
  return "new " .. compile(x)
end})
setenv("typeof", {_stash = true, special = function (x)
  return "typeof(" .. compile(x) .. ")"
end})
setenv("error", {_stash = true, special = function (x)
  local __e57
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    __e57 = "throw " .. compile({"new", {"Error", x}})
  else
    local __e58
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
      __e58 = "raise " .. compile({"Exception", x})
    else
      __e58 = "error(" .. compile(x) .. ")"
    end
    __e57 = __e58
  end
  local __e15 = __e57
  return indentation() .. __e15
end, stmt = true})
setenv("%local", {_stash = true, special = function (name, value)
  if nil63(value) and has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    value = "nil"
  end
  local __id28 = compile(name)
  local __value11 = compile(value)
  local __e59
  if is63(value) then
    __e59 = " = " .. __value11
  else
    __e59 = ""
  end
  local __rh2 = __e59
  local __e60
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "js" then
    __e60 = "var "
  else
    local __e61
    if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
      __e61 = "local "
    else
      __e61 = ""
    end
    __e60 = __e61
  end
  local __keyword1 = __e60
  local __ind11 = indentation()
  return __ind11 .. __keyword1 .. __id28 .. __rh2
end, stmt = true})
setenv("%set", {_stash = true, special = function (lh, rh)
  local __lh2 = compile(lh)
  local __e62
  if nil63(rh) then
    __e62 = "nil"
  else
    __e62 = rh
  end
  local __rh4 = compile(__e62)
  return indentation() .. __lh2 .. " = " .. __rh4
end, stmt = true})
setenv("get", {_stash = true, special = function (t, k)
  local __t12 = compile(t)
  local __k12 = compile(k)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" and char(__t12, 0) == "{" or infix_operator63(t) then
    __t12 = "(" .. __t12 .. ")"
  end
  if string_literal63(k) and valid_id63(inner(k)) and not( has(setenv("target", {_stash = true, toplevel = true}), "value") == "py") then
    return __t12 .. "." .. inner(k)
  else
    return __t12 .. "[" .. __k12 .. "]"
  end
end})
setenv("idx", {_stash = true, special = function (t, k)
  local __t14 = compile(t)
  local __k14 = compile(k)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" and char(__t14, 0) == "{" or infix_operator63(t) then
    __t14 = "(" .. __t14 .. ")"
  end
  return __t14 .. "." .. __k14
end})
setenv("%array", {_stash = true, special = function (...)
  local __forms3 = unstash({...})
  local __e63
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
    __e63 = "{"
  else
    __e63 = "["
  end
  local __open1 = __e63
  local __e64
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
    __e64 = "}"
  else
    __e64 = "]"
  end
  local __close1 = __e64
  local __s8 = ""
  local __c7 = ""
  local ____o10 = __forms3
  local __k10 = nil
  for __k10 in next, ____o10 do
    local __v9 = ____o10[__k10]
    if number63(__k10) then
      __s8 = __s8 .. __c7 .. compile(__v9)
      __c7 = ", "
    end
  end
  return __open1 .. __s8 .. __close1
end})
setenv("%object", {_stash = true, special = function (...)
  local __forms5 = unstash({...})
  local __s10 = "{"
  local __c9 = ""
  local __e65
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "lua" then
    __e65 = " = "
  else
    __e65 = ": "
  end
  local __sep1 = __e65
  local ____o12 = pair(__forms5)
  local __k141 = nil
  for __k141 in next, ____o12 do
    local __v12 = ____o12[__k141]
    if number63(__k141) then
      local ____id30 = __v12
      local __k15 = has(____id30, 1)
      local __v13 = has(____id30, 2)
      if not string63(__k15) then
        error("Illegal key: " .. _str(__k15))
      end
      __s10 = __s10 .. __c9 .. key(__k15) .. __sep1 .. compile(__v13)
      __c9 = ", "
    end
  end
  return __s10 .. "}"
end})
setenv("%literal", {_stash = true, special = function (...)
  local __args111 = unstash({...})
  return apply(cat, map(compile, __args111))
end})
setenv("global", {_stash = true, special = function (x)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    return indentation() .. "global " .. compile(x) .. "\n"
  else
    return ""
  end
end, stmt = true, tr = true})
setenv("import", {_stash = true, special = function (x)
  if has(setenv("target", {_stash = true, toplevel = true}), "value") == "py" then
    return indentation() .. "import " .. compile(x)
  else
    return indentation() .. compile({"%local", x, {"require", escape(x)}})
  end
end, stmt = true})
local __exports = exports or {}
__exports.run = run
__exports["eval"] = _eval
__exports._eval = _eval
__exports.expand = expand
__exports.compile = compile
return __exports
