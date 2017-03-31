[](The first two slides are intentionally blank for the intro)

***

[](The first two slides are intentionally blank for the intro)

***

## pyyaml == eval?

***

### solution? `safe_load`

```pycon
>>> yaml.safe_load("!!python/object/apply:os.system\nargs: ['echo hi']")
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
...
yaml.constructor.ConstructorError: could not determine a constructor for the tag 'tag:yaml.org,2002:python/object/apply:os.system'
  in "<unicode string>", line 1, column 1:
    !!python/object/apply:os.system
    ^
```

***

## but wait! there's more!

***

### `yaml.safe_load` is pure python

* Essentially `yaml.load(..., Loader=SafeLoader)`
* For cpython this is _slow_ by default


***

### fast _and_ safe

```python
try:
    from yaml.cyaml import CSafeLoader as Loader
except ImportError:
    from yaml import SafeLoader as Loader


yaml.load(..., Loader=Loader)
```
