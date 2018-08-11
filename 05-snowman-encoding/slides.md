[comment]: # (The first two slides are intentionally blank for the intro)

***

[comment]: # (The first two slides are intentionally blank for the intro)

***

## the snowman encoding
### UTF-☃

***

```rawhtml
<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr"># Ennnnnnnnnnnnnnncoding: UTF^-_-^-_-^8 also works :)</p>&mdash; Armin Ronacher (@mitsuhiko) <a href="https://twitter.com/mitsuhiko/status/1020398504689250304?ref_src=twsrc%5Etfw">July 20, 2018</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
```

```comment
@dabeaz https://twitter.com/dabeaz/status/1020397965456953344
@mitsukiko https://twitter.com/mitsuhiko/status/1020398504689250304
```

```comment
# Ennnnnnnnnnnnnnncoding: utf-8
jalapeño = 'spicy'
```

```comment
# Ennnnnnnnnnnnnnncoding: UTF^-_-^-_-^8 also works :)
jalapeño = 'spicy'
```

```comment
when demonstrating:
- show it failing in python2, explain that python3 allows unicode variables
- change the encoding to "fake" and show that it fails
- also show that utf-8 is the default encoding
```

***

### PEP 263

- "Defining Python Source Code Encodings"
- Search for "encoding cookie" in first two lines
- Decode the file contents using that encoding

***

### what was happening

```pycon
>>> from tokenize import cookie_re
>>> print(cookie_re.pattern)
^[ \t\f]*#.*?coding[:=][ \t]*([-\w.]+)
>>> cookie_re.search('# Ennnncoding: utf-8').group(1)
'utf-8'
>>> cookie_re.search('# Ennnncoding: UTF^-_-^-_-^8').group(1)
'UTF'
```

***

## ok the actual wat

_all examples use python 3.x_

_for python 2 add a `u` prefix to the string_

***

### `.encode()` working

converts the string to `byte`s

```pycon
>>> '☃'.encode('UTF-8')
b'\xe2\x98\x83'
```

***

### `.encode()` failing

when an invalid codec is passed, a `LookupError` is produced

```pycon
>>> '☃'.encode('UTF-garbage')
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
LookupError: unknown encoding: UTF-garbage
```

... _usually_

***

### 🤔🤨🤔🤨🤔

```pycon
>>> '☃'.encode('UTF-^-_-^-_-^8')
b'\xe2\x98\x83'

>>> '☃'.encode('UTF-☃')
b'\xe2\x98\x83'
```

***

### explanation

```pycon
>>> encodings.normalize_encoding('UTF-^-_-^-_-^8'.lower())
'utf_8'

>>> encodings.normalize_encoding('UTF-☃'.lower())
'utf'
>>> encodings.aliases.aliases['utf']
'utf_8'
```

```comment
encodings go through a multi-phase normalization:
1. `normalizestring`: lower case and `s/ /-/g'
https://github.com/python/cpython/blob/v3.7.0/Python/codecs.c#L56
2. `encodings.normalize_encoding`
https://github.com/python/cpython/blob/v3.7.0/Lib/encodings/__init__.py#L43
3. alias normalization
https://github.com/python/cpython/blob/v3.7.0/Lib/encodings/__init__.py#L86-L87
```
