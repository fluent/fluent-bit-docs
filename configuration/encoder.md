# Encoding input to UTF-8

Some input plugins converting input to UTF-8 from a specified encoding.  The current set of supported encodings are:

  'iso-8859-1', 'iso-8859-2',  'iso-8859-3',  'iso-8859-4',
  'iso-8859-5', 'iso-8859-6',  'iso-8859-7',  'iso-8859-8',
  'iso-8859-9', 'iso-8859-10', 'iso-8859-11', 'iso-8859-13',
  'iso-8859-14', 'iso-8859-15', 'iso-8859-16'

and

  'windows-1250', 'windows-1251', 'windows-1252',
  'windows-1253', 'windows-1254', 'windows-1255',
  'windows-1256', 'windows-1257', 'windows-1258',

The plugins supporting UTF-8 encoding currently include [head](../input/head.md), [tail](../input/tail.md) and [syslog](../input/syslog.md) via the 'Encoder' parameter.
