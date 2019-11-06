# Encoding input to UTF-8

Some input plugins converting input to UTF-8 from a specified encoding.  The current set of supported encodings are:

  * [iso-8859-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1) Latin-1 Western European
  * [iso-8859-2](https://en.wikipedia.org/wiki/ISO/IEC_8859-2) Latin-2 East European
  * [iso-8859-3](https://en.wikipedia.org/wiki/ISO/IEC_8859-3) Latin-3 South European
  * [iso-8859-4](https://en.wikipedia.org/wiki/ISO/IEC_8859-4) Latin-4 North European
  * [iso-8859-5](https://en.wikipedia.org/wiki/ISO/IEC_8859-5) Part 5: Latin/Cyrillic
  * [iso-8859-6](https://en.wikipedia.org/wiki/ISO/IEC_8859-6) Part 6: Latin/Arabic
  * [iso-8859-7](https://en.wikipedia.org/wiki/ISO/IEC_8859-7) Part 7: Latin/Greek
  * [iso-8859-8](https://en.wikipedia.org/wiki/ISO/IEC_8859-8) Part 8: Latin/Hebrew
  * [iso-8859-9](https://en.wikipedia.org/wiki/ISO/IEC_8859-9) Latin-5 Turkish
  * [iso-8859-10](https://en.wikipedia.org/wiki/ISO/IEC_8859-10) Latin-6 Nordic
  * [iso-8859-11](https://en.wikipedia.org/wiki/ISO/IEC_8859-11) Part 11: Latin/Thai
  * [iso-8859-13](https://en.wikipedia.org/wiki/ISO/IEC_8859-13) Latin-7 Baltic Rim
  * [iso-8859-14](https://en.wikipedia.org/wiki/ISO/IEC_8859-14) Latin-8 Celtic
  * [iso-8859-15](https://en.wikipedia.org/wiki/ISO/IEC_8859-15) Latin-9 Western European 
  * [iso-8859-16](https://en.wikipedia.org/wiki/ISO/IEC_8859-16) Latin-10 South-Eastern European

  * [windows-1250](https://en.wikipedia.org/wiki/Windows-1250) Central European and Eastern European
  * [windows-1251](https://en.wikipedia.org/wiki/Windows-1251) Cyrillic
  * [windows-1252](https://en.wikipedia.org/wiki/Windows-1252) English
  * [windows-1253](https://en.wikipedia.org/wiki/Windows-1253) Greek
  * [windows-1254](https://en.wikipedia.org/wiki/Windows-1254) Turkish
  * [windows-1255](https://en.wikipedia.org/wiki/Windows-1255) Hebrew
  * [windows-1256](https://en.wikipedia.org/wiki/Windows-1256) Arabic
  * [windows-1257](https://en.wikipedia.org/wiki/Windows-1257) Baltic
  * [windows-1258](https://en.wikipedia.org/wiki/Windows-1258) Vietnamese

The plugins supporting UTF-8 encoding currently include [head](../input/head.md), [tail](../input/tail.md) and [syslog](../input/syslog.md) via the `Encoder` parameter.
