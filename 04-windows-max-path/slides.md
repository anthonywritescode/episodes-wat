[comment]: # (The first two slides are intentionally blank for the intro)

***

[comment]: # (The first two slides are intentionally blank for the intro)

***

## long paths on windows?
### `\\?\`

***

### `MAX_PATH` limitations

- 260 characters
- -3: drive letter, colon, backslash: "`C:\`"
- -1: terminating `NUL` character
- -12: directory must allow for an "8.3 filename"
- ~244 characters for a directory structure

```comment
https://msdn.microsoft.com/en-us/library/windows/desktop/aa365247(v=vs.85).aspx
```

***

### 8.3 filename

- aka short filename
- up to 8 characters for filename
- up to 3 characters for extension
- shortened by use of `~` + ordinal:
    - `LONGFI~1.TXT` for `longfilename.txt`

***

### enabling long paths

- via registry
    - `HKLM\SYSTEM\CurrentControlSet\Control\FileSystem` `LongPathsEnabled=1`
- group policy
    - `Computer Configuration` > `Administrative Templates` > `System` >
      `Filesystem` > `Enable NTFS long paths`
- may not apply to 32 bit programs

***

### extended length paths

- prefix with `\\?\`
- up to ~32,767 characters (may be subject to path expansion)
- do not go undergo usual path normalizations
    - cannot use forward slashes as separators
- `"\\?\C:\very\long\path\..."`

***

### real world problem

- `pre-commit` is a multi-language git hooks framework
- multi-language multi-platform hooks
    - including nodejs
- must be able to install deeply nested `node_modules`
- current `npm` requires 199 characters (!)
