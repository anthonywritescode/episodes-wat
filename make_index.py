from markdown_code_blocks import highlight


def main():
    contents = open('README.md').read()
    highlighted = highlight(contents)
    with open('index.htm', 'w') as index:
        index.write(f'<!doctype html><html><body>{highlighted}</body></html>')

if __name__ == '__main__':
    exit(main())
