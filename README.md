# Zettelkasten

**Abandoned version** When development started again, I decided that the app
architecture was bad, so I started from fresh
[here](https://github.com/jladan/zkserver).

This is a service to help track and maintain a zettelkasten-style filesystem.


## Design

The goal is to provide an api that is accessible from your favourite text editor
and the command line.

Each file is a card (kasten) identified by its filename. The zettel server tracks
hyperlinks between the cards (outgoing and ingoing). All files are tracked
(text, images, videos, pdfs, etc.).

Through the api, clients can retrieve a list of files (for auto-completing
links), links and backlinks in a card, and broken links (files that don't
exist).

A necessary feature is updating links in the files if they're ever moved. This
means that a `zettel mv` command is necessary, just like `git mv`.

## Features / TODO

- [/] Link parsing, all types of links work in all files
    - [/] markdown 
        - [X] inline `[alias](card)`
        - [/] references
    - [X] wikilinks `[[card|alias]]`
    - [ ] latex `\input{card}`
- [ ] File management
    - [X] track files
    - [ ] watch for changes
    - [ ] update links
    - [ ] move files
- [ ] Interfaces
    - [ ] TCP socket api
    - [ ] command line interface
    - [ ] other apis




