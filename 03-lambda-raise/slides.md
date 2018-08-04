[comment]: # (The first two slides are intentionally blank for the intro)

***

[comment]: # (The first two slides are intentionally blank for the intro)

***

```rawhtml
<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr"><a href="https://twitter.com/codewithanthony">@codewithanthony</a> please explain the insane golf answer in a youtube <a href="https://t.co/ZvX194zUpk">https://t.co/ZvX194zUpk</a></p>&mdash; Eldon Schoop (@zinosys) <a href="https://twitter.com/zinosys/status/873227565925711872">June 9, 2017</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>
```

```comment
https://stackoverflow.com/q/8294618/812183
@zinosys https://twitter.com/zinosys/status/873227565925711872
```

***

## generator solution

```python
y = lambda: (_ for _ in ()).throw(Exception('foobar'))
```

- `(_ for _ in ())` is a generator

```pycon
>>> y()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "<stdin>", line 1, in <lambda>
  File "<stdin>", line 1, in <genexpr>
Exception: foobar
```

***

## generators

- generators allow you to implement coroutines
- can think of them as asynchronously executed code
- three operations
    - `.next()` - run up to and return the `yield`ed value
    - `.send(val)` - substitute `val` for the previous `yield`,
      `return self.next()`
    - `.throw(exc[,typ[,tb]])` - raise an exception from the current `yield`

***

## code object solution

```pycon
>>> type(lambda:0)(type((lambda:0).func_code)(
...   1,1,1,67,'|\0\0\202\1\0',(),(),('x',),'','',1,''),{}
... )(Exception())
Traceback (most recent call last):
  File "<stdin>", line 3, in <module>
  File "", line 1, in

Exception
```

***

```python
y = type(lambda:0)(type((lambda:0).func_code)(
  1,1,1,67,'|\0\0\202\1\0',(),(),('x',),'','',1,''),{}
)
```

```pycon
>>> y(OSError('ohai'))
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "", line 1, in

OSError: ohai
```

***

```python
type(lambda: 0)
```
- Retrieve the `type` that represents a function
- Same as `types.FunctionType` or `types.LambdaType`

```python
# from python3.6 types.py
def _f(): pass
FunctionType = type(_f)
LambdaType = type(lambda: None)         # Same as FunctionType
```

***

## what is `types.FunctionType`?

- `python -m pydoc types.FunctionType`

```
types.FunctionType = class function(object)
 |  function(code, globals[, name[, argdefs[, closure]]])
```

***

```python
type((lambda: 0).func_code)
```

- Retrieve the type that represents a function's `code` object
- Same as `types.CodeType`

```python
# from python3.6 types.py
CodeType = type(_f.__code__)
```

***

## what is `types.CodeType`?

- `python -m pydoc types.CodeType`

```
types.CodeType = class code(object)
 |  code(argcount, nlocals, stacksize, flags, codestring, constants, names,
 |        varnames, filename, name, firstlineno, lnotab[, freevars[, cellvars]])
```

***

```python
y = LambdaType(CodeType(
  1,1,1,67,'|\0\0\202\1\0',(),(),('x',),'','',1,''),{}
)
```

***

## arguments to the function

- The `inspect` module allows us to do some reflection

```pycon
>>> inspect.getargspec(y)
ArgSpec(args=['x'], varargs=None, keywords=None, defaults=None)
```

- So our lambda is a function which takes one positional argument named `x`

***

## `dis`

- `dis` - Disassembler of Python byte code into mnemonics.
- often useful to figure out wtf is going on
- python implements a "stack" virtual machine
    - source code is compiled into opcodes
    - each opcode pushes / pops / performs some side-effect

***

```pycon
>>> dis.dis(y)
  1           0 LOAD_FAST                0 (x)
              3 RAISE_VARARGS            1
```

- `LOAD_FAST` loads a positional variable (in this case position `0`) in
  locals (which is the named parameter `x`)
- `FAST` here means it doesn't need to a full `locals()` / `globals()` /
  `builtins` lookup (it *knows* it is a local)
- `RAISE_VARARGS` with `1`
    - pop `1` argument from the stack (the exception)
    - `raise` it

***

```pycon
>>> def f(x): raise x
...
>>> dis.dis(f)
  1           0 LOAD_FAST                0 (x)
              3 RAISE_VARARGS            1
              6 LOAD_CONST               0 (None)
              9 RETURN_VALUE
```

- looks about the same!
- includes the implicit `return None`

***

## python 3 equivalent

```python
type(lambda: 0)(type((lambda: 0).__code__)(
    1,0,1,1,67,b'|\0\202\1\0',(),(),('x',),'','',1,b''),{}
)(Exception())
```

```pycon
>>> type(lambda: 0)(type((lambda: 0).__code__)(
...     1,0,1,1,67,b'|\0\202\1\0',(),(),('x',),'','',1,b''),{}
... )(Exception())
Traceback (most recent call last):
  File "<stdin>", line 3, in <module>
  File "", line 1, in
Exception
```

***

## argumentless solution

```python
y = types.LambdaType(
    types.CodeType(
        0, 0, 0, 1, 67, b't\0\x83\0\202\1', (), ('Exception',), (),
        '', '<lambda>', 1, b'',
    ),
    globals(),
)
```

```pycon
>>> dis.dis(y)
  1           0 LOAD_GLOBAL              0 (Exception)
              2 CALL_FUNCTION            0
              4 RAISE_VARARGS            1
>>> y()
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "", line 1, in <lambda>
Exception
```
