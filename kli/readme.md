# klingon translator

## description

translates english text into klingon and then converts it to klingon pIqaD glyphs. it's a fun tool for star trek fans.

## features

- translates english words to klingon
- converts klingon text to pIqaD glyphs
- implements basic object-verb-subject (ovs) word order for simple sentences
- handles basic pluralization for some klingon words

## setup and requirements

1. **font installation**: 
   - to properly display klingon pIqaD glyphs, you need a font that supports these characters.
   - download and install a pIqaD font such as "quiske" or "klingon piqaD HaSta" from [klingon language institute](https://www.kli.org/learn-klingon/klingon-fonts/).
   - https://github.com/dadap/pIqaD-fonts (the one i use)
   - install the font on your system:
     - for linux: copy the font file to `~/.local/share/fonts/` and run `fc-cache -f -v`
     - for macos: double-click the font file and click "install font"
     - for windows: right-click the font file and select "install"

## usage

1. make the script executable:
   ```
   chmod +x klingon.sh
   ```

2. run the script:
   ```
   ./klingon.sh
   ```

3. enter english text when prompted. the script will output the klingon translation in pIqaD glyphs.

4. type 'exit' or press enter without any input to quit the program.

## example

```
Enter text (or type 'exit' to quit): hello friend
```
output will be in klingon pIqaD glyphs.

## troubleshooting

- if you see boxes or question marks instead of klingon glyphs, ensure you've installed a pIqaD font and configured your terminal to use it, though the script should auto find the font if you have it installed.
- if the script doesn't run, make sure it has executable permissions and you're using a bash shell.

## limitations

- the translation is word-by-word and may not capture complex grammatical structures.
- the dictionary is limited to the words defined in the script.
- the ovs word order implementation is basic and may not work for all sentence structures.

## contributing

feel free to contribute by adding more words to the dictionary or improving the translation logic. pull requests are welcome!

## acknowledgments

- this script uses unicode characters for klingon pIqaD glyphs.
- inspired by the klingon language created for star trek.
- https://hol.kag.org/
- https://github.com/dadap (the klingon glyphs)

qapla'! (success!)
